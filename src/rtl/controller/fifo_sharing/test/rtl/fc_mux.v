module fc_mux#(
    parameter COL = 32,
    parameter W_DATA = 8
)(
    input [(COL * (W_DATA + 1))-1 : 0] i_data,
    input [5:0] i_sel,
    output [W_DATA : 0] o_data
);

reg [W_DATA : 0] data = 0;
assign o_data = data;

always@(*)begin
case (i_sel)
    0:begin
      data <= i_data[8:0];  
    end 

    1: begin
        data <= i_data[17:9];
    end

    2: begin
        data <= i_data[26:18];
    end

    3: begin
        data <= i_data[35:27];
    end
    
    4: begin
        data <= i_data[44:36];
    end
    
    5: begin
        data <= i_data[53:45];
    end
    
    6: begin
        data <= i_data[62:54];
    end
    
    7: begin
        data <= i_data[71:63];
    end
    
    8: begin
        data <= i_data[80:72];
    end
    
    9: begin
        data <= i_data[89:81];
    end
    
    10: begin
        data <= i_data[98:90];
    end
    
    11: begin
        data <= i_data[107:99];
    end
    
    12: begin
        data <= i_data[116:108];
    end
    
    13: begin
        data <= i_data[125:117];
    end
    
    14: begin
        data <= i_data[134:126];
    end
    
    15: begin
        data <= i_data[143:135];
    end

    16:begin
        data <= i_data[152:144];  
      end 

    17: begin
        data <= i_data[161:153];
    end

    18: begin
        data <= i_data[170:162];
    end

    19: begin
        data <= i_data[179:171];
    end
    
    20: begin
        data <= i_data[188:180];
    end
    
    21: begin
        data <= i_data[197:189];
    end
    
    22: begin
        data <= i_data[206:198];
    end
    
    23: begin
        data <= i_data[215:207];
    end
    
    24: begin
        data <= i_data[224:216];
    end
    
    25: begin
        data <= i_data[233:225];
    end
    
    26: begin
        data <= i_data[242:234];
    end
    
    27: begin
        data <= i_data[251:243];
    end
    
    28: begin
        data <= i_data[260:252];
    end
    
    29: begin
        data <= i_data[269:261];
    end
    
    30: begin
        data <= i_data[278:270];
    end
    
    31: begin
        data <= i_data[287:279];
    end
    default: data <= 0;
endcase
end
    
endmodule