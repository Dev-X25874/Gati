module Req_Manager #(
    parameter NUM_PORTS = 4,
    parameter DATA_WIDTH = 41,
    parameter ADDRESS_WIDTH = 32,
    parameter BURST_WIDTH = 4,
    parameter PORT_ID_WIDTH = 4
) (
input clk,
input rst,
input [NUM_PORTS-1 : 0] req_in,
output reg [NUM_PORTS-1 :0] req_out = 0,
input [(NUM_PORTS*DATA_WIDTH)-1 : 0] in_data_div,
output reg [ADDRESS_WIDTH-1 : 0] o_addr_div = 0,
output reg [BURST_WIDTH-1 : 0] o_burst_div = 0,
output reg [PORT_ID_WIDTH-1:0] o_port_div = 0,
output reg o_rw_div = 0,
input [NUM_PORTS-1 : 0] rd_valid 
);

always @ (posedge clk) begin 
    if (!rst) begin 
       // o_addr_div <= 0;
       // o_burst_div <= 0;
       // o_port_div <= 0 ;
       // o_rw_div <= 0; 
        req_out <= 0;
     end 
     
     else begin 
        if (req_in != 0) 
            req_out <= req_in  ;
        else 
            req_out <= 0 ;
        
     end 
end 

  
always @ (posedge clk) begin 
        if (!rst) begin
            o_addr_div <= 0;
            o_burst_div <= 0;
            o_port_div <= 0;
            o_rw_div <= 0;
        end 
        else begin
            if (rd_valid != 0) begin
                o_addr_div <= in_data_div[(rd_valid-1)*DATA_WIDTH +: ADDRESS_WIDTH];
                o_burst_div <= in_data_div[(rd_valid-1)*DATA_WIDTH + ADDRESS_WIDTH +: BURST_WIDTH];
                o_port_div <= in_data_div[(rd_valid-1)*DATA_WIDTH + ADDRESS_WIDTH + BURST_WIDTH +: PORT_ID_WIDTH];
                o_rw_div <= in_data_div[(rd_valid-1)*DATA_WIDTH + ADDRESS_WIDTH + BURST_WIDTH + PORT_ID_WIDTH];
            end 
            
            else begin 
                o_addr_div <= 0 ;
                o_burst_div <= 0 ;
                o_port_div <= 0 ;
                o_rw_div <= 0 ;
            end 
         end 
           /* 
             if (rd_valid != 0) begin
                o_addr_div <= in_data_div[ADDRESS_WIDTH*(rd_valid-1) +: ADDRESS_WIDTH];
                o_burst_div <= in_data_div[(NUM_PORTS*ADDRESS_WIDTH) + BURST_WIDTH*(rd_valid-1) +: BURST_WIDTH];
                o_port_div <= in_data_div[(NUM_PORTS*ADDRESS_WIDTH) + (NUM_PORTS*BURST_WIDTH) + PORT_ID_WIDTH*(rd_valid-1) +: PORT_ID_WIDTH];
                o_rw_div <= in_data_div[(NUM_PORTS*DATA_WIDTH) - 1 - ((rd_valid-1) * DATA_WIDTH) + BURST_WIDTH + PORT_ID_WIDTH ];
            end
            else begin 
                o_addr_div <= 0 ;
                o_burst_div <= 0 ;
                o_port_div <= 0;
                o_rw_div <= 0;
           end */
   end 
