hsi open_hw_design build/system_top.hdf
set cpu_name [lindex [hsi get_cells -filter {IP_TYPE==PROCESSOR}] 0]

sdk set_workspace ./build/sdk
sdk create_hw_project -name hw_0 -hwspec build/system_top.hdf
sdk create_app_project -name fsbl -hwproject hw_0 -proc $cpu_name -os standalone -lang C -app {Zynq FSBL}
sdk build_project -type all
#xsdk -batch -source create_fsbl_project.tcl
