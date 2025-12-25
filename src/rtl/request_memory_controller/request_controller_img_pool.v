`include "../common/arch_param.vh"

module request_controller_img_pool_resize#(
    parameter BURST_LENGTH_WIDTH = 8, 
    parameter AXI_ADDRESS_WIDTH = 32,
    parameter ADDR_OUT_CHUNK_WIDTH = 8,
    parameter KERNELITR_WIDTH = 12,
    parameter CHANNELITR_WIDTH = 12,
    parameter BURST_LENGTH = 10,
    parameter AXI_DATA_BYTES = 32,
    parameter MOD = 2,
    parameter N_SA = 4,
    parameter W_POOL_IW = 4,
    parameter W_POOL_IH = 4
) (
    input clk,
    input rst,
    input [AXI_ADDRESS_WIDTH - 1 : 0] start_addr,
    input [KERNELITR_WIDTH - 1 : 0] kernelitr,
    input [W_POOL_IH - 1 : 0] input_img_height,
    input [W_POOL_IW - 1 : 0] input_img_width,
    input config_start,
    input fifo_status,
    input c_done,

    output reg img_rd_done = 0,
    output reg [ADDR_OUT_CHUNK_WIDTH - 1 : 0] addr_out  = 0,
    output reg wr_enable = 0, //write-read enable
    output reg valid = 0,
    output reg last = 0,
    output [BURST_LENGTH_WIDTH - 1 : 0] burst_length
);

    integer i;
    reg [4:0] count = 0;
    reg [AXI_ADDRESS_WIDTH - 1 : 0] nxt_addr = 0,nxt_burst=0;
    reg [2:0] state = 0;
    reg [KERNELITR_WIDTH - 1 : 0] count_kernel = 0;
    reg [BURST_LENGTH_WIDTH - 1 : 0] r_burst_length = 0,rbl_add1=0;
    
    localparam IDLE = 3'b000;
    localparam FIFO_STATUS = 3'b001;
    localparam START_ADDR = 3'b010;
    localparam ADDR_ITR = 3'b011;
    localparam C_DONE = 3'b100;
    localparam KERNEL_ITR = 3'b101;

    assign burst_length = r_burst_length;
	reg [AXI_ADDRESS_WIDTH - 1 : 0] r_start_addr;
    reg [KERNELITR_WIDTH - 1 : 0] 	r_kernelitr;
    reg [AXI_ADDRESS_WIDTH - 1 : 0] r_stop_addr;
    reg r_config_start;
    reg r_fifo_status; //occupancy check
    reg r_c_done;

    wire [2*W_POOL_IW-1 : 0] input_img_size;
    wire [W_POOL_IW-1 : 0] extra_img_size;
    wire [AXI_ADDRESS_WIDTH - 1 : 0] offset;

    assign input_img_size = input_img_height * input_img_width;
    assign extra_img_size = (input_img_size % MOD == 0) ? 0 : (MOD - (input_img_size % MOD));
    assign offset = (input_img_size + extra_img_size) * N_SA;

always @ (posedge clk) begin 
	r_start_addr    <=  start_addr;
	r_config_start  <=  config_start;
	r_fifo_status   <=  fifo_status;
    r_c_done        <=  c_done;
end

always @(posedge clk) begin
    if(!rst) begin
        state <= 0;
        valid <= 0;
        last <= 0;
        addr_out <= 0;
        img_rd_done <= 0;
    end
    else begin
        case(state) 
        IDLE: begin
            addr_out <= 0;
            wr_enable <= 0;
            valid <= 0;
            last <= 0;
            img_rd_done <= 0;
            if(r_config_start) begin
                r_kernelitr     <= kernelitr;
                state           <= FIFO_STATUS;
                nxt_addr        <= r_start_addr;
                r_stop_addr     <= r_start_addr + offset;
                r_burst_length  <= BURST_LENGTH;
            end
            else begin
                state <= IDLE;
            end
        end
        FIFO_STATUS: begin //for checking if required occupancy has been achieved or not
            nxt_burst<=(nxt_addr+((r_burst_length+1)<<$clog2(AXI_DATA_BYTES)));
            img_rd_done <= 0;
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
            if(count==i) begin 
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
            if(nxt_addr == r_stop_addr) begin  //if stop_address is equal to nxt_address then the data request will end and state will move to kernel_itr state to check for the no. of kernel itreration needed  
                state <= C_DONE; 
                addr_out <= 0;
                valid <= 0;  
                r_burst_length <= r_burst_length;
                wr_enable <= 0;
                nxt_addr <= (nxt_addr + ((r_burst_length + 1) << $clog2(AXI_DATA_BYTES)));
            end
            else if(nxt_burst >= r_stop_addr) begin //if nxt_address is greater than stop_address then burst_length will be reduced from the default value to suit the stop_address 
                state <= C_DONE;
                wr_enable <= 0;
                valid <= 0;
                r_burst_length <= r_burst_length;
                nxt_addr <= (nxt_addr + ((r_burst_length + 1) << $clog2(AXI_DATA_BYTES)));
            end
            else begin //if nxt_address is smaller than the stop_address then it will simply go to the FIFO_STATUS to check for the fifo's status and iterate again
                state <= FIFO_STATUS;
                wr_enable <= 0;
                valid <= 0;
                r_burst_length <= r_burst_length;
                nxt_addr <= (nxt_addr + ((r_burst_length + 1) << $clog2(AXI_DATA_BYTES)));
            end
        end
        C_DONE: begin
                if (r_c_done) begin
                    state <= KERNEL_ITR;
                    img_rd_done <= 1;
                end
                else begin
                    state <= C_DONE;
                    img_rd_done <= 0;
                end
             end      
        KERNEL_ITR: begin //this state will check for kernal value as to how many times the same image has to be read
            img_rd_done <= 0;
            if (count_kernel < r_kernelitr -1) begin
                nxt_addr <= nxt_addr;
                r_stop_addr <= nxt_addr + offset;
                state <= FIFO_STATUS;
                count_kernel <= count_kernel + 1;
                r_burst_length <= BURST_LENGTH;
            end
            else begin
                nxt_addr <= 0;
                state <= IDLE;
                count_kernel <= 0;
            end
        end
        endcase
    end
end

endmodule