module iteration_cnt #(
    parameter CITER_CNT_WIDTH = 12,
    parameter KITER_CNT_WIDTH = 12
)
(
    input i_clk,
    input i_start,
    input rst,
    input CONV_FC,
    
    output o_layer_done,
    output o_iter_done,
    output o_c_done,
    
    input im2col_done,
    input SA_psum_fifo_empty,
    input Tail_done,
    input op_fifo_empty,
    input FC_done,
    
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

    //'ack' signals for config blk
    output Conv_Ack,
    output OpBlock_Ack,
    output Tail_Ack,
    
    //io signals
    output [6:0] kernal_count, // represents the current kernal iteration number 
    output [6:0] channel_count // represents the current channel iteration number 
);

reg [KITER_CNT_WIDTH:0] k_ctr = 0; //k_iter
reg [CITER_CNT_WIDTH:0] c_ctr = 0; //c_iter
reg iter_done;
reg c_done;
reg SA_done;
wire layer_done;

reg [2:0] state = 0;

assign o_iter_done = iter_done;
assign o_layer_done = r_layer_done;
assign o_c_done = c_done;

assign kernal_count =  k_ctr [6:0]; // represents the current kernal iteration number
assign channel_count =  c_ctr [6:0]; // represents the current channel iteration number
// assign layer_done = (k_ctr == k_iter);

//assign c_done = (c_iter==1)? r_iter_done: ((c_ctr==c_iter-1)?1:0);

//assign o_c_done = c_done & ~r_c_done[0];
/*
reg [1:0] r_c_done;
always @(posedge i_clk) begin
    if(!rst) r_c_done <= 2'd0;
    else begin
        r_c_done[1] <= c_done;
        r_c_done[0] <= r_c_done[1];
    end
end
*/
    reg r_i_start;
    reg r_CONV_FC;
    reg r_im2col_done;
    reg r_SA_psum_fifo_empty;
    reg r_Tail_done;
    reg r_op_fifo_empty;
    reg r_FC_done;
	reg [CITER_CNT_WIDTH-1:0] r_c_iter,sub_iter;
    reg [KITER_CNT_WIDTH-1:0] r_k_iter;
    
    //Enable signals from instruction
    reg r_BIAS_EN;
    reg r_RELU_EN;    //relu and quant enable
    reg r_QUANT_EN;
    reg r_POOL_EN;
    reg r_ACC_EN;
    reg r_FC_BIAS_EN;


//reg r_iter_done;
reg r_layer_done;
//always@(posedge i_clk) r_iter_done <= iter_done;
	always@(posedge i_clk) begin 
	//	r_layer_done <= layer_done;
		r_i_start<=i_start;
		r_CONV_FC<=CONV_FC;
		r_im2col_done<=im2col_done;       	
        r_SA_psum_fifo_empty<=SA_psum_fifo_empty;
        r_Tail_done<=Tail_done;
        r_op_fifo_empty<=op_fifo_empty;
        r_FC_done<=FC_done;
		// r_c_iter<=c_iter-1;
		// r_k_iter<=k_iter;
		r_BIAS_EN<=BIAS_EN;
		r_RELU_EN<=RELU_EN;
		r_QUANT_EN<=QUANT_EN;
		r_POOL_EN<=POOL_EN;
		r_ACC_EN<=ACC_EN;
		r_FC_BIAS_EN<=FC_BIAS_EN;
		
	end
always@(posedge i_clk) begin
    if(!rst) begin
        c_ctr <= 0;
        k_ctr <= 0;
        state <= 0;
		iter_done <= 0;
        c_done <= 0;
        SA_done <= 0;
        r_layer_done <= 0;
    end
    else begin
        case(state)
        3'd0:begin
            if(r_i_start) begin
                state <= 3'd1;
                r_c_iter<=c_iter-1;
		        r_k_iter<=k_iter;
            end
			c_ctr <= 0;
            k_ctr <= 0;
			r_layer_done <= 1'b0;
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
                end 
                else begin
                    if(r_CONV_FC==0)begin
                        if(r_im2col_done) state <= 3'd2;
                    end
                    else begin
                        if(r_FC_done) state <= 3'd3;
                    end
                end
            end
        end
        
        3'd2: begin
            if(r_SA_psum_fifo_empty) begin
                state <= 3'd3;
                SA_done <= 1'b1;
            end
            else begin
                state <= 3'd2;
                SA_done <= 1'b0;
            end
        end
        
        3'd3: begin
            SA_done <= 1'b0;
            if(r_Tail_done) state <= 3'd4; //Tail_done status
        end
        
        3'd4: begin
            if(r_op_fifo_empty) begin
                iter_done <= 1;
                state <= 3'd5; //iter_done status
            end
            else begin
                iter_done <= 0;
                state <= 3'd4;
            end
        end
        
        3'd5:begin
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
 

//Generation of enable 'en' signals for tail and o/p block based on c_ctr and c_iter
//Also check the "EN" signals of instructions.
// wire acc_en, relu_en, quant_en, bias_en, pool_en, en;    //en-for shift register
// wire fc_bias_en;

/*
assign  acc_en      =   (ACC_EN==0)?0 : ((c_ctr==0)?0:1);
assign  relu_en     =   (RELU_EN==0)?0 : ((c_ctr==c_iter-1)?1:0);
assign  quant_en    =   (QUANT_EN==0)?0 : ((c_ctr==c_iter-1)?1:0);
assign  bias_en     =   (BIAS_EN==0)?0 : ((c_ctr==c_iter-1)?1:0);
assign  fc_bias_en  =   (FC_BIAS_EN==0)?0 : ((c_ctr==c_iter-1)?1:0);
assign  pool_en     =   (POOL_EN==0)?0 : ((c_ctr==c_iter-1)?1:0);
assign  en          =   (c_ctr==c_iter-1)?1:0;
*/

always@(posedge i_clk) begin
    if(!rst) begin
        acc_en  <=  0;
    end
    else begin
        if(r_ACC_EN==0) begin
            acc_en <= 0;
        end
        else begin
            if(c_ctr==0) acc_en <= 0;
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

//Generation of 'ack' signals for config blk
assign Conv_Ack     =   ((c_ctr==r_c_iter)&&(k_ctr==r_k_iter-1))? SA_done : 0;
//assign OpBlock_Ack  =   ((c_ctr==c_iter-1)&&(k_ctr==k_iter-1))? iter_done : 0;
assign OpBlock_Ack  =   o_layer_done;
assign Tail_Ack     =   ((c_ctr==r_c_iter)&&(k_ctr==r_k_iter-1))? r_Tail_done : 0;

endmodule
