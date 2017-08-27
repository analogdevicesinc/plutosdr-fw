# plutosdr-fw
PlutoSDR Firmware for the [ADALM-PLUTO](https://wiki.analog.com/university/tools/pluto "PlutoSDR Wiki Page") Active Learning Module

Latest binary Release : [![GitHub release](https://img.shields.io/github/release/analogdevicesinc/plutosdr-fw.svg)](https://github.com/analogdevicesinc/plutosdr-fw/releases/latest)

* The major requirements
  - [VIVADO 2016.4](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2016-4.html)
  - glic that supports multilib (for building uboot it's necessary to run a 32bit binary but for VIVADO you need 64bit)

* Build Instructions
 ```bash
 
      git clone --recursive https://github.com/analogdevicesinc/plutosdr-fw.git
      cd plutosdr-fw
      export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
      export PATH=$PATH:/opt/Xilinx/SDK/2016.2/gnu/arm/lin/bin
      export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2016.2/settings64.sh
      make
 
 ```
 
 * Updating your local repository 
 ```bash 
      git pull --recurse-submodules
  ```
 
* Build Artifacts
 ```bash
      michael@HAL9000:~/devel/plutosdr-fw$ ls -AGhl build
      total 52M
      -rw-rw-r-- 1 michael   69 Apr 19 17:45 boot.bif
      -rw-rw-r-- 1 michael 446K Apr 19 17:45 boot.bin
      -rw-rw-r-- 1 michael 446K Apr 19 17:45 boot.dfu
      -rw-rw-r-- 1 michael 575K Apr 19 17:45 boot.frm
      -rw-rw-r-- 1 michael 8,3M Apr 19 17:45 pluto.dfu
      -rw-rw-r-- 1 michael 8,3M Apr 19 17:45 pluto.frm
      -rw-rw-r-- 1 michael   33 Apr 19 17:45 pluto.frm.md5
      -rw-rw-r-- 1 michael 8,3M Apr 19 17:45 pluto.itb
      -rw-rw-r-- 1 michael  16M Apr 19 17:45 plutosdr-fw-v0.20.zip
      -rw-rw-r-- 1 michael 471K Apr 19 17:45 plutosdr-jtag-bootstrap-v0.20.zip
      -rw-r--r-- 1 michael 4,2M Apr 19 17:39 rootfs.cpio.gz
      drwxrwxr-x 6 michael 4,0K Apr 19 17:45 sdk
      -rw-rw-r-- 1 michael 940K Apr 19 17:45 system_top.bit
      -rw-rw-r-- 1 michael 362K Apr 19 17:45 system_top.hdf
      -rwxrwxr-x 1 michael 409K Apr 19 17:45 u-boot.elf
      -rw-rw---- 1 michael 128K Apr 19 17:45 uboot-env.bin
      -rw-rw---- 1 michael 129K Apr 19 17:45 uboot-env.dfu
      -rw-rw-r-- 1 michael 4,6K Apr 19 17:45 uboot-env.txt
      -rwxrwxr-x 1 michael 3,2M Apr 19 17:33 zImage
      -rw-rw-r-- 1 michael  16K Apr 19 17:39 zynq-pluto-sdr.dtb
      -rw-rw-r-- 1 michael  16K Apr 19 17:39 zynq-pluto-sdr-revb.dtb 
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

 

