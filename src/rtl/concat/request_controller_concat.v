module request_controller_concat #(
    parameter BURST_LENGTH_WIDTH = 8,
    parameter AXI_ADDRESS_WIDTH = 32,
    parameter ADDR_OUT_CHUNK_WIDTH = 8,
    parameter BURST_LENGTH = 16,
    parameter AXI_DATA_BYTES = 32,
    parameter CONCAT_InNum_WIDTH = 3
) (
    input [AXI_ADDRESS_WIDTH - 1 : 0] start_addr_1,
    input [AXI_ADDRESS_WIDTH - 1 : 0] stop_addr_1,
    input config_start,
    input CONV_FC,
    input fifo_status, //occupancy check
    input clk,
    input data_last,
    input [CONCAT_InNum_WIDTH-1:0] CONCAT_InNum, 
    output reg [ADDR_OUT_CHUNK_WIDTH - 1 : 0] addr_out  = 0,
    output reg wr_enable = 0, //write-read enable
    output reg valid = 0,
    output reg last  = 0,
    output reg req_done = 1'b1,
    output [BURST_LENGTH_WIDTH - 1 : 0] burst_length
);


    // state definitions
    localparam IDLE            = 3'b000;
    localparam FIFO_STATUS     = 3'b001;
    localparam START_ADDR      = 3'b010;
    localparam ADDR_ITR        = 3'b011;
    localparam LATCH_NEXT_ADDR = 3'b100;
    localparam DONE            = 3'b101;

    assign burst_length = r_burst_length;

    reg [1:0] input_count = 0; // number of input to be concat'ed 
    reg [CONCAT_InNum_WIDTH-1:0] r_CONCAT_InNum;
    reg [2:0] state = 0;
    reg [4:0] count = 0;
    reg       r_config_start;
    reg       r_fifo_status;
    reg       r_data_last;
    reg       r_CONV_FC;
    reg       r_Concat;
    reg [AXI_ADDRESS_WIDTH - 1:0] nxt_addr = 0,nxt_burst=0;
    reg [BURST_LENGTH_WIDTH - 1 : 0] r_burst_length = 0;

    reg [AXI_ADDRESS_WIDTH  - 1 : 0] r_start_addr;
    reg [AXI_ADDRESS_WIDTH  - 1 : 0] r_stop_addr; 



    always @(posedge clk) begin
        r_fifo_status <= fifo_status;
        r_config_start <= config_start;
        r_start_addr <= start_addr_1;
        r_stop_addr  <=  stop_addr_1;

    end


	integer i;
    always @(posedge clk) begin
            case(state) 
            IDLE: begin
                addr_out <= 0;
                wr_enable <= 0;
                valid <= 0;
                last <= 0;
                req_done <= 1'b0;
                if(r_config_start) begin
                    state <= FIFO_STATUS;
                    nxt_addr <= r_start_addr;
                    r_burst_length <= BURST_LENGTH;
                end
                else begin
                    state <= IDLE;
                end
            end
            FIFO_STATUS: begin //for checking if required occupancy has been achieved or not
                nxt_burst<=(nxt_addr+((r_burst_length+1)<<$clog2(AXI_DATA_BYTES)));
                if(r_fifo_status) begin
                    state <= START_ADDR;
                end
                else begin
                    state <= FIFO_STATUS;
                end
            end
            START_ADDR: begin
                if(nxt_burst > r_stop_addr) begin
                    r_burst_length <= ((r_stop_addr - nxt_addr) >> $clog2(AXI_DATA_BYTES)) - 1;
                    end
                else begin
                    r_burst_length <= r_burst_length;
                end

                if(count < 3) begin
    				for(i=0;i<3;i=i+1) begin 
                        if(i==count) begin
    					    addr_out <= nxt_addr[32-(i*8)-1 -:8];
                        end
    				end
    				wr_enable <= 0;
                    valid <= 1;
                    state <= START_ADDR;
                    count <= count + 1;
                end
                else begin
                    addr_out <= nxt_addr[7:0];
                    wr_enable <= 0;
                    last <= 1;
                    valid <= 1;
                    state <= ADDR_ITR;
                    count <= 0;
                end
            end
            ADDR_ITR: begin
                last <= 0;
                if(nxt_addr == r_stop_addr) begin  //if stop_address is equal to nxt_address then the data request will end and state will move to IDLE state.
                    state <= IDLE;   
                    addr_out <= 0;
                    valid <= 0;  
                    r_burst_length <= r_burst_length;
                    wr_enable <= 0;
                    req_done <= 1'b1;
                end
                else if(nxt_burst >= r_stop_addr) begin //if nxt_address is greater than stop_address then burst_length will be reduced from the default value to suit the stop_address 
                    state <= IDLE;
                    wr_enable <= 0;
                    valid <= 0;
                    r_burst_length <= r_burst_length;
                    nxt_addr <= nxt_addr;
                    req_done <= 1'b1;
                end
                else begin //if nxt_address is smaller than the stop_address then it will simply go to the FIFO_STATUS to check for the fifo's status and iterate again
                    state <= FIFO_STATUS;
                    wr_enable <= 0;
                    valid <= 0;
                    r_burst_length <= r_burst_length;
                    nxt_addr <= (nxt_addr + ((r_burst_length + 1) << $clog2(AXI_DATA_BYTES)));
                    req_done <= 1'b0;
                end
            end
            endcase
        end

endmodule