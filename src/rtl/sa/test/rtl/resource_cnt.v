module resource_cnt#(
    parameter N_SA = (NSA_BOOTH + NSA_DSP),
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter COL = 32,
    parameter ROW = 1,
    parameter W_PSUM = 19,
    parameter RAM_DEPTH = (1<<W_ADDR),
    parameter NSA_BOOTH = 0,
    parameter NSA_DSP = 1
)(
    input i_clk,
    input s_clk,
    input i_rst,
    input i_trigger_1,
    input [(N_SA * COL)-1 : 0] i_north_dv,
    input [5:0] i_weight_sel,
    input [5:0] i_psum_sel,
    input [(N_SA * COL)-1 : 0] i_north_empty,
    input [W_DATA-1 : 0] i_north_data,
    input [W_ADDR : 0] i_north_occ,
    
    input [(N_SA * W_DATA)-1 : 0] i_west_data,
    input i_west_dv,
    input [(N_SA * COL)-1 : 0] i_west_empty,
    
    output [(N_SA * COL)-1 : 0] o_north_read_en,
    output [W_PSUM-1 : 0] o_psum_out,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_empty,
    output [(COL * N_SA)-1 : 0] o_psum_ff_array_dv,
    output [(N_SA * COL)-1 : 0] o_weight_fifo_array_read_enable
);

wire [(N_SA * (COL * W_DATA))-1 : 0] sa_north_data;
res_input_demux#(
    .W_DATA(W_DATA),
    .COL(COL)
)weight_data(
    .i_clk(i_clk),
    .i_data(i_north_data),
    .i_sel(i_weight_sel),
    .o_data(sa_north_data)
);

wire [(N_SA * (COL * (W_ADDR + 1)))-1 : 0] sa_north_occ;
res_input_demux#(
    .W_DATA(W_ADDR + 1),
    .COL(COL)
)weight_occ(
    .i_clk(i_clk),
    .i_data(i_north_occ),
    .i_sel(i_weight_sel),
    .o_data(sa_north_occ)
);


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
)fc_engines_inst(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rst(i_rst),
    .i_trigger_1(i_trigger_1),
    .i_weight_fifo_array_data(sa_north_data),
    
    .i_weight_fifo_array_dv(i_north_dv),
    .i_weight_fifo_array_empty(i_north_empty),
    .i_weight_fifo_array_occupants(sa_north_occ),
    .i_image_fifo_array_data(i_west_data),
    .i_image_fifo_array_wren(i_west_dv),
    .i_psum_ff_array_read_en(i_west_empty),
    .o_psum_ff_array_partial_sums(o_psum),
    .o_psum_ff_array_empty(),
    .o_psum_ff_array_dv(),
    .o_weight_fifo_array_read_enable(o_north_read_en)
);

wire [((COL * W_PSUM) * N_SA)-1 : 0] o_psum;

res_output_mux#(
    .W_DATA(W_PSUM),
    .ROW(COL)
)acc_mux(
    .i_clk(i_clk),
    .i_data(o_psum),
    .i_sel(i_psum_sel),
    .o_data(o_psum_out)
);

endmodule

module res_output_mux#(
    parameter W_DATA = 8,
    parameter ROW = 32
)(
    input i_clk,
    input [(W_DATA * ROW)-1 : 0] i_data,
    input [5:0] i_sel,
    output reg [W_DATA-1:0] o_data
);

