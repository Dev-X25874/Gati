/*
    Handle signals to load inputs(weights) into an array of fifo 
    which send those weights from top(north) into systolic array's columns
*/
module col_buf_controller#(
    parameter COL = 3,
    parameter ROW = 9,
    parameter W_ADDR = 8
)(  input i_clk,
    input i_fifo_empty,
    input [W_ADDR : 0] occupants,
    output reg o_read_enable = 0,
    output reg sr_enable = 0,
    output reg [1:0] state = 0
);

reg [($clog2(ROW * COL)) -1: 0] counter = 0;

always @(posedge i_clk)begin
  case (state)
    0: begin
        counter <= 0;
        sr_enable <= 1'b0;
        o_read_enable <= 1'b0;
        //fifo should not be empty and must have atleast one data for each column
        if(i_fifo_empty == 0)
            state <= 1;
    end 

    1: begin
        if(occupants == COL)begin
            state <= 2;
        end
    end

    2: begin
        o_read_enable <= 1'b1;
        sr_enable <= 1'b1;
        if(counter == (COL-1))begin
            state <= 3;
        end else begin
            counter <= counter + 1;
        end
    end
    
    3: begin
        o_read_enable <= 1'b0;
        sr_enable <= 1'b0;
        counter <= 0;
        state <= 0;
    end
    default: begin
        state <= 0;
    end 
  endcase  
end
endmodule