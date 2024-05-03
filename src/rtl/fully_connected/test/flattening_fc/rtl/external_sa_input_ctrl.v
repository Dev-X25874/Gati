//send the data to the north fifo array located inside the engine
module external_sa_input_ctrl#(
    parameter N_SA = 2,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_data_valid,
    input [(N_SA * W_DATA)-1 : 0] i_data,
    output [(N_SA * W_DATA)-1 : 0] o_data,
    output [N_SA-1 : 0] o_wren
);

reg [N_SA-1 : 0] wren = 0;
reg [(N_SA * W_DATA)-1 : 0] data = 0;
assign o_data = data;
assign o_wren = wren;

always @(*) begin
    if(i_rst)begin
        wren <= 0;
    end else begin
        if(i_data_valid == {N_SA{1'b1}})begin
            wren <= {N_SA{1'b1}};
        end else begin
            wren <= 0;
        end
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        
    end else begin
        if(i_data_valid == {N_SA{1'b1}})begin
            data <= i_data;
        end else begin
            data <= data;
        end
    end
end
endmodule