always @ (posedge i_clk) begin
    case (i_sel)
        6'd0: o_data <= i_data[(W_DATA*(0+1))-1:W_DATA*0];
        6'd1: o_data <= i_data[(W_DATA*(1+1))-1:W_DATA*1];
        6'd2: o_data <= i_data[(W_DATA*(2+1))-1:W_DATA*2];
        6'd3: o_data <= i_data[(W_DATA*(3+1))-1:W_DATA*3];
        6'd4: o_data <= i_data[(W_DATA*(4+1))-1:W_DATA*4];
        6'd5: o_data <= i_data[(W_DATA*(5+1))-1:W_DATA*5];
        6'd6: o_data <= i_data[(W_DATA*(6+1))-1:W_DATA*6];
        6'd7: o_data <= i_data[(W_DATA*(7+1))-1:W_DATA*7];
        6'd8: o_data <= i_data[(W_DATA*(8+1))-1:W_DATA*8];
        6'd9: o_data <= i_data[(W_DATA*(9+1))-1:W_DATA*9];
        6'd10: o_data <= i_data[(W_DATA*(10+1))-1:W_DATA*10];
        6'd11: o_data <= i_data[(W_DATA*(11+1))-1:W_DATA*11];
        6'd12: o_data <= i_data[(W_DATA*(12+1))-1:W_DATA*12];
        6'd13: o_data <= i_data[(W_DATA*(13+1))-1:W_DATA*13];
        6'd14: o_data <= i_data[(W_DATA*(14+1))-1:W_DATA*14];
        6'd15: o_data <= i_data[(W_DATA*(15+1))-1:W_DATA*15];
        6'd16: o_data <= i_data[(W_DATA*(16+1))-1:W_DATA*16];
        6'd17: o_data <= i_data[(W_DATA*(17+1))-1:W_DATA*17];
        6'd18: o_data <= i_data[(W_DATA*(18+1))-1:W_DATA*18];
        6'd19: o_data <= i_data[(W_DATA*(19+1))-1:W_DATA*19];
        6'd20: o_data <= i_data[(W_DATA*(20+1))-1:W_DATA*20];
        6'd21: o_data <= i_data[(W_DATA*(21+1))-1:W_DATA*21];
        6'd22: o_data <= i_data[(W_DATA*(22+1))-1:W_DATA*22];
        6'd23: o_data <= i_data[(W_DATA*(23+1))-1:W_DATA*23];
        6'd24: o_data <= i_data[(W_DATA*(24+1))-1:W_DATA*24];
        6'd25: o_data <= i_data[(W_DATA*(25+1))-1:W_DATA*25];
        6'd26: o_data <= i_data[(W_DATA*(26+1))-1:W_DATA*26];
        6'd27: o_data <= i_data[(W_DATA*(27+1))-1:W_DATA*27];
        6'd28: o_data <= i_data[(W_DATA*(28+1))-1:W_DATA*28];
        6'd29: o_data <= i_data[(W_DATA*(29+1))-1:W_DATA*29];
        6'd30: o_data <= i_data[(W_DATA*(30+1))-1:W_DATA*30];
        6'd31: o_data <= i_data[(W_DATA*(31+1))-1:W_DATA*31];
        default: o_data <= 0; // Default case if no selection is made
    endcase
end

endmodule


module res_input_demux#(
    parameter W_DATA = 8,
    parameter COL = 32
)(
    input i_clk,
    input [W_DATA-1:0] i_data,
    input [5:0] i_sel,
    output [(W_DATA * COL)-1 : 0] o_data
);

assign o_data = {data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8, 
                data_9, data_10, data_11, data_12, data_13, data_14, data_15, data_16,
                data_17, data_18, data_19, data_20, data_21, data_22, data_23, data_24,
                data_25, data_26, data_27, data_28, data_29, data_30, data_31, data_32};

reg [W_DATA-1:0] o_data_1 = 0;
reg [W_DATA-1:0] o_data_2 = 0;
reg [W_DATA-1:0] o_data_3 = 0;
reg [W_DATA-1:0] o_data_4 = 0;
reg [W_DATA-1:0] o_data_5 = 0;
reg [W_DATA-1:0] o_data_6 = 0;
reg [W_DATA-1:0] o_data_7 = 0;
reg [W_DATA-1:0] o_data_8 = 0;
reg [W_DATA-1:0] o_data_9 = 0;
reg [W_DATA-1:0] o_data_10 = 0;
reg [W_DATA-1:0] o_data_11 = 0;
reg [W_DATA-1:0] o_data_12 = 0;
reg [W_DATA-1:0] o_data_13 = 0;
reg [W_DATA-1:0] o_data_14 = 0;
reg [W_DATA-1:0] o_data_15 = 0;
reg [W_DATA-1:0] o_data_16 = 0;
reg [W_DATA-1:0] o_data_17 = 0;
reg [W_DATA-1:0] o_data_18 = 0;
reg [W_DATA-1:0] o_data_19 = 0;
reg [W_DATA-1:0] o_data_20 = 0;
reg [W_DATA-1:0] o_data_21 = 0;
reg [W_DATA-1:0] o_data_22 = 0;
reg [W_DATA-1:0] o_data_23 = 0;
reg [W_DATA-1:0] o_data_24 = 0;
reg [W_DATA-1:0] o_data_25 = 0;
reg [W_DATA-1:0] o_data_26 = 0;
reg [W_DATA-1:0] o_data_27 = 0;
reg [W_DATA-1:0] o_data_28 = 0;
reg [W_DATA-1:0] o_data_29 = 0;
reg [W_DATA-1:0] o_data_30 = 0;
reg [W_DATA-1:0] o_data_31 = 0;
reg [W_DATA-1:0] o_data_32 = 0;

