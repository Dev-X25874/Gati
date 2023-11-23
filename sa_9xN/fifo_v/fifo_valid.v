/*  Apart from storing data, this synchronouns fifo checks the validity of data being read from the memory.
    This is achieved by the output port data_valid of this module   */
module fifo_valid (
             clk,
             rst_n ,
             data_in,
             we,
             re,
             data_out,
             occupants,
             empty,
             full,
             data_valid
);

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8; 
parameter RAM_DEPTH = (1 << ADDR_WIDTH);

input clk;
input rst_n;
input we;
input re;
input [DATA_WIDTH-1:0] data_in;
output reg [ADDR_WIDTH:0] occupants = 0;
output                 full;
output                 empty;
output [DATA_WIDTH-1:0] data_out;
output data_valid;

wire [DATA_WIDTH-1:0]   data_ram;
reg [ADDR_WIDTH:0]      wr_pointer = 0;
reg [ADDR_WIDTH:0]      rd_pointer = 0;
wire dv;

//data will only be considered valid if it is read from a non-empty memory of fifo
//assign data_valid = (~empty) ? dv : 1'b0;

always @ (posedge clk) begin
    if (~rst_n) begin
        wr_pointer <= 0;
        rd_pointer <= 0;
        occupants <= 0;
    end else begin
        if (we) wr_pointer <= wr_pointer + 1;
        if (re) rd_pointer <= rd_pointer + 1;
        if (re && !we && (occupants != 0)) occupants <= occupants - 1;
        else if (we && !re && (occupants != RAM_DEPTH)) occupants <= occupants + 1;
    end // else: !if(~rst_n)
end // always @ (posedge clk)

assign data_out = data_ram;
assign full = (occupants == (RAM_DEPTH-1));
assign empty = (occupants == 0);

memory_valid #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .RAM_DEPTH(RAM_DEPTH)
) memory_in0 (
    .wr_clk (clk),
    .rd_clk (clk),
    .wr_rst_n (rst_n),
    .rd_rst_n (rst_n),						    
    .waddr (wr_pointer),
    .wdata (data_in),
    .wr_en (we),
    .rd_en (re),
    .raddr (rd_pointer),
    .rdata (data_ram),
    .valid(data_valid)
);     

endmodule
