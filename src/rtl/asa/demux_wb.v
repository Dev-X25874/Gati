
/* In a single PE block, this module stores weight into the weight buffer if select line is high, 
and performs required operations on the data and sends 32 bit output to mux */
module demux_wb(
    input dmx_clk,
    input i_sel,
    input [31:0] d_north,
    input [7:0] d_west,
    output o_sel,
    output [31:0] mux_d1,
    output [31:0] mux_d2
);


reg [7:0] wb = 0;
wire [31:0] o_dmx2;
wire [7:0] o_dmx1;
wire [31:0] i_sum1;

assign o_dmx1 = d_north[7:0];
assign o_dmx2 = (~i_sel) ? d_north : 0;
assign o_sel = i_sel;
//product
assign i_sum1 = d_west * wb;

//sum
assign mux_d2 = i_sum1 + o_dmx2;

assign mux_d1 = wb;

//demultiplexer
always @(posedge dmx_clk) begin
    if(i_sel ) begin 
        wb <= o_dmx1;
    end else begin
        wb <= wb;
    end
end 

endmodule