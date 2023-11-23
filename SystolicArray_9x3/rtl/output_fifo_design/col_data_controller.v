/*
    Controller for handling read enable signal of fifo array that stores weights for column.
    It also fetches weights from array of fifo and stores it into one fifo
    while reading weights from all the fifo in array one by one.
*/
module col_data_controller#(
    parameter COL = 3
)(
        input i_clk,
        input [COL-1:0] i_fifo_empty,
        input [8:0] i_data_1,
        input [8:0] i_data_2,
        input [8:0] i_data_3,
        output [8:0] o_data,
        output [COL-1:0] o_fifo_read_enable
);

wire i_signal;
wire [1:0] data_select;
wire [1:0] rden_select; 

reg [1:0] counter =  0;
reg [2:0] state = 0;
reg [1:0] count = 0;


assign data_select = count;
assign rden_select = counter;
assign i_signal = (rden_select > 0) ? 1'b1 : 1'b0;

//Asserts read enable signal of one fifo (in fifo array) at a time
col_fifo_read_en#(
    .COL(COL)
) fifo_rden_col (
    .i_clk (i_clk),
    .i_data (i_signal),
    .i_sel (rden_select),
    .o_read_enable (o_fifo_read_enable)
    );

always @(posedge i_clk)begin
    count <= counter;
end

always @(posedge i_clk)begin
    case(state)
        0: begin
            if(~i_fifo_empty[0]) begin
                 counter <= 4'd1;
                 state <= 1;
            end
            else begin
                counter <= 4'd0;
                state <= 0;
            end
        end
        
        1: begin
            if(counter == 4'd3)begin
                state <= 0;
                counter <= 4'd0;
            end
            else begin
                counter <= counter + 1;
                state <= 1;
            end
            
        end
    endcase
end

//Asserting read enable signal for reading weights from fifo array
col_fifo_data
fifo_data (
    .i_clk(i_clk),
    .i_sel(data_select),
    .i_data1 (i_data_1),
    .i_data2 (i_data_2),
    .i_data3 (i_data_3),
    .o_data (o_data)
    );
endmodule
