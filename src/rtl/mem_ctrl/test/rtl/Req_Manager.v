module Req_Manager #(
    parameter NUM_PORTS = 4,
    parameter DATA_WIDTH = 41,
    parameter ADDRESS_WIDTH = 32,
    parameter BURST_WIDTH = 4,
    parameter BIN_WIDTH = $clog2(NUM_PORTS-1),
    parameter PORT_ID_WIDTH = 4
) (
    input clk,
    input rst,
    input [NUM_PORTS-1:0] req_in,
    output reg [NUM_PORTS-1:0] req_out = 0,
    input [(NUM_PORTS*DATA_WIDTH)-1:0] in_data_div,
    output reg [ADDRESS_WIDTH-1:0] o_addr_div = 0,
    output reg [BURST_WIDTH-1:0] o_burst_div = 0,
    output reg [PORT_ID_WIDTH-1:0] o_port_div = 0,
    output reg o_rw_div = 0,
  //  output  [NUM_PORTS-1 : 0] rd_sel_binary = 0 ,
    input [NUM_PORTS-1:0] rd_valid 
);

onehot_to_bin #(
    .ONEHOT_WIDTH (NUM_PORTS),
    .BIN_WIDTH (BIN_WIDTH)
) onehot_inst (
    .onehot (rd_valid),
    .bin (rd_sel_binary)
);


always @(*) begin
    req_out = req_in;
end

wire [1:0] rd_sel_binary ;

always @ (posedge clk) begin 
    if (!rst) begin
        o_addr_div <= 0;
        o_burst_div <= 0;
        o_port_div <= 0;
        o_rw_div <= 0;
    end 
    else begin
        // Select the active port based on rd_valid
            if (rd_sel_binary != 0) begin 
                // Use bitwise AND operation to select the active port  
                o_addr_div <= in_data_div[(rd_sel_binary-1) * DATA_WIDTH +: ADDRESS_WIDTH];
               // o_addr_div <= in_data_div[((rd_sel_binary-1) * DATA_WIDTH) + ADDRESS_WIDTH + BURST_WIDTH + PORT_ID_WIDTH];
                o_burst_div <= in_data_div[(rd_sel_binary * DATA_WIDTH) + ADDRESS_WIDTH +: BURST_WIDTH];
               // o_burst_div <= in_data_div[(rd_sel_binary * DATA_WIDTH) + ADDRESS_WIDTH+ PORT_ID_WIDTH +: BURST_WIDTH];
                o_port_div <= in_data_div[(rd_sel_binary * DATA_WIDTH) + ADDRESS_WIDTH + BURST_WIDTH +: PORT_ID_WIDTH];
              //  o_port_div <= in_data_div[(rd_sel_binary * DATA_WIDTH) + ADDRESS_WIDTH +: PORT_ID_WIDTH];
                o_rw_div <= in_data_div[(rd_sel_binary * DATA_WIDTH) + ADDRESS_WIDTH + BURST_WIDTH + PORT_ID_WIDTH];
               // o_rw_div <= in_data_div[(rd_sel_binary * DATA_WIDTH)];
            end
            else begin 
                // Reset outputs when there is no valid read request
                o_addr_div <= o_addr_div;
                o_burst_div <= o_burst_div;
                o_port_div <= o_port_div;
                o_rw_div <= o_rw_div;
            end
    end 
end 

endmodule