module top_max #(parameter DATA_WIDTH = 8, 
            parameter POOL_HEIGHT = 4,
            parameter POOL_WIDTH = 4,
            parameter POOLING_TYPE_WIDTH = 3,
            parameter POOLSTRIDE_WIDTH = 4,
            parameter POOLPADDING_WIDTH = 4,
            parameter POOLCEIL_WIDTH = 1,
            parameter POOLMODCOUNT_WIDTH = 4,
            parameter POOLPADSIDES_WIDTH = 4,
            parameter OH_WIDTH = 10,
            parameter ADDR_WIDTH = 5,
            parameter OW_WIDTH = 10
            )
    (
    input clk,
    input rst_n,
    input ENABLE,                                       // Enable signal to control the operation
    input [(DATA_WIDTH - 1) : 0] din,                   // Input data to the pooling operation
    input datavalid_in,                                 // Input data valid signal
    input [(POOLING_TYPE_WIDTH - 1) : 0] PoolType,      // Type of pooling (Max/Avg)
    input [(POOLSTRIDE_WIDTH - 1) : 0]PoolStride,
    input [(POOL_WIDTH - 1) : 0] PoolWidth,             // Width of the pooling kernel
    input [(POOL_HEIGHT - 1) : 0] PoolHeight,           // Height of the pooling kernel
    input [(POOLPADDING_WIDTH - 1) : 0] PoolPadding,
    input [(POOLCEIL_WIDTH - 1) : 0] PoolCeil,
    input [(POOLMODCOUNT_WIDTH - 1) : 0] PoolModCount,
    input [(POOLPADSIDES_WIDTH - 1) : 0] PoolPadSides,
    input [(OH_WIDTH - 1) : 0] OH,                      // Output Height of the image
    input [(OW_WIDTH - 1) : 0] OW,                      // Output Width of the image
    output [(DATA_WIDTH - 1) : 0] dout,                 // Final output of the pooling operation
    output done,                                        // Done signal to indicate completion
    output datavalid_out                                // Final data valid signal
    );

wire [(DATA_WIDTH - 1) : 0] dout_pooling_first_stage;
wire [(DATA_WIDTH - 1) : 0] dout_crc_pfs; 
wire dv_pooling_first_stage;
wire [(DATA_WIDTH - 1) : 0] data_in_fifo1;
wire [(DATA_WIDTH - 1) : 0] data_in_fifo2;
wire we_fifo;
wire [(DATA_WIDTH - 1) : 0] din_fifo_1;
wire [(DATA_WIDTH - 1) : 0] din_fifo_2;
wire re;
wire empty1;
wire empty2;
wire dv_pooling_second_stage;
wire [(DATA_WIDTH - 1) : 0] dout_pooling_second_stage;
wire datavalid_final_pool;
wire we_mux;
wire enable_rowwise;
wire [(DATA_WIDTH - 1) : 0] dout_final_mux;
wire [(DATA_WIDTH - 1) : 0] dout_fifo1_mux;
wire [(DATA_WIDTH - 1) : 0] dout_fifo1;
wire sel;
wire dv_demux_counter;
wire we_fifo1;
wire we_fifo2;
wire dv_pooling_second_stage1;
wire dv_pooling_second_stage2;

//intermediate
wire [(DATA_WIDTH - 1) : 0] dout_intermediate;
wire datavalid_out_intermediate;
wire full_o1, full_o2;
wire datavalid_crc_pfs;
wire [(POOL_WIDTH - 1) : 0] mod_value; //remainder

// counter_rowwise_columnwise #(.OW_WIDTH(OW_WIDTH),
//                              .OH_WIDTH(OH_WIDTH))
// counter_rowwise_columnwise (
//     .clk(clk),
//     .rst_n(rst_n),
//     .OW(OW),
//     .OH(OH),
//     .ENABLE(ENABLE),
//     .datavalid_in(datavalid_in),
//     //.rx_valid(rx_valid),
//     .dv_demux_counter(dv_demux_counter),
//     .done(done)  
// );

gen_mod_op # (
    .DATA_WIDTH(DATA_WIDTH),
    .OH_WIDTH(OH_WIDTH),
    .POOL_WIDTH(POOL_WIDTH)
  )
  gen_mod_op_inst (
    .clk(clk),
    .rst(rst_n),
    .diff(OH), //Dividend-OH
    .pool_width(PoolWidth), //Divisor-Pool_Height
    .o_partial(mod_value) //Remainder-mod_value
  );

counter_rowwise_columnwise # (
    .OW_WIDTH(OW_WIDTH),
    .OH_WIDTH(OH_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .POOLMODCOUNT_WIDTH(POOLMODCOUNT_WIDTH)
  )
  counter_rowwise_columnwise_inst (
    .clk(clk),
    .rst_n(rst_n),
    .OW(OW),
    .OH(OH),
    .ENABLE(ENABLE),
    .datavalid_in(datavalid_in),
    .din(din),
    .mod_value(PoolModCount),//.mod_value(mod_value),
    .datavalid_out(datavalid_crc_pfs),
    .dout(dout_crc_pfs),
    .done(done),
    .dv_demux_counter(dv_demux_counter)
  );

