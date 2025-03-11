/*  This module takes the data that was read from DRAM 
    and writes into the corresponding operator FIFO
*/
module operator_fifo_wren_ctrl #(
    parameter AXI_DATA_WIDTH = 256,
    parameter N_FIFO = 16,
    parameter DATA_WIDTH = 32
)(
    input i_clk,
    input i_rst,
    input [AXI_DATA_WIDTH-1:0] i_dram_data,
    input i_datavalid_dram_data,
    
    output [N_FIFO-1:0] o_fifo_wren,
    output [N_FIFO*DATA_WIDTH-1:0] o_data
);

    localparam DATA_VALID_WIDTH = AXI_DATA_WIDTH/DATA_WIDTH;
    localparam SHIFT_WIDTH = (N_FIFO*DATA_WIDTH > AXI_DATA_WIDTH)? $clog2(N_FIFO*DATA_WIDTH/AXI_DATA_WIDTH) : 0;
    localparam SHIFT_COUNT = (N_FIFO*DATA_WIDTH > AXI_DATA_WIDTH)? N_FIFO*DATA_WIDTH/AXI_DATA_WIDTH : 0;

    reg [N_FIFO-1:0] r_fifo_wren;
    reg [N_FIFO*DATA_WIDTH-1:0] r_data;

    generate
        if(SHIFT_WIDTH == 0) begin
            always@(posedge i_clk) begin
                if(!i_rst) begin
                    r_fifo_wren <= 0;
                    r_data <= 0;
                end
                else begin
                    if(i_datavalid_dram_data) begin
                        r_fifo_wren <= {N_FIFO{1'b1}};
                        r_data <= i_dram_data;
                    end
                    else begin
                        r_fifo_wren <= {N_FIFO{1'b0}};
                        r_data <= r_data;
                    end
                end
            end

            assign o_fifo_wren = r_fifo_wren;
            assign o_data = r_data;
        end

        else begin
            reg [SHIFT_WIDTH-1:0] r_shift_count;
            wire [N_FIFO*DATA_WIDTH-1:0] demux_op_data;
            wire [N_FIFO-1:0] demux_op_wren;

            always@(posedge i_clk) begin
                if(!i_rst) begin
                    r_fifo_wren <= 0;
                    r_data <= 0;
                    r_shift_count <= 0;
                end
                else begin
                    r_data <= demux_op_data;
                    r_fifo_wren <= demux_op_wren;

                    if(r_shift_count == SHIFT_COUNT-1) begin
                        if(i_datavalid_dram_data) begin
                            r_shift_count <= 0;
                        end
                    end
                    else begin
                        if(i_datavalid_dram_data) begin
                            r_shift_count <= r_shift_count + 1;
                        end
                    end
                end
            end

            // Demux for writing data into FIFOs and wren signals
            demux_param #(
                .N_PORT(SHIFT_COUNT),
                .DATA_WIDTH(AXI_DATA_WIDTH)
            ) demux_op_data_inst (
                .i_din(i_dram_data),
                .i_sel(r_shift_count),
                .o_dout(demux_op_data)
            );

            demux_param #(
                .N_PORT(SHIFT_COUNT),
                .DATA_WIDTH(DATA_VALID_WIDTH)
            ) demux_op_wren_inst (
                .i_din({DATA_VALID_WIDTH{i_datavalid_dram_data}}),
                .i_sel(r_shift_count),
                .o_dout(demux_op_wren)
            );

            assign o_fifo_wren = r_fifo_wren;
            assign o_data = r_data;
        end
    endgenerate

endmodule