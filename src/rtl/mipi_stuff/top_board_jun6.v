module top_board(
    input clkin,
    input user_start,
    output mipi_valid,
    output ready_sig
);
wire read_enable;
wire [255:0]data_wire;
wire data_valid;
mipi_formatter mipi_m(
    .clkin(clkin),
    .id(32'hABCD0102),
    .data_size(32'd500),
    .valid_req(1'b1),
    .start(user_start),
    .data_fifo(data_wire),
    .data_valid(data_valid),
    .ready_sig(ready_sig),
    .mipi_packet(),
    .mipi_valid(mipi_valid),
    .read_enable(read_enable)
);

memory_test memory_m(
    .clkin(clkin),
    .read_enable(read_enable),
    .reset(1'b0),
    .data_out(data_wire),
    .data_valid(data_valid)
);
endmodule