## JTAG bootstrap u-boot for initial SF/SPI flash programming
## Open Xilinx Command Line Tool
## type: xmd -tcl run.tcl

#fpga -f system_top.bit

connect arm hw
stop
xreset 64

source ps7_init.tcl
ps7_init
ps7_post_config

dow u-boot.elf
run
disconnect 64
