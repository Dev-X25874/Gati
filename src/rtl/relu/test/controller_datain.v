module controller_datain #( parameter N = 3,
                            parameter DATA_WIDTH = 32,
                            parameter CLIP_WIDTH = 8,
                            parameter UART_WIDTH = 8)(
    input                           clk,
    input [(UART_WIDTH-1):0]        data_in,
    input                           i_valid,
    output [(N*DATA_WIDTH)-1:0]     data_out,
    output [N-1:0]                  o_valid,
    output [(CLIP_WIDTH*N)-1:0]     o_clip
    
);

    reg [3:0]                   r_counter = N*4;
    reg [N-1:0]                 r_o_valid;
    reg [(N*32)-1:0]            r_data_out=0;
    reg [(CLIP_WIDTH*N)-1:0]    r_o_clip=0;
    reg [2:0]                   r_counter_clip = N;
    
    reg [2:0]                   p_state=0;
    assign o_valid = r_o_valid;
    assign data_out = r_data_out;
    assign o_clip = r_o_clip;
    
always @(posedge clk) begin
    case (p_state) 
/*    0 : begin
        if (i_valid) begin
            r_o_clip[(r_counter_clip*8)-1 -: 8] <= data_in;
            if (r_counter_clip > 1) begin
                p_state <= 0;
                r_counter <= r_counter - 1;
                r_o_valid <= {N{1'b0}};
            end
        end else if (r_counter_clip == 1)begin
                r_counter_clip <= 2;
                p_state <= 1;
        end
    end */

/*    0 : begin
        if (i_valid) begin
            r_o_clip[15:8] <= data_in;
            p_state <= 1;
            r_o_valid <= {N{1'b0}};
        end
    end
        1 : begin
            if (i_valid) begin
            
                r_o_clip[7 : 0] <= data_in;
                p_state <= 2;
            end
        end
        
*/ 


    0 : begin
        if (i_valid) begin
            p_state <= 1;
            r_o_clip[(r_counter_clip*8)-1 -: 8] <= data_in;
            r_o_valid <= {N{1'b0}};

        end
    end
    1 : begin   
        if (r_counter_clip > 1) begin
            r_counter_clip <= r_counter_clip - 1;
            p_state <= 0;
        end else if (r_counter_clip == 1)begin
            r_o_clip[(r_counter_clip*8)-1 -: 8] <= data_in;
            r_counter_clip <= N;
            p_state <= 2;
            r_o_valid <= {N{1'b0}};
        end
    end  
    2 : begin
        if (i_valid) begin
            p_state <= 3;
            r_data_out[(r_counter*8)-1 -: 8] <= data_in;
            r_o_valid <= {N{1'b0}};

        end
    end
    3 : begin   
        if (r_counter > 1) begin
            r_counter <= r_counter - 1;
            p_state <= 2;
        end else if (r_counter == 1)begin
            r_data_out[(r_counter*8)-1 -: 8] <= data_in;
            r_counter <= N*4;
            p_state <= 4;
            r_o_valid <= {N{1'b1}};
        end
    end
    4 : begin
        r_o_valid <= {N{1'b0}};
        p_state <= 0;
        end
    endcase
end
    
endmodule