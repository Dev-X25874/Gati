create_clock -period 10.0000 i_clk
create_clock -period 10.0000 s_clk
set_clock_groups -exclusive -group {i_clk} -group {s_clk}