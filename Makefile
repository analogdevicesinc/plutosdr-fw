#PATH=$PATH:/opt/Xilinx/SDK/2015.4/gnu/arm/lin/bin

VIVADO_VERSION ?= 2019.1
CROSS_COMPILE ?= arm-linux-gnueabihf-

HAVE_CROSS=$(shell which $(CROSS_COMPILE)gcc | wc -l)
ifeq (0, ${HAVE_CROSS})
$(warning *** can not find $(CROSS_COMPILE)gcc in PATH)
$(error please update PATH)
endif

#gives us path/bin/arm-linux-gnueabihf-gcc
TOOLCHAIN = $(shell which $(CROSS_COMPILE)gcc)
#gives us path/bin
TOOLCHAIN2 = $(shell dirname $(TOOLCHAIN))
#gives us path we need
TOOLCHAIN_PATH = $(shell dirname $(TOOLCHAIN2))


NCORES = $(shell grep -c ^processor /proc/cpuinfo)
VIVADO_SETTINGS ?= /opt/Xilinx/Vivado/$(VIVADO_VERSION)/settings64.sh
VSUBDIRS = hdl buildroot linux u-boot-xlnx

VERSION=$(shell git describe --abbrev=4 --dirty --always --tags)
LATEST_TAG=$(shell git describe --abbrev=0 --tags)
UBOOT_VERSION=$(shell echo -n "PlutoSDR " && cd u-boot-xlnx && git describe --abbrev=0 --dirty --always --tags)
HAVE_VIVADO= $(shell bash -c "source $(VIVADO_SETTINGS) > /dev/null 2>&1 && vivado -version > /dev/null 2>&1 && echo 1 || echo 0")

ifeq (1, ${HAVE_VIVADO})
	VIVADO_INSTALL= $(shell bash -c "source $(VIVADO_SETTINGS) > /dev/null 2>&1 && vivado -version | head -1 | awk '{print $2}'")
	ifeq (, $(findstring $(VIVADO_VERSION), $(VIVADO_INSTALL)))
$(warning *** This repository has only been tested with $(VIVADO_VERSION),)
$(warning *** and you have $(VIVADO_INSTALL))
$(warning *** Please 1] set the path to Vivado $(VIVADO_VERSION) OR)
$(warning ***        2] remove $(VIVADO_INSTALL) from the path OR)
$(error "      3] export VIVADO_VERSION=v20xx.x")
	endif
endif

TARGET ?= pluto
SUPPORTED_TARGETS:=pluto sidekiqz2

# Include target specific constants
include scripts/$(TARGET).mk

ifeq (, $(shell which dfu-suffix))
$(warning "No dfu-utils in PATH consider doing: sudo apt-get install dfu-util")
TARGETS = build/$(TARGET).frm
ifeq (1, ${HAVE_VIVADO})
TARGETS += build/boot.frm jtag-bootstrap
endif
else
TARGETS = build/$(TARGET).dfu build/uboot-env.dfu build/$(TARGET).frm
ifeq (1, ${HAVE_VIVADO})
TARGETS += build/boot.dfu build/boot.frm jtag-bootstrap
endif
endif

ifeq ($(findstring $(TARGET),$(SUPPORTED_TARGETS)),)
all:
	@echo "Invalid `TARGET variable ; valid values are: pluto, sidekiqz2" &&
	exit 1
else
all: clean-build $(TARGETS) zip-all legal-info
endif

.NOTPARALLEL: all

TARGET_DTS_FILES:=$(foreach dts,$(TARGET_DTS_FILES),build/$(dts))

build:
	mkdir -p $@

%: build/%
	cp $< $@

### u-boot ###

u-boot-xlnx/u-boot u-boot-xlnx/tools/mkimage:
	make -C u-boot-xlnx ARCH=arm zynq_$(TARGET)_defconfig
	make -C u-boot-xlnx ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) UBOOTVERSION="$(UBOOT_VERSION)"

.PHONY: u-boot-xlnx/u-boot

build/u-boot.elf: u-boot-xlnx/u-boot | build
	cp $< $@

build/uboot-env.txt: u-boot-xlnx/u-boot | build
	CROSS_COMPILE=$(CROSS_COMPILE) scripts/get_default_envs.sh > $@

build/uboot-env.bin: build/uboot-env.txt
	u-boot-xlnx/tools/mkenvimage -s 0x20000 -o $@ $<

### Linux ###

linux/arch/arm/boot/zImage:
	make -C linux ARCH=arm zynq_$(TARGET)_defconfig
	make -C linux -j $(NCORES) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) zImage UIMAGE_LOADADDR=0x8000

.PHONY: linux/arch/arm/boot/zImage


build/zImage: linux/arch/arm/boot/zImage  | build
	cp $< $@

### Device Tree ###

linux/arch/arm/boot/dts/%.dtb: linux/arch/arm/boot/dts/%.dts  linux/arch/arm/boot/dts/zynq-pluto-sdr.dtsi
	make -C linux -j $(NCORES) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) $(notdir $@)

build/%.dtb: linux/arch/arm/boot/dts/%.dtb | build
	cp $< $@

### Buildroot ###

buildroot/output/images/rootfs.cpio.gz:
	@echo device-fw $(VERSION)> $(CURDIR)/buildroot/board/$(TARGET)/VERSIONS
	@$(foreach dir,$(VSUBDIRS),echo $(dir) $(shell cd $(dir) && git describe --abbrev=4 --dirty --always --tags) >> $(CURDIR)/buildroot/board/$(TARGET)/VERSIONS;)
	make -C buildroot ARCH=arm zynq_$(TARGET)_defconfig
	make -C buildroot legal-info
	scripts/legal_info_html.sh "$(COMPLETE_NAME)" "$(CURDIR)/buildroot/board/$(TARGET)/VERSIONS"
	cp build/LICENSE.html buildroot/board/$(TARGET)/msd/LICENSE.html
	make -C buildroot TOOLCHAIN_EXTERNAL_INSTALL_DIR=$(TOOLCHAIN_PATH) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) BUSYBOX_CONFIG_FILE=$(CURDIR)/buildroot/board/$(TARGET)/busybox-1.25.0.config all

