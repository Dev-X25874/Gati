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
    // input i_dlen,                        //Comes from mipi, indicated number of data packets to be written
    input i_data_valid,                     //comes from mipi fifo
    input [W_DATA-1 : 0] i_data,            //comes from mipi fifo
    output [W_DATA-1 : 0] o_start_address,  //sends initial address to write request controller
    output [W_DATA-1 : 0] o_data_size,      //sends total number of bytes of data to write request controller, for eg, 98x4
    output [N_FIFO-1 : 0] o_write_enable,   //sends write enable signal to fifo array
    output [W_DATA-1 : 0] o_data,           //sends data to store into fifo array
    output o_valid,
	output reg soft_start
);

reg valid = 0;
reg [2:0] state = 0;
reg [3:0] wr_counter = 0;
reg [W_DATA-1 : 0] counter = 0;
reg [W_DATA-1 : 0] start_addr = 0;
reg [W_DATA-1 : 0] data_size = 0;       //indicates total number of bytes in all the data packets
reg [W_DATA-1 : 0] data = 0;
reg [N_FIFO-1 : 0] wren = 0;
	reg [31:0] page_number=0;
assign o_data = data;
assign o_write_enable = wren;
assign o_data_size = data_size;
assign o_start_address = start_addr;
assign o_valid = valid;
	reg start=0;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        counter <= 0;
        start_addr <= 0;
        data_size <= 0;
        data <= 0;
        wren <= 0;
        wr_counter <= 0;
    end else begin
        case (state)
           3: begin
			   soft_start<=0;
                if(i_data_valid)begin
                    page_number <= i_data;
                    valid <= 1'b1;
                    state <= 0;
                end
            end


			0: begin
                if(i_data_valid)begin
                    start_addr <= i_data;
                    valid <= 1'b1;
                    state <= 1;
					if(page_number==0) begin 
						start<=1;
					end 
                end
            end

            1: begin
               if(i_data_valid)begin
                    data_size <= i_data;
                    valid <= 1'b1;
                    state <= 2;
               end
            end

            2: begin
                if(i_data_valid)begin
                    //reset everything once all the data from mipi packet is written
                    if(counter == (data_size >> 2))begin
                        counter <= 0;
						state <= 0;
						page_number<=i_data;
						if(start) begin 
							soft_start<=1;
							state<=3;
						end 
			//			start_addr<=i_data;
                        wr_counter <= 0;
                        wren <= 0;
                        data <= 0;
                    end else begin
                        counter <= counter + 1;
                        data <= i_data;
                        valid <= 1'b1;
                        //asserting write enable signal, one by one,for each fifo in fifo array
						if (wr_counter == N_FIFO-1 ) begin 
                            wr_counter <= 0;
						end
						else begin 
							wr_counter <= wr_counter + 1;
						end
						wren[wr_counter] <= 1;

                       if(N_FIFO > 1) begin
                           if (wr_counter == 0)
                               wren[N_FIFO - 1] <= 0;
                           else
                               wren[wr_counter - 1] <= 0;
                       end
                    end
                end 
				else begin
                    wr_counter <= wr_counter;
                    wren <= 0;
                end
            end

            default: state <= 3; 
        endcase
    end
end

endmodule
