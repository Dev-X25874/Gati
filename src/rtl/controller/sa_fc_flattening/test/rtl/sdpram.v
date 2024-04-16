module  sdpram#(
    parameter DATA_WIDTH = 8,                 
    parameter ADDR_WIDTH = 9,
    parameter RAM_DEPTH = (1 << ADDR_WIDTH)
)(    
    input we,         
    input re,         
    input clk,
    input [DATA_WIDTH-1:0] data,      
    input [ADDR_WIDTH:0] read_addr,  
    input [ADDR_WIDTH:0] write_addr,   
    output reg [DATA_WIDTH-1:0] q     
);

reg [DATA_WIDTH-1:0] ram [RAM_DEPTH-1 : 0]; 
//reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH:0]; 

always @(posedge clk) begin
    if (we) begin 
        ram[write_addr] <= data;
    end
end

always @(posedge clk) begin
    if(re)begin
        q <= ram[read_addr];
    end
end

endmodule