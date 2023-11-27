//Top pe block
module top_pe_block(
    input i_clk,
    input i_sel,
    input   [7:0] i_weight,
    input   [8:0] i_data,
    output o_sel,
    output   [7:0] o_weight,
    output   [31:0] o_p_sum,
    output   [8:0] o_data
);

reg   [7:0] wb = 0;           //register store weight
reg   [31:0] psum_buff = 0;   //register store partial sum

assign o_data = i_data;

always @(posedge i_clk)begin
    if(i_sel)begin
        wb <= i_weight;
    end else begin
        psum_buff <= 0;
    end
end

//Computing data
wire  signed [31:0] mul_out;
assign mul_out = i_data[7:0] * wb;
assign o_p_sum = psum_buff + mul_out;   //32 bit computed output
assign o_weight = wb;
assign o_sel = i_sel;
endmodule

//Middle pe blocks
module pe_block(
    input i_clk,
    input i_sel,
    input  signed [7:0] i_weight,
    input  signed [31:0] i_p_sum,
    input  signed [8:0] i_data,
    output o_sel,
    output  signed [8:0] o_data,
    output  signed [7:0] o_weight,
    output  signed [31:0] o_p_sum
);

reg  signed [7:0] wb = 0;           //register store weight
reg  signed [31:0] psum_buff = 0;   //register store partial sum

assign o_data = i_data;

always @(posedge i_clk)begin
    if(i_sel)begin
        wb <= i_weight;
    end else begin
        psum_buff <= i_p_sum;
    end
end

//Computing data
wire  signed [31:0] mul_out;
assign mul_out = i_data[7:0] * wb;
assign o_p_sum = psum_buff + mul_out;   //32 bit computed output
assign o_weight = wb;
assign o_sel = i_sel;
endmodule

//Bottom pe block

module bottom_pe_block(
    input i_clk,
    input i_sel,
    input  signed [7:0] i_weight,
    input  signed [31:0] i_p_sum,
    input  signed [8:0] i_data,
    output signed  [8:0] o_data,
    output o_sel,
    output signed [31:0] o_p_sum
);

reg  signed [7:0] wb = 0;           //register store weight
reg  signed [31:0] psum_buff = 0;   //register store partial sum

assign o_data = i_data;

always @(posedge i_clk)begin
    if(i_sel)begin
        wb <= i_weight;
    end else begin
        psum_buff <= i_p_sum;
    end
end

//Computing data
wire  signed [31:0] mul_out;
assign mul_out = i_data[7:0] * wb;
assign o_p_sum = psum_buff + mul_out;   //32 bit computed output
assign o_sel = i_sel;
endmodule