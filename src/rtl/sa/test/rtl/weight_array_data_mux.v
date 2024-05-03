module weight_array_data_mux#(
    parameter COL = 8,
    parameter N_SA = 8,
    parameter W_DATA = 8
)(
    input clk,
    input [3:0] i_sel,
    input [(N_SA * W_DATA)-1 : 0] i_data,
    output [(N_SA * W_DATA * COL)-1 : 0] o_data
);

genvar i;
generate
    for (i = 0;i < N_SA; i = i+ 1) begin
        input_demux#(
            .W_DATA(W_DATA),
            .COL(COL)
        )input_data(
            .clk(clk),
            .i_data(i_data[(W_DATA * (N_SA - i))-1 -: W_DATA]),
            .i_sel(i_sel),
            .o_data(o_data[((W_DATA * COL) * (N_SA - i))-1 -: (W_DATA * COL)])
        );
    end
endgenerate

endmodule

module input_demux#(parameter W_DATA = 8, parameter COL = 8)(
    input clk,
    input [W_DATA-1:0] i_data,
    input [3:0] i_sel,
    output [(W_DATA * COL)-1 : 0] o_data
);

assign o_data = {data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8};

reg [W_DATA-1:0] o_data_1 = 0;
reg [W_DATA-1:0] o_data_2 = 0;
reg [W_DATA-1:0] o_data_3 = 0;
reg [W_DATA-1:0] o_data_4 = 0;
reg [W_DATA-1:0] o_data_5 = 0;
reg [W_DATA-1:0] o_data_6 = 0;
reg [W_DATA-1:0] o_data_7 = 0;
reg [W_DATA-1:0] o_data_8 = 0;

assign data_1 = o_data_1;
assign data_2 = o_data_2;
assign data_3 = o_data_3;
assign data_4 = o_data_4;
assign data_5 = o_data_5;
assign data_6 = o_data_6;
assign data_7 = o_data_7;
assign data_8 = o_data_8;

always @(posedge clk)begin
    if(i_sel == 4'd1)
        o_data_1 = i_data;
    else if(i_sel == 4'd2)
        o_data_2 <= i_data;
    else if(i_sel == 4'd3)
        o_data_3 <= i_data;
    else if(i_sel == 4'd4)
        o_data_4 <= i_data;
    else if(i_sel == 4'd5)
        o_data_5 <= i_data;
    else if(i_sel == 4'd6)
        o_data_6 <= i_data;
    else if(i_sel == 4'd7)
        o_data_7 <= i_data;
    else if(i_sel == 4'd8)
        o_data_8 <= i_data;
    else begin
        o_data_1 = 0;
        o_data_2 = 0;
        o_data_3 = 0;
        o_data_4 = 0;
        o_data_5 = 0;
        o_data_6 = 0;
        o_data_7 = 0;
        o_data_8 = 0;
    end
end

endmodule