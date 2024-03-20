create_clock -period 10.0000 i_clk
#create_clock -period 10.0000 s_clk
set_clock_groups -exclusive -group {i_clk} -group {s_clk}
#set_multicycle_path -setup -from p_sum_array_rden_controller/genblk1[*].last_ff_controller/* -to last_ff_input[*]~* 2
#set_multicycle_path -hold -from p_sum_array_rden_controller/genblk1[*].last_ff_controller/* -to last_ff_input[*]~* 1