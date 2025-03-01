module request_controller_FCbias #(parameter BURST_LENGTH_WIDTH = 8, 
                                    parameter AXI_ADDRESS_WIDTH = 32,
                                    parameter ADDR_OUT_CHUNK_WIDTH = 8,
                                    parameter BURST_LENGTH = 10,
                                    parameter AXI_DATA_BYTES = 32)(
    input [AXI_ADDRESS_WIDTH - 1 : 0] start_addr,
    input [AXI_ADDRESS_WIDTH - 1 : 0] stop_addr,
    input config_start,
    input fifo_status, //occupancy check
    input clk,
    input FCbiasen,
    output reg [ADDR_OUT_CHUNK_WIDTH - 1 : 0] addr_out  = 0,
    output reg wr_enable = 0, //write-read enable
    output reg last = 0,
    output reg valid = 0,
    output [BURST_LENGTH_WIDTH - 1 : 0] burst_length
);
//reg [31:0] r_addr_out = 0;
reg [4:0] count = 0;
reg [AXI_ADDRESS_WIDTH - 1 : 0] nxt_addr = 0, nxt_burst;
reg [2:0] state = 0;
reg [BURST_LENGTH_WIDTH - 1 : 0] r_burst_length = 0;
parameter IDLE = 3'b000;
parameter FIFO_STATUS = 3'b001;
parameter START_ADDR = 3'b010;
parameter ADDR_ITR = 3'b011;
assign burst_length = r_burst_length;
	reg [AXI_ADDRESS_WIDTH - 1 : 0] r_start_addr;
    reg [AXI_ADDRESS_WIDTH - 1 : 0] r_stop_addr;
    reg r_config_start;
    reg r_fifo_status; //occupancy check
    reg r_FCbiasen;
//always @ (posedge clk) begin 
//	r_start_addr<=start_addr;
//	r_stop_addr<=stop_addr;
//	r_config_start<=config_start;
//	r_fifo_status<=fifo_status;
// 	r_FCbiasen<=FCbiasen;
//end

// always@(posedge clk) begin
//     nxt_burst<=(nxt_addr+((r_burst_length+1)<<$clog2(AXI_DATA_BYTES)));
// end
integer i;
always @(posedge clk) begin
    if(FCbiasen) begin
        case(state) 
        IDLE: begin
            addr_out <= 0;
            wr_enable <= 0;
            valid <= 0;
            last <= 0;
            if(config_start) begin
                state <= FIFO_STATUS;
                nxt_addr <= start_addr;
                r_burst_length <= BURST_LENGTH;
            end
            else begin
                state <= IDLE;
            end
        end
        FIFO_STATUS: begin //for checking if required occupancy has been achieved or not
            nxt_burst<=(nxt_addr+((r_burst_length+1)<<$clog2(AXI_DATA_BYTES)));
            if(fifo_status) begin
                state <= START_ADDR;
            end
            else begin
                state <= FIFO_STATUS;
            end
        end
        START_ADDR: begin
            if(nxt_burst > stop_addr) begin
                r_burst_length <= ((stop_addr - nxt_addr) >> $clog2(AXI_DATA_BYTES)) - 1;
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
                // r_burst_length <= r_burst_length;
                state <= START_ADDR;
                count <= count + 1;
            end
            else begin
                addr_out <= nxt_addr[7:0];
                wr_enable <= 0;
                valid <= 1;
                last <= 1;
                // r_burst_length <= r_burst_length;
                state <= ADDR_ITR;
                count <= 0;
            end
        end
        ADDR_ITR: begin
            last <= 0;
            // nxt_addr <= (nxt_addr + ((BURST_LENGTH + 1) << $clog2(AXI_DATA_BYTES)));
            if(nxt_addr == stop_addr) begin  //if stop_address is equal to nxt_address then the data request will end and state will move to IDLE state.
                state <= IDLE;     
                addr_out <= 0;
                valid <= 0;  
                r_burst_length <= r_burst_length;
                wr_enable <= 0;
            end
            else if(nxt_burst >= stop_addr) begin //if nxt_address is greater than stop_address then burst_length will be reduced from the default value to suit the stop_address 
                state <= IDLE;
                wr_enable <= 0;
                valid <= 0;
                r_burst_length <= r_burst_length;
                nxt_addr <= stop_addr;
            end
            else begin //if nxt_address is smaller than the stop_address then it will simply go to the FIFO_STATUS to check for the fifo's status and iterate again
                state <= FIFO_STATUS;
                wr_enable <= 0;
                valid <= 0;
                r_burst_length <= r_burst_length;
                nxt_addr <= (nxt_addr + ((BURST_LENGTH + 1) << $clog2(AXI_DATA_BYTES)));
            end
        end
        endcase
    end
    else begin
        addr_out <= 0;
        wr_enable <= 0;
        r_burst_length <= 0;
        valid <= 0;
    end
end

endmodule
