module counter_rowwise_columnwise#(parameter OW_WIDTH = 10,     // Bit-width of the row counter of img
                                   parameter OH_WIDTH = 10,     // Bit-width of the column counter of img
                                   parameter DATA_WIDTH = 8,    // Image Width
                                   parameter POOL_WIDTH = 4,
                                   parameter POOLMODCOUNT_WIDTH = 4
                                   )  
    (
        input clk,
        input rst_n,
        input [(OW_WIDTH - 1) : 0] OW,          // Total number of rows (width)
        input [(OH_WIDTH - 1) : 0] OH,          // Total number of columns (height)
        input ENABLE,                           // Gen Pool enable signal
        input [(POOLMODCOUNT_WIDTH - 1) : 0] mod_value, // Remainder 
        input datavalid_in,                     // data Valid signal from relu output                 
        input [(DATA_WIDTH - 1) : 0] din,       // output of relu and input of Generalized pool
        output reg datavalid_out = 0,
        output reg [(DATA_WIDTH - 1) : 0] dout = 0, // output data from row_col_counter
        output reg done = 0,                    // Done signal, set when counting completes
        output reg dv_demux_counter = 0        // Data valid signal for the counter_demux stage 
);

reg [(OW_WIDTH - 1) : 0] column_counter = 0;
reg [(OH_WIDTH - 1) : 0] row_counter = 0;
wire [(OW_WIDTH - 1) : 0] OW_mod;
wire [(OH_WIDTH - 1) : 0] OH_mod;

assign OW_mod = (OW - mod_value);
assign OH_mod = (OH - mod_value);

always @(posedge clk) begin
    dout <= din;
    if(~rst_n) begin
        done <= 0;
        column_counter <= 0;
        row_counter <= 0;
        datavalid_out <= 0;
        dv_demux_counter <= 0;
    end
    else begin
        if(ENABLE) begin
            if (datavalid_in) begin
                if(row_counter < (OH - 1)) begin
                    if(column_counter < (OW - 1)) begin
                        column_counter <= column_counter + 1;
                        dv_demux_counter <= 0;
                        done <= 0;
                        row_counter <= row_counter;
                        if ((row_counter > (OH_mod - 1)) || (column_counter > (OW_mod - 1))) begin
                            datavalid_out <= 0;
                        end
                        else begin
                            datavalid_out <= 1;
                        end
                    end
                    else begin //(column_counter == (OW - 1))
                        row_counter <= row_counter + 1;
                        column_counter <= 0;
                        dv_demux_counter <= 1;
                        done <= 0;
                        if ((row_counter > (OH_mod - 1)) || (column_counter > (OW_mod - 1))) begin
                            datavalid_out <= 0;
                        end
                        else begin
                            datavalid_out <= 1;
                        end
                    end
                end                                 
                else  begin   //else if (row_counter == (OH-1))
                    if(column_counter < (OW - 1)) begin
                        column_counter <= column_counter + 1;
                        dv_demux_counter <= 0;
                        done <= 0;
                        row_counter <= row_counter;
                        if ((row_counter > (OH_mod - 1)) || (column_counter > (OW_mod - 1))) begin
                            datavalid_out <= 0;
                        end
                        else begin
                            datavalid_out <= 1;
                        end
                    end
                    else begin // row_counter == (OH-1) && column_counter == (OW-1)
                        row_counter <= 0;
                        column_counter <= 0;
                        dv_demux_counter <= 1;
                        done <= 1;
                        if ((row_counter > (OH_mod - 1)) || (column_counter > (OW_mod - 1))) begin
                            datavalid_out <= 0;
                        end
                        else begin
                            datavalid_out <= 1;
                        end
                    end
                end
            end
            else begin
                done <= 0;
                datavalid_out <= 0;
                dv_demux_counter <= 0;
            end
        end
        else begin
            done <= 0;
            datavalid_out <= 0;
            row_counter <= 0;
            column_counter <= 0;
            dv_demux_counter <= 0;
        end
    end
end
endmodule
