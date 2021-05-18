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
 export CROSS_COMPILE=arm-linux-gnueabihf-
 export PATH=$PATH:/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin
 export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2019.1/settings64.sh
 make

```

The project may build also using Vivado 2018.2 2017.4, 2017.2, 2016.4 or 2016.2.
However 2019.1 is the current tested FPGA systhesis toolchain.
In the v0.30 release we swithched to the arm-linux-gnueabihf-gcc hard-float toolchain.

If you want to use the former arm-xilinx-linux-gnueabi-gcc soft-float toolchain included in SDK 2017.2.
Following variables should be exported:


 ```bash
 export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
 export PATH=$PATH:/opt/Xilinx/SDK/2017.2/gnu/arm/lin/bin
 export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2017.4/settings64.sh
 ```

And you need to revert this patch:
https://github.com/analogdevicesinc/buildroot/commit/fea212afc7dc0ee530762a1921d9ae8180778ffa


 If you receive an error similar to the following:
 ```
 Starting SDK. This could take few seconds... timeout while establishing a connection with SDK
    while executing
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
      total 372M
      -rw-rw-r-- 1 michael   69 Apr 14 11:01 boot.bif
      -rw-rw-r-- 1 michael 459K Apr 14 11:01 boot.bin
      -rw-rw-r-- 1 michael 459K Apr 14 11:01 boot.dfu
      -rw-rw-r-- 1 michael 588K Apr 14 11:01 boot.frm
      -rw-rw-r-- 1 michael 254M Apr 14 11:01 legal-info-v0.33.tar.gz
      -rw-rw-r-- 1 michael 527K Apr 14 11:03 LICENSE.html
      -rw-rw-r-- 1 michael  11M Apr 14 11:01 pluto.dfu
      -rw-rw-r-- 1 michael  11M Apr 14 11:01 pluto.frm
      -rw-rw-r-- 1 michael   33 Apr 14 11:01 pluto.frm.md5
      -rw-rw-r-- 1 michael  11M Apr 14 11:01 pluto.itb
      -rw-rw-r-- 1 michael  20M Apr 14 11:01 plutosdr-fw-v0.33.zip
      -rw-rw-r-- 1 michael 571K Apr 14 11:01 plutosdr-jtag-bootstrap-v0.33.zip
      -rw-rw-r-- 1 michael 442K Apr 14 11:00 ps7_init.c
      -rw-rw-r-- 1 michael 442K Apr 14 11:00 ps7_init_gpl.c
      -rw-rw-r-- 1 michael 4,2K Apr 14 11:00 ps7_init_gpl.h
      -rw-rw-r-- 1 michael 4,8K Apr 14 11:00 ps7_init.h
      -rw-rw-r-- 1 michael 2,4M Apr 14 11:00 ps7_init.html
      -rw-rw-r-- 1 michael  31K Apr 14 11:00 ps7_init.tcl
      -rw-r--r-- 1 michael 5,4M Apr 14 11:00 rootfs.cpio.gz
      drwxrwxr-x 6 michael 4,0K Apr 14 11:01 sdk
      -rw-rw-r-- 1 michael  52M Apr 14 11:03 sysroot-v0.33.tar.gz
      -rw-rw-r-- 1 michael 943K Apr 14 11:01 system_top.bit
      -rw-rw-r-- 1 michael 476K Apr 14 11:00 system_top.hdf
      -rwxrwxr-x 1 michael 438K Apr 14 11:01 u-boot.elf
      -rw-rw---- 1 michael 128K Apr 14 11:01 uboot-env.bin
      -rw-rw---- 1 michael 129K Apr 14 11:01 uboot-env.dfu
      -rw-rw-r-- 1 michael 6,5K Apr 14 11:01 uboot-env.txt
      -rwxrwxr-x 1 michael 3,9M Apr 14 10:59 zImage
      -rw-rw-r-- 1 michael  19K Apr 14 11:00 zynq-pluto-sdr.dtb
      -rw-rw-r-- 1 michael  19K Apr 14 11:00 zynq-pluto-sdr-revb.dtb
      -rw-rw-r-- 1 michael  19K Apr 14 11:00 zynq-pluto-sdr-revc.dtb
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
 

