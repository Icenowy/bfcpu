import_device eagle_s20.db -package BG256
open_project bfcpu_tang.al
elaborate -top top_tang
optimize_rtl
report_area -file "bfcpu_tang_rtl.area"
read_adc "io_tang.adc"
export_db "bfcpu_tang_rtl.db"
map_macro
map
pack
report_area -file "bfcpu_tang_gate.area"
export_db "bfcpu_tang_gate.db"
start_timer
place
route
report_area -io_info -file "bfcpu_tang_phy.area"
export_db "bfcpu_tang_pr.db"
start_timer
report_timing -mode FINAL -net_info -ep_num 3 -path_num 3 -file "bfcpu_tang_phy.timing"
bitgen -bit "bfcpu_tang.bit" -version 0X00 -g ucode:00000000000000000000000000000000
