module memory_controller(
    input clkin,
    input memory_request,
    output reg memory_acknowledgement
);
reg [20:0]counter=5;
reg [3:0]state=0;
always @(posedge clkin) begin
    case(state)
    4'd0:begin
        if(memory_request)begin
            state<=1;
        end
        else begin
            state<=0;
        end
        memory_acknowledgement<=0;
    end
    4'd1:begin
        memory_acknowledgement<=0;
        if(counter<1)begin
            state<=2;
        end
        counter=counter-1;
        
    end
    4'd2:begin
        state<=0;
        counter<=5;
        memory_acknowledgement<=1;
    end
    endcase
end
endmodule