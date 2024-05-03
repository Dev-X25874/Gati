/* This memory module is used in the synchronous fifo which is used for checking validity of data.
It checks whether the correct data is read from memory or not */
module memory_valid
    ( 
      wr_clk,  
      wr_rst,  
      rd_clk,  
      rd_rst,  
      wdata,  
      waddr,  
      raddr,  
      wr_en,
      rd_en,
      rdata,
      valid,
      empty_flag,
      full_flag
     );

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8;
parameter RAM_DEPTH = (1 << ADDR_WIDTH);

input wr_rst; 
input wr_clk; 
input rd_rst; 
input rd_clk;
input [DATA_WIDTH-1:0] wdata; 
input [ADDR_WIDTH-1:0] waddr; 
input [ADDR_WIDTH-1:0] raddr; 
input wr_en;
input rd_en;
input empty_flag;
input full_flag;
output [DATA_WIDTH-1:0] rdata; 
output valid;

reg [DATA_WIDTH-1:0] mem [RAM_DEPTH-1:0];
reg [DATA_WIDTH-1:0] rdata = 0;
reg dv = 0;

assign valid = dv;

always @(posedge rd_clk)
    if(rd_rst)begin
        dv <= 0;
        rdata <= 0;
    end else begin
        if(rd_en & (!empty_flag)) begin
        rdata <= mem [raddr];
        dv <= 1'b1;
        end 
        else begin
        rdata <= rdata;
        dv <= 1'b0;
    end
end

always @(posedge wr_clk)
if(wr_rst)begin
    mem[waddr] <= 0;
end else begin
    if(wr_en & (!full_flag))  
        mem[waddr] <= wdata;  
end
endmodule
