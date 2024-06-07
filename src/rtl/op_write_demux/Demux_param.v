module Dmux_param #(
    parameter NUM_PORTS = 2,
    parameter DATA_WIDTH = 32,
    parameter COL_SA = 4
) (
    input [(DATA_WIDTH*COL_SA)-1 : 0] i_din,
    input [COL_SA-1 : 0] i_datavalid,
    input [$clog2(NUM_PORTS)-1: 0] i_sel,
    output [(NUM_PORTS*DATA_WIDTH*COL_SA)-1 : 0 ] o_dout,
    output reg [(NUM_PORTS*COL_SA)-1 : 0] o_datavalid
);
	assign o_dout=r_o_dout;
//    integer i;
//    initial begin
//     for(i=0;i<NUM_PORTS;i=i+1)
//         o_dout[i] = 0;
//    end
    assign o_dout = r_o_dout;
    (*syn_use_dsp = "no"*) reg [(NUM_PORTS*DATA_WIDTH*COL_SA)-1 : 0] r_o_dout;
    always@(*) begin
        r_o_dout = 0;
        r_o_dout[(COL_SA*DATA_WIDTH*(NUM_PORTS-i_sel)-1) -: COL_SA*DATA_WIDTH] = i_din;
    end

   always@(*) begin
        o_datavalid = 0;
        o_datavalid[(COL_SA*(NUM_PORTS-i_sel)-1) -: COL_SA] = i_datavalid;
        // if(i_datavalid == {COL_SA{1'b1}})
        //     o_datavalid[i_sel] = 1'b1;
        // else
        //     o_datavalid = 0;
   end

endmodule
