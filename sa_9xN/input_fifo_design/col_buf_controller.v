module col_buf_controller#(
    parameter COL = 3,
    parameter ROW = 9,
    parameter W_ADDR = 8
)(  input i_clk,
    input i_fifo_empty,
    input [W_ADDR : 0] occupants,
    output reg o_read_enable = 0,
    output reg sr_enable = 0,
    output reg [1:0] state = 0
);


//reg [4:0] counter = 0;
reg [($clog2(ROW * COL)) -1: 0] counter = 0;
//reg [($clog2(ROW))-1 : 0] wr_counter = 0;

always @(posedge i_clk)begin
  case (state)
    0: begin
        counter <= 0;
        sr_enable <= 1'b0;
        o_read_enable <= 1'b0;
        //fifo should not be empty and must have atleast 9 occupants
        if(i_fifo_empty == 0)
            state <= 1;
        //else
          //  state <= 0;
    end 

    1: begin
        //if(occupants == (ROW * COL))begin
        if(occupants == COL)begin
            state <= 2;
        end
    end

    2: begin
        o_read_enable <= 1'b1;
        sr_enable <= 1'b1;
        if(counter == (COL-1))begin
            //state <= 0;
            state <= 3;
        end else begin
            counter <= counter + 1;
        end
        //state <= 3;
    end
    
    3: begin
        o_read_enable <= 1'b0;
        sr_enable <= 1'b0;
        counter <= 0;
        state <= 0;
    end
    
    
    //3: begin
      //  if(counter == 8)begin
     //       state <= 0;
     //   end else begin
     //       state <= 2;
     //       counter <= counter + 1;
     //   end
   // end
    
    default: begin
        state <= 0;
    end 
  endcase  
end
endmodule

/*module col_buf_controller#(
    parameter COL = 3,
    parameter ROW = 9,
    parameter W_ADDR = 8
)(  input i_clk,
    input i_fifo_empty,
    input [W_ADDR : 0] occupants,
    output reg o_read_enable = 0,
    output reg sr_enable = 0,
    output reg [1:0] state = 0
);


//reg [4:0] counter = 0;
reg [($clog2(ROW * COL)) -1: 0] counter = 0;
//reg [($clog2(ROW))-1 : 0] wr_counter = 0;

always @(posedge i_clk)begin
  case (state)
    0: begin
        counter <= 0;
        sr_enable <= 1'b0;
        o_read_enable <= 1'b0;
        //fifo should not be empty and must have atleast 9 occupants
        if(i_fifo_empty == 0)
            state <= 1;
        //else
          //  state <= 0;
    end 

    1: begin
        if(occupants == (ROW * COL))begin
            state <= 2;
        end
    end

    2: begin
        o_read_enable <= 1'b1;
        sr_enable <= 1'b1;
        if(counter == ((ROW * COL)-1))begin
            //state <= 0;
            state <= 3;
        end else begin
            counter <= counter + 1;
        end
        //state <= 3;
    end
    
    3: begin
        o_read_enable <= 1'b0;
        sr_enable <= 1'b0;
        counter <= 0;
        state <= 0;
    end
    
    
    //3: begin
      //  if(counter == 8)begin
     //       state <= 0;
     //   end else begin
     //       state <= 2;
     //       counter <= counter + 1;
     //   end
   // end
    
    default: begin
        state <= 0;
    end 
  endcase  
end
endmodule*/