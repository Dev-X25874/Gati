//zero padding circuit: Appends zeros to the o/p stream if i/p dimension not matches
// with the requirement of 256-bit AXI size

module zero_padder(
                   clk,
                   rst,
                   i_size,
                   data_in,
                   i_dv,
                   data_out,
                   o_dv);
                   
parameter DW = 32;
parameter I_SIZE_WIDTH = 20;
parameter MOD = 2;

input                       clk,rst;
input [I_SIZE_WIDTH-1:0]    i_size;
input [DW-1:0]              data_in;
input                       i_dv;

output [DW-1:0] data_out;
output          o_dv;

reg [DW-1:0] doutns, doutps;
reg o_dvns, o_dvps;


reg [I_SIZE_WIDTH:0] countps,countns;

wire [I_SIZE_WIDTH:0] count_max;
wire [I_SIZE_WIDTH:0] extra_cycles;

assign count_max = r_i_size + extra_cycles;
assign extra_cycles = (r_i_size%MOD == 0)? 0 : MOD-(r_i_size%MOD);
reg [I_SIZE_WIDTH-1:0]    r_i_size;
reg [DW-1:0]              r_data_in;
reg                       r_i_dv;
always @(posedge clk) begin 

r_i_size<=i_size;
r_data_in<=data_in;
r_i_dv<=i_dv;
end
always@(posedge clk)
begin
   if(!rst) begin
    countps <= 0;
    doutps  <= 0;
    o_dvps  <= 0;
   end
   else begin
    countps <= countns;
    doutps  <= doutns;
    o_dvps  <= o_dvns;
    flag1<=(countps >=r_i_size-1 && countps<count_max)?1:0;
    flag2<=((countps == count_max-1)||(countps == 0))?1:0;
   end
end

reg flag1,flag2;
//always @ (posedge clk)  begin 
//	
// 	
//	
//end 


always@(*) 
begin
    if(r_i_dv==1'b1)
    begin
        doutns  = r_data_in;
        o_dvns  = 1'b1;
        countns = countps + 1;
    end
    
    else
    begin
        if(flag2)
        begin
            doutns  =  doutps;
            o_dvns  =  1'b0;
            countns =  0;
        end
        
        else if(flag1)
        begin
            doutns  = 0;
            o_dvns  = 1'b1;
            countns = countps + 1;
        end
        
        else begin
            doutns  = doutps;
            o_dvns  = 1'b0;
            countns = countps;
        end
    end
end

assign data_out = doutps;
assign o_dv = o_dvps;

endmodule
