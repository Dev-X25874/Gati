module memory
    ( 
      wr_clk,  
      wr_rst_n,  
      rd_clk,  
      rd_rst_n,  
      wdata,  
      waddr,  
      raddr,  
      wr_en,
      rd_en,
      rdata 	 
     );

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8;
parameter RAM_DEPTH = (1 << ADDR_WIDTH);

input wr_rst_n; 
input wr_clk; 
input rd_rst_n; 
input rd_clk;
input [DATA_WIDTH-1:0] wdata; 
input [ADDR_WIDTH-1:0] waddr; 
input [ADDR_WIDTH-1:0] raddr; 
input wr_en;
input rd_en;
output [DATA_WIDTH-1:0] rdata; 

reg [DATA_WIDTH-1:0] mem [RAM_DEPTH-1:0];
reg [DATA_WIDTH-1:0] rdata = 0;

always @(posedge rd_clk)
  if(rd_en)
    rdata <= mem [raddr];

always @(posedge wr_clk)
  if(wr_en)  
    mem[waddr] <= wdata;  
         
   
endmodule
