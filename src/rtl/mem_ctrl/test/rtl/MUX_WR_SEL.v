module MUX_WR_SEL (
    input clk,
    input rst, 
    input w_valid_1,
    input w_valid_2,
    input w_last1,
    input w_last2,
    input sel_in1,
    input sel_in2,
    input [255:0] data_in1,
    input [255:0] data_in2,
    output reg w_valid_out = 0 ,
    output reg w_last_out = 0,
    output reg [255:0] w_odata_sel = 0
);

always @ (posedge clk) begin 

    if (!rst) begin 
        w_valid_out <= 0 ;
        w_last_out <= 0 ;
        w_odata_sel <= 0 ;
    end 
    
    else begin 
        if (sel_in1 == 1) begin 
            w_valid_out <= w_valid_1;
            w_odata_sel <= data_in1 ;
            w_last_out <= w_last1 ;
        end 
        
        else if (sel_in2 == 1) begin
                w_valid_out <= w_valid_2;
                w_odata_sel <= data_in2;
                w_last_out <= w_last2 ;
        end 
            
        else begin 
            w_valid_out <= 0 ;
            w_odata_sel <= 0 ;
            w_last_out <=  0 ;
        end 
    end 
end 

endmodule 