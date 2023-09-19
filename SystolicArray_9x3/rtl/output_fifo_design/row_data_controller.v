/*
    Controlls the read enable signal of array of fifo that stores
    systolic array's row's output simultaneously into each fifo.
*/
module row_data_controller#(
    parameter ROW =9
)(
        input i_clk,
        input [ROW-1:0] i_fifo_empty,
        input [8:0] i_data_1,
        input [8:0] i_data_2,
        input [8:0] i_data_3,
        input [8:0] i_data_4,
        input [8:0] i_data_5,
        input [8:0] i_data_6,
        input [8:0] i_data_7,
        input [8:0] i_data_8,
        input [8:0] i_data_9,
        output [8:0] o_data,
        output [ROW-1:0] o_fifo_read_enable
    );

wire i_signal;
wire [3:0] data_select;
wire [3:0] rden_select; 

reg [3:0] counter =  0;
reg [2:0] state = 0;
reg [3:0] count = 0;


assign data_select = count;
assign rden_select = counter;
assign i_signal = (rden_select > 0) ? 1'b1 : 1'b0;

/*
    Handles read enable signal of fifo in array that stores 
    systolic array's rows output data.
*/
row_fifo_read_en#(
    .ROW(ROW)
) fifo_rden (
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
            if(counter == 4'd9)begin
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

/*
    Mux used to load data of the selected fifo from array
    into one fifo.
*/
row_fifo_data
fifo_data (
    .i_clk(i_clk),
    .i_sel(data_select),
    .i_data1 (i_data_1),
    .i_data2 (i_data_2),
    .i_data3 (i_data_3),
    .i_data4 (i_data_4),
    .i_data5 (i_data_5),
    .i_data6 (i_data_6),
    .i_data7 (i_data_7),
    .i_data8 (i_data_8),
    .i_data9 (i_data_9),
    .o_data (o_data)
    );
endmodule