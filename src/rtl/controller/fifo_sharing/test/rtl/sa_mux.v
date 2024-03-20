module sa_mux#(
    parameter COL = 16,
    parameter W_DATA = 8
)(
    input [(COL * (W_DATA + 1))-1 : 0] i_data,
    input [4:0] i_sel,
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
    default: data <= 0;
endcase
end
    
endmodule