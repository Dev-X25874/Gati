module Mem_Rd_ctrl (
    input clk,
    input rst,
    input select_rd,
    input rvalid_rd ,
    input rlast_rd ,
    input [255:0] rdata_in,
    output reg [255:0] rdata_out = 0,
    output reg data_valid = 0 
) ;

reg [255:0] delay_rd  = 0 ;

always @ (posedge clk) begin 
    if (!rst) begin 
        rdata_out <= 0 ;
        data_valid <=  0 ;
      
    end

    else begin 
          if ((select_rd == 1) && rvalid_rd) begin 
               rdata_out <= delay_rd ; 
               data_valid <=  1'b1;
           end

           else begin 
               rdata_out <= rdata_out ; 
               data_valid <=  0;
            end 
    end
end

//assign delay_rd = rdata_in ;
always  @ (posedge clk) begin 
     delay_rd <= rdata_in ;
end 

endmodule 

endmodule 