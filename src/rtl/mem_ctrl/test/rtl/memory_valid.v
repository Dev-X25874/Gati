module memory_valid
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
      rdata,
      valid,
      empty_flag,
      full_flag
     );

parameter DATA_WIDTH = 41;
parameter ADDR_WIDTH = 10;
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
input empty_flag;
input full_flag;
output [DATA_WIDTH-1:0] rdata; 
output valid;

reg [DATA_WIDTH-1:0] mem [RAM_DEPTH-1:0];
reg [DATA_WIDTH-1:0] rdata = 0;
reg dv = 0;

assign valid = dv;

always @(posedge rd_clk)
    if(rd_en & (!empty_flag)) begin
    rdata <= mem [raddr];
    dv <= 1'b1;
    end 
    else begin
    rdata <= rdata;
    dv <= 1'b0;
end

always @(posedge wr_clk)
    if(wr_en & (!full_flag))  
        mem[waddr] <= wdata;  

endmodule