wire [W_DATA-1 : 0] data_1;
wire [W_DATA-1 : 0] data_2;
wire [W_DATA-1 : 0] data_3;
wire [W_DATA-1 : 0] data_4;
wire [W_DATA-1 : 0] data_5;
wire [W_DATA-1 : 0] data_6;
wire [W_DATA-1 : 0] data_7;
wire [W_DATA-1 : 0] data_8;
wire [W_DATA-1 : 0] data_9;
wire [W_DATA-1 : 0] data_10;
wire [W_DATA-1 : 0] data_11;
wire [W_DATA-1 : 0] data_12;
wire [W_DATA-1 : 0] data_13;
wire [W_DATA-1 : 0] data_14;
wire [W_DATA-1 : 0] data_15;
wire [W_DATA-1 : 0] data_16;
wire [W_DATA-1 : 0] data_17;
wire [W_DATA-1 : 0] data_18;
wire [W_DATA-1 : 0] data_19;
wire [W_DATA-1 : 0] data_20;
wire [W_DATA-1 : 0] data_21;
wire [W_DATA-1 : 0] data_22;
wire [W_DATA-1 : 0] data_23;
wire [W_DATA-1 : 0] data_24;
wire [W_DATA-1 : 0] data_25;
wire [W_DATA-1 : 0] data_26;
wire [W_DATA-1 : 0] data_27;
wire [W_DATA-1 : 0] data_28;
wire [W_DATA-1 : 0] data_29;
wire [W_DATA-1 : 0] data_30;
wire [W_DATA-1 : 0] data_31;
wire [W_DATA-1 : 0] data_32;

assign data_1 = o_data_1;
assign data_2 = o_data_2;
assign data_3 = o_data_3;
assign data_4 = o_data_4;
assign data_5 = o_data_5;
assign data_6 = o_data_6;
assign data_7 = o_data_7;
assign data_8 = o_data_8;
assign data_9 = o_data_9;
assign data_10 = o_data_10;
assign data_11 = o_data_11;
assign data_12 = o_data_12;
assign data_13 = o_data_13;
assign data_14 = o_data_14;
assign data_15 = o_data_15;
assign data_16 = o_data_16;
assign data_17 = o_data_17;
assign data_18 = o_data_18;
assign data_19 = o_data_19;
assign data_20 = o_data_20;
assign data_21 = o_data_21;
assign data_22 = o_data_22;
assign data_23 = o_data_23;
assign data_24 = o_data_24;
assign data_25 = o_data_25;
assign data_26 = o_data_26;
assign data_27 = o_data_27;
assign data_28 = o_data_28;
assign data_29 = o_data_29;
assign data_30 = o_data_30;
assign data_31 = o_data_31;
assign data_32 = o_data_32;

always @(posedge i_clk) begin
    case(i_sel)
        6'd1: o_data_1 <= i_data;
        6'd2: o_data_2 <= i_data;
        6'd3: o_data_3 <= i_data;
        6'd4: o_data_4 <= i_data;
        6'd5: o_data_5 <= i_data;
        6'd6: o_data_6 <= i_data;
        6'd7: o_data_7 <= i_data;
        6'd8: o_data_8 <= i_data;
        6'd9: o_data_9 <= i_data;
        6'd10: o_data_10 <= i_data;
        6'd11: o_data_11 <= i_data;
        6'd12: o_data_12 <= i_data;
        6'd13: o_data_13 <= i_data;
        6'd14: o_data_14 <= i_data;
        6'd15: o_data_15 <= i_data;
        6'd16: o_data_16 <= i_data;
        6'd17: o_data_17 <= i_data;
        6'd18: o_data_18 <= i_data;
        6'd19: o_data_19 <= i_data;
        6'd20: o_data_20 <= i_data;
        6'd21: o_data_21 <= i_data;
        6'd22: o_data_22 <= i_data;
        6'd23: o_data_23 <= i_data;
        6'd24: o_data_24 <= i_data;
        6'd25: o_data_25 <= i_data;
        6'd26: o_data_26 <= i_data;
        6'd27: o_data_27 <= i_data;
        6'd28: o_data_28 <= i_data;
        6'd29: o_data_29 <= i_data;
        6'd30: o_data_30 <= i_data;
        6'd31: o_data_31 <= i_data;
        6'd32: o_data_32 <= i_data;
        default: begin
                    o_data_1 <= 0;
                    o_data_2 <= 0;
                    o_data_3 <= 0;
                    o_data_4 <= 0;
                    o_data_5 <= 0;
                    o_data_6 <= 0;
                    o_data_7 <= 0;
                    o_data_8 <= 0;
                    o_data_9 <= 0;
                    o_data_10 <= 0;
                    o_data_11 <= 0;
                    o_data_12 <= 0;
                    o_data_13 <= 0;
                    o_data_14 <= 0;
                    o_data_15 <= 0;
                    o_data_16 <= 0;
                    o_data_17 <= 0;
                    o_data_18 <= 0;
                    o_data_19 <= 0;
                    o_data_20 <= 0;
                    o_data_21 <= 0;
                    o_data_22 <= 0;
                    o_data_23 <= 0;
                    o_data_24 <= 0;
                    o_data_25 <= 0;
                    o_data_26 <= 0;
                    o_data_27 <= 0;
                    o_data_28 <= 0;
                    o_data_29 <= 0;
                    o_data_30 <= 0;
                    o_data_31 <= 0;
                    o_data_32 <= 0;
                end
    endcase
end

endmodule
