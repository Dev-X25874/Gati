/*module col_buff_controller#(
	parameter COL = 3,
	parameter ROW = 9,
	parameter W_ADDR = 8
)(
	input i_clk,
	input i_fifo_empty,
	input [W_ADDR : 0] occupants,
	output o_read_enable,
	output sr_enable
);

reg rden = 0;
reg sren = 0;
reg [($clog2(COL)) -1 : 0] counter = 0;
reg [1:0] state = 0;

assign o_read_enable = rden;
assign sr_enable = sren;

always @(posedge i_clk) begin
	if(i_fifo_empty == 0 && occupants == (ROW * COL))begin
		if((occupants == (ROW * COL)) || (occupants > 0))begin
			rden <= 1'b1;
			sren <= 1'b1;
			counter <= counter + 1;	
		end else begin
			rden <= 0;
			sren <= 0;
			counter <= 0;
		end	
	end else begin
		rden <= 0;
		sren <= 0;	
		counter <= 0;	
	end
end
endmodule
*/
module col_buff_controller#(
    parameter COL = 3,
    parameter ROW = 9,
    parameter W_ADDR = 8
)(  input i_clk,
    input i_fifo_empty,
    input [W_ADDR : 0] occupants,
    output reg o_read_enable = 0,
    output reg sr_enable = 0
);

reg [1:0] state = 0;
reg [3:0] counter = 0;

always @(posedge i_clk)begin
    case(state)
        0: begin
            counter <= 0;
            sr_enable <= 0;
            o_read_enable <= 0;
            //(ROW * COL) will be total number of occupants and, in the end, we will be sending 0
            if((occupants == ((ROW * COL) + 1)) && (i_fifo_empty == 0))begin
                state <= 1;
            end
        end
        
        1: begin
            //if(counter == (ROW * COL)-1))begin
            if(counter == 9)begin  
              state <= 0;
            end else begin
                //state <= 2;
            o_read_enable <= 1'b1;
            sr_enable <= 1'b1;
            counter <= counter + 1;
            end
        end
        /*
        2: begin
            o_read_enable <= 1'b1;
            sr_enable <= 1'b1;
            counter <= counter + 1;
            state <= 1;
        end
        
        3: begin
            counter <= counter + 1;
            state <= 1;
        end*/
        
    endcase
end


endmodule

//module col_buff_controller#(
//    parameter W_ADDR = 8,
//    parameter COL = 3,
//    parameter ROW = 9
//)(
//    input i_clk,
//    input i_fifo_empty,
//    input [W_ADDR : 0] occupants,
//    output o_read_enable,
//    output reg sr_enable = 0
//);
//reg rden = 0;
//assign o_read_enable = rden;

//    always @(posedge i_clk)begin
//        if(occupants == ROW * COL) begin
//            if(i_fifo_empty == 0) begin
//                rden <= 1;
//                sr_enable <= 1;
//            end else begin
//                rden <= 0;
//                sr_enable <= 0;
//            end
//        end
//    end
    
//endmodule