.PHONY: buildroot/output/images/rootfs.cpio.gz

build/rootfs.cpio.gz: buildroot/output/images/rootfs.cpio.gz | build
	cp $< $@

build/$(TARGET).itb: u-boot-xlnx/tools/mkimage build/zImage build/rootfs.cpio.gz $(TARGET_DTS_FILES) build/system_top.bit
	u-boot-xlnx/tools/mkimage -f scripts/$(TARGET).its $@

build/system_top.hdf:  | build
ifeq (1, ${HAVE_VIVADO})
	bash -c "source $(VIVADO_SETTINGS) && make -C hdl/projects/$(TARGET) && cp hdl/projects/$(TARGET)/$(TARGET).sdk/system_top.hdf $@"
	unzip -l $@ | grep -q ps7_init || cp hdl/projects/$(TARGET)/$(TARGET).srcs/sources_1/bd/system/ip/system_sys_ps7_0/ps7_init* build/
else ifneq ($(HDF_FILE),)
	cp $(HDF_FILE) $@
else ifneq ($(HDF_URL),)
	wget -T 3 -t 1 -N --directory-prefix build $(HDF_URL)
endif

### TODO: Build system_top.hdf from src if dl fails - need 2016.2 for that ...

build/sdk/fsbl/Release/fsbl.elf build/sdk/hw_0/system_top.bit : build/system_top.hdf
	rm -Rf build/sdk
ifeq (1, ${HAVE_VIVADO})
	bash -c "source $(VIVADO_SETTINGS) && xsdk -batch -source scripts/create_fsbl_project.tcl"
else
	mkdir -p build/sdk/hw_0
	unzip -o build/system_top.hdf system_top.bit -d build/sdk/hw_0
endif

build/system_top.bit: build/sdk/hw_0/system_top.bit
	cp $< $@

build/boot.bin: build/sdk/fsbl/Release/fsbl.elf build/u-boot.elf
	@echo img:{[bootloader] $^ } > build/boot.bif
	bash -c "source $(VIVADO_SETTINGS) && bootgen -image build/boot.bif -w -o $@"

### MSD update firmware file ###

build/$(TARGET).frm: build/$(TARGET).itb
	md5sum $< | cut -d ' ' -f 1 > $@.md5
	cat $< $@.md5 > $@

build/boot.frm: build/boot.bin build/uboot-env.bin scripts/target_mtd_info.key
	cat $^ | tee $@ | md5sum | cut -d ' ' -f1 | tee -a $@

### DFU update firmware file ###

build/%.dfu: build/%.bin
	cp $< $<.tmp
	dfu-suffix -a $<.tmp -v $(DEVICE_VID) -p $(DEVICE_PID)
	mv $<.tmp $@

build/$(TARGET).dfu: build/$(TARGET).itb
	cp $< $<.tmp
	dfu-suffix -a $<.tmp -v $(DEVICE_VID) -p $(DEVICE_PID)
	mv $<.tmp $@

clean-build:
	rm -f $(notdir $(wildcard build/*))
	rm -rf build/*

clean:
	make -C u-boot-xlnx clean
	make -C linux clean
	make -C buildroot clean
	make -C hdl clean
	rm -f $(notdir $(wildcard build/*))
	rm -rf build/*

zip-all: $(TARGETS)
	zip -j build/$(ZIP_ARCHIVE_PREFIX)-fw-$(VERSION).zip $^

dfu-$(TARGET): build/$(TARGET).dfu
	dfu-util -D build/$(TARGET).dfu -a firmware.dfu
	dfu-util -e

dfu-sf-uboot: build/boot.dfu build/uboot-env.dfu
	echo "Erasing u-boot be careful - Press Return to continue... " && read key  && \
		dfu-util -D build/boot.dfu -a boot.dfu && \
		dfu-util -D build/uboot-env.dfu -a uboot-env.dfu
	dfu-util -e

dfu-all: build/$(TARGET).dfu build/boot.dfu build/uboot-env.dfu
	echo "Erasing u-boot be careful - Press Return to continue... " && read key && \
		dfu-util -D build/$(TARGET).dfu -a firmware.dfu && \
		dfu-util -D build/boot.dfu -a boot.dfu  && \
		dfu-util -D build/uboot-env.dfu -a uboot-env.dfu
	dfu-util -e

dfu-ram: build/$(TARGET).dfu
	sshpass -p analog ssh root@$(TARGET) '/usr/sbin/device_reboot ram;'
	sleep 7
	dfu-util -D build/$(TARGET).dfu -a firmware.dfu
	dfu-util -e

jtag-bootstrap: build/u-boot.elf build/sdk/hw_0/ps7_init.tcl build/sdk/hw_0/system_top.bit scripts/run.tcl
	$(CROSS_COMPILE)strip build/u-boot.elf
	zip -j build/$(ZIP_ARCHIVE_PREFIX)-$@-$(VERSION).zip $^

sysroot: buildroot/output/images/rootfs.cpio.gz
	tar czfh build/sysroot-$(VERSION).tar.gz --hard-dereference --exclude=usr/share/man -C buildroot/output staging

legal-info: buildroot/output/images/rootfs.cpio.gz
	tar czvf build/legal-info-$(VERSION).tar.gz -C buildroot/output legal-info

git-update-all:
	git submodule update --recursive --remote

git-pull:
	git pull --recurse-submodules
