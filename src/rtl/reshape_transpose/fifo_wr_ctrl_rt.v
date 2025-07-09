module fifo_wr_ctrl_rt #(
    parameter N_FIFO = 32,
    parameter IMG_HEIGHT = 16,
    parameter IMG_CHANNELS = 16)
    (
        input  clk,
        input  rst,
        input  valid, // comes from bram read controller after getting delayed
        input  [(2*IMG_HEIGHT)-1:0] img_dimension,
        input  [IMG_CHANNELS-1:0] input_channels,
        output reg [$clog2(N_FIFO)-1:0] fifo_counter,
        output [N_FIFO-1:0] wr_en //write enable for dram fifos
    );

    reg [N_FIFO-1:0] wen = 0;
    reg [(2*IMG_HEIGHT)-1:0] data_counter = 0;
    (*syn_use_dsp = "no"*) reg [(2*IMG_HEIGHT)-1:0] data_count;

    assign wr_en = wen;

    always @(posedge clk) begin
        data_count = img_dimension*input_channels;
    end 

    always @ (posedge clk) begin
        if(!rst) begin
            wen <= 0;
            data_counter <= 0;
            fifo_counter <= 0; //counter for shifting write enable of fifos
        end

        else begin
            if(fifo_counter == 0) begin //initially give write enable from MSB 
                if(valid) begin
                    wen[N_FIFO-1] <= 1; 
                    wen[0] <= 0;
                    data_counter <= data_counter + 1;
                    fifo_counter <= fifo_counter + 1;
                end
                else begin
                    if(data_counter == data_count) begin
                        wen <= 0;
                        fifo_counter <= 0;
                        data_counter <= 0;
                    end
                    else begin
                        wen <= 0;
                        data_counter <= data_counter;
                        fifo_counter <= 0;
                    end
                end
            end

            else if(fifo_counter == N_FIFO-1) begin //wrap around after counter reaches maximum
                if(valid) begin
                    fifo_counter <= 0;
                    data_counter <= data_counter + 1;
                    wen[0] <= 1;
                    wen[1] <= 0;
                end
                else begin
                    if(data_counter == data_count) begin
                        wen[0] <= 1;
                        wen[1] <= 0;
                        fifo_counter <= fifo_counter + 1;
                        data_counter <= data_counter;
                    end
                    else begin
                        wen <= 0;
                        data_counter <= data_counter;
                        fifo_counter <= fifo_counter;
                    end
                end
            end

            else begin
                if(valid) begin //shifting write enable by 1 bit according to valid 
                    wen[N_FIFO-1-fifo_counter] <= 1;
                    wen[N_FIFO-fifo_counter] <= 0;
                    data_counter <= data_counter + 1;
                    fifo_counter <= fifo_counter + 1;
                end
                else begin
                    if(data_counter == data_count) begin
                        wen[N_FIFO-1-fifo_counter] <= 1;
                        wen[N_FIFO-fifo_counter] <= 0;
                        fifo_counter <= fifo_counter + 1;
                        data_counter <= data_counter;
                    end
                    else begin
                        wen <= 0;
                        data_counter <= data_counter;
                        fifo_counter <= fifo_counter;
                    end
                end
            end
        end
    end
endmodule