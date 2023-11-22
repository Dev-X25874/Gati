module controller #(
   parameter COL = 1,
   parameter ROW = 9,
   parameter W_ADDR = 8
) (
   input i_clk,
   input i_trigger,
   input [(COL * 32) -1 : 0] i_data,
   input [COL-1:0] i_fifo_empty,
   input [COL-1:0] i_data_valid,
   output [COL-1:0] o_fifo_read_enable,
   output o_select,
   output [(COL * 32) -1 :  0] o_data,
   input [(W_ADDR * COL) : 0] i_fifo_occupants
);
    
reg [COL-1:0] rden = 0;
reg [2:0] state = 0;
reg sel = 0;
//   reg [4:0] counter = 0;
reg [($clog2(COL * 32))-1 : 0] counter = 0;

assign o_fifo_read_enable = rden;
assign o_select = sel;

assign o_data = (~counter[0]) ? 0 : i_data;

reg [(W_ADDR * COL) : 0] replicated_value = 0;

always @(*)begin
    replicated_value <= {COL{9'b000001001}};
end

always @(posedge i_clk)begin
    case(state)
        0: begin
            if(i_fifo_empty == 0) begin
                //if(i_fifo_occupants == 1184274)begin    //Concatinating 9'd8 COL number of times
                 if(i_fifo_occupants == (replicated_value)) begin
                  state <= 1;
                end
            end
        end
        
        1: begin
            if(counter == (2 * ROW) + 1)begin
                state <= 2;
            end else begin
                counter <= counter + 1;
                sel <= 1'b1;
                if(counter[0] == 1)
                    rden <= 0;
                else 
                    rden <= ~rden;
            end
        end
        
        2: begin
            counter <= 0;
            sel <= 0;
            rden <= 0;
        end

        default : begin
            state <= 0;
        end
        
    endcase
end

/*--former
always @(posedge i_clk)begin
    case(state)
        0: begin
            if(i_fifo_empty == 0)
                state <= 1;
            else
                state <= 0;
        end
        
        1: begin
            if(counter == (2 * ROW) + 1)begin
                state <= 2;
            end else begin
                counter <= counter + 1;
                sel <= 1'b1;
                if(counter[0] == 1)
                    rden <= 0;
                else 
                    rden <= ~rden;
            end
        end
        
        2: begin
            counter <= 0;
            sel <= 0;
            rden <= 0;
        end
        
        default : begin
            state <= 0;
        end
    endcase
end*/

/*
always @(posedge i_clk)begin
    case(state)
        0: begin
            if(i_fifo_empty == 0)
            state <= 1;
            else
            state <= 0;
        end

        1: begin
            sel <= 1;
            if(counter[0] == 1)
            rden <= 0; 
            else
            rden <= ~rden;
            state <= 2;	
        end

        2: begin
            if(counter == (2 * ROW))begin
            counter <= 0;
            sel <= 0;
            rden <= 0;	
            end else begin
            counter <= counter + 1;
            state <= 1;
            
            end
        end
        
        default : begin
            state <= 0;
        end
    endcase
end
*/

/*
always @(posedge i_clk)begin
    case(state)
    //    0: begin
      //      rden <= 0;
        //    sel <= 0;
          //  counter <= 0;
            //    if(i_trigger)
              //      state <= 1;
             //   else
             //       state <= 0;
       // end
       //
        0: begin
           // if((i_fifo_empty == 0) && (i_data_valid[COL-1] == 1))begin   
             if(i_fifo_empty == 0) begin
                sel <= 1'b1;
                if(~counter[0])begin
                    rden <= 0;
                end else begin
                    rden <= ~rden;
                end
                counter <=  counter + 1;
                
                if( counter == (2 * ROW))begin
//                if(counter == (COL * 32) - 1)begin //TODO: Correct this condition
                    counter <= 0;
                    //state <= 0;
                    sel <= 1'b0;
                end
                else begin
                    state <= 0;
                end
            end
            else begin
            counter <=  counter;
            sel <= 1'b0;
            rden <= 0;
            state <= 0;
            end
        end
    endcase
end
*/
/*
always @(posedge i_clk) begin
	if(i_fifo_empty == 0) begin
		sel <= 1'b1;
		if(~counter[0]) begin
			rden <= 0;
		end else begin
			rden <= ~rden;
		end
		//counter <= counter + 1;

		if(counter == ( 2 * ROW))begin
			counter <= 0;
			sel <= 1'b0;
            rden <= 0;
		end	
        //logic
        else begin
            counter <= counter + 1;
        end
	end else begin
		counter <= counter;
		sel <= 1'b0;
		rden <= 0;
	end
end*/

endmodule
