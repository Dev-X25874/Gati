/*
    Delay of two clock cycle is applied to data valid signal of partial sum 
    becase the multiplied output coming from booth algorithm has delay of two clock cycle
*/
module booth_top_pe_block#(
	parameter W_DATA = 8, 
	parameter W_PSUM = 19
)(  input i_clk,
    input i_rst,
    input [W_DATA : 0] i_weight,
    input [W_DATA : 0] i_data,
    output [W_DATA : 0] o_weight,
    output [W_PSUM : 0] o_p_sum,
    output [W_DATA : 0] o_data
);

//Width for appending msb to mul_reg for addition in case of signed number
localparam W_APPEND = (W_PSUM - (2*W_DATA));

reg [W_DATA-1 : 0] wb = 0;           //register to store weight
reg [W_PSUM-1 : 0] psum_buff = 0;    //register to store partial sum
reg w_dv = 0;
reg [1:0] ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv[0] <= 0;
        ps_dv[1] <= 0;
    end else begin
        ps_dv[0] <= (i_data[W_DATA] & w_dv);
        ps_dv[1] <= ps_dv[0];
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        wb <= 0;
        w_dv <= 0;
        psum_buff <= 0;    
    end else begin
        if(i_weight[W_DATA])begin
            wb <= i_weight[W_DATA-1 : 0];
            w_dv <= i_weight[W_DATA];
            psum_buff <= 0;
        end else begin
                wb <= wb;
                w_dv <= w_dv;
                psum_buff <= 0;
        end
    end
end

//16 bit output of product of weight and image
wire signed [(2 * W_DATA)-1 : 0] temp;

top_booth t1(
    .clk(i_clk),
    .a(i_data[W_DATA-1:0]),
    .b(wb),
    .c(temp)
);

assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{temp[(2*W_DATA)-1]}},{temp}});
assign o_data = i_data;
assign o_p_sum[W_PSUM] = ps_dv[1];
assign o_weight = {i_weight[W_DATA],wb};

endmodule

//Middle pe blocks
module booth_pe_block  #(parameter W_DATA = 8, W_PSUM = 19) (
    input i_clk,
    input i_rst,
    input [W_DATA : 0] i_weight,
    input [W_PSUM : 0] i_p_sum,
    input [W_DATA : 0] i_data,
    output [W_DATA : 0] o_data,
    output [W_DATA : 0] o_weight,
    output [W_PSUM : 0] o_p_sum
);

//Width for appending msb to mul_reg for addition in case of signed number
localparam W_APPEND = (W_PSUM - (2*W_DATA));

reg [W_DATA-1:0] wb = 0;           //register to store weight
reg [W_PSUM -1:0] psum_buff = 0;   //register to store partial sum
reg w_dv = 0;
reg [1:0] ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv[0] <= 0;
        ps_dv[1] <= 0;
    end else begin
        ps_dv[0] <= (i_data[W_DATA] & w_dv);
        ps_dv[1] <= ps_dv[0];
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        wb <= 0;
        w_dv <= 0;
        psum_buff <= 0;
    end else begin
        if(i_weight[W_DATA])begin
            wb <= i_weight[W_DATA-1 : 0];
            w_dv <= i_weight[W_DATA];
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end else begin
            wb <= wb;
            w_dv <= w_dv;
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end
    end
end

//16 bit output of product of weight and image
wire signed [(2 * W_DATA)-1 : 0] temp;

top_booth t2(
    .clk(i_clk),
    .a(i_data[W_DATA-1:0]),
    .b(wb),
    .c(temp)
);
assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{temp[(2*W_DATA)-1]}},{temp}});
assign o_p_sum[W_PSUM] = ps_dv[1];
assign o_weight = {i_weight[W_DATA],wb};
assign o_data = i_data;

endmodule

//Bottom pe block
module booth_bottom_pe_block #(parameter W_DATA = 8, W_PSUM = 19) (
    input i_clk,
    input i_rst,
    input [W_DATA : 0] i_weight,
    input [W_PSUM : 0] i_p_sum,
    input [W_DATA : 0] i_data,
    output [W_DATA : 0] o_data,
    output [W_PSUM : 0] o_p_sum
);

//Width for appending msb to mul_reg for addition in case of signed number
localparam W_APPEND = (W_PSUM - (2*W_DATA));
reg [W_DATA-1:0] wb = 0;           //register to store weight
reg [W_PSUM -1:0] psum_buff = 0;   //register to store partial sum
reg w_dv = 0;
reg [1:0] ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv[0] <= 0;
        ps_dv[1] <= 0;
    end else begin
        ps_dv[0] <= (i_data[W_DATA] & w_dv);
        ps_dv[1] <= ps_dv[0];
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        wb <= 0;
        w_dv <= 0;
        psum_buff <= 0;
    end else begin
        if(i_weight[W_DATA])begin
            wb <= i_weight[W_DATA-1:0];
            w_dv <= i_weight[W_DATA];
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end else begin
            wb <= wb;
            w_dv <= w_dv;
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end
    end
end

//16 bit output of product of weight and image
wire signed [(2 * W_DATA)-1 : 0] temp;

top_booth t3(
	.clk(i_clk),
	.a(i_data[W_DATA-1:0]),
	.b(wb),
	.c(temp)
);

assign o_data = i_data;
assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{temp[(2*W_DATA)-1]}},{temp}});
assign o_p_sum[W_PSUM] = ps_dv[1];
assign o_weight = {i_weight[W_DATA], wb};

endmodule
