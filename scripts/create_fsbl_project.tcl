hsi open_hw_design build/system_top.hdf
set cpu_name [lindex [hsi get_cells -filter {IP_TYPE==PROCESSOR}] 0]

sdk setws ./build/sdk
sdk createhw -name hw_0 -hwspec build/system_top.hdf

# Workaround for broken write_sysdev in vivado 2018.2
catch {
	set copyfiles [glob ./build/ps7_init*]
	if {[llength $copyfiles]} {
		file copy {*}$copyfiles ./build/sdk/hw_0/
	}
}
sdk createapp -name fsbl -hwproject hw_0 -proc $cpu_name -os standalone -lang C -app {Zynq FSBL}
configapp -app fsbl build-config release
sdk projects -build -type all
#xsdk -batch -source create_fsbl_project.tcl
