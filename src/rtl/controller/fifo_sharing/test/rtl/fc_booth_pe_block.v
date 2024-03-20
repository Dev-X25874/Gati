module fc_booth_top_pe_block#(
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

reg [W_PSUM-1 : 0] psum_buff = 0;   //register to store partial sum
reg ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv <= 0;
    end else begin
        ps_dv <= (i_data[W_DATA] & i_weight[W_DATA]);
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        psum_buff <= 0;    
    end else begin
        if(i_weight[W_DATA])begin
            psum_buff <= 0;
        end else begin
            psum_buff <= 0;
        end
    end
end

//Computing data

(* syn_use_dsp = "no" *) reg  signed [(2 * W_DATA)-1 : 0] temp;

always @(posedge i_clk)
begin
   temp<=($signed(i_weight[W_DATA-1 : 0]) * $signed(i_data[W_DATA-1:0]));

end
/*
booth_top t1(
    .clk(i_clk),
    .a(i_data[W_DATA-1:0]),
    .b(i_weight[W_DATA-1 : 0]),
    .c(temp)
);
*/
assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{temp[(2*W_DATA)-1]}},{temp}});
assign o_data = i_data;
assign o_p_sum[W_PSUM] = ps_dv;
assign o_weight = {i_weight[W_DATA],i_weight[W_DATA-1 : 0]};

endmodule

//Middle pe blocks
module fc_booth_middle_pe_block  #(parameter W_DATA = 8, W_PSUM = 19) (
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

reg [W_PSUM -1:0] psum_buff = 0;   //register to store partial sum
reg ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv <= 0;
    end else begin
        ps_dv <= (i_data[W_DATA] & i_weight[W_DATA]);
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        psum_buff <= 0;
    end else begin
        if(i_weight[W_DATA])begin
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end else begin
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end
    end
end

//Computing data
(* syn_use_dsp = "no" *) reg  signed [(2 * W_DATA)-1 : 0] temp;

always @(posedge i_clk)
begin
    temp<=($signed(i_weight[W_DATA-1 : 0]) * $signed(i_data[W_DATA-1:0]));

end
/*
booth_top t1(
    .clk(i_clk),
    .a(i_data[W_DATA-1:0]),
    .b(i_weight[W_DATA-1 : 0]),
    .c(temp)
);
*/
assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{temp[(2*W_DATA)-1]}},{temp}});
assign o_p_sum[W_PSUM] = ps_dv;
assign o_weight = {i_weight[W_DATA],i_weight[W_DATA-1 : 0]};
assign o_data = i_data;

endmodule

//Bottom pe block
module fc_booth_bottom_pe_block #(parameter W_DATA = 8, W_PSUM = 19) (
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
reg [W_PSUM -1:0] psum_buff = 0;   //register to store partial sum
reg ps_dv = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv <= 0;
    end else begin
        ps_dv <= (i_data[W_DATA] & i_weight[W_DATA]);
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        psum_buff <= 0;
    end else begin
        if(i_weight[W_DATA])begin
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end else begin
            psum_buff <= i_p_sum[W_PSUM-1 : 0];
        end
    end
end

//Computing data
(* syn_use_dsp = "no" *) reg  signed [(2 * W_DATA)-1 : 0] temp;

always @(posedge i_clk)
begin
   temp<=($signed(i_weight[W_DATA-1 : 0]) * $signed(i_data[W_DATA-1:0]));

end
/*
booth_top t1(
    .clk(i_clk),
    .a(i_data[W_DATA-1:0]),
    .b(i_weight[W_DATA-1 : 0]),
    .c(temp)
);
*/
assign o_data = i_data;
assign o_p_sum[W_PSUM-1 : 0] = (psum_buff + {{W_APPEND{temp[(2*W_DATA)-1]}},{temp}});
assign o_p_sum[W_PSUM] = ps_dv;
assign o_weight = {i_weight[W_DATA], i_weight[W_DATA-1 : 0]};

endmodule
