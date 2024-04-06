//Processing elements for first row in PE grid made using LUT multipliers
module lut_top_pe_block#(
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
reg ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv <= 0;
    end else begin
        ps_dv <= (i_data[W_DATA] & w_dv);
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
(* syn_use_dsp = "no" *) reg  signed [(2 * W_DATA)-1 : 0] mul_out;

always @(posedge i_clk) begin
    mul_out <= ($signed(i_data[W_DATA-1 : 0]) * $signed(wb));
end

assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{mul_out[(2*W_DATA)-1]}},{mul_out}});
assign o_data = i_data;
assign o_p_sum[W_PSUM] = ps_dv;
assign o_weight = {i_weight[W_DATA],wb};

endmodule

//Processing elements for rest of the rows in the grid made using LUT multipliers
module lut_pe_block  #(parameter W_DATA = 8, W_PSUM = 19) (
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
reg ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv <= 0;
    end else begin
        ps_dv <= (i_data[W_DATA] & w_dv);
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
(* syn_use_dsp = "no" *) reg  signed [(2 * W_DATA)-1 : 0] mul_out;

always @(posedge i_clk) begin
    mul_out <= ($signed(i_data[W_DATA-1 : 0]) * $signed(wb));
end

assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{mul_out[(2*W_DATA)-1]}},{mul_out}});
assign o_p_sum[W_PSUM] = ps_dv;
assign o_weight = {i_weight[W_DATA],wb};
assign o_data = i_data;

endmodule

//Processing elements for last row in the grid made using LUT multipliers
module lut_bottom_pe_block #(parameter W_DATA = 8, W_PSUM = 19) (
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
reg ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv <= 0;
    end else begin
        ps_dv <= (i_data[W_DATA] & w_dv);
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
(* syn_use_dsp = "no" *) reg  signed [(2 * W_DATA)-1 : 0] mul_out;

always @(posedge i_clk) begin
    mul_out <= ($signed(i_data[W_DATA-1 : 0]) * $signed(wb));
end

assign o_data = i_data;
assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{mul_out[(2*W_DATA)-1]}},{mul_out}});
assign o_p_sum[W_PSUM] = ps_dv;
assign o_weight = {i_weight[W_DATA], wb};

endmodule
