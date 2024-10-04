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

reg flag3,flag4;
reg [I_SIZE_WIDTH:0] countps,countns;

wire [I_SIZE_WIDTH:0] count_max;
wire [I_SIZE_WIDTH:0] extra_cycles;

reg [I_SIZE_WIDTH-1:0]    r_i_size;
reg [DW-1:0]              r_data_in;
reg                       r_i_dv;
reg [1:0]                 ns,ps;

assign count_max = r_i_size + extra_cycles;
assign extra_cycles = (r_i_size%MOD == 0)? 0 : (MOD-(r_i_size%MOD));

localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;
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
    ps      <= 0;
   end
   else begin
    countps <= countns;
    doutps  <= doutns;
    o_dvps  <= o_dvns;
    ps      <= ns;
    // flag1 <= (countps>=r_i_size-1 && countps<count_max)?1:0;
    // flag2 <= ((countps >= count_max-1)||(countps == 0))?1:0;
   end
end

reg flag1,flag2;

always@(*) 
begin
    if(r_i_dv==1'b1)
    begin
        doutns  = r_data_in;
        o_dvns  = 1'b1;
    end
    
    else
    begin
        // if(flag2)
        // begin
        //     doutns  =  doutps;
        //     o_dvns  =  1'b0;
        // end
        
        // else 
        if(flag1)
        begin
            doutns  = 0;
            o_dvns  = 1'b1;
        end
        
        else begin
            doutns  = doutps;
            o_dvns  = 1'b0;
        end
    end
end


/*
FSM logic for zero pad:
S0: waits for datavalid and starts incrementing the ctr and goes to S1
S1: if datavalid is high update the ctr. If ctr reaches maximum then load the extra cycles cnt value and go to S2
S2: send zeros to the output and decrement the ctr. If ctr is zero then goto S0
*/

always@(*) begin
    case (ps)
        S0: begin
            flag1   =   0;
            if(r_i_dv==1'b1)
            begin
                // doutns  = r_data_in;
                // o_dvns  = 1'b1;
                countns = countps + 1;
                ns      = S1;
                flag2   = 0;
            end
            else begin
                // doutns = doutps;
                // o_dvns = 1'b0;
                countns = countps;
                ns      = S0;
                flag2   = 0;
            end
        end

        S1: begin
            flag1   =   0;
            flag2   =   0;
            if(countps==r_i_size) begin
                // doutns = doutps;
                // o_dvns = 0;
                countns = extra_cycles;
                ns      = S2;
            end
            else begin
                if(r_i_dv==1'b1) begin
                    // doutns = r_data_in;
                    // o_dvns = 1'b1;
                    countns = countps + 1;
                    ns      = S1;
                end
                else begin
                    // doutns = doutps;
                    // o_dvns = 1'b0;
                    countns = countps;
                    ns      = S1;
                end
            end
        end

        S2: begin
            flag2   =   1;
            if(countps==0) begin
                countns =  0;
                // doutns  = doutps;
                // o_dvns  =  0;
                flag1   =   0;
                ns      =  S0;
            end
            else begin
                countns = countps - 1;
                // doutns  = 0;
                // o_dvns  = 1;
                ns      = S2;
                flag1   = 1;
            end
        end

        default: begin
            countns = countps;
            // doutns  = doutps;
            // o_dvns  = o_dvps;
            ns      = ps;
            flag1   = 0;
            flag2   = 0;
        end
    endcase
end

assign data_out = doutps;
assign o_dv = o_dvps;

endmodule
