module counters(
    input i_clk,
    input i_start,
    output o_layer_done,
    output o_done
);

reg [4:0] count3 = 0;
reg [4:0] count2 = 0;
reg [9:0] count1 = 0;
reg done = 0;
reg layer_done = 0;
reg [1:0] state = 0;
assign o_done = done;
assign o_layer_done = (count3 == 2);

wire w_start;
one_pulse start_pulse(
    .a(i_start),
    .clk(i_clk),
    .b(w_start)
);

always @(posedge i_clk) begin
    case (state)
        0:begin
            count3 <= 0;
            count2 <= 0;
            count1 <= 0;
            done <= 1'b0;
            if(w_start)begin
                state <= 1;
            end
        end 

        1: begin
            if(count3 == 2)begin
                count3 <= 0;
                count2 <= 0;
                count1 <= 0;
                state <= 0;
                done <= 0;
            end else begin
                if(count2 == 4)begin
                    count3 <= count3 + 1;
                    count2 <= 0;
                    done <= 0;
                end else begin
                    if(count1 == 30)begin
                        count2 <= count2 + 1;
                        count1 <= 0;
                        done <= 1'b1;
                    end else begin
                        count1 <= count1 + 1;
                        done <= 1'b0;
                    end
                end
            end
        end

        default: state <= 0; 
    endcase
end
    
endmodule