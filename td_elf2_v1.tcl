import_device ef2_4.db -package EF2M45LG48B
open_project bfcpu_elf2_v1.al
elaborate -top top_elf2_v1
optimize_rtl
report_area -file "bfcpu_elf2_v1_rtl.area"
read_sdc "timing_elf2_v1.sdc"
read_adc "io_elf2_v1.adc"
export_db "bfcpu_elf2_v1_rtl.db"
optimize_gate -packarea "bfcpu_elf2_v1_gate.area"
legalize_phy_inst
read_sdc "timing_elf2_v1.sdc"
legalize_phy_inst
export_db "bfcpu_elf2_v1_gate.db"
place
route
report_area -io_info -file "bfcpu_elf2_v1_phy.area"
export_db "bfcpu_elf2_v1_pr.db"
start_timer
report_timing -mode FINAL -net_info -ep_num 3 -path_num 3 -file "bfcpu_elf2_v1_phy.timing"
bitgen -bit "bfcpu_elf2_v1.bit" -version 0X00 -g ucode:00000000000000000000000000000000
