`define SOF {32{1'b1}}
/*
    Receives data and data valid from mipi fifo,
    segregates AXI address, data size and send write request 
    along with the data into fifo array.
*/
module fifo_wr_ctrl#(
    parameter W_DATA = 32,
    parameter N_FIFO = 8
)(
    input i_clk,
    input i_rstn,                           //Active low reset
    input i_data_valid,                     //comes from mipi fifo
    input [W_DATA-1 : 0] i_data,            //comes from mipi fifo
    input i_rd_en_size_address, 			//enable for data_size and start_address
	output o_empty_size_address,
	output o_valid_size_address, 			//valid data_size or start_address
	output [W_DATA-1 : 0] o_rd_size_address,//sends data_size or start_address
	output [N_FIFO-1 : 0] o_write_enable,   //sends write enable signal to fifo array
    output [W_DATA-1 : 0] o_data,           //sends data to store into fifo array
    output o_valid,
	output reg soft_start,
	output reg eop
);
	localparam IDLE=2'd0;
	localparam DATA_SIZE=2'd1;
	localparam ADDR=2'd2;
	localparam NEXT=2'd3;
	localparam sof = 32'hFF_FF_FF_FF;

reg valid = 0;
reg [1:0] state = 0;
reg [3:0] wr_counter = 0;
reg [W_DATA-1 : 0] counter = 0;
reg [W_DATA-1 : 0] start_addr = 0;
reg [W_DATA-1 : 0] data_size = 0;       //indicates total number of bytes in all the data packets
reg [W_DATA-1 : 0] data = 0;
reg [N_FIFO-1 : 0] wren = 0;
assign o_data = data;
assign o_write_enable = wren;
assign o_valid = valid;
	reg last=0;
	reg 				r_i_data_valid;                     //comes from mipi fifo
    reg [W_DATA-1 : 0]  r_i_data;            //comes from mipi fifo


always @(posedge i_clk)begin
    if(~i_rstn)begin
        counter <= 0;
		state <= 0;
        start_addr <= 0;
        data_size <= 0;
        data <= 0;
		state<=IDLE;
        wren <= 0;
        wr_counter <= 0;
    end 
	else begin
		case(state) 
			IDLE:begin 
				soft_start<=0;
				last<=0;

				if(i_data_valid && (i_data==sof)) begin 
					state<=DATA_SIZE;
				end

				else  begin 
					state<=IDLE;
				end

			end
			DATA_SIZE: begin 
			eop <= 0;
				if(i_data_valid) begin 
					data_size <= i_data;
					counter <= i_data;
					wr_en_dai <= 1'b1;	//write enable data_size-address fifo
					wdata_dao <= i_data;//data_size for fifo 
					state<=ADDR;
				end
				else begin 
					data_size<=0;
					state<=DATA_SIZE;
				end

			end

			ADDR: begin
				counter<=data_size; 
					if(data_size==0) begin 
						last<=1;
						state<=NEXT;
						wr_en_dai<=1'b0;
					end
					else if(i_data_valid)  begin 
						start_addr<=i_data;
						state<=NEXT;
						wr_en_dai<=1'b1; 	//write enable data_size-address fifo
						wdata_dao<= i_data; //start_address for fifo 
					end
					else begin 
						state<=ADDR;
						wr_en_dai<=1'b0;
					end
			end


			NEXT: begin 
				wr_en_dai<=1'b0; //write enable data_size-address fifo
				if((i_data_valid==1) && (counter!=0) && (~last)) begin 
					if(data_size>0)begin 
						data<=i_data;
						valid <= 1'b1;	
						counter<=counter-4;
					end
					else  begin 
						data<=0;
						valid<=1'b0;
						counter<=counter;
					end

					 
                	wren[wr_counter] <= 1;
					if (wr_counter == N_FIFO-1 ) begin 
                          wr_counter <= 0;
                	end
                	else begin 
                		wr_counter <= wr_counter + 1;
                	end
                                                        
                     if(N_FIFO > 1) begin
                         if (wr_counter == 0)
                             wren[N_FIFO - 1] <= 0;
                         else
                             wren[wr_counter - 1] <= 0;
                     end
				end
				else if(last) begin
					soft_start<=1;
					state<=IDLE;
					wren<=0;
				end

				else if((i_data_valid==1) && (i_data==sof) && (counter==0)) begin 
						state<=DATA_SIZE;
						wren<=0;
						eop <= 1;
				end
				else begin 
					wren<=0;
					valid<=0;
				end
			end
		endcase

	end
end

//FIFO for Data_Size and Starting_Address
wire overflow_dao, full_dao;// o_valid_dao;
reg wr_en_dai;// rd_en_dai, valid_f; 
wire [6:0] datacount_dao;
reg [W_DATA-1:0] wdata_dao;

sync_fifo # (
    .W_DATA(W_DATA),
    .OUTPUT_REG(0),
    .W_ADDR(6)
  )
  sync_fifo_inst (
    .almost_full_o(),
    .prog_full_o(),
    .full_o(full_dao),
    .overflow_o(overflow_dao),
    .wr_ack_o(),
    .empty_o(o_empty_size_address),
    .almost_empty_o(),
    .underflow_o(),
    .clk_i(i_clk),
    .wr_en_i(wr_en_dai),
    .rd_en_i(i_rd_en_size_address),
    .wdata(wdata_dao),
    .datacount_o(datacount_dao),
    .rst_busy(),
    .rdata(o_rd_size_address),
    .a_rst_i(~i_rstn),
    .o_valid(o_valid_size_address)
  );

/* Logic added for debugging */
reg [15:0] counter1;
always@(posedge i_clk) begin
	if(~i_rstn) begin
		counter1 <= 0;
	end
	else begin
		// if(counter1 == 16'd33) begin
		// 	counter1 <= 0;
		// end
		// else begin
			if(counter==0 && i_data==sof && state==3) begin
				counter1 <= counter1 + 1;
			end
		// end
	end
end
			
endmodule