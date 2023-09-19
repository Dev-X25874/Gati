/*
    Array of relu modules used for clipping 32 bits of
    column's output of systolic array into 8 bits, so that
    it can get stored into fifo.
    relu_8 module used here can be found in Relu folder
*/
module col_relu_array#(
    parameter W_DATA = 8,
    parameter COL = 3
)(
    input i_clk,
    input [COL-1:0] in_data_valid,
    input [(COL * 32)-1 : 0] data_in,
    output [W_DATA-1:0] data_out_1,
    output [W_DATA-1:0] data_out_2,
    output [W_DATA-1:0] data_out_3,
    output [COL-1:0] out_data_valid
);

    wire [31:0] data1;
    wire [31:0] data2;
    wire [31:0] data3;

    wire [8:0] o_data_1;
    wire [8:0] o_data_2;
    wire [8:0] o_data_3;

    assign data3 = data_in[31:0];
    assign data2 = data_in[63:32];
    assign data1 = data_in[95:64];

    assign out_data_valid = {o_data_1[8], o_data_2[8], o_data_3[8]};

    assign data_out_1 = o_data_1[7:0];
    assign data_out_2 = o_data_2[7:0];
    assign data_out_3 = o_data_3[7:0];

    genvar i;
    generate
        for(i = 0; i < COL; i = i +1)begin : RELU_GEN
            
            if(i == 0) begin
                relu_8 relu_inst1(
                    .i_data(data1),
                    .clk(i_clk),
                    .o_data(o_data_1), //Output of the Relu
                    .data_valid(in_data_valid[2])
                );
            end

            if(i == 1) begin
                relu_8 relu_inst2(
                    .i_data(data2),
                    .clk(i_clk),
                    .o_data(o_data_2), //Output of the Relu
                    .data_valid(in_data_valid[1])
                );
            end            

            if(i == 2) begin
                relu_8 relu_inst3(
                    .i_data(data3),
                    .clk(i_clk),
                    .o_data(o_data_3), //Output of the Relu
                    .data_valid(in_data_valid[0])
                );
            end            
        end
    endgenerate

endmodule