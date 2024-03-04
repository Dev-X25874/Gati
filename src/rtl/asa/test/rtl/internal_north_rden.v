//Load weights from internal north fifo array into pe grid
module internal_north_rden#(
   parameter COL = 1,
   parameter ROW = 9,
   parameter W_ADDR = 8,
   parameter W_DATA = 8
) (
   input i_clk,
   input i_rst,
   input i_trigger,
   input [COL-1:0] i_fifo_empty,
   output [COL-1:0] o_fifo_read_enable,
   input [((W_ADDR + 1) * COL)-1 : 0] i_fifo_occupants
);
localparam S_ROW = ROW[8:0];
wire w_trigger;

one_cycle one_pulse (
    .a(i_trigger),
    .rst(i_rst),
    .clk(i_clk),
    .b(w_trigger)
);

reg [COL-1:0] rden = 0;
reg [2:0] state = 0;
reg sel = 0;
reg [($clog2(COL * 32))-1 : 0] counter = 0;
reg [((W_ADDR+1) * COL) -1 : 0] replicated_value = 0;

assign o_fifo_read_enable = rden;


//Occupants of each fifo for all columns should be atleast equal to the number of rows
always @(*)begin
    replicated_value <= {COL{S_ROW}};
end

always @(posedge i_clk)begin
    if(i_rst)begin
        rden <= 0;
        state <= 0;
        counter <= 0;
    end else begin
        case(state)
            0: begin
                if(w_trigger) begin
                    if(i_fifo_empty == 0)begin
                        if(i_fifo_occupants >= replicated_value) begin
                            rden <= {COL{1'd1}}; 
                            state <= 1;
                        end
                    end
                end 
            end    

            1: begin
                if(counter == (ROW-1))begin
                    rden <= 0;
                    counter <= 0;
                    state <= 0;
                end 
                else 
                begin
                    counter <= counter + 1;
                end
            end

            default : begin
                state <= 0;
            end
        endcase
    end
end
endmodule