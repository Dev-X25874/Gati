`include "../common/instructions.vh"
`include "../common/arch_param.vh"

module iteration_cnt #(
    parameter CITER_CNT_WIDTH = 12,
    parameter KITER_CNT_WIDTH = 12,
    parameter OutputBlock_AccumulantReadFirst_WIDTH = 1,
    parameter NUM_INSTRUCTIONS = 6
)
(
    input i_clk,
    input i_start,
    input rst,
    input CONV_FC,
    
    output o_layer_done,
    output o_iter_done,
    output o_c_done,
    output o_SA_done,
    
    input im2col_done,
    input SA_psum_fifo_empty,
    input Tail_done,
    input op_fifo_empty,
    input FC_done,
    input EW_done,
    input RT_done,
    input pool_done,

   // input [15:0] img_w, //width of input image matrix
    input [CITER_CNT_WIDTH-1:0] c_iter,
    input [KITER_CNT_WIDTH-1:0] k_iter,
    
    //Enable signals from instruction
    input BIAS_EN,
    input RELU_EN,    //relu and quant enable
    input QUANT_EN,
    input POOL_EN,
    input ACC_EN,
    input FC_BIAS_EN,

    //enable signals for tail blocks
    output reg acc_en,
    output reg relu_en,
    output reg quant_en,
    output reg bias_en,
    output reg fc_bias_en,
    output reg pool_en,
    output reg en,   //enable signal for shift register to select accumulant o/p and quantized o/p
    output [6:0] kernal_count, // represents the current kernal iter
    output [6:0] channel_count, // represents the current channel iter
    input [OutputBlock_AccumulantReadFirst_WIDTH-1:0] OutputBlock_AccumulantReadFirst,
    output reg [NUM_INSTRUCTIONS-1:0] ack_opcode,
    input [NUM_INSTRUCTIONS-1:0] valid_opcode
);

    reg [KITER_CNT_WIDTH:0] k_ctr = 0; //k_iter
    reg [CITER_CNT_WIDTH:0] c_ctr = 0; //c_iter
    reg iter_done;
    reg c_done;
    reg SA_done;
    wire layer_done;

    reg [2:0] state = 0;

    reg [NUM_INSTRUCTIONS-1:0] done_reg;
    wire [NUM_INSTRUCTIONS-1:0] done_input;


