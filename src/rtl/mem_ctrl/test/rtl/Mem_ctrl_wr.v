module Mem_ctrl_wr (
    input clk,
    input rst,
    input select,
    input wready_w,
    output reg wvalid_w = 0,
    output reg wlast_w = 0,
    input [255:0] wdata_in,
    output reg [255:0] wdata_out = 0,
    input [3:0] BLEN_w
) ;

reg [2:0] count_blen = 0 ;
reg [1:0] state = 0 ;

localparam IDLE = 2'b00;
localparam MEM_DATA = 2'b01;
localparam COUNT_BLEN = 2'b10;

always @ (posedge clk) begin 
    if (!rst) begin 
        wvalid_w <= 0;
        wlast_w <= 0 ;
        wdata_out <= 0 ;
        count_blen <= 0 ;
    end

    else begin 
        case (state)
            IDLE : begin 
                if (select == 1) begin 
                    state <= MEM_DATA ;
                    wdata_out <= 0 ; 
                    count_blen <= 0 ;
                end

                else 
                    state <= IDLE ; 
            end

            MEM_DATA : begin 
                if (wready_w == 1) begin 
                    wvalid_w <= 1 ;
                    wdata_out <= wdata_in ;
                    count_blen <= count_blen + 1 ;
                    
                    if (count_blen == BLEN_w) begin
                        wlast_w <= 1 ;
                        wdata_out <= wdata_in ;
                        state <= BLEN_w ;
                    end

                end

                else begin 
                    wvalid_w <= wvalid_w ;
                    wdata_out <= wdata_out ; 
                    state <= MEM_DATA ;
                end 
            end 

            COUNT_BLEN : begin 
                wvalid_w <= 0 ; 
                wlast_w <= 0 ;
                state <= IDLE ;
                wdata_out <= 0 ;
            end 

        endcase 
    end
end 

endmodule 
