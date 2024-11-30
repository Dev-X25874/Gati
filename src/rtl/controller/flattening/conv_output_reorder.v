/*
    Reorder the output coming from convolution layer 
    in the desired way.
*/
module conv_output_reorder#(
    parameter N_BANK = 4,
    parameter N_BRAM = 8,
    parameter W_DATA = 8,
    parameter SHFT_REG_X = 4,
    parameter N_SA = 4,
    parameter DRAM_BW = 32
)(
    input clk,
    input rstn,
    input [(N_BANK * N_BRAM)-1 : 0] i_valid,
    input flatten,
    input [((N_BANK * N_BRAM) * W_DATA)-1 : 0] i_data,
    output [((N_BANK * N_BRAM) * W_DATA)-1 : 0] o_data,
    output data_valid
);

reg valid = 0;
reg [1:0] state = 0;
reg [(W_DATA * (N_BANK * N_BRAM))-1 : 0] data = 0;

wire [(W_DATA * (N_BANK * N_BRAM))-1 : 0] temp;

assign o_data = data;
assign data_valid = valid;

always @(posedge clk ) begin
    if(~rstn)begin
        data <= 0;        
        valid <= 0;
    end else begin
        if(i_valid)begin
            if(flatten)begin
                data <= temp;
                valid <= 1'b1;
            end else begin
                data <= i_data;
                valid <= 1'b1;
            end
        end else begin
            data <= data;
            valid <= 0;
        end
    end
end

localparam OFFSET = N_SA;
localparam UPPER_LOOP = N_SA;
localparam LOWER_LOOP = (DRAM_BW/(SHFT_REG_X*N_SA));

genvar i,j;
  generate
  for(i=0;i<UPPER_LOOP;i=i+1) begin
    for (j=0;j<LOWER_LOOP;j=j+1) begin
        localparam k = i * LOWER_LOOP + j;
        assign temp[(((SHFT_REG_X*W_DATA)*((DRAM_BW/SHFT_REG_X)- k))-1) -: SHFT_REG_X*W_DATA] =
        i_data[(((SHFT_REG_X*W_DATA)*(((DRAM_BW/SHFT_REG_X)-i)-(j*OFFSET)))-1) -: SHFT_REG_X*W_DATA];
    end
  end
  endgenerate

endmodule