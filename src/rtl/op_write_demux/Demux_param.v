module Demux_param #(
    parameter NUM_PORTS = 4,
    parameter DATA_WIDTH = 16,
    parameter COL_SA = 4,
) (
    input [(DATA_WIDTH*COL_SA)-1 : 0] i_din,
    input [COL_SA-1 : 0] i_datavalid,
    input [$clog2(NUM_PORTS)-1: 0] i_sel,
    output reg [(NUM_PORTS*DATA_WIDTH*COL_SA)-1 : 0 ] o_dout,
    output reg [(NUM_PORTS*COL_SA)-1 : 0] o_datavalid
);

//    integer i;
//    initial begin
//     for(i=0;i<NUM_PORTS;i=i+1)
//         o_dout[i] = 0;
//    end
   (*syn_use_dsp = "no"*) reg o_dout[DATA_WIDTH-1:0];
   always@(*) begin
        o_dout = 0;
        o_dout[(DATA_WIDTH*(NUM_PORTS-i_sel)-1) -: DATA_WIDTH] = i_din;
   end

   always@(*) begin
        o_datavalid = 0;
        if(i_data_valid == {COL_SA{1'b1}})
            o_datavalid[i_sel] = {COL_SA{1'b1}};
        else
            o_datavalid = 0;
   end

endmodule