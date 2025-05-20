/*  This blocks stores the accumulant and quantize output data into corresponding FIFOs and writes in to 
    a single FIFO based on the 'acc_quant_enable' signal. If 'acc_quant_enable=0' then write into acc_op_fifo,
    else into quant_op_fifo. Then write into 'op_write_fifo' whose data width is always equal to AXI_DATAWIDTH. 
*/

module dram_data_aligner#(
    parameter AXI_DATA_WIDTH = 256,
    parameter N_SA = 16,
    parameter DATA_WIDTH_ACC = 32,
    parameter ACC_OP_FIFO = 2,
    parameter ACC_OP_FIFO_DEPTH = 256,

    parameter QUANT_OP_FIFO = 1,
    parameter QUANT_OP_FIFO_DEPTH = 256,

    parameter OP_FIFO_DEPTH = 512,
    parameter OP_FIFO = 1,
    parameter OUTPUT_REG = 0
) (
    input i_clk,
    input i_rst,
    input i_acc_quant_enable, // 0: acc, 1: quant
    // input i_op_full,
    output o_op_full,
    
    input [ACC_OP_DATAWIDTH-1:0] i_acc_data,
    input [ACC_OP_FIFO-1 : 0] i_acc_data_wren,
    input [QUANT_OP_FIFO*AXI_DATA_WIDTH-1:0] i_quant_data,
    input [QUANT_OP_FIFO-1 : 0] i_quant_data_wren,

    input [OP_FIFO-1 : 0] i_op_write_dram_fifo_rden,
    output [(($clog2(OP_FIFO_DEPTH)+1)*OP_FIFO)-1:0] o_op_write_dram_fifo_occupants,
    output [OP_FIFO-1 : 0] o_op_write_dram_fifo_empty,
    output [AXI_DATA_WIDTH-1:0] o_op_write_dram_fifo_data,
    output [OP_FIFO-1 : 0] o_op_write_dram_fifo_dv
);
    
    localparam ACC_OP_DATAWIDTH = ((N_SA*DATA_WIDTH_ACC) < (AXI_DATA_WIDTH)) ? (N_SA*DATA_WIDTH_ACC*ACC_OP_FIFO) : (N_SA*DATA_WIDTH_ACC);
    wire op_write_dram_fifo_full, op_write_dram_fifo_almost_full;
    wire op_write_dram_fifo_empty, op_write_dram_fifo_almost_empty;
    wire op_write_dram_fifo_prog_full;

    wire [ACC_OP_FIFO-1:0] acc_op_fifo_empty, acc_op_fifo_almost_empty;
    wire [ACC_OP_FIFO-1:0] acc_op_fifo_full, acc_op_fifo_almost_full;
    wire [ACC_OP_FIFO-1:0] acc_op_fifo_dv;
    (* syn_keep = "true" *) wire [ACC_OP_FIFO-1 : 0] acc_fifo_read_enable;
    wire [ACC_OP_DATAWIDTH-1:0] acc_op_fifo_data;
    wire [(($clog2(ACC_OP_FIFO_DEPTH)+1)*ACC_OP_FIFO)-1:0] acc_op_fifo_occupants;
    // ACC_OP_FIFO
    dram_fifo # (
        .DIMENSION(ACC_OP_FIFO),
        .W_DATA(ACC_OP_DATAWIDTH/ACC_OP_FIFO),
        .W_ADDR($clog2(ACC_OP_FIFO_DEPTH)),
        .OUTPUT_REG(OUTPUT_REG)
    )
    acc_op_fifo_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_acc_data),
        .i_read_enable(acc_fifo_read_enable),
        .i_write_enable(i_acc_data_wren),
        .o_data(acc_op_fifo_data),
        .o_fifo_empty(acc_op_fifo_empty),
        .o_fifo_almost_empty(acc_op_fifo_almost_empty),
        .o_fifo_full(acc_op_fifo_full),
        .o_fifo_almost_full(acc_op_fifo_almost_full),
        .o_fifo_dv(acc_op_fifo_dv),
        .o_occupants(acc_op_fifo_occupants)
    );

    wire [QUANT_OP_FIFO-1:0] quant_op_fifo_empty, quant_op_fifo_almost_empty;
    wire [QUANT_OP_FIFO-1:0] quant_op_fifo_full, quant_op_fifo_almost_full;
    wire [QUANT_OP_FIFO-1:0] quant_op_fifo_dv;
    wire [QUANT_OP_FIFO*AXI_DATA_WIDTH-1:0] quant_op_fifo_data;
    // QUANT_OP_FIFO
    dram_fifo # (
        .DIMENSION(QUANT_OP_FIFO),
        .W_DATA(AXI_DATA_WIDTH),
        .W_ADDR($clog2(QUANT_OP_FIFO_DEPTH)),
        .OUTPUT_REG(OUTPUT_REG)
    )
    quant_op_fifo_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_quant_data),
        .i_read_enable(quant_fifo_read_enable),
        .i_write_enable(i_quant_data_wren),
        .o_data(quant_op_fifo_data),
        .o_fifo_empty(quant_op_fifo_empty),
        .o_fifo_almost_empty(quant_op_fifo_almost_empty),
        .o_fifo_full(quant_op_fifo_full),
        .o_fifo_almost_full(quant_op_fifo_almost_full),
        .o_fifo_dv(quant_op_fifo_dv),
        .o_occupants()
    );
    
    // Read signal generation for quant FIFOs 
    reg [QUANT_OP_FIFO-1 : 0] r_quant_fifo_read_enable;
    wire [QUANT_OP_FIFO-1 : 0] quant_fifo_read_enable;
    assign quant_fifo_read_enable = r_quant_fifo_read_enable;
    always@(posedge i_clk) begin
        if(!i_rst) begin
            r_quant_fifo_read_enable <= 0;
        end
        else begin
            if(i_acc_quant_enable) begin
                if(o_op_full) r_quant_fifo_read_enable <= 0;
                else if(r_quant_fifo_read_enable & quant_op_fifo_almost_empty) r_quant_fifo_read_enable <= 0;
                else if(~quant_op_fifo_empty) r_quant_fifo_read_enable <= {QUANT_OP_FIFO{1'b1}};
            end
            else begin
                r_quant_fifo_read_enable <= 0;
            end
        end
    end

    // Read signal generation for acc FIFOs
    localparam SHIFT_WIDTH = ((N_SA*DATA_WIDTH_ACC) < AXI_DATA_WIDTH) ? 0 : ((ACC_OP_FIFO > 1)? $clog2(ACC_OP_FIFO) : 0);
    localparam SHIFT_COUNT = ACC_OP_FIFO;

    reg [SHIFT_WIDTH-1:0] r_shift_count, r_shift_count_delayed;
    reg [SHIFT_WIDTH-1:0] r_shift_count_dv;
    generate
        if(SHIFT_WIDTH==0) begin
            reg [ACC_OP_FIFO-1 : 0] r_acc_fifo_read_enable;
            always@(posedge i_clk) begin
                if(!i_rst) begin
                    r_acc_fifo_read_enable <= 0;
                end
                else begin
                    if(~i_acc_quant_enable) begin
                        if(o_op_full) r_acc_fifo_read_enable <= 0;
                        else if(acc_fifo_read_enable & (&(acc_op_fifo_almost_empty))) r_acc_fifo_read_enable <= 0;
                        else if(~|acc_op_fifo_empty) r_acc_fifo_read_enable <= {ACC_OP_FIFO{1'b1}};
                    end
                    else begin
                        r_acc_fifo_read_enable <= 0;
                    end
                end
            end
            assign acc_fifo_read_enable = r_acc_fifo_read_enable;
        end

        else begin
            reg r_acc_fifo_read_enable;

            always@(posedge i_clk) begin
                if(!i_rst) begin
                    r_acc_fifo_read_enable <= 0;
                end
                else begin
                    if(~i_acc_quant_enable) begin
                        if(op_write_dram_fifo_prog_full) r_acc_fifo_read_enable <= 0;
                        else if((r_acc_fifo_read_enable) && (&(acc_op_fifo_almost_empty))) r_acc_fifo_read_enable <= 0;
                        else if(~&acc_op_fifo_empty) r_acc_fifo_read_enable <= 1;
                        else r_acc_fifo_read_enable <= r_acc_fifo_read_enable;
                        
                        // if(r_shift_count == SHIFT_COUNT-1) begin
                        //     if(i_op_full) r_acc_fifo_read_enable <= 0;
                        //     else if(~|acc_op_fifo_empty) r_acc_fifo_read_enable <= 1;
                        // end
                        // else begin
                        //     if(i_op_full) r_acc_fifo_read_enable <= 0;
                        //     else if(~|acc_op_fifo_empty) r_acc_fifo_read_enable <= 1;
                        // end
                    end
                    else begin
                        r_acc_fifo_read_enable <= 0;
                    end
                end
            end

            always@(posedge i_clk) begin
                if(!i_rst) begin
                    r_shift_count <= 0;
                    r_shift_count_delayed <= 0;
                end
                else begin
                    r_shift_count_delayed <= r_shift_count;
                    if(~i_acc_quant_enable) begin
                        if(r_shift_count == SHIFT_COUNT-1) begin
                            if(r_acc_fifo_read_enable) r_shift_count <= 0;
                        end
                        else begin
                            if(r_acc_fifo_read_enable) r_shift_count <= r_shift_count + 1;
                        end
                    end
                    else begin
                        r_shift_count <= 0;
                    end
                end
                    
            end

            demux_param1 #(
                .N_PORT(ACC_OP_FIFO),
                .DATA_WIDTH(1)
            )
            acc_fifo_read_enable_demux (
                .i_din(r_acc_fifo_read_enable),
                .i_sel(r_shift_count),
                .o_dout(acc_fifo_read_enable)
            );
        end
    endgenerate

    /*
        have another shift counter updating based on the acc_op_fifo_dv signal and use that 
        to slice the data from acc_op_fifo. This is to be done because the data from acc_op_fifo is not
        always available at the output of the FIFO. It is only available when the FIFO o/p is valid.
        So, the shift counter should be updated based on the FIFO o/p valid signal.
    */
    // Data write into dram FIFO
    wire op_write_dram_fifo_wren;
    wire [AXI_DATA_WIDTH-1:0] op_write_dram_fifo_data;

    generate
        if(SHIFT_WIDTH==0) begin
            assign op_write_dram_fifo_wren = i_acc_quant_enable? quant_op_fifo_dv : acc_op_fifo_dv;
            assign op_write_dram_fifo_data = i_acc_quant_enable? quant_op_fifo_data : acc_op_fifo_data;
        end
        else begin

            always@(posedge i_clk) begin
                if(!i_rst) begin
                    r_shift_count_dv <= 0;
                end
                else begin
                    if(~i_acc_quant_enable) begin
                        if(r_shift_count_dv == SHIFT_COUNT-1) begin
                            if(|(acc_op_fifo_dv)) r_shift_count_dv <= 0;
                        end
                        else begin
                            if(|(acc_op_fifo_dv)) r_shift_count_dv <= r_shift_count_dv + 1;
                        end
                    end
                    else begin
                        r_shift_count_dv <= 0;
                    end
                end
            end

            assign op_write_dram_fifo_wren = i_acc_quant_enable? quant_op_fifo_dv : |(acc_op_fifo_dv);
            assign op_write_dram_fifo_data = i_acc_quant_enable? quant_op_fifo_data : acc_op_fifo_data[(AXI_DATA_WIDTH*(ACC_OP_FIFO-r_shift_count_dv)-1) -: AXI_DATA_WIDTH];
        end
    endgenerate

    //Generate op_full signal
    generate
        if(SHIFT_WIDTH==0) begin
            assign o_op_full = (o_op_write_dram_fifo_occupants >= (OP_FIFO_DEPTH-16)) ? 1'b1 : 1'b0;
        end
        else begin
            assign o_op_full = (~i_acc_quant_enable)?
                ((acc_op_fifo_occupants[$clog2(ACC_OP_FIFO_DEPTH):0] >= (ACC_OP_FIFO_DEPTH-16)) ? 1'b1 : 1'b0) :
                ((o_op_write_dram_fifo_occupants >= (OP_FIFO_DEPTH-16)) ? 1'b1 : 1'b0);
        end
    endgenerate

    assign op_write_dram_fifo_prog_full = (o_op_write_dram_fifo_occupants >= (OP_FIFO_DEPTH-4)) ? 1'b1 : 1'b0;
    
    // op_write_dram_fifo
    dram_fifo # (
        .DIMENSION(OP_FIFO),
        .W_DATA(AXI_DATA_WIDTH),
        .W_ADDR($clog2(OP_FIFO_DEPTH)),
        .OUTPUT_REG(OUTPUT_REG)
    ) op_write_dram_fifo (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(op_write_dram_fifo_data),
        .i_write_enable(op_write_dram_fifo_wren),
        .o_data(o_op_write_dram_fifo_data),
        .i_read_enable(i_op_write_dram_fifo_rden),
        .o_fifo_empty(o_op_write_dram_fifo_empty),
        .o_fifo_almost_empty(),
        .o_fifo_full(),
        .o_fifo_almost_full(),
        .o_fifo_dv(o_op_write_dram_fifo_dv),
        .o_occupants(o_op_write_dram_fifo_occupants)
    );
    
endmodule