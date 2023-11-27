//Load weights from array of fifo into systolic array
module controller #(
   parameter COL = 1,
   parameter ROW = 9,
   parameter W_ADDR = 8,
   parameter W_DATA = 8
) (
   input i_clk,
   input i_trigger,
   input [(COL * (W_DATA)) -1 : 0] i_data,
   input [COL-1:0] i_fifo_empty,
   input [COL-1:0] i_data_valid,
   output [COL-1:0] o_fifo_read_enable,
   output o_select,
   output [(COL * (W_DATA)) -1 :  0] o_data,
   input [(W_ADDR * COL) : 0] i_fifo_occupants
);
    
reg [COL-1:0] rden = 0;
reg [2:0] state = 0;
reg sel = 0;
reg [($clog2(COL * 32))-1 : 0] counter = 0;

assign o_fifo_read_enable = rden;
assign o_select = sel;
assign o_data = i_data;
reg [(W_ADDR * COL) : 0] replicated_value = 0;

//Occupants of each fifo should be atleast equal to the number of rows
always @(*)begin
    replicated_value <= {COL{9'b000001001}};
end

always @(posedge i_clk)begin
    case(state)
        0: begin
            if(i_fifo_empty == 0) begin
                 if(i_fifo_occupants == (replicated_value)) begin
                  state <= 1;
                end
            end
        end
        
        1: begin
            if(counter == (ROW))begin
                state <= 2;
            end else begin
                counter <= counter + 1;
                sel <= 1'b1;
                rden <= {COL{1'd1}};  
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
endmodule