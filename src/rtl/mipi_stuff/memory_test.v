module memory_test(
    input clkin,
    input read_enable,
    input reset,
    output reg [255:0]data_out,
    output reg data_valid
);
reg [255:0]internal_mem[0:511];
reg [10:0]count=0;
initial begin
    $readmemh("memory_file.mem",internal_mem,0,511);
end

always @(posedge clkin) begin
    if(read_enable)begin
        data_out<=internal_mem[count];
        data_valid<=1;
        count<=count+1;
    end
    else begin
        data_valid<=0;
    end
    if(reset)begin
        count<=0;
    end

end
endmodule