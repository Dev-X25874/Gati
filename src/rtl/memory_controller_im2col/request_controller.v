module request_controller #(parameter burst_length_out = 10, parameter occupancy_count = 40, parameter AXI_DATA_BYTES = 32) (
    input [31:0] start_addr,
    input [11:0] channelitr,
    input [11:0] kernelitr,
    input [31:0] stop_addr,
    input config_start,
    input fifo_status, //occupancy check
    output [7:0] addr_out,
    output rn,
    output wn,
    output valid,
    output burst_length
);
reg [31:0] r_addr_out = 0;
reg [3:0] count = 0;

always @(posedge clk) begin
    case(state) 
    IDLE: begin
        addr_out <= 0;
        rn <= 0;
        wn <= 0;
        valid <= 0;
        burst_length <= 0;
        if(config_start) begin
            state <= START_ADDR;
        end
        else begin
            state <= IDLE;
        end
    end
    START_ADDR: begin
        if(count < 3) begin
            addr_out <= start_addr[31-(count*8)-1 -:8];
            rn <= 1;
            wn <= 0;
            burst_length <= burst_length_out;
            state <= START_ADDR;
            count <= count + 1;
        end
        else begin
            addr_out <= start_addr[31-(count*8)-1 -:8];
            rn <= 0;
            wn <= 0;
            burst_length <= 0;
            state <= ADDR_ITR;
            count <= 0;
        end
    end
    ADDR_ITR: begin
        r_addr_out <= (burst_length_out<<log2(AXI_DATA_BYTES));
        if(r_addr_out == stop_addr) begin
            state <= KERNEL_ITR_STATE;
            rn <= 0;
            valid <= 0;
            wn <= 0;
            burst_length <= 0; 
            addr_out <=            
        end
        else begin
            state <= START_ADDR_STATE;
            rn <= 0;
            valid <= 0;
            wn <= 0;
            burst_length <= 0; 
            addr_out <= r_addr_out[31-(count*8)-1 -:8];
        end
    end
    KERNEL_ITR: begin
        if (count_kernel == kernelitr) begin
            state <= IDLE;
        end
        else begin
            state <= START_ADDR_STATE;
        end
    end
    endcase
end

endmodule