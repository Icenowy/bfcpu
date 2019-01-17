import_device eagle_s20.db -package BG256
open_project bfcpu.al
elaborate -top top_tang
optimize_rtl
report_area -file "bfcpu_rtl.area"
read_adc "io.adc"
export_db "bfcpu_rtl.db"
map_macro
map
pack
report_area -file "bfcpu_gate.area"
export_db "bfcpu_gate.db"
start_timer
place
route
report_area -io_info -file "bfcpu_phy.area"
export_db "bfcpu_pr.db"
start_timer
report_timing -mode FINAL -net_info -ep_num 3 -path_num 3 -file "bfcpu_phy.timing"
bitgen -bit "bfcpu.bit" -version 0X00 -g ucode:00000000000000000000000000000000
