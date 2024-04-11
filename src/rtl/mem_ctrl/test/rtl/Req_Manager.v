module Req_Manager #(
    parameter NUM_PORTS = 4,
    parameter DATA_WIDTH = 41,
    parameter ADDRESS_WIDTH = 32,
    parameter BURST_WIDTH = 4,
    parameter BIN_WIDTH = $clog2(NUM_PORTS),
    parameter PORT_ID_WIDTH = 4
) (
    input clk,
    input rst,
    input [NUM_PORTS-1:0] req_in,
    output reg [NUM_PORTS-1:0] req_out = 0,
    input [(NUM_PORTS*DATA_WIDTH)-1:0] in_data_div,
    output  [ADDRESS_WIDTH-1:0] o_addr_div ,
    output  [BURST_WIDTH-1:0] o_burst_div ,
    output  [PORT_ID_WIDTH-1:0] o_port_div ,
    output  o_rw_div ,
    input [NUM_PORTS-1:0] rd_valid ,
    output reg valid_req = 0
);

onehot_to_bin #(
    .ONEHOT_WIDTH (NUM_PORTS),
    .BIN_WIDTH (BIN_WIDTH)
) onehot_inst (
    .onehot (rd_valid),
    .bin (rd_sel_binary)
);

assign o_addr_div = data_sel[DATA_WIDTH-1:PORT_ID_WIDTH+BURST_WIDTH+1] ;
assign o_burst_div = data_sel [DATA_WIDTH-ADDRESS_WIDTH-1:BURST_WIDTH+1];
assign o_port_div = data_sel [DATA_WIDTH-ADDRESS_WIDTH-BURST_WIDTH-1:DATA_WIDTH-ADDRESS_WIDTH-BURST_WIDTH-PORT_ID_WIDTH];
assign o_rw_div = data_sel [DATA_WIDTH-ADDRESS_WIDTH-BURST_WIDTH-PORT_ID_WIDTH-1];

always @(*) begin
    req_out = req_in;
end

wire [BIN_WIDTH-1:0] rd_sel_binary;
reg [(DATA_WIDTH*NUM_PORTS)-1:0] data_sel = 0 ;

always @ (posedge clk) begin 
    if (!rst) begin 
        valid_req <= 0 ;
    
    end 
    
    else begin 
        if(rd_valid) begin 
            data_sel <= in_data_div [DATA_WIDTH*(NUM_PORTS-rd_sel_binary) -1 -: DATA_WIDTH] ;
            valid_req <= 1'b1 ;
        end 
        
        else begin 
            data_sel <= 0 ;
            valid_req <= 0 ;
        end 
    end 
    
end 

endmodule 
        
