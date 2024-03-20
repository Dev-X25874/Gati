module data_mux#(
    parameter W_DATA = 8
)(
    input i_clk,
    input i_sel,
    input i_rst,
    input [W_DATA : 0] i_fc_data,
    input [W_DATA : 0] i_sa_data,
    output [W_DATA : 0] o_data
);

reg [W_DATA : 0] data = 0;
assign o_data = data;

always@(posedge i_clk)begin
    if(i_rst)begin
        data <= 0;
    end else begin
        if(i_sel)begin
            data <= i_sa_data;
        end else begin
            data <= i_fc_data;
        end
    end
end

endmodule