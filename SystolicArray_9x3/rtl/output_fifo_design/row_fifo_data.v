/*
    Loads the data of selected fifo from it's array, into one fifo
*/
module row_fifo_data(
    input i_clk,
    input [3:0] i_sel,
    input [8:0] i_data1,
    input [8:0] i_data2,
    input [8:0] i_data3,
    input [8:0] i_data4,
    input [8:0] i_data5,
    input [8:0] i_data6,
    input [8:0] i_data7,
    input [8:0] i_data8,
    input [8:0] i_data9,        
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

            4: begin
                data <= i_data4;
            end

            5: begin
                data <= i_data5;
            end

            6: begin
                data <= i_data6;
            end 

            7: begin
                data <= i_data7;
            end

            8: begin
                data <= i_data8;
            end

            9: begin
                data <= i_data9;
            end                        
            
            default: begin
                data <= 0;
            end                  
        endcase
    end

endmodule
