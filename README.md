# plutosdr-fw
PlutoSDR Firmware


* Build Instructions
 ```bash
 
      git clone --recursive https://github.com/analogdevicesinc/plutosdr-fw.git
      cd plutosdr-fw
      export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
      export PATH=$PATH:/opt/Xilinx/SDK/2015.4/gnu/arm/lin/bin
      export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2015.4/settings64.sh
      make
 
 ```
 
 * Updating your local repository 
 ```bash 
      git pull --recurse-submodules
  ```
 
* Build Artifacts
 ```bash
      michael@HAL9000:~/devel/plutosdr-fw$ ls -AGhl build
      total 30M
      -rw-rw-r-- 1 michael   69 Nov 10 17:17 boot.bif
      -rw-rw-r-- 1 michael 485K Nov 10 17:17 boot.bin
      -rw-rw-r-- 1 michael 485K Nov 10 17:17 boot.dfu
      -rw-rw-r-- 1 michael 6,4M Nov 10 17:17 pluto.dfu
      -rw-rw-r-- 1 michael 6,4M Nov 10 17:17 pluto.frm
      -rw-rw-r-- 1 michael   33 Nov 10 17:17 pluto.frm.md5
      -rw-rw-r-- 1 michael 6,4M Nov 10 17:17 pluto.itb
      -rw-r--r-- 1 michael 2,8M Nov 10 17:17 rootfs.cpio.gz
      drwxrwxr-x 6 michael 4,0K Nov 10 17:17 sdk
      -rw-rw-r-- 1 michael  81K Nov 10 17:17 system_bd.tcl
      -rw-rw-r-- 1 michael 941K Nov 10 17:17 system_top.bit
      -rw-rw-r-- 1 michael 399K Okt 27 18:46 system_top.hdf
      -rwxrwxr-x 1 michael 2,5M Nov 10 17:17 u-boot.elf
      -rw-rw---- 1 michael 128K Nov 10 17:17 uboot-env.bin
      -rw-rw---- 1 michael 129K Nov 10 17:17 uboot-env.dfu
      -rw-rw-r-- 1 michael 3,9K Nov 10 17:17 uboot-env.txt
      -rwxrwxr-x 1 michael 2,7M Nov 10 17:17 zImage
      -rw-rw-r-- 1 michael  16K Nov 10 17:17 zynq-pluto-sdr.dtb   
 ```
 
| File  | Comment |
| ------------- | ------------- |
| pluto.frm | Main PlutoSDR firmware file used with the USB Mass Storage Device |
| pluto.dfu | Main PlutoSDR firmware file used in DFU mode |
| boot.dfu  | First and Second Stage Bootloader (u-boot + fsbl) used in DFU mode |
| uboot-env.dfu  | u-boot default environemnt used in DFU mode |
 
