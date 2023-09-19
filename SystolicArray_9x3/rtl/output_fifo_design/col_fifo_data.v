/*
   Loads data of selected fifo from it's array 
   into one fifo.
*/
module col_fifo_data(
    input i_clk,
    input [1:0] i_sel,
    input [8:0] i_data1,
    input [8:0] i_data2,
    input [8:0] i_data3, 
    output [8:0] o_data
    );
    
    reg [8:0] data = 0;
    
    assign o_data = data;
    
    always @(*)begin
        case(i_sel)
            0: begin
                data <= 0;
            end

            1: begin
                data <= i_data1;
            end

            2: begin
                data <= i_data2;
            end

            3: begin
                data <= i_data3;
            end
         
            
            default: begin
                data <= 0;
            end                  
        endcase
    end

endmodule
