//Accumulates output coming from pe blocks
module accumulator#(
    parameter COL = 4,
    parameter W_ACC = 32,
    parameter W_FC_CNT = 15,
    parameter W_PSUM = 19
)(
    input i_clk,
    input i_rst,
    input [W_FC_CNT-1 : 0] i_img_dim,
    input [(COL * (W_PSUM+1))-1 : 0] i_psum_data,
    output [COL-1 :0] o_dv,
    output [(COL * W_ACC)-1 : 0] o_data
);

genvar i;
generate
    for(i = 0; i < COL; i = i + 1) begin
        acc#(
            .W_ACC(W_ACC),   
            .COL(COL),
            .W_PSUM(W_PSUM),
            .W_FC_CNT(W_FC_CNT)
        ) accumulator_array (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_img_dim(i_img_dim),
            .i_psum(i_psum_data[(((W_PSUM + 1) * (COL - i))-1) -: (W_PSUM+1)]),
            .o_data(o_data[((W_ACC * (COL - i))-1) -: W_ACC]),
            .o_dv(o_dv[(COL - i)-1])
        );
    end
endgenerate
    
endmodule

module acc#(
    parameter W_ACC = 32,   
    parameter COL = 4,
    parameter W_FC_CNT = 15,   
    parameter W_PSUM = 19
)(
    input i_clk,
    input i_rst,
    input [W_FC_CNT-1 : 0] i_img_dim,
    input [W_PSUM:0] i_psum,    
    output [W_ACC-1 : 0] o_data,
    output o_dv
);

localparam W_IN_DATA = (W_ACC - W_PSUM);

wire [W_ACC -1 : 0] w_data;
assign w_data = {{W_IN_DATA{i_psum[W_PSUM-1]}},{i_psum[W_PSUM-1 : 0]}};
wire p_sum_dv;
assign p_sum_dv = i_psum[W_PSUM];

reg [31:0] acc_reg = 0;
reg [W_FC_CNT-1 : 0] counter = 0;
reg dv = 0;
reg [W_ACC-1 : 0] data = 0;
reg [1:0] state = 0;

assign o_data = data;
assign o_dv = dv;

always @(posedge i_clk)begin
    if(i_rst)begin
        data <= 0;
        dv <= 0;
        counter <= 0;
        acc_reg <= 0;
        state <= 0;
    end else begin
        case (state)
            0:begin
                acc_reg <= 0;
                dv <= 0;
                counter <= 0;
                data <= data;
                if(i_psum[W_PSUM])begin
                    acc_reg <= w_data + acc_reg;
                    counter <= counter + 1;
                    state <= 1;
                end else begin
                    state <= 0;
                end
            end

            1: begin
                if(counter == i_img_dim)begin
                    data <= acc_reg;
                    dv <= 1'b1;
                    counter <= 0;
                    acc_reg = 0;
                    state <= 0;
                end else begin
                    acc_reg <= w_data + acc_reg;
                    counter <= counter + 1;
                end
            end

            default: state <= 0;
        endcase
    end
end

endmodule