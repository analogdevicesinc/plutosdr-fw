## JTAG bootstrap u-boot for initial SF/SPI flash programming
## Use Xilinx System Debug Tool
## type: xsdb run-xsdb.tcl

#fpga -f system_top.bit

connect
target 2

rst

source ps7_init.tcl
ps7_init
ps7_post_config

dow u-boot.elf
con
disconnect
