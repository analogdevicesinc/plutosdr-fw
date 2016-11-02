#PATH=$PATH:/opt/Xilinx/SDK/2015.4/gnu/arm/lin/bin

NCORES = $(shell grep -c ^processor /proc/cpuinfo)
VIVADO_SETTINGS ?= /opt/Xilinx/Vivado/2015.4/settings64.sh
VSUBDIRS = hdl buildroot linux

VERSION=$(shell git describe --abbrev=4 --dirty --always --tags)

all: build-dir build/pluto.dfu build/pluto.frm build/boot.dfu

build-dir:
	mkdir -p build

%: build/%
	cp $< $@

### u-boot ###

u-boot-xlnx/u-boot:
u-boot-xlnx/tools/mkimage:
	make -C u-boot-xlnx ARCH=arm zynq_pluto_defconfig
	make -C u-boot-xlnx ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

.PHONY: u-boot-xlnx/u-boot

build/u-boot.elf: u-boot-xlnx/u-boot
	cp $< $@

### Linux ###

linux/arch/arm/boot/zImage:
	make -C linux ARCH=arm zynq_pluto_defconfig
	make -C linux -j $(NCORES) ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- zImage UIMAGE_LOADADDR=0x8000

.PHONY: linux/arch/arm/boot/zImage


build/zImage: linux/arch/arm/boot/zImage
	cp $< $@

### Device Tree ###

linux/arch/arm/boot/dts/%.dtb: linux/arch/arm/boot/dts/%.dts
	make -C linux ARCH=arm $(notdir $@)

build/%.dtb: linux/arch/arm/boot/dts/%.dtb
	cp $< $@

### Buildroot ###

buildroot/output/images/rootfs.cpio.gz:
	@echo plutosdr-fw $(VERSION)> $(CURDIR)/buildroot/board/pluto/VERSIONS
	@$(foreach dir,$(VSUBDIRS),echo $(dir) $(shell cd $(dir) && git describe --abbrev=4 --dirty --always --tags) >> $(CURDIR)/buildroot/board/pluto/VERSIONS;)
	make -C buildroot ARCH=arm zynq_pluto_defconfig
	make -C buildroot ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- BUSYBOX_CONFIG_FILE=$(CURDIR)/buildroot/board/pluto/busybox-1.25.0.config all

.PHONY: buildroot/output/images/rootfs.cpio.gz

build/rootfs.cpio.gz: buildroot/output/images/rootfs.cpio.gz
	cp $< $@

build/pluto.itb: u-boot-xlnx/tools/mkimage build/zImage build/rootfs.cpio.gz build/zynq-pluto-sdr.dtb  build/system_top.bit
	u-boot-xlnx/tools/mkimage -f scripts/pluto.its $@

build/system_top.hdf:
	wget -N --directory-prefix build http://10.50.1.20/jenkins_export/hdl/dev/sdrstk_sdrstk/latest/system_top.hdf

### TODO: Build system_top.hdf from src if dl fails - need 2016.2 for that ...

build/sdk/fsbl/Release/fsbl.elf: build/system_top.hdf
build/sdk/hw_0/system_top.bit : build/system_top.hdf
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

### DFU update firmware file ###

build/boot.dfu: build/boot.bin
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
	rm -f $(notdir $(wildcard build/*))
	rm -rf build/*

git-update-all:
	git submodule update --recursive --remote
	git submodule foreach git pull --ff-only

zip-all:  build/pluto.dfu build/pluto.frm build/boot.dfu
	zip -j build/plutosdr-fw-$(VERSION).zip $^

dfu-pluto: build/pluto.dfu
	dfu-util -D build/pluto.dfu -a 1
	sudo dfu-util -e

dfu-uboot: build/boot.dfu
	read -p "Erasing u-boot be careful - Press any key to continue... " -n1 -s && dfu-util -D boot.dfu -a 0
	sudo dfu-util -e