endmodule


            /*if (rd_valid != 0) begin 
                o_addr_div <= in_data_div [DATA_WIDTH-1 : BURST_WIDTH+PORT_ID_WIDTH] ;
                o_burst_div <= in_data_div[(DATA_WIDTH-ADDRESS_WIDTH) : BURST_WIDTH+1];
                o_port_div <= in_data_div [(DATA_WIDTH-ADDRESS_WIDTH-BURST_WIDTH): 1 ];
                o_rw_div <= in_data_div [DATA_WIDTH-ADDRESS_WIDTH-BURST_WIDTH-PORT_ID_WIDTH:0];
            end */

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/*
module Req_Manager #(
    parameter NUM_PORTS = 4,
    parameter DATA_WIDTH = 41,
    parameter ADDRESS_WIDTH = 32,
    parameter BURST_WIDTH = 4,
    parameter PORT_ID_WIDTH = 4
) (
    input clk,
    input rst,
    input [NUM_PORTS-1 : 0] req_in,
    output reg [NUM_PORTS-1 :0] req_out = 0,
    input [(NUM_PORTS*DATA_WIDTH)-1 : 0] in_data_div,
    output reg [ADDRESS_WIDTH-1 : 0] o_addr_div = 0,
    output reg [BURST_WIDTH-1 : 0] o_burst_div = 0,
    output reg [PORT_ID_WIDTH-1:0] o_port_div = 0,
    output reg o_rw_div = 0,
    input [NUM_PORTS-1 : 0] rd_valid 
);

always @ (posedge clk) begin 
    if (!rst) begin 
        req_out <= 0;
    end 
    else begin 
        if (req_in != 0) 
            req_out <= req_in;
        else 
            req_out <= req_out; // Preserve req_out when req_in is not active
    end 
end 

always @ (posedge clk) begin 
    if (!rst) begin
        o_addr_div <= 0;
        o_burst_div <= 0;
        o_port_div <= 0;
        o_rw_div <= 0;
    end 
    else begin
        if (rd_valid != 0 && req_in[rd_valid-1]) begin
            o_addr_div <= in_data_div[(rd_valid-1)*DATA_WIDTH +: ADDRESS_WIDTH];
            o_burst_div <= in_data_div[(rd_valid-1)*DATA_WIDTH + ADDRESS_WIDTH +: BURST_WIDTH];
            o_port_div <= in_data_div[(rd_valid-1)*DATA_WIDTH + ADDRESS_WIDTH + BURST_WIDTH +: PORT_ID_WIDTH];
            o_rw_div <= in_data_div[(rd_valid-1)*DATA_WIDTH + ADDRESS_WIDTH + BURST_WIDTH + PORT_ID_WIDTH];
        end 
        else begin 
            // Reset output registers when rd_valid is not active or req_in is not high for the corresponding port
            o_addr_div <= 0;
            o_burst_div <= 0;
            o_port_div <= 0;
            o_rw_div <= 0;
        end
    end
end

endmodule*/


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
module req_manager #(
  parameter GRANT_WIDTH = 4,
  parameter ADDRESS_WIDTH = 32,
  parameter RW_ENABLE_WIDTH = 1,
  parameter BURST_LENGTH_WIDTH = 4
)
(
  input clk ,
  input rst,
 // input  [GRANT_WIDTH-1:0] grant,
  input [ADDRESS_WIDTH-1:0] in_address,
  input [RW_ENABLE_WIDTH-1:0] in_rw_enable,
  input [BURST_LENGTH_WIDTH-1:0] in_burst_length,
  input [GRANT_WIDTH-1:0] grant_port_id,
  output [RW_ENABLE_WIDTH-1:0] rd_en,
  output reg [ADDRESS_WIDTH-1:0] stored_address,
  output reg [GRANT_WIDTH-1:0] stored_port_id,
  output reg [RW_ENABLE_WIDTH-1:0] stored_rw_enable,
  output reg [BURST_LENGTH_WIDTH-1:0] stored_burst_length
);

 always @(posedge clk) begin
  if (!rst) begin 
    stored_address <= 0;
    stored_burst_length <= 0;
    stored_port_id <= 0;
    stored_rw_enable <= 0;
  end 
  
  else begin 
    if (rd_en) begin
      stored_address = in_address;
      stored_port_id = grant_port_id;
      stored_rw_enable = in_rw_enable;
      stored_burst_length = in_burst_length;
    end
  end
end 

endmodule
*/