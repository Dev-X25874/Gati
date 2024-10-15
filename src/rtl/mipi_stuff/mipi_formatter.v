module mipi_formatter #(
    parameter DATA_SIZE = 20,
    parameter ID = 10,
    parameter AXI_DATA_WIDTH = 256,
    parameter CPU_DATA_WIDTH = 32)
(
    input  clk,
    input  rst,
    input  valid_req,
    input  [DATA_SIZE-1:0] i_data_size,
    input  [ID-1:0] i_id,
    input  empty,
    input  config_done, //comes from config block
    input  full,
    input  fifo_valid,
    input  [AXI_DATA_WIDTH-1:0] data_in,
    output [CPU_DATA_WIDTH-1:0] data_out,
    output reg ready,
    output reg valid,
    output reg rd_en
);

reg [CPU_DATA_WIDTH-1:0] r_data_out = 0;
reg [3:0] state = 0;
reg [DATA_SIZE-1:0] data_size_count = 0; //reg for updating the data size
reg [ID-1:0] r_id = 0;
reg [CPU_DATA_WIDTH -1:0] sof = 32'hFFFFFFFF;
reg [3:0] packet_count = 0;
reg [AXI_DATA_WIDTH-1:0] r_data_in = 0; //reg for holding th input data before slicing into 32 bits and sending to MIPI fifo
//reg r_config_done = 0; //reg for holding the done instruction

assign data_out = r_data_out;

always @ (posedge clk) begin
    if(!rst) begin
        state <= 0;
        r_data_out <= 0;
        ready <= 0;
        valid <= 0;
        data_size_count <= 0;
        r_id <= 0;
        packet_count <= 0;
        r_data_in <= 0;
    end

    else begin
        case(state)
        0:begin
            ready <= 1;
            r_data_out <= 0;
            valid <= 0;
            if(valid_req) begin
                data_size_count <= i_data_size;
                r_id <= i_id;
                state <= 1;
            end
            else begin
                data_size_count <= 0;
                r_id <= 0;
                state <= 0;
            end
        end

        1:begin
            ready <= 0;
            if(!empty) begin
                r_data_out <= sof;
                valid <= 1;
                state <= 2;
            end
            else begin
                r_data_out <= 0;
                valid <= 0;
                state <= 1;
            end
        end

        2:begin
            rd_en <= 0;
            r_data_out <= data_size_count;
            valid <= 1;
            state <= 3;
        end

        3:begin
            rd_en <= 1;
            r_data_out <= r_id;
            valid <= 1;
            state <= 4;
        end
        
        4:begin
            rd_en <= 0;
            valid <= 0;
            if(fifo_valid) begin
                r_data_in <= data_in;
                state <= 5;
            end
            else begin
                r_data_in <= r_data_in;
                state <= 4;
            end
        end        

        5:begin //slicing the data and sending it in 8 cycles of 32 bits
            if(~full) begin
                if(packet_count < 7) begin
                    r_data_out <= r_data_in[(AXI_DATA_WIDTH - (32*packet_count))-1 -:32];
                    valid <= 1;
                    state <= 5;
                    packet_count <= packet_count + 1;
                end
                else if (packet_count == 7) begin
                    r_data_out <= r_data_in[(AXI_DATA_WIDTH - (32*packet_count))-1 -:32];
                    valid <= 1;
                    packet_count <= packet_count + 1;
                    data_size_count <= data_size_count - 32;
                    state <= 5;
                end
                else begin
                    packet_count <= 0;
                    valid <= 0;
                    state <= 6;
                end
            end
            else begin
                valid <= 0;
                r_data_out <= r_data_out;
                state <= 5;
            end
        end

        6:begin
            if((data_size_count > 0) && (data_size_count[DATA_SIZE-1] != 1)) begin //check if all the data has been sent or not
                rd_en <= 1;
                state <= 4;
            end
            else begin
                rd_en <= 0;
                data_size_count <= 0;
                r_id <= 0;
                state <= 7;
                /*if(r_config_done)begin //check whether the current request was the last request 
                    rd_en <= 0;
                    data_size_count <= 0;
                    r_id <= 0;
                    state <= 7;
                    end
                else begin
                    rd_en <= 0;
                    data_size_count <= 0;
                    r_id <= 0;
                    state <= 0;
                end */   
            end
        end

        7:begin
            if(full) begin
            valid <= 0;
            state <= 7;
            end
            else begin
            r_data_out <= sof;
            valid <= 1;
            state <= 8;
            end
        end

        8:begin
            if(~full) begin
            r_data_out <= data_size_count;
            valid <= 1;
            state <= 9;
            end
            else begin
                valid <= 0;
                state <= 8;
            end
        end

        9:begin
            if(~full) begin
            r_data_out <= r_id;
            valid <= 1;
            state <= 0;
            end
            else begin
                valid <= 0;
                state <= 9;
            end
        end
        endcase
    end
end

/*always @ (posedge clk) begin
if(!rst) begin
r_config_done <= 0;
end
else begin
if (config_done) begin
r_config_done <= 1;
end
else if(state == 8) begin
r_config_done <= 0;
end
else begin
r_config_done <= r_config_done;
end
end
end*/

endmodule




