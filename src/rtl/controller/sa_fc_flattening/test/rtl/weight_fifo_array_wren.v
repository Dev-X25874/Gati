/*
    Asserts write enable signal of all the fifo one by one, 
    in weight fifo array.
*/
module weight_fifo_array_wren#(
    parameter N_FIFO = 3
)(
    input clk,
    input rst,
    input i_enable,
    output [N_FIFO-1:0] o_data 
);
    
reg [N_FIFO-1:0] counter = 0;
reg [N_FIFO-1:0] data = 0;

assign o_data = data;

always @(posedge clk) begin
    if(rst)begin
        counter <= 0;
        data <= 0;
    end else begin
        if(i_enable) begin
            if (counter == N_FIFO - 1)
                counter <= 0;
            else
                counter <= counter + 1;
                
            data[counter] <= 1;
            
            if(N_FIFO > 1) begin
                if (counter == 0)
                    data[N_FIFO - 1] <= 0;
                else
                    data[counter - 1] <= 0;
            end
        end else begin
            counter <= 0;
            data <= 0;
        end
    end
end
    
endmodule