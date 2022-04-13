connect -url tcp:127.0.0.1:3121
source D:/VivdoProjects/SCRs_AXI/SCRs_AXI.sdk/design_1_wrapper_hw_platform_0/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Zed 210248780828"} -index 0
loadhw D:/VivdoProjects/SCRs_AXI/SCRs_AXI.sdk/design_1_wrapper_hw_platform_0/system.hdf
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Zed 210248780828"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248780828"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248780828"} -index 0
dow D:/VivdoProjects/SCRs_AXI/SCRs_AXI.sdk/SCRs_Controller/Debug/SCRs_Controller.elf
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248780828"} -index 0
con
