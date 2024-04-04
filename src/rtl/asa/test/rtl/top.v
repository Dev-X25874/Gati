module top#(
    parameter N_SA = (NSA_BOOTH + NSA_DSP),
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter COL = 8,
    parameter ROW = 9,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1 << W_ADDR),
    parameter NSA_BOOTH = 4,
    parameter NSA_DSP = 4
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input [(COL * N_SA)-1 : 0] i_weight_fifo_array_wren,
    input [(ROW * N_SA)-1 : 0] i_image_fifo_array_wren,
    input [(COL * N_SA)-1 : 0] i_psum_fifo_array_rden,
    input [W_DATA-1 : 0] i_weight,
    input [W_DATA-1 : 0] i_image,
    input [3:0] i_weight_sel,
    input [3:0] i_image_sel,
    input [4:0] i_psum_sel,
    output [W_PSUM-1 : 0] psum_mux_1,
    output [W_PSUM-1 : 0] psum_mux_2,
    output [W_PSUM-1 : 0] psum_mux_3,
    output [W_PSUM-1 : 0] psum_mux_4,
    output [W_PSUM-1 : 0] psum_mux_5,
    output [W_PSUM-1 : 0] psum_mux_6,
    output [W_PSUM-1 : 0] psum_mux_7,
    output [W_PSUM-1 : 0] psum_mux_8
);

wire [W_DATA-1 : 0] engine_weight_1;
wire [W_DATA-1 : 0] engine_weight_2;
wire [W_DATA-1 : 0] engine_weight_3;
wire [W_DATA-1 : 0] engine_weight_4;
wire [W_DATA-1 : 0] engine_weight_5;
wire [W_DATA-1 : 0] engine_weight_6;
wire [W_DATA-1 : 0] engine_weight_7;
wire [W_DATA-1 : 0] engine_weight_8;

//Weights fifo data demux
input_demux#(
    .W_DATA(W_DATA)
)weights_demux(
    .clk(i_clk),
    .i_data(i_weight),
    .i_sel(i_weight_sel),
    .data_1(engine_weight_1),
    .data_2(engine_weight_2),
    .data_3(engine_weight_3),
    .data_4(engine_weight_4),
    .data_5(engine_weight_5),
    .data_6(engine_weight_6),
    .data_7(engine_weight_7),
    .data_8(engine_weight_8)  
);

wire [(N_SA * W_DATA)-1 : 0] weight_fifo_array;

assign weight_fifo_array = {engine_weight_1, engine_weight_2, engine_weight_3, engine_weight_4, engine_weight_5, engine_weight_6, engine_weight_7, engine_weight_8};

wire [W_DATA-1 : 0] engine_image_1;
wire [W_DATA-1 : 0] engine_image_2;
wire [W_DATA-1 : 0] engine_image_3;
wire [W_DATA-1 : 0] engine_image_4;
wire [W_DATA-1 : 0] engine_image_5;
wire [W_DATA-1 : 0] engine_image_6;
wire [W_DATA-1 : 0] engine_image_7;
wire [W_DATA-1 : 0] engine_image_8;

//Image fifo data demux
input_demux#(
    .W_DATA(W_DATA)
)image_demux(
    .clk(i_clk),
    .i_data(i_image),
    .i_sel(i_image_sel),
    .data_1(engine_image_1),
    .data_2(engine_image_2),
    .data_3(engine_image_3),
    .data_4(engine_image_4),
    .data_5(engine_image_5),
    .data_6(engine_image_6),
    .data_7(engine_image_7),
    .data_8(engine_image_8)  
);

wire [(N_SA * W_DATA)-1 : 0] image_fifo_array;

assign image_fifo_array = {engine_image_1, engine_image_2, engine_image_3, engine_image_4, engine_image_5, engine_image_6, engine_image_7, engine_image_8};


wire [((COL * W_PSUM) * N_SA)-1 : 0] o_psum;
mul_engines#(
    .N_SA(N_SA),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .COL(COL),
    .ROW(ROW),
    .W_PSUM(W_PSUM),
    .RAM_DEPTH(RAM_DEPTH),
    .NSA_BOOTH(NSA_BOOTH),
    .NSA_DSP(NSA_DSP)
)multiple_sa_engines(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(i_trigger_1),
    .i_weight_fifo_array_data(weight_fifo_array),
    .i_weight_fifo_array_write_en(i_weight_fifo_array_wren),
    .i_image_fifo_array_data(image_fifo_array),
    .i_image_fifo_array_wren(i_image_fifo_array_wren),
    .i_psum_ff_array_read_en(i_psum_fifo_array_rden),
    .o_psum_ff_array_partial_sums(o_psum),
    .o_psum_ff_array_empty(),
    .o_psum_ff_array_dv()
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_1_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[1215:1064]),
    .o_data(psum_mux_1)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_2_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[1063:912]),
    .o_data(psum_mux_2)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_3_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[911:760]),
    .o_data(psum_mux_3)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_4_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[759:608]),
    .o_data(psum_mux_4)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_5_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[607:456]),
    .o_data(psum_mux_5)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_6_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[455:304]),
    .o_data(psum_mux_6)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_7_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[303:152]),
    .o_data(psum_mux_7)
);

output_mux#(
    .W_DATA(W_PSUM * N_SA), 
    .W_PSUM(W_PSUM), 
    .N(N_SA)
)psum_mux_8_inst(
    .clk(i_clk),
    .i_sel(i_psum_sel),
    .i_data(o_psum[151:0]),
    .o_data(psum_mux_8)
);

endmodule


module input_demux#(parameter W_DATA = 8)(
    input clk,
    input [W_DATA-1:0] i_data,
    input [3:0] i_sel,
    output [W_DATA-1:0] data_1,
    output [W_DATA-1:0] data_2,
    output [W_DATA-1:0] data_3,
    output [W_DATA-1:0] data_4,
    output [W_DATA-1:0] data_5,
    output [W_DATA-1:0] data_6,
    output [W_DATA-1:0] data_7,
    output [W_DATA-1:0] data_8  
);

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

module output_mux#(parameter W_DATA = (19*8), parameter W_PSUM = 19, parameter N = 8)(
    input clk,
    input [4:0] i_sel,
    input [(W_DATA * N)-1 : 0] i_data,
    output reg [W_PSUM-1:0] o_data = 0
);

always @(posedge clk)begin
    if(i_sel == 4'd1)
        o_data = i_data[151:133];
    else if(i_sel == 4'd2)
        o_data <= i_data[132:114];
    else if(i_sel == 4'd3)
        o_data <= i_data[113:95];
    else if(i_sel == 4'd4)
        o_data <= i_data[94:76];
    else if(i_sel == 4'd5)
        o_data <= i_data[75:57];
    else if(i_sel == 4'd6)
        o_data <= i_data[56:38];
    else if(i_sel == 4'd7)
        o_data <= i_data[37:19];
    else if(i_sel == 4'd8)
        o_data <= i_data[18:0];
    else begin
        o_data = 0;
    end
end

endmodule