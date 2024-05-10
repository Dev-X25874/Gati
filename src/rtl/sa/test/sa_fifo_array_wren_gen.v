/*
    The fsm given below controls write enable signal of sa_engine_weight_fifo_array and sa_engine_image_fifo_array. 
    It activates the write enable signal for one fifo in array at a time. 
    It goes through each fifo in the array, activating the write enable signal for one clock cycle per fifo. 
    After reaching the last fifo, it deactivates the write enable signal in the next clock cycle and 
    then activates the write enable signal for the first fifo again. 
    This process continues as long as the finite state machine is enabled.
    Whereas, weight_ff_array_wren module generates wren_fsm for N_SA times, 
    i.e., each engine has this module.
*/
module sa_fifo_array_wren_gen#(
    parameter DIMENSION = 4,
    parameter N_SA = 1
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_enb,
    output [(N_SA * DIMENSION)-1 : 0] o_wren
);
genvar i;
generate
    for(i = 0; i < N_SA; i = i + 1)begin
        wren_fsm#(
            .DIMENSION(DIMENSION),
            .N_SA(N_SA)
        )int_north_wren_ctrl(
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_enable(i_enb[i]),
            .o_data(o_wren[(DIMENSION * (N_SA - i))-1 -: DIMENSION]) 
        );
    end
endgenerate
endmodule

module wren_fsm#(
    parameter DIMENSION = 3,
    parameter N_SA = 2
)(
    input i_clk,
    input i_rst,
    input i_enable,
    output [DIMENSION-1:0] o_data 
);
    
reg [DIMENSION-1:0] counter = 0;
reg [DIMENSION-1:0] data = 0;

assign o_data = data;

always @(posedge i_clk) begin
    if(i_rst)begin
        counter <= 0;
        data <= 0;
    end else begin
        if(i_enable) begin
            if (counter == DIMENSION - 1)
                counter <= 0;
            else
                counter <= counter + 1;
                
            data[counter] <= 1;
            
            if(DIMENSION > 1) begin
                if (counter == 0)
                    data[DIMENSION - 1] <= 0;
                else
                    data[counter - 1] <= 0;
            end
        end else begin
            counter <= 0;
            data <= 0;
        end
    end
end
    
endmodule