pooling_first_stage #(.DATA_WIDTH(DATA_WIDTH), 
                      .POOL_WIDTH(POOL_WIDTH), 
                      .POOLING_TYPE_WIDTH(POOLING_TYPE_WIDTH)
                      )
pooling_first_stage (
    .clk(clk),
    .rst_n(rst_n),
    .din(dout_crc_pfs),
    .ENABLE(ENABLE),
    .datavalid_in(datavalid_crc_pfs),
    .pool_width(PoolWidth),
    .pooling_type(PoolType),
    .dout(dout_pooling_first_stage),
    .datavalid_out(dv_pooling_first_stage)
);

counter_demux #(.POOL_HEIGHT(POOL_HEIGHT))
counter_demux (
    .clk(clk),
    .rst_n(rst_n),
    .datavalid_in(dv_demux_counter),
    .pool_height(PoolHeight),
    //.rx_valid(rx_valid),
    .datavalid_out(),
    .sel(sel)
);

demux_for_fifo1 #(.DATA_WIDTH(DATA_WIDTH))
demux_for_fifo1 (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .sel(sel),
    .data_in(dout_pooling_first_stage), 
    .data_out_fifo1(data_in_fifo1),
    .data_out_fifo2(data_in_fifo2),
    .datavalid_in(dv_pooling_first_stage),
    .datavalid_out_fifo1(we_fifo1),
    .datavalid_out_fifo2(we_fifo2)
    //.rx_valid(rx_valid)
);

sync_fifo  #(.W_DATA(DATA_WIDTH),
             .W_ADDR(ADDR_WIDTH) //FIFO Depth
)
sync_fifo_1(
    .full_o(full_o1),
    .empty_o(empty1),
    .clk_i(clk),
    .wr_en_i(dv),
    .rd_en_i(re),
    .wdata(dout_fifo1),
    .datacount_o(),
    .rst_busy(),
    .rdata(din_fifo_1),
    .a_rst_i(~rst_n),
    .o_valid(dv_pooling_second_stage1)
);

sync_fifo  #(.W_DATA(DATA_WIDTH),
             .W_ADDR(ADDR_WIDTH) //FIFO Depth
)
sync_fifo_2(
    .full_o(full_o2),
    .empty_o(empty2),
    .clk_i(clk),
    .wr_en_i(we_fifo2),
    .rd_en_i(re),
    .wdata(data_in_fifo2),
    .datacount_o(),
    .rst_busy(),
    .rdata(din_fifo_2),
    .a_rst_i(~rst_n),
    .o_valid(dv_pooling_second_stage2)
);

/*fifo_valid #(.DATA_WIDTH(DATA_WIDTH),
             .ADDR_WIDTH(5))
fifo_1 (
    .clk(clk),
    .rst_n(rst_n),
    .we(dv),
    .re(re),
    .data_in(dout_fifo1),
    .occupants(),
    .full(),
    .empty(empty1),
    .data_out(din_fifo_1),
    .data_valid(dv_pooling_second_stage1)
);

fifo_valid #(.DATA_WIDTH(DATA_WIDTH),
             .ADDR_WIDTH(5))
fifo_2 (
    .clk(clk),
    .rst_n(rst_n),
    .we(we_fifo2),
    .re(re),
    .data_in(data_in_fifo2),
    .occupants(),
    .full(),
    .empty(empty2),
    .data_out(din_fifo_2),
    .data_valid(dv_pooling_second_stage2)
);*/

pooling_second_stage #(.DATA_WIDTH(DATA_WIDTH),
                       .POOLING_TYPE_WIDTH(POOLING_TYPE_WIDTH))
pooling_second_stage (
    .clk(clk), 
    .rst_n(rst_n),
    .din_fifo_1(din_fifo_1),
    .din_fifo_2(din_fifo_2),
    .ENABLE(ENABLE),
    .datavalid_in(dv_pooling_second_stage),
    .pooling_type(PoolType),
    .dout(dout_pooling_second_stage),
    .datavalid_out(datavalid_final_pool)
);

counter_pooling_second #(.DATA_WIDTH(DATA_WIDTH),
                         .POOL_HEIGHT(POOL_HEIGHT))
counter_pooling_second (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .datavalid_in(datavalid_final_pool),
    .dout_pooling_second_stage(dout_pooling_second_stage),
    .pool_height(PoolHeight),
    .datavalid_out_final(datavalid_out_intermediate), //datavalid_out
    .datavalid_out_fifo1(dv_mux),
    .dout_final(dout_intermediate), //dout
    .dout_fifo1(dout_fifo1_mux)
);

mux_final_pool #(.DATA_WIDTH(DATA_WIDTH))
mux_final_pool (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .din_demux_for_fifo1(data_in_fifo1),
    .din_pooling_second_stage_fifo1(dout_fifo1_mux),
    .datavalid_out_final(dv_mux),
    .datavalid_out_fifo1(we_fifo1),
    .dv(dv),
    .dout_fifo1(dout_fifo1)
);

assign re = (~empty2);
//assign re = ((~empty1) & (~empty2));

// Combines data valid signals for second-stage pooling
assign dv_pooling_second_stage = ((dv_pooling_second_stage1) && (dv_pooling_second_stage2));

assign datavalid_out = (ENABLE==1)?datavalid_out_intermediate : datavalid_in;
assign dout =(ENABLE==1)? dout_intermediate : din ;


endmodule