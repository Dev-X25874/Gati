module Mem_Rd_ctrl (
    input clk,
    input rst,
    input select_rd,
    input rvalid_rd ,
   // input rlast_rd ,
    input [255:0] rdata_in,
    output reg [255:0] rdata_out = 0,
    output reg data_valid = 0 
    //input [3:0] BLEN_rd
) ;

//reg [2:0] count_rd_blen = 0 ;
reg [1:0] state = 0 ;

//localparam IDLE = 2'b00;
//localparam MEM_DATA = 2'b01;
//localparam COUNT_BLEN = 2'b10;
 

always @ (posedge clk) begin 
    if (!rst) begin 
        rdata_out <= 0 ;
        data_valid <=  0 ;
       // state <= IDLE ;
     //   count_rd_blen <= 0 ;
    end

    else begin 
          if ((select_rd == 1) && rvalid_rd) begin 
              //state <= MEM_DATA ;
               rdata_out <= rdata_in ; 
               data_valid <=  1'b1;
               //  count_rd_blen <= 0 ;
           end

           else begin 
               rdata_out <= rdata_out ; 
               data_valid <=  0;
                   // state <= IDLE ; 
            end 
    end
end


endmodule 
