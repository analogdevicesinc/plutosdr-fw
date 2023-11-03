# plutosdr-fw
PlutoSDR Firmware for the [ADALM-PLUTO](https://wiki.analog.com/university/tools/pluto "PlutoSDR Wiki Page") Active Learning Module

Latest binary Release : [![GitHub Release](https://img.shields.io/github/release/analogdevicesinc/plutosdr-fw.svg)](https://github.com/analogdevicesinc/plutosdr-fw/releases/latest)  [![Github Releases](https://img.shields.io/github/downloads/analogdevicesinc/plutosdr-fw/total.svg)](https://github.com/analogdevicesinc/plutosdr-fw/releases/latest)

Firmware License : [![Many Licenses](https://img.shields.io/badge/license-LGPL2+-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md)  [![Many License](https://img.shields.io/badge/license-GPL2+-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md)  [![Many License](https://img.shields.io/badge/license-BSD-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md)  [![Many License](https://img.shields.io/badge/license-apache-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md) and many others.

[Instructions from the Wiki: Building the image](https://wiki.analog.com/university/tools/pluto/building_the_image)

* Build Instructions
```bash
 sudo apt-get install git build-essential fakeroot libncurses5-dev libssl-dev ccache
 sudo apt-get install dfu-util u-boot-tools device-tree-compiler libssl1.0-dev mtools
 sudo apt-get install bc python cpio zip unzip rsync file wget
 git clone --recursive https://github.com/analogdevicesinc/plutosdr-fw.git
 cd plutosdr-fw
 export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2021.2/settings64.sh
 make

```

Due to incompatibility between the AMD/Xilinx GCC toolchain supplied with Vivado/Vitis and Buildroot.
This project switched to Buildroot external Toolchain: Linaro GCC 7.3-2018.05 7.3.1

https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/arm-linux-gnueabihf/

This toolchain is used to build: Buildroot, Linux and u-boot


"error "timeout while establishing a connection with SDK""
    (procedure "getsdkchan" line 108)
    invoked from within
"getsdkchan"
    (procedure "createhw" line 26)
    invoked from within
"createhw {*}$args"
    (procedure "::sdk::create_hw_project" line 3)
    invoked from within
"sdk create_hw_project -name hw_0 -hwspec build/system_top.hdf"
    (file "scripts/create_fsbl_project.tcl" line 5)
```
you may be able to work around it by preventing eclipse from using GTK3 for the Standard Widget Toolkit (SWT). Prior to running make, also set the following environment variable: 
```bash
export SWT_GTK3=0
```
This problem seems to affect Ubuntu 16.04LTS only.

 * Updating your local repository 
 ```bash 
      git pull
      git submodule update --init --recursive
  ```
   
* Build Artifacts
 ```bash
      michael@HAL9000:~/devel/plutosdr-fw$ ls -AGhl build
      total 543M
      -rw-rw-r-- 1 michael   69 Mär  1 09:28 boot.bif
      -rw-rw-r-- 1 michael 443K Mär  1 09:28 boot.bin
      -rw-rw-r-- 1 michael 443K Mär  1 09:28 boot.dfu
      -rw-rw-r-- 1 michael 572K Mär  1 09:28 boot.frm
      -rw-rw-r-- 1 michael 475M Mär  1 09:28 legal-info-v0.36.tar.gz
      -rw-rw-r-- 1 michael 617K Mär  1 09:25 LICENSE.html
      -rw-rw-r-- 1 michael  11M Mär  1 09:27 pluto.dfu
      -rw-rw-r-- 1 michael  11M Mär  1 09:28 pluto.frm
      -rw-rw-r-- 1 michael   33 Mär  1 09:28 pluto.frm.md5
      -rw-rw-r-- 1 michael  11M Mär  1 09:27 pluto.itb
      -rw-rw-r-- 1 michael  20M Mär  1 09:28 plutosdr-fw-v0.36.zip
      -rw-rw-r-- 1 michael 578K Mär  1 09:28 plutosdr-jtag-bootstrap-v0.36.zip
      -rw-rw-r-- 1 michael 441K Mär  1 09:26 ps7_init.c
      -rw-rw-r-- 1 michael 442K Mär  1 09:26 ps7_init_gpl.c
      -rw-rw-r-- 1 michael 4,2K Mär  1 09:26 ps7_init_gpl.h
      -rw-rw-r-- 1 michael 3,6K Mär  1 09:26 ps7_init.h
      -rw-rw-r-- 1 michael 2,4M Mär  1 09:26 ps7_init.html
      -rw-rw-r-- 1 michael  31K Mär  1 09:26 ps7_init.tcl
      -rw-r--r-- 1 michael 5,3M Mär  1 09:25 rootfs.cpio.gz
      drwxrwxr-x 6 michael 4,0K Mär  1 09:26 sdk
      -rw-rw-r-- 1 michael 943K Mär  1 09:26 system_top.bit
      -rw-rw-r-- 1 michael 716K Mär  1 09:26 system_top.xsa
      -rwxrwxr-x 1 michael 761K Mär  1 09:28 u-boot.elf
      -rw-rw---- 1 michael 128K Mär  1 09:28 uboot-env.bin
      -rw-rw---- 1 michael 129K Mär  1 09:28 uboot-env.dfu
      -rw-rw-r-- 1 michael 7,0K Mär  1 09:28 uboot-env.txt
      -rwxrwxr-x 1 michael 4,1M Mär  1 09:24 zImage
      -rw-rw-r-- 1 michael  22K Mär  1 09:26 zynq-pluto-sdr.dtb
      -rw-rw-r-- 1 michael  22K Mär  1 09:26 zynq-pluto-sdr-revb.dtb
      -rw-rw-r-- 1 michael  23K Mär  1 09:26 zynq-pluto-sdr-revc.dtb

 ```
 
 * Main targets
 
     | File  | Comment |
     | ------------- | ------------- | 
     | pluto.frm | Main PlutoSDR firmware file used with the USB Mass Storage Device |
     | pluto.dfu | Main PlutoSDR firmware file used in DFU mode |
     | boot.frm  | First and Second Stage Bootloader (u-boot + fsbl + uEnv) used with the USB Mass Storage Device |
     | boot.dfu  | First and Second Stage Bootloader (u-boot + fsbl) used in DFU mode |
     | uboot-env.dfu  | u-boot default environment used in DFU mode |
     | plutosdr-fw-vX.XX.zip  | ZIP archive containg all of the files above |  
     | plutosdr-jtag-bootstrap-vX.XX.zip  | ZIP archive containg u-boot and Vivao TCL used for JATG bootstrapping |       
 
  * Other intermediate targets

     | File  | Comment |
     | ------------- | ------------- |
     | boot.bif | Boot Image Format file used to generate the Boot Image |
     | boot.bin | Final Boot Image |
     | pluto.frm.md5 | md5sum of the pluto.frm file |
     | pluto.itb | u-boot Flattened Image Tree |
     | rootfs.cpio.gz | The Root Filesystem archive |
     | sdk | Vivado/XSDK Build folder including  the FSBL |
     | system_top.bit | FPGA Bitstream (from HDF) |
     | system_top.hdf | FPGA Hardware Description  File exported by Vivado |
     | u-boot.elf | u-boot ELF Binary |
     | uboot-env.bin | u-boot default environment in binary format created form uboot-env.txt |
     | uboot-env.txt | u-boot default environment in human readable text format |
     | zImage | Compressed Linux Kernel Image |
     | zynq-pluto-sdr.dtb | Device Tree Blob for Rev.A |
     | zynq-pluto-sdr-revb.dtb | Device Tree Blob for Rev.B|     
     | zynq-pluto-sdr-revc.dtb | Device Tree Blob for Rev.C|
 

