module op_write_req_block#(
 parameter N = 8,
 parameter DEPTH = 512, 
 parameter BURST_LENGTH = 15,
 parameter BURST_LENGTH_1 = 15,
 parameter BURST_LENGTH_2 =15,
 parameter NUMBER_ACC = 2,
 parameter NUMBER_OP = 8,
 parameter AXI_DATA_BYTES = 32,
 parameter ADDR_WIDTH = 32,
 parameter W_KERNEL_CNT = 16,
 parameter W_CHANNEL_CNT = 16,
 parameter IMAGE_DIM_WIDTH_ACC = 16,
 parameter IMAGE_DIM_WIDTH_OP = 16
)
(
input clkin,
input i_rstn,
input i_start,
input i_data_last,        // acts as an ack, after finishing the transfer it raises new request
input [ADDR_WIDTH-1:0]i_acc_address,
input [ADDR_WIDTH-1:0]i_op_start,
input [W_CHANNEL_CNT-1:0]i_channel_itr,
input [W_KERNEL_CNT-1:0]i_kernel_itr,
input [IMAGE_DIM_WIDTH_ACC-1:0]i_imag_dim, // image width-input
input [IMAGE_DIM_WIDTH_OP-1:0]i_imag_dim_2, // image width-output
input [N*($clog2(DEPTH)+1)-1:0] occupants,

input acc_en,               //from iteration counter
input Tail_done,            //from TOP_CONV_FC
input Acc_onchip,           //from instructions
//signals to mem_controller
output o_last,
output [7:0] o_address,
output [7:0] o_burst_len,
output o_read_write_req,
output o_valid,

output reg layer_done
);

//read request controller

reg [2:0] state;
reg [7:0] r_addr;
reg [ADDR_WIDTH-1:0] r_acc_start_add,r_layer_start_add;
wire [ADDR_WIDTH-1:0] r_layer_stop_add,r_acc_stop_add;
reg [ADDR_WIDTH-1:0] r_acc_next_add,r_layer_next_add;
reg [$clog2(DEPTH) : 0] r_burst_len,r_burst_len1,r_burst_len2;
reg wr_req_reg;
reg r_last;
reg r_valid;
reg [1:0] counter; 

//reg state1;
wire data_last;
reg result_int;

assign data_last = i_data_last;
assign o_address   = r_addr;
assign o_burst_len = r_burst_len;
assign o_read_write_req = wr_req_reg & ~wr_req_reg_delayed;
assign o_last      = r_last;
assign o_valid     = r_valid;

// updation of fifo status based on fifo occupants
wire [$clog2(DEPTH) : 0] r_burst_len_1;
assign r_burst_len_1 = r_burst_len+1;
// assign result_int = (occupants>=({N{r_burst_len_1}}))? 1 : 0; 

//calculation of burst length
wire [ADDR_WIDTH-1 : 0] offset1, offset2;
assign offset1 = (i_imag_dim/NUMBER_ACC)<<$clog2(AXI_DATA_BYTES);
assign offset2 = (i_imag_dim_2/NUMBER_OP)<<$clog2(AXI_DATA_BYTES);  

assign r_acc_stop_add = r_acc_next_add + offset1;
assign r_layer_stop_add = r_layer_next_add + offset2;                    

reg [ADDR_WIDTH-1:0] acc_add_reg1, op_add_reg1;
/*
always@(posedge clkin) begin
    // acc_add_reg1 <= (r_acc_stop_add-((r_burst_len1+1)<<$clog2(AXI_DATA_BYTES)));
    acc_add_reg1 <= (r_acc_start_add+((r_burst_len1+1)<<$clog2(AXI_DATA_BYTES)));
    // op_add_reg1 <= (r_layer_stop_add-((r_burst_len2+1)<<$clog2(AXI_DATA_BYTES)));
    op_add_reg1 <= (r_layer_start_add+((r_burst_len2+1)<<$clog2(AXI_DATA_BYTES)));
end
*/
/*
always@(posedge clkin) begin
    if(!i_rstn)
        r_burst_len1 <= BURST_LENGTH;
    else begin
        if(acc_en==0) begin
            if(acc_add_reg1 > r_acc_stop_add) begin
                r_burst_len1 <= ((r_acc_stop_add-r_acc_start_add)>>$clog2(AXI_DATA_BYTES))-1;
            end
            else begin
                r_burst_len1 <= BURST_LENGTH;
            end
        end
        else begin
            if(acc_add_reg1 > r_acc_stop_add) begin
                r_burst_len1 <= ((r_acc_stop_add-r_acc_start_add)>>$clog2(AXI_DATA_BYTES))-1;
            end
            else begin
                r_burst_len1 <= BURST_LENGTH_1;
            end
        end
    end
end

always@(posedge clkin) begin
    if(!i_rstn)
        r_burst_len2 <= BURST_LENGTH_2;
    else begin
        if(op_add_reg1 > r_layer_stop_add) begin
            r_burst_len2 <= ((r_layer_stop_add-r_layer_start_add)>>$clog2(AXI_DATA_BYTES))-1;
        end
        else begin
            r_burst_len2 <= BURST_LENGTH_2;
        end
    end
end
*/
reg [W_CHANNEL_CNT-1:0] r_channel_itr;
reg [IMAGE_DIM_WIDTH_OP-1:0] count2;
reg [IMAGE_DIM_WIDTH_ACC-1:0] count1;
reg [W_CHANNEL_CNT-1:0] c_ctr=0;
reg [W_KERNEL_CNT-1:0] k_ctr=0;
integer i;

