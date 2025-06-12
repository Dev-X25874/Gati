module TOP_W_BRAM #(parameter AXI_DATA_WIDTH = 256,
             parameter AXI_DATA_BYTES = 32,
             parameter BURST_LENGTH_WIDTH = 8,                                                     //fifos in a fifo array 
             parameter IMG_HEIGHT = 16,
             parameter W_CITER_CNT = 16,
             parameter DATA_WIDTH = 8,
             parameter W_ADDR = 9,
             parameter N_BRAM = 32,
             parameter ELEMENTS = 2, 
             parameter ADDR_OUT_CHUNCK_WIDTH = 8)
(
    input  clk,
    input  rst_n,
    input  rd_start,                                                                    //to start the dram rd requestor pulse 
    input  empty,                 
    input  i_select,                                                   //select for the mem rd ctrl
    input  i_data_last,                                                   //data last input for mem rd ctrl from dram
    input  i_data_valid,                                                  //data valid input for mem rd ctrl from dram
    input  [(W_ADDR*N_BRAM)-1:0]                   rd_addr,                             //read addr for n_brams
    input  [(N_BRAM - 1) : 0]                      n_bram_rden,                         //rd enable for n_brams
    input  [(AXI_DATA_BYTES - 1) : 0]              rd_rq_offset,                        //offset value as input
    input  [(2*IMG_HEIGHT) - 1 : 0]                img_dimension,                       //img dimension as input
    input  [(W_CITER_CNT - 1) : 0]                 channel_itr_count,                   //channel itr count as input
    input  [AXI_DATA_BYTES - 1 : 0]                start_addr_rd_req,                   //the start addr for the rd req
    input  [AXI_DATA_WIDTH - 1 : 0]                i_dram_data,                         //input data from dram
    output [(BURST_LENGTH_WIDTH - 1) : 0]          burst_length_read_requestor,         //burst length for the rd req
    output [(ADDR_OUT_CHUNCK_WIDTH - 1) : 0]       addr_out_read_requestor,             //8 bits addr output from rd req
    output [(AXI_DATA_BYTES * DATA_WIDTH) - 1 : 0] o_data_final,                        //data output from n_brams
    output rw_enable_rd_req,                                                            //rd-wr enable from rd req
    output last_read_requestor,                                                         //last data bit from rd req
    output valid_read_requestor,                                                        //valid bit from rd req
    output rd_bram_start                                                                //signal to start reading from n_brams
);

reg last_data;
reg valid_in_slice_controller;
reg [(AXI_DATA_BYTES * DATA_WIDTH) - 1 : 0] data_in_slice_controller;
wire [(AXI_DATA_BYTES * DATA_WIDTH) - 1 : 0] data_out_slice_controller;

DRAM_read_requestor #(.AXI_BYTES(AXI_DATA_BYTES),
                      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
                      .W_CITER_CNT(W_CITER_CNT),
                      .IMG_HEIGHT(IMG_HEIGHT),
                      .ADDR_OUT_CHUNCK_WIDTH(ADDR_OUT_CHUNCK_WIDTH))
DRAM_read_requestor(
    .clk(clk),
    .rst_n(rst_n),
    .rd_start(rd_start),
    .last_data(last_data), 
    .empty(empty), 
    .img_dimension(img_dimension),
    .offset(rd_rq_offset),
    .channel_itr_count(channel_itr_count),
    .start_addr(start_addr_rd_req),
    .burst_length(burst_length_read_requestor),
    .addr_out(addr_out_read_requestor),
    .rw_enable(rw_enable_rd_req),
    .last(last_read_requestor), 
    .valid(valid_read_requestor),
    .channel_last()
);

always@(posedge clk) begin
    if(!rst) begin
        data_in_slice_controller <= 0;
        valid_in_slice_controller <= 0;
    end
    else begin
        if(i_select==1) begin
            if(i_data_valid) begin
                valid_in_slice_controller <= 1'b1;
                data_in_slice_controller <= i_dram_data;
            end
            else begin
                valid_in_slice_controller <= 1'b0;
                data_in_slice_controller <= o_dram_data;
            end
        end
        else begin
            valid_in_slice_controller <= 1'b0;
            data_in_slice_controller <= o_dram_data;
        end
    end
end

always@(posedge clk) begin
    if(i_select==1) last_data <= i_data_last;
    else last_data <= 0;
end    

bram_wr_ctrl #(.AXI_DATA_BYTES(AXI_DATA_BYTES),
               .N_BRAM(N_BRAM),
               .W_DATA(DATA_WIDTH),
               .W_ADDR(W_ADDR),
               .W_CITER_CNT(W_CITER_CNT))
bram_wr_ctrl(
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in_slice_controller),
    .data_in(data_in_slice_controller),
    .n_bram_rden(n_bram_rden),
    .data_out(o_data_final),
    .channel_itr_count(channel_itr_count),
    .rd_bram_start(rd_bram_start),
    .rd_addr(rd_addr)
);

endmodule