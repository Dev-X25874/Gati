//Processing elements (PE) of first row in SA
module sa_top_pe_block#(
    parameter W_PSUM = 19,
    parameter W_DATA = 8
)(  input i_clk,
    input i_rst,
    input [W_DATA :0] i_weight,
    input [W_DATA :0] i_data,
    output [W_DATA :0] o_weight,
    output [W_PSUM :0] o_p_sum,
    output [W_DATA :0] o_data
);
//Width for appending msb to mul_reg for addition in case of signed number
localparam W_APPEND = (W_PSUM - (2*W_DATA));

reg [W_DATA - 1:0] wb = 0;           //register store weight
reg [W_PSUM - 1:0] psum_buff = 0;   //register store partial sum
reg w_dv = 0;
reg ps_dv_delay = 0;
reg [1:0] ps_dv = 0;
reg [(2 * W_DATA)-1 : 0] mul_out=0;
reg signed [(2 * W_DATA)-1 : 0] mul_reg = 0;
always @(posedge i_clk) begin
    if(i_rst)begin
        mul_reg <= 0;
        mul_out <= 0;
    end else begin
        mul_reg <= ($signed(i_data[W_DATA-1 : 0]) * $signed(wb));
        mul_out <= mul_reg;
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv[0] <= 0;
        ps_dv[1] <= 0;
        ps_dv_delay <= 0;
    end else begin
        ps_dv[0] <= (i_data[W_DATA] & w_dv);
        ps_dv[1] <= ps_dv[0];    
        ps_dv_delay <= ps_dv[1];
    end
end

assign o_p_sum[W_PSUM] = ps_dv_delay;
assign o_p_sum[W_PSUM-1 : 0] = psum_buff + {{W_APPEND{mul_out[(2*W_DATA)-1]}},{mul_out}};
assign o_weight = {i_weight[W_DATA], wb};
assign o_data = i_data;

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

endmodule

//Middle pe blocks
module sa_pe_block#(
    parameter W_PSUM = 19,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_rst,
    input [W_DATA :0] i_weight,
    input [W_PSUM :0] i_p_sum,
    input [W_DATA :0] i_data,
    output [W_DATA :0] o_data,
    output [W_DATA :0] o_weight,
    output [W_PSUM :0] o_p_sum
);

//Width for appending msb to mul_reg for addition in case of signed number
localparam W_APPEND = (W_PSUM - (2*W_DATA));

reg [W_DATA - 1:0] wb = 0;           //register store weight
reg [W_PSUM - 1:0] psum_buff = 0;   //register store partial sum
reg w_dv = 0;
reg [1:0] ps_dv = 0;
reg [(2 * W_DATA)-1:0] mul_out = 0;
reg signed [(2 * W_DATA)-1 : 0] mul_reg = 0;
reg ps_dv_delay = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        mul_reg <= 0;
        mul_out <= 0;
    end else begin
        mul_reg <= ($signed(i_data[W_DATA-1 : 0]) * $signed(wb));
        mul_out <= mul_reg;
    end
end

assign o_p_sum[W_PSUM-1 : 0] = (psum_buff +  {{W_APPEND{mul_out[(2*W_DATA)-1]}},{mul_out}});   //32 bit computed output
assign o_p_sum[W_PSUM] = ps_dv_delay;
assign o_weight = {i_weight[W_DATA], wb};
assign o_data = i_data;

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv[0] <= 0;
        ps_dv[1] <= 0;
        ps_dv_delay <= 0;
    end else begin
        ps_dv[0] <= (i_data[W_DATA] & w_dv);
        ps_dv[1] <= ps_dv[0];
        ps_dv_delay <= ps_dv[1];
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
endmodule

//Bottom pe block
module sa_bottom_pe_block#(
    parameter W_PSUM = 19,
    parameter W_DATA = 8
)(
    input i_clk,
    input i_rst,
    input [W_DATA :0] i_weight,
    input [W_PSUM :0] i_p_sum,
    input [W_DATA :0] i_data,
    output [W_DATA :0] o_data,
    output [W_PSUM:0] o_p_sum
);

//Width for appending msb to mul_reg for addition in case of signed number
localparam W_APPEND = (W_PSUM - (2*W_DATA));

reg [W_DATA - 1:0] wb = 0;           //register store weight
reg [W_PSUM - 1:0] psum_buff = 0;   //register store partial sum
reg w_dv = 0;
reg [1:0] ps_dv = 0;
reg ps_dv_delay= 0;
reg [(2 * W_DATA)-1:0] mul_out = 0;
reg signed [(2 * W_DATA)-1 : 0] mul_reg = 0;

always @(posedge i_clk) begin
    if(i_rst)begin
        mul_reg <= 0;
        mul_out <= 0;
    end else begin
        mul_reg <= ($signed(i_data[W_DATA-1 : 0]) * $signed(wb));
        mul_out <= mul_reg;
    end
end

always @(posedge i_clk) begin
    if(i_rst)begin
        ps_dv[0] <= 0;
        ps_dv[1] <= 0;
        ps_dv_delay <= 0;
    end else begin
        ps_dv[0] <= (i_data[W_DATA] & w_dv);
        ps_dv[1] <= ps_dv[0];
        ps_dv_delay <= ps_dv[1];
    end
end

assign o_data = i_data;
assign o_p_sum[W_PSUM-1 : 0] = (psum_buff +  {{W_APPEND{mul_out[(2*W_DATA)-1]}},{mul_out}});   //32 bit computed output
assign o_p_sum[W_PSUM] = ps_dv_delay;

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
endmodule
