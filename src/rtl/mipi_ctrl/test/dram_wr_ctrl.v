module dram_wr_ctrl#(
    parameter W_ADDR = 8,
    parameter N_FIFO = 8,
    parameter W_BURST_LEN = 8
)(
    input i_clk,
    input i_rstn,
   input i_dv,
	input i_select,
    input i_write_ready,
    input [W_BURST_LEN-1 : 0]i_burst_length,
    output [N_FIFO-1 : 0] o_fifo_read_enable,
    output o_data_last,
    output o_data_valid
);
reg data_last = 0;
reg dv = 0;
reg [2:0] state = 0;
reg [W_BURST_LEN-1 : 0] rd_counter = 0;
reg [N_FIFO-1 : 0] rden = 0;
reg [W_BURST_LEN-1 : 0] r_blen = 0;
wire [((W_ADDR + 1) * N_FIFO)-1 : 0] fifo_occupants;
assign fifo_occupants = {N_FIFO{1'b0,r_blen}};
//assign o_data_valid = dv;
assign o_fifo_read_enable = rden;
assign o_data_last = data_last;
	reg  prev=0;
	assign o_data_valid=i_dv;
	always @(posedge i_clk) begin 
		prev<=i_write_ready;
	end
always @(posedge i_clk)begin
    if(~i_rstn)begin
        data_last <= 0;
        rden <= 0;
        state <= 0;
        dv <= 0;
    end else begin
        case (state)
            0:begin
				data_last<=0;
                if(i_select)begin
                    r_blen <= i_burst_length;
                    if(i_write_ready)begin
                        state <= 1;
						rden <= {N_FIFO{1'b1}};
                    end 
                end
            end

			1: begin
					if(prev) begin 
                        rden <= {N_FIFO{1'b1}};
                        rd_counter <= rd_counter + 1;
                        state <= 2;
					end
					else begin 
						rden<=0;
					end
            end

            2: begin
				if(prev) begin 

               		 if(rd_counter == r_blen)begin
               		     rd_counter <= 0;
               		     rden <= 0;
               		     state <= 0;
               		     data_last <= 1'b1;
               		     dv <= 1'b1;
               		 end 
               	      else begin
               		     rden <= {N_FIFO{1'b1}};
               		     rd_counter <= rd_counter + 1;
               		     dv <= 1'b1;
               		 end
				end
				else begin 
					rden<=0;
					dv<=0;
				end

            end

            default: state <= 0;
        endcase
    end
end
    
endmodule
