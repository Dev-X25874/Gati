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
    case(state)
        0: begin
            counter <= 0;
            sr_enable <= 0;
            o_read_enable <= 0;
            if((occupants == (ROW * COL)) && (i_fifo_empty == 0))begin
                state <= 1;
            end
        end
        
        1: begin
            //if(counter == (ROW * COL)-1))begin
            if(counter == 8)begin  
              state <= 0;
            end else begin
                //state <= 2;
            o_read_enable <= 1'b1;
            sr_enable <= 1'b1;
            counter <= counter + 1;
            end
        end
        /*
        2: begin
            o_read_enable <= 1'b1;
            sr_enable <= 1'b1;
            counter <= counter + 1;
            state <= 1;
        end
        
        3: begin
            counter <= counter + 1;
            state <= 1;
        end*/
        
    endcase
end


endmodule