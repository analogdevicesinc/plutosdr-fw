hsi open_hw_design build/system_top.xsa
set cpu_name [lindex [hsi get_cells -filter {IP_TYPE==PROCESSOR}] 0]

setws ./build/sdk
app create -name fsbl -hw build/system_top.xsa -proc $cpu_name -os standalone -lang C -template {Zynq FSBL}
app config -name fsbl -set build-config release
app build -name fsbl
