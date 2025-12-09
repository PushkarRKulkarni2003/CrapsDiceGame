set_db lib_search_path {./lib}
set_db hdl_search_path {./}
set_db library {./lib/slow.lib}
read_hdl fsm_fpga.v

elaborate
read_sdc fsm_fpga.sdc
syn_gen
syn_map
syn_opt

report_timing
report_area

write_hdl>a1_netlist.v
write_sdc>a1_sdc.sdc

write_sdf -nonegchecks -edges check_edge -timescale ns -recrem split -setuphold split >a1.sdf
