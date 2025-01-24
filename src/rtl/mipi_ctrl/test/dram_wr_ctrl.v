module dram_wr_ctrl#(
    parameter W_ADDR = 8,
    parameter N_FIFO = 8,
    parameter W_BURST_LEN = 8
)(
    input i_clk,
    input i_rstn,
   input i_dv,
	input s_start,
	input i_select,
    input i_write_ready,
    input [W_BURST_LEN-1 : 0]i_burst_length,
    output [N_FIFO-1 : 0] o_fifo_read_enable,
    output o_data_last,
	output reg soft_start,
    output o_data_valid
);
reg data_last = 0;

reg dv = 0;
reg s_flag=0;
wire [N_FIFO-1 : 0] rden;
wire [((W_ADDR + 1) * N_FIFO)-1 : 0] fifo_occupants;
reg data_valid;

	reg [1:0] state;
    reg [W_BURST_LEN-1 : 0] r_blen;
    reg [W_BURST_LEN : 0] count_blen;
	reg DataWrLast;
    wire DataWrEnd;

	always @(posedge i_clk) begin 
        if (!i_rstn) s_flag <= 0;
        else begin
            if(s_start) begin 
                s_flag<=1;	
            end
            else if(soft_start) begin
                s_flag <= 0;
            end
        end
	end

    always@(posedge i_clk)begin
        if (!i_rstn) begin
            count_blen <= 0;
            state <= 2'd0;
			soft_start <= 0;
        end else begin
            case(state)
                2'd0:begin
					soft_start <= 0;
                    if(i_select==1) begin
                        state <= 2'd1;
                        count_blen <= 0;
                        data_valid <= 1'b0;
                        r_blen <= i_burst_length;
                    end
                    else begin
                        state <= 0;
                        count_blen <= 0;
                        data_valid <= 1'b0;
                        r_blen <= r_blen;
                    end
                end

                2'd1:begin
                    if(i_select==1)
                        state <= 2'd2;
                    else
                        state <= 2'd0;
                end

                2'd2:begin
                    // if(r_blen == 0) begin
                    //     if(i_write_ready) begin
                    //         data_valid <= 1'b1;
                    //         state <= 3;
                    //         count_blen <= 0;
                    //         if(s_flag) begin 
                    //             soft_start<=1;
                    //         end
                    //     end
                    // end
                        
                    // else begin
                    // if((count_blen > r_blen) && DataWrEnd) begin
                    if(count_blen>r_blen) begin
                        if(i_write_ready & data_valid) begin
                            data_valid <= 1'b0;
                        end
                        if(o_data_last) begin
                            state <= 0;
                            count_blen <= 0;
                        end
						if(s_flag) begin 
							soft_start<=1;
					    end
                    end
                    else if (count_blen == r_blen) begin
                        if(i_write_ready) begin
                            data_valid <= 1'b1;
                            count_blen <= count_blen + 1;
                            state <= 2'd2;
                        end
                        else begin
                            data_valid <= data_valid;
                            count_blen <= count_blen;
                            state <= 2'd2;
                        end
                    end
                    else begin
                        if(i_write_ready) begin
                            data_valid <= 1'b1;
                            count_blen <= count_blen + 1;
                            state <= 2'd2;
                        end
                        else begin
                            data_valid <= data_valid;
                            count_blen <= count_blen;
                            state <= 2'd2;
                        end
                    end
                    // end
                end
                
                default: begin
                    state <= 0;
                    count_blen <= 0;
                    data_valid <= 0;
                end

            endcase
        end
    end

    assign rden = (data_valid & i_write_ready) ? {N_FIFO{1'b1}} : {N_FIFO{1'b0}};

    assign DataWrEnd = (r_blen==0)? (DataWrLast & i_write_ready) : (DataWrLast & dv & i_write_ready);

    // assign DataWrEnd = DataWrLast & data_valid & i_write_ready;
    // assign DataWrEnd = DataWrLast & i_write_ready;

    always@( posedge i_clk)
    begin
        if(!i_rstn)                                                    DataWrLast <= 1'b0;
        else if (data_valid && (r_blen==0))                            DataWrLast <= 1'b1;
        else if (data_valid && i_write_ready && (count_blen==r_blen+1))DataWrLast <= 1'b1;
        else if (DataWrEnd)                                            DataWrLast <= 1'b0;
        // else                                                           DataWrLast <= 1'b0;
    end

reg f_DataWrEnd;

// always@(posedge i_clk) begin
    // added for blen =0 : Check it
    // if(r_blen==0) begin
    //     data_last <= DataWrLast; 
    // end
    // else begin
        // f_DataWrEnd <= DataWrEnd;
        // data_last <= f_DataWrEnd;
    // end
// end

reg dv1 = 0;
always@(posedge i_clk) begin
    if(!i_rstn) dv <= 0;
    else begin
        if(r_blen==0) begin
            dv  <= data_valid;
        end
        else begin
            if(o_data_last) dv <= 1'b0;
            else if(data_valid) dv <= 1'b1;
        end
    end
end

assign fifo_occupants = {N_FIFO{1'b0,r_blen}};
assign o_data_valid = dv;
assign o_fifo_read_enable = rden;
assign o_data_last = (r_blen==0)? DataWrLast : DataWrEnd;
    
endmodule
