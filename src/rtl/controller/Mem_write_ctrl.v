module Mem_write_ctrl #(
    parameter AXI_DATA_WIDTH = 256,
    parameter BURST_LENGTH_WIDTH = 8,
    parameter N_FIFO = 8 //Number of fifos from which data has ti read
) (
    input clk,
    input rst,
    input select, // from DRAM ctrler (WR_ID mger)
    input wready, // from DRAM ctrler (WR_ID mger)
    input [BURST_LENGTH_WIDTH-1:0] blen, // from DRAM ctrler (WR_ID mger)
    
    output reg data_valid,
    output data_last,
    // output [AXI_DATA_WIDTH-1:0] data_out,
    output [N_FIFO-1:0] fifo_rd_en
);
    
    reg [1:0] state;
    reg [BURST_LENGTH_WIDTH-1 : 0] r_blen;
    reg [BURST_LENGTH_WIDTH : 0] count_blen;

    always@(posedge clk)begin
        if (!rst) begin
            count_blen <= 0;
            state <= 2'd0;
        end else begin
            case(state)
                2'd0:begin
                    if(select==1) begin
                        state <= 2'd1;
                        count_blen <= 0;
                        data_valid <= 1'b0;
                        r_blen <= blen;
                    end
                    else begin
                        state <= 0;
                        count_blen <= 0;
                        data_valid <= 1'b0;
                        r_blen <= r_blen;
                    end
                end

                2'd1:begin
                    if(select==1)
                        state <= 2'd2;
                    else
                        state <= 2'd0;
                end

                2'd2:begin
                    if((count_blen > r_blen) && DataWrEnd) begin
                        data_valid <= 1'b0;
                        state <= 0;
                        count_blen <= 0;
                    end
                    else if (count_blen == r_blen) begin
                        if(wready) begin
                            data_valid <= 1'b1;
                            count_blen < =count_blen + 1;
                            state <= 2'd2;
                        end
                        else begin
                            data_valid <= data_valid;
                            count_blen < =count_blen + 1;
                            state <= 2'd2;
                        end
                    end
                    else begin
                        if(wready) begin
                            data_valid <= 1'b1;
                            count_blen < =count_blen + 1;
                            state <= 2'd2;
                        end
                        else begin
                            data_valid <= data_valid;
                            count_blen < =count_blen + 1;
                            state <= 2'd2;
                        end
                    end
                end

                default: begin
                    state <= 0;
                    count_blen <= 0;
                    data_valid <= 0;
                end

            endcase
        end
    end

    assign fifo_rd_en = (data_valid & wready) ? {N_FIFO{1'b1}} : {N_FIFO{1'b0}};

    reg DataWrLast;
    wire DataWrEnd;

    assign DataWrEnd = DataWrLast & data_valid & wready;
        
    always@( posedge clk)
    begin
        if(!rst)                                                DataWrLast <= 1'b0;
        else if (data_valid && wready && (count_blen==r_blen))  DataWrLast <= 1'b1;
        else if (DataWrEnd)                                     DataWrLast <= 1'b0;
    end

    assign data_last = DataWrEnd;

endmodule