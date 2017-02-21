#PATH=$PATH:/opt/Xilinx/SDK/2015.4/gnu/arm/lin/bin

CROSS_COMPILE ?= arm-xilinx-linux-gnueabi-

NCORES = $(shell grep -c ^processor /proc/cpuinfo)
VIVADO_SETTINGS ?= /opt/Xilinx/Vivado/2016.2/settings64.sh
VSUBDIRS = hdl buildroot linux

VERSION=$(shell git describe --abbrev=4 --dirty --always --tags)
UBOOT_VERSION=$(shell echo -n "PlutoSDR " && cd u-boot-xlnx && git describe --abbrev=0 --dirty --always --tags)

all: build/pluto.dfu build/pluto.frm build/boot.dfu build/uboot-env.dfu build/boot.frm

build:
	mkdir -p $@

%: build/%
	cp $< $@

### u-boot ###

u-boot-xlnx/u-boot u-boot-xlnx/tools/mkimage:
	make -C u-boot-xlnx ARCH=arm zynq_pluto_defconfig
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
	make -C linux ARCH=arm zynq_pluto_defconfig
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
	@echo device-fw $(VERSION)> $(CURDIR)/buildroot/board/pluto/VERSIONS
	@$(foreach dir,$(VSUBDIRS),echo $(dir) $(shell cd $(dir) && git describe --abbrev=4 --dirty --always --tags) >> $(CURDIR)/buildroot/board/pluto/VERSIONS;)
	make -C buildroot ARCH=arm zynq_pluto_defconfig
	make -C buildroot TOOLCHAIN_EXTERNAL_INSTALL_DIR= ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) BUSYBOX_CONFIG_FILE=$(CURDIR)/buildroot/board/pluto/busybox-1.25.0.config all

.PHONY: buildroot/output/images/rootfs.cpio.gz

build/rootfs.cpio.gz: buildroot/output/images/rootfs.cpio.gz | build
	cp $< $@

build/pluto.itb: u-boot-xlnx/tools/mkimage build/zImage build/rootfs.cpio.gz build/zynq-pluto-sdr.dtb build/zynq-pluto-sdr-revb.dtb build/system_top.bit
	u-boot-xlnx/tools/mkimage -f scripts/pluto.its $@

build/system_top.hdf:  | build
#	wget -T 3 -t 1 -N --directory-prefix build http://10.50.1.20/jenkins_export/hdl/dev/pluto/latest/system_top.hdf || bash -c "source $(VIVADO_SETTINGS) && make -C hdl projects/pluto && cp hdl/projects/pluto/pluto.sdk/system_top.hdf $@"
	bash -c "source $(VIVADO_SETTINGS) && make -C hdl projects/pluto && cp hdl/projects/pluto/pluto.sdk/system_top.hdf $@"

### TODO: Build system_top.hdf from src if dl fails - need 2016.2 for that ...

build/sdk/fsbl/Release/fsbl.elf build/sdk/hw_0/system_top.bit : build/system_top.hdf
	rm -Rf build/sdk
	bash -c "source $(VIVADO_SETTINGS) && xsdk -batch -source scripts/create_fsbl_project.tcl"

build/system_top.bit: build/sdk/hw_0/system_top.bit
	cp $< $@

build/boot.bin: build/sdk/fsbl/Release/fsbl.elf build/u-boot.elf
	@echo img:{[bootloader] $^ } > build/boot.bif
	bash -c "source $(VIVADO_SETTINGS) && bootgen -image build/boot.bif -w -o $@"

### MSD update firmware file ###

build/pluto.frm: build/pluto.itb
	md5sum $< | cut -d ' ' -f 1 > $@.md5
	cat $< $@.md5 > $@

build/boot.frm: build/boot.bin build/uboot-env.bin scripts/target_mtd_info.key
	cat $^ | tee $@ | md5sum | cut -d ' ' -f1 | tee -a $@

### DFU update firmware file ###

build/%.dfu: build/%.bin
	cp $< $<.tmp
	dfu-suffix -a $<.tmp -v 0x0456 -p 0xb673
	mv $<.tmp $@

build/pluto.dfu: build/pluto.itb
	cp $< $<.tmp
	dfu-suffix -a $<.tmp -v 0x0456 -p 0xb673
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

zip-all:  build/pluto.dfu build/pluto.frm build/boot.dfu build/uboot-env.dfu build/boot.frm
	zip -j build/plutosdr-fw-$(VERSION).zip $^

dfu-pluto: build/pluto.dfu
	dfu-util -D build/pluto.dfu -a firmware.dfu
	dfu-util -e

dfu-sf-uboot: build/boot.dfu build/uboot-env.dfu
	echo "Erasing u-boot be careful - Press Return to continue... " && read key  && \
		dfu-util -D build/boot.dfu -a boot.dfu && \
		dfu-util -D build/uboot-env.dfu -a uboot-env.dfu
	dfu-util -e

dfu-all: build/pluto.dfu build/boot.dfu build/uboot-env.dfu
	echo "Erasing u-boot be careful - Press Return to continue... " && read key && \
		dfu-util -D build/pluto.dfu -a firmware.dfu && \
		dfu-util -D build/boot.dfu -a boot.dfu  && \
		dfu-util -D build/uboot-env.dfu -a uboot-env.dfu
	dfu-util -e

dfu-ram: build/pluto.dfu
	sshpass -p analog ssh root@pluto '/usr/sbin/device_reboot ram;'
	sleep 5
	dfu-util -D build/pluto.dfu -a firmware.dfu
	dfu-util -e


git-update-all:
	git submodule update --recursive --remote

git-pull:
	git pull --recurse-submodules
