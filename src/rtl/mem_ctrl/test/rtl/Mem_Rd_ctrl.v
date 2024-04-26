module Mem_Rd_ctrl (
    input clk,
    input rst,
    input select_rd,
    input rvalid_rd ,
    input rlast_rd ,
    input [255:0] rdata_in,
    output reg [255:0] rdata_out = 0
    //input [3:0] BLEN_rd
) ;

//reg [2:0] count_rd_blen = 0 ;
reg [1:0] state = 0 ;

localparam IDLE = 2'b00;
localparam MEM_DATA = 2'b01;
//localparam COUNT_BLEN = 2'b10;

always @ (posedge clk) begin 
    if (!rst) begin
        rdata_out <= 0 ;
        state <= IDLE ;
     //   count_rd_blen <= 0 ;
    end

    else begin 
        case (state)
            IDLE : begin 
                if (select_rd == 1) begin 
                    state <= MEM_DATA ;
                    rdata_out <= 0 ; 
                  //  count_rd_blen <= 0 ;
                end

                else 
                    state <= IDLE ; 
            end

            MEM_DATA : begin 
                if (rvalid_rd== 1) begin 
                    rdata_out <= rdata_in ;
                 //   count_rd_blen <= count_rd_blen + 1 ;
                    state <= MEM_DATA ;
                end
                
                else if (rlast_rd) begin 
                    rdata_out <= rdata_in ;
                    state <= IDLE ;
                end 
              
                else if (rvalid_rd && rlast_rd) begin
                    rdata_out <= rdata_in ;
                    state <= IDLE ;
                end 

                else begin 
                    rdata_out <= rdata_out ; 
                    state <= MEM_DATA ;
                end 
            end 

        endcase 
    end
end 

endmodule 