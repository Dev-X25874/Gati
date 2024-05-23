module counter_rowwise_columnwise(
    input clk,
    input rst_n,
    input [9:0] OW,
    input [9:0] OH,
    input ENABLE,
    input rx_valid,
    output reg done = 0,
    output reg dv_demux_counter = 1
);

reg [9:0] row_counter = 0;
reg [9:0] column_counter = 0;
reg enable = 0;
reg [1:0] state = 0;

always @(posedge rx_valid) begin
    if(~rst_n) begin
        enable <= 0;
        done <= 0;
    end
    else begin
        // case(state) 
        // 0: begin
            // enable <= 0;
            // done <= 0;
            // dv_demux_counter = 1;
            // if(ENABLE) begin
                // state <= 1;
            // end
            // else begin
                // state <= 0;
            // end
        // end
        //1: begin
        if(ENABLE) begin
            if(row_counter < (OW - 1)) begin
                if(column_counter == (OH - 1)) begin
                    column_counter <= column_counter;
                    row_counter <= row_counter + 1;
                    dv_demux_counter <= 0;
                    done <= 0;
                    //state <= 1;
                end
                else begin
                    row_counter <= row_counter + 1;
                    column_counter <= column_counter;
                    dv_demux_counter <= 0;
                    done <= 0;
                    //state <= 1;
                end
            end
            else if(row_counter == (OW - 1)) begin
                if(column_counter == (OH - 1)) begin
                    column_counter <= 0;
                    row_counter <= 0;
                    dv_demux_counter <= 0;
                    done <= 1;
                    //state <= 0;
                end
                else begin
                    column_counter <= column_counter + 1;
                    row_counter <= 0;
                    dv_demux_counter <= 1;
                    done <= 0;
                    //state <= 1;
                end
            end
            else begin
                //state <= 1;
                done <= 0;
                row_counter <= 0;
                column_counter <= 0;
                dv_demux_counter <= 0;
            end
        end
        //end
        //endcase
    end
end
endmodule
