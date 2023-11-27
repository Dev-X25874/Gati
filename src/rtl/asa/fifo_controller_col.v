module fifo_controller_col#(
    parameter COL = 1,
    parameter ROW = 9,
    parameter W_ADDR = 8
)(
    input i_clk,
    input i_fifo_empty,
    input [W_ADDR:0] occupants,
    input [COL-1:0] fifo_array_full,
    output fifo_read_enable,
    output sr_enable
);
reg sren = 0;
reg rden = 0;

assign fifo_read_enable = rden;
assign sr_enable = sren;

reg [1:0] state = 0;

always @(posedge i_clk)begin
    case(state)
        0: begin
            sren <= 0;
            rden <= 0;
            if(occupants == (COL * ROW))
                state <= 1;
        end
        
        1: begin
            if(occupants == 0)begin
                state <= 0;
            end else begin
                if(i_fifo_empty == 0 && fifo_array_full == 0)begin
                    rden <= 1'b1;
                    sren <= 1'b1;
                    state <= 2;
                end
            end
        end
        
        2: begin
            rden <= 1'b0;
            state <= 1;
        end
    endcase
end    

//always @(posedge i_clk)begin
//    if(occupants == (ROW * COL)) begin
//        if(i_fifo_empty == 0 && fifo_array_full == 0)begin
//            rden <= ~rden;
//            sren <= 1'b1;
//        end
//    end else begin
//        rden <= 0;
//        sren <= 0;
//    end
//end

endmodule
