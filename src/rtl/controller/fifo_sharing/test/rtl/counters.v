module counters(
    input i_clk,
    input i_start,
    output o_layer_done,
    output o_done
);

reg [3:0] i = 0;
reg [3:0] j = 0;
reg [3:0] k = 0;
reg done = 0;
reg layer_done = 0;
reg [1:0] state = 0;
assign o_done = done;
assign o_layer_done = layer_done;

always @(posedge i_clk) begin
    case (state)
        0:begin
            i <= 0;
            j <= 0;
            k <= 0;
            if(i_start)begin
                state <= 1;
            end
        end 

        1: begin
            for(i = 0; i < 3; i = i + 1)begin   //layer_done
                layer_done <= 1'b1;
                done <= 1'b1;
                for(j = 0; j < 4; j = j + 1)begin   //done
                    done <= 1'b1;
                    layer_done <= 0;
                    for(k = 0; k < 10; k = k + 1)begin  //SA output
                        done <= 1'b0;
                        layer_done <= 0;
                    end
                end
            end    
        end

        default: state <= 0; 
    endcase
end
    
endmodule