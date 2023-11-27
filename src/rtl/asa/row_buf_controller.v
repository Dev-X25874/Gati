/*
    Handle signals to load inputs(data) into an array of fifo 
    which send those data from side(west) into systolic array's columns
*/
module row_buf_controller#(
    parameter COL = 3,
    parameter ROW = 9,
    parameter W_ADDR = 8
)(  input i_clk,
    input i_fifo_empty,
    input [W_ADDR : 0] occupants,
    output reg o_read_enable = 0,
    output reg sr_enable = 0
);

reg [1:0] state = 0;
reg [3:0] counter = 0;

always @(posedge i_clk)begin
  case (state)
    0: begin
        counter <= 0;
        //fifo should not be empty and must have atleast one occupant for each row
        if(i_fifo_empty == 0)
            state <= 1;
        else
            state <= 0;
    end 

    1: begin
        if(occupants == 9)begin
            state <= 2;
        end
    end

    2: begin
        o_read_enable <= 1'b1;
        sr_enable <= 1'b1;
        if(counter == 9)begin
            state <= 0;
            o_read_enable <= 1'b0;
            sr_enable <= 1'b0;
        end else begin
            counter <= counter + 1;
        end
    end
    
    default: begin
        state <= 0;
    end
    
  endcase  
end

endmodule