always@(posedge clkin) begin
    r_channel_itr <= i_channel_itr;
    result_int <= (occupants[$clog2(DEPTH) : 0]>=(r_burst_len_1));
end

always@(posedge clkin) begin
    if(!i_rstn) begin
        r_addr      <=  8'd0;
        r_acc_start_add <=  32'd0;
        r_acc_next_add <= 32'd0;
        r_layer_next_add <= 32'd0;
        r_layer_start_add<=  32'd0;
        r_burst_len <=  0;
        r_burst_len1 <= BURST_LENGTH;
        r_burst_len2 <= BURST_LENGTH_2;
        wr_req_reg  <=  0;
        r_last      <=  0;
        r_valid     <=  0;
        state       <=  0;
        counter     <=  0;
        count1      <=  0;
        count2      <=  0;
        
        layer_done <= 0;
    end
    
    else begin
        
        case(state)
            3'd0:begin
                //idle state
                layer_done <= 0;
                if(i_start) begin
                    layer_done <= 0;
                    state <= 3'd1;
                    r_acc_next_add <= i_acc_address;
                    r_layer_next_add<= i_op_start;
                    r_acc_start_add <= i_acc_address;
                    r_layer_start_add <= i_op_start;
                    r_burst_len1 <= BURST_LENGTH;
                    r_burst_len2 <= BURST_LENGTH_2;
                end
            end
            
            3'd1:
            begin
                if(k_ctr==i_kernel_itr) begin
                    state <= 0;
                    layer_done <= 1;
                    k_ctr <= 0;
                end
                else begin
                    layer_done <= 0;
                    state <= 2;
                    acc_add_reg1 <= (r_acc_start_add+((r_burst_len1+1)<<$clog2(AXI_DATA_BYTES)));
                    op_add_reg1 <= (r_layer_start_add+((r_burst_len2+1)<<$clog2(AXI_DATA_BYTES)));
                end
            end

            /*
            3'd1:
            begin
            if(k_ctr==i_kernel_itr) begin
                state <= 0;
                layer_done <= 1;
                k_ctr <= 0;
            end
            else begin
                layer_done <= 0;
                if(c_ctr==r_channel_itr-1) r_burst_len<= r_burst_len2;
                else r_burst_len <= r_burst_len1;
                if(result_int)
                begin
                  state <= 3'd2;
                end
                else begin
                  wr_req_reg<= 1'b0;
                  r_valid   <= 1'b0;
                  r_addr    <= r_addr;
                  r_last    <= r_last;
                  state     <= 3'd1;
                end
           end
           end
           */ 
           
            3'd2: begin
                
                if(c_ctr==r_channel_itr-1) begin
                    state <= 3;
                    if(op_add_reg1 > r_layer_stop_add) begin
                        r_burst_len2 <= ((r_layer_stop_add-r_layer_start_add)>>$clog2(AXI_DATA_BYTES))-1;
                    end
                    else begin
                        r_burst_len2 <= BURST_LENGTH_2;
                    end
                end
                else begin
                    if(Acc_onchip) begin            //Added to skip the DRAM requests if Acc_onchip is enabled.
                        if(Tail_done) state <= 7;   //Wait for Tail_done and go to state 7 to update th c_ctr.
                        else          state <= 2;   //If c_ctr reaches c_iter-1 then proceed in usual way of DRAM requests.
                    end
                    else begin
                        state <= 3;
                        if(acc_en==0) begin
                            if(acc_add_reg1 > r_acc_stop_add) begin
                                r_burst_len1 <= ((r_acc_stop_add-r_acc_start_add)>>$clog2(AXI_DATA_BYTES))-1;
                            end
                            else begin
                                r_burst_len1 <= BURST_LENGTH;
                            end
                        end
                        else begin
                            if(acc_add_reg1 > r_acc_stop_add) begin
                                r_burst_len1 <= ((r_acc_stop_add-r_acc_start_add)>>$clog2(AXI_DATA_BYTES))-1;
                            end
                            else begin
                                r_burst_len1 <= BURST_LENGTH_1;
                            end
                        end
                    end
                end
            end

            3'd3: begin
                if(c_ctr==r_channel_itr-1) r_burst_len<= r_burst_len2;
                else r_burst_len <= r_burst_len1;
                state <= 4;
            end

            3'd4: begin
                if(result_int)
                begin
                  state <= 3'd5;
                end
                else begin
                  wr_req_reg<= 1'b0;
                  r_valid   <= 1'b0;
                  r_addr    <= r_addr;
                  r_last    <= r_last;
                  state     <= 3'd4;
                end
            end
            
            3'd5:
            begin
            layer_done<=0;
            if(c_ctr==r_channel_itr-1) begin
                r_valid     <= 1'b1;
                wr_req_reg  <= 1'b1;
                r_burst_len<= r_burst_len;                
                if(counter==3) begin
                    r_last   <= 1'b1;
                    counter <= 2'd0;
                    wr_req_reg <= 1'b0;
                    r_addr  <=  r_layer_start_add[7:0];
                    state        <=  3'd6;  
                    count2 <= count2 + (NUMBER_OP*(r_burst_len+1)); 
                end
                else begin
                    for(i=0;i<3;i=i+1) begin
                        if(counter==i) begin
                            r_addr  <=  r_layer_start_add[32-(i*8)-1-:8];
                        end
                    end
                    counter      <=  counter+1;
                    r_last       <=  0;
                    state        <=  3'd5;
                end
            end
            
            else begin
                r_valid     <= 1'b1;
                wr_req_reg  <= 1'b1;
                r_burst_len<= r_burst_len;                
                if(counter==3) begin
                    r_last   <= 1'b1;
                    counter <= 2'd0;
                    wr_req_reg <= 1'b0;
                    r_addr  <=  r_acc_start_add[7:0];
                    state        <=  3'd6;  
                    count1 <= count1 + (NUMBER_ACC*(r_burst_len+1)); 
                end
                else begin
                    for(i=0;i<3;i=i+1) begin
                        if(counter==i) begin
                            r_addr  <=  r_acc_start_add[32-(i*8)-1-:8];
                        end
                    end
                    counter      <=  counter+1;
                    r_last        <=  0;
                    state        <=  3'd5;
                end
            end
            end
            
            3'd6:
            begin
                layer_done <= 0;
                r_last <= 0;
                r_valid   <= 0;
                wr_req_reg <= 0;
                if(c_ctr < r_channel_itr-1) begin
                    if(count1==i_imag_dim) begin
                        //count1 <= 0;
                        //r_acc_start_add<=r_acc_start_add+((r_burst_len1+1)<<5);
                        //state <= 4;
                        if(data_last) begin 
                            state <= 7;
                            count1 <= 0;
                            // r_acc_start_add<=r_acc_start_add+((r_burst_len+1)<<$clog2(AXI_DATA_BYTES));
                        end
                        else begin
                            state<=state;
                            r_acc_start_add<=r_acc_start_add;
                        end
                    end
                    else begin
                        count1 <= count1;
                        //r_acc_start_add<=r_acc_start_add+((r_burst_len1+1)<<5);
                        //state <= 1;
                        if(data_last) begin 
                            state <= 1;
                            r_acc_start_add<=r_acc_start_add+((r_burst_len+1)<<$clog2(AXI_DATA_BYTES));
                        end
                        else begin
                            state<=state;
                            r_acc_start_add<=r_acc_start_add;
                        end
                    end
                end
                else if(c_ctr==r_channel_itr-1) begin
                    if(count2==i_imag_dim_2) begin
                        //state <= 4;
                        if(data_last) begin 
                            state <= 7;
                            r_layer_start_add<=r_layer_start_add+((r_burst_len+1)<<$clog2(AXI_DATA_BYTES));
                            count2 <= 0;
                        end
                        else begin
                            state<=state;
                            r_layer_start_add<=r_layer_start_add;
                        end
                    end
                    else begin
                        //count2 <= count2 + (8*(r_burst_len2+1));
                        
                        //state <= 1;
                        if(data_last) begin
                            state <= 1;
                            r_layer_start_add<=r_layer_start_add+((r_burst_len+1)<<$clog2(AXI_DATA_BYTES));
                        end
                        else begin 
                            state<=state;
                            r_layer_start_add<=r_layer_start_add;
                        end
                    end
                end
                  
            end
            
            3'd7: begin
                r_layer_start_add<=r_layer_start_add;
                r_layer_next_add <= r_layer_start_add;
                layer_done <= 0;
                if(c_ctr == r_channel_itr-1) begin
                    r_acc_start_add <= i_acc_address;
                    r_acc_next_add <= i_acc_address;
                    r_burst_len2 = BURST_LENGTH_2;
                    c_ctr <= 0;
                    k_ctr <= k_ctr + 1;
                end
                else begin
                    r_acc_next_add <= i_acc_address;
                    r_acc_start_add <= i_acc_address;
                    c_ctr <= c_ctr + 1;
                    k_ctr <= k_ctr;
                    if(acc_en==0) r_burst_len1 <= BURST_LENGTH;
                    else r_burst_len1 <= BURST_LENGTH_1;
                end
                state <= 1;
            end
                        
            default: begin
                layer_done<=layer_done;
                wr_req_reg<= wr_req_reg;
                r_valid   <= 1'b0;
                r_addr    <= r_addr;
                r_last    <= r_last;
                r_burst_len<= r_burst_len;
                state     <= 3'd0;
            end
            
        endcase       
    end
    
end


reg wr_req_reg_delayed = 0;
always@(posedge clkin) begin 
    wr_req_reg_delayed <= wr_req_reg; 
end

endmodule