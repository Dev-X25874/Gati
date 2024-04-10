//memory module that sends instruction data in bursts of 8
module burst_mem_module(
    input clkin,
    input burst_read_trigger,
    output reg [255:0]mem_instruction,
    output reg valid_signal
);
reg [255:0]internal_mem[0:64];
reg [4:0]counter1=0;
reg [3:0]state=0;
reg [10:0]pointer=0;
initial begin
    $readmemh("vgg16.mem",internal_mem,0,63);
end
always @(posedge clkin) begin
    if(burst_read_trigger)begin
        state<=4'd1;
    end
    case(state)
    4'd0:begin
        counter1<=0;
        valid_signal<=1'b0;
    end
    4'd1:begin
        if(counter1>8)begin
            state<=4'd0;
            valid_signal<=1'b0;
        end
        counter1<=counter1+1;
        mem_instruction<=internal_mem[pointer];
        pointer<=pointer+1;
        valid_signal<=1'b1;
    end
    endcase
end
endmodule