// assigning the done_input signals\
// To Add new Mega Block, add the corresponding done_input signal here

    assign done_input[`OP_CONV] = conv_done;
    assign done_input[`OP_FC] = r_FC_done;
    assign done_input[`OP_EltWise] = r_EW_done;
    assign done_input[`OP_TRANSPOSE] = r_RT_done;
    assign done_input[`OP_TailBlock] = r_Tail_done;
    assign done_input[`OP_OutputBlock] = r_op_fifo_empty;
    
    `ifdef MEGA_MAX
    reg r_pool_done;
    assign done_input[`OP_POOL] = r_pool_done; 
    `endif

    assign o_SA_done = SA_done;
    assign o_iter_done = iter_done;
    assign o_layer_done = r_layer_done;
    assign o_c_done = c_done;

    assign kernal_count =  k_ctr [6:0]; // represents the current kernal iteration number
    assign channel_count =  c_ctr [6:0]; // represents the current channel iteration number

    reg r_i_start;
    reg r_CONV_FC;
    reg r_im2col_done;
    reg r_SA_psum_fifo_empty;
    reg r_Tail_done;
    reg r_op_fifo_empty;
    reg r_FC_done;
    reg r_EW_done;
    reg r_RT_done;
	reg [CITER_CNT_WIDTH-1:0] r_c_iter,sub_iter;
    reg [KITER_CNT_WIDTH-1:0] r_k_iter;
    
    //Enable signals from instruction
    reg r_BIAS_EN;
    reg r_RELU_EN;    //relu and quant enable
    reg r_QUANT_EN;
    reg r_POOL_EN;
    reg r_ACC_EN;
    reg r_FC_BIAS_EN;
    reg [NUM_INSTRUCTIONS-1:0] r_valid_opcode;

    reg conv_done = 0; // conv_done signal to be used in the state machine
    reg [1:0] state_conv_done = 2'b0 ; // state machine to generate conv_done signal usages one cycle after im2col_done and SA_psum_fifo_empty are both high
        // usage gray code to avoid glitches

    // State machine to generate conv_done signal
    // This state machine waits for im2col_done and SA_psum_fifo_empty to be high Once both are high, it sets conv_done to 1 for one cycle

    always @(posedge i_clk) begin
        if(!rst) begin
            conv_done <= 0;
            state_conv_done <= 2'b00;
            SA_done <= 0;
        end
        else begin
            case(state_conv_done)
            2'b00: begin
                if(r_im2col_done) begin
                    state_conv_done <= 2'b01;
                    SA_done <= 0;
                end
                else begin
                    conv_done <= 0;
                    state_conv_done <= 2'b00;
                    SA_done <= 0;
                end
            end
            2'b01: begin
                if(r_SA_psum_fifo_empty) begin
                    state_conv_done <= 2'b00;
                    conv_done <= 1; // set conv_done
                    SA_done <= 1;
                end
                else begin
                    conv_done <= 0;
                    state_conv_done <= 2'b01;
                    SA_done <= 0;
                end
            end

            default : begin
                state_conv_done <= 2'b00;
                conv_done <= 0; // reset conv_done
            end

            endcase  
        end        
    end

    //reg r_iter_done;
    reg r_layer_done;
    //always@(posedge i_clk) r_iter_done <= iter_done;
	always@(posedge i_clk) begin 
		r_i_start<=i_start;
		r_CONV_FC<=CONV_FC;
		r_im2col_done<=im2col_done;       	
        r_SA_psum_fifo_empty<=SA_psum_fifo_empty;
        r_op_fifo_empty<=op_fifo_empty;
        r_FC_done<=FC_done;
        r_EW_done<=EW_done;
        r_RT_done<=RT_done;

        `ifdef MEGA_MAX
        r_pool_done <= pool_done;
        `endif
        
		r_BIAS_EN<=BIAS_EN;
		r_RELU_EN<=RELU_EN;
		r_QUANT_EN<=QUANT_EN;
		r_POOL_EN<=POOL_EN;
		r_ACC_EN<=ACC_EN;
		r_FC_BIAS_EN<=FC_BIAS_EN;
        r_Tail_done <= Tail_done;
	end


    integer i;
    always@(posedge i_clk) begin
        if(!rst) begin
            c_ctr <= 0;
            k_ctr <= 0;
            state <= 0;
    		iter_done <= 0;
            c_done <= 0;
            r_layer_done <= 0;
            r_valid_opcode <= 0;
        end
        else begin
            case(state)
            3'd0:begin
                if(r_i_start) begin
                    state <= 3'd1;
                    r_c_iter<=c_iter-1;
    		        r_k_iter<=k_iter;
                    r_valid_opcode <= valid_opcode;
                end
    			c_ctr <= 0;
                k_ctr <= 0;
    			r_layer_done <= 1'b0;
                done_reg <= 0; //reset done_reg
            end
        
            3'd1: begin
                c_done <= 0;
                if(r_k_iter==0) state <= 0;
                else begin
                    if(k_ctr==r_k_iter) begin
                        k_ctr <= 0;
                        c_ctr <= 0;
                        state <= 3'd0;
                        r_layer_done <= 1'b1;
                        done_reg <= 0; //reset done_reg
                        r_valid_opcode <= 0; //reset valid_opcode
                    end 
                
                    else begin
                        if (r_valid_opcode == done_reg) begin 
                            state <= 3'd2;
                            iter_done <= 1;
                            done_reg <= 0; //reset done_reg
                        end 
                        else begin
                            for (i = 0 ; i < NUM_INSTRUCTIONS ; i = i+1) begin
                                if (valid_opcode[i]) begin 
                                    if (done_input[i]) done_reg[i] <= 1'b1;
                                    else done_reg[i] <= done_reg[i]; //this should be done reg
                                end 
                            end 
                        end
                    end
                end
            end
               
            3'd2:begin
                iter_done <= 0;
                if(c_ctr==r_c_iter) begin
                    c_done <= 1;
                    k_ctr <= k_ctr + 1;
                    c_ctr <= 0;
                end
                else begin
                    c_done <= 0;
                    k_ctr <= k_ctr;
                    c_ctr <= c_ctr + 1;
                end
                state <= 3'd1;
            end
        
            default: begin
                state <= 3'd0;
            end
            endcase
        end
    
    end
    
    always@(posedge i_clk) begin
        if(!rst) begin
            acc_en  <=  0;
        end
        else begin
            if(r_ACC_EN==0) begin
                acc_en <= 0;
            end
            else begin
                if(c_ctr==0 && OutputBlock_AccumulantReadFirst == 0 ) acc_en <= 0;
                else         acc_en <= 1;
            end
        end
    end

    always@(posedge i_clk)begin
        if(!rst) begin
            relu_en <= 0;
        end
        else begin
            if(r_RELU_EN==0) begin
                relu_en <= 0;
            end
            else begin
                if(c_ctr==r_c_iter) relu_en <= 1;
                else                relu_en <= 0;
            end
        end
    end

    always@(posedge i_clk)begin
        if(!rst) begin
            quant_en <= 0;
        end
        else begin
            if(r_QUANT_EN==0) begin
                quant_en <= 0;
            end
            else begin
                if(c_ctr==r_c_iter) quant_en <= 1;
                else                quant_en <= 0;
            end
        end
    end

    always@(posedge i_clk)begin
        if(!rst) begin
            bias_en <= 0;
        end
        else begin
            if(r_BIAS_EN==0) begin
                bias_en <= 0;
            end
            else begin
                if(c_ctr==r_c_iter) bias_en <= 1;
                else                bias_en <= 0;
            end
        end
    end

    always@(posedge i_clk)begin
        if(!rst) begin
            fc_bias_en <= 0;
        end
        else begin
            if(r_FC_BIAS_EN==0) begin
                fc_bias_en <= 0;
            end
            else begin
                if(c_ctr==r_c_iter) fc_bias_en <= 1;
                else                fc_bias_en <= 0;
            end
        end
    end

    always@(posedge i_clk)begin
        if(!rst) begin
            pool_en <= 0;
        end
        else begin
            if(r_POOL_EN==0) begin
                pool_en <= 0;
            end
            else begin
                if(c_ctr==r_c_iter) pool_en <= 1;
                else                pool_en <= 0;
            end
        end
    end

    always@(posedge i_clk)begin
        if(!rst) begin
            en <= 0;
        end
        else begin
            if(c_ctr==r_c_iter) en <= 1;
            else                en <= 0;
        end
    end

    integer j;
    reg [NUM_INSTRUCTIONS-1:0] prev_done;

    always @(posedge i_clk ) begin
      if (!rst) begin
        prev_done   <= 0;
        ack_opcode  <= 0;
      end else begin
        for (j = 0; j < NUM_INSTRUCTIONS; j = j+1) begin
          prev_done[j]  <= done_reg[j];
        
          // generate one-cycle ack only on rising edge
          if ((c_ctr == r_c_iter) && (k_ctr == r_k_iter - 1)) begin
            ack_opcode[j] <= done_reg[j] & ~prev_done[j];
          end else begin
            ack_opcode[j] <= 0;
          end
        end
      end
    end

endmodule