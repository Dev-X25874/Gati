/*  Apart from storing data, this synchronouns fifo checks the validity of data being read from the memory.
    This is achieved by the output port data_valid of this module   */
        module fifo_valid#(
            parameter DATA_WIDTH = 8,
            parameter ADDR_WIDTH = 8, 
            parameter RAM_DEPTH = (1 << ADDR_WIDTH)
        )(
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

input clk;
input rst_n;
input we;
input re;
input [DATA_WIDTH-1:0] data_in;
output reg [ADDR_WIDTH:0] occupants = 0;
output                 full;
output                 empty;
output [DATA_WIDTH-1:0] data_out;
output data_valid;  //data will only be considered valid if it is read from a non-empty memory of fifo

wire [DATA_WIDTH-1:0]   data_ram;
reg [ADDR_WIDTH:0]      wr_pointer = 0;
reg [ADDR_WIDTH:0]      rd_pointer = 0;

always @ (posedge clk) begin
   if (~rst_n) begin
       wr_pointer <= 0;
       rd_pointer <= 0;
       occupants <= 0;
   end else begin
       if (we & (!full)) begin
           wr_pointer <= wr_pointer + 1;
           occupants <= occupants + 1;
       end 
       
       if (re & (!empty)) begin
           rd_pointer <= rd_pointer + 1;
           occupants <= occupants - 1;
       end
   end
end

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
   .waddr (wr_pointer[ADDR_WIDTH-1:0]),
   .wdata (data_in),
   .wr_en (we),
   .rd_en (re),
   .raddr (rd_pointer[ADDR_WIDTH-1:0]),
   .rdata (data_ram),
   .valid(data_valid),
   .empty_flag(empty),
   .full_flag(full)
);     

endmodule
