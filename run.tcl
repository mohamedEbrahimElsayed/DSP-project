create_project project_10 D:/digital\ assignments/vivado\ projects -part xc7a200tffg1156-1 -force

add_files Spartan6.v Register.v

synth_design -rtl -top Spartan6 > elab.log

write_schematic elaborated_schematic.pdf -format pdf -force 

launch_runs synth_1 > synth.log

wait_on_run synth_1
open_run synth_1

write_schematic synthesized_schematic.pdf -format pdf -force 

write_verilog -force DSP_netlist.v

# launch_runs impl_1 -to_step write_bitstream 

# wait_on_run impl_1
# open_run impl_1

# open_hw

# connect_hw_server