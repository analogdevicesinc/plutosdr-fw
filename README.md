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
