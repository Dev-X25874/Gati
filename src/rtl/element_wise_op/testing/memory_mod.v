module memory_mod(
    input clkin,
    input burst_read_trigger,
    output reg [37:0]test_data
);
reg [37:0]internal_mem[0:29];
reg [3:0]state=0;
reg [5:0]counter1=0;
reg [7:0]pointer=0;
initial begin
    $readmemh("yoyo.mem",internal_mem,0,29);
end

always @(posedge clkin) begin
    case(state)
    4'd0:begin
        counter1<=0;
        test_data<=0;
        if(burst_read_trigger)begin
            state<=1;
        end
    end
    4'd1:begin
        if(counter1>29)begin
            state<=0;
        end
        test_data<=internal_mem[pointer];
        pointer<=pointer+1;
        counter1<=counter1+1;
    end
    endcase
end
endmodule