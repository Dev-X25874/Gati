module bram_rden_ctrl#(
    parameter N_BANK = 4,
    parameter BRAM_BANK_FF = 8
)(
    input clk,
    input rst,
    input w_done,
    input iteration_done,   //accumulator data valid
    input flatten,
    input [3:0] image_height,
    input [3:0] image_width,
    input [14:0] image_dimension,
    output [(N_BANK * BRAM_BANK_FF)-1 : 0] read_enable,
    output o_done,
    output [N_BANK-1 : 0] bank_enable
);

//Assert read enable on one bram at a time, one by one 
reg [3:0] rden_counter = 0;         //here, counts from 1 to 8
//increment address after reading an element from all bram in a bank
reg [4:0] addr_counter = 0;         //here, counts from 1 to 8  //TODO: Counts till 7 or 8?
//counts all the elements of one image stored in a bank
reg [8:0] element_counter = 0;      //here, counts from 1 to 49 for 7x7 image dimension
//counts number of times this image is iterated all over again for remaining set of kernals
reg [9:0] kernal_counter = 0;       //here,for 4096 neurons, counts from 1 to 128
//counts number of banks enables
reg [3:0] bank_en_counter = 0;

reg [1:0] bank_en_state = 0;
reg [1:0] rden_state = 0;
reg done = 0;
reg [N_BANK-1 : 0] bank_en = 0;
reg [(N_BANK * BRAM_BANK_FF)-1 : 0] rden = 0;
assign read_enable = rden;
assign bank_enable = bank_en;
assign o_done = done;

//To assert bank enable signal
always @(posedge clk) begin
    if(rst)begin
        bank_en <= 0;
        bank_en_counter <= 0;
    end else begin
        case (flatten)
            1'b0:begin
                case (bank_en_state)    //TODO: Check iteration done (accumulator valid) condition
                    0:begin
                        if(w_done)begin
                            bank_en_state <= 1;
                        end
                    end

                    1: begin
                        if(kernal_counter == 0)begin
                            if(bank_en_counter == N_BANK-1)begin
                                bank_en_counter <= 0;
                                kernal_counter <= kernal_counter + 1;
                            end else begin
                                if(element_counter == 9'd8)begin
                                    bank_en <= 1'b0;
                                    bank_en_counter <= bank_en_counter + 1;
                                end else begin
                                    bank_en <= 1'b1;
                                    element_counter <= element_counter + 1;
                                end
                            end
                            bank_en[bank_en_counter] <= 1;
                            bank_en[bank_en_counter-1] <= 0;
                        end else begin
                            if(kernal_counter == 10'128)begin
                                state <= 0;
                                done <= 1'b1;
                            end else begin
                                if(bank_en_counter == N_BANK-1)begin
                                    bank_en_counter <= 0;
                                    kernal_counter <= kernal_counter + 1;
                                end else begin
                                    if(element_counter == 9'd8)begin
                                        bank_en <= 1'b0;
                                        bank_en_counter <= bank_en_counter + 1;
                                    end else begin
                                        bank_en <= 1'b1;
                                        element_counter <= element_counter + 1;
                                    end
                                end
                                bank_en[bank_en_counter] <= 1;
                                bank_en[bank_en_counter-1] <= 0;
                            end
                        end
                    end
                endcase
            end

            1'b1:begin
                case (bank_en_state)    //TODO: Check iteration done (accumulator valid) condition
                    0:begin
                        if(w_done)begin
                            bank_en_state <= 1;
                        end
                    end

                    1: begin
                        if(kernal_counter == 0)begin
                            if(bank_en_counter == N_BANK-1)begin
                                bank_en_counter <= 0;
                                kernal_counter <= kernal_counter + 1;
                            end else begin
                                if(element_counter == (image_height * image_width))begin
                                    bank_en <= 1'b0;
                                    bank_en_counter <= bank_en_counter + 1;
                                end else begin
                                    bank_en <= 1'b1;
                                    element_counter <= element_counter + 1;
                                end
                            end
                            bank_en[bank_en_counter] <= 1;
                            bank_en[bank_en_counter-1] <= 0;
                        end else begin
                            if(kernal_counter == 10'128)begin
                                state <= 0;
                                done <= 1'b1;
                            end else begin
                                if(bank_en_counter == N_BANK-1)begin
                                    bank_en_counter <= 0;
                                    kernal_counter <= kernal_counter + 1;
                                end else begin
                                    if(element_counter == (image_height * image_width))begin
                                        bank_en <= 1'b0;
                                        bank_en_counter <= bank_en_counter + 1;
                                    end else begin
                                        bank_en <= 1'b1;
                                        element_counter <= element_counter + 1;
                                    end
                                end
                                bank_en[bank_en_counter] <= 1;
                                bank_en[bank_en_counter-1] <= 0;
                            end
                        end
                    end
                endcase
            end
        endcase
    end
end

//To assert read enable signal
always @(posedge clk) begin
    if(rst)begin
        rden <= 0;
    end begin
        case (rden_state)
            0:begin
                if(w_done)begin
                    state <= 1;
                end
            end
            1: begin
                if(bank_en != 0)begin   //One hot to binary converter and send address part accordingly
                    if(addr_counter == 5'd8)begin
                        addr_counter <= addr_counter;
                        rden <= 0;
                    end else begin
                        if(rden_counter == 4'd7)begin
                            rden_counter <= 0;
                            addr_counter <= addr_counter + 1;
                        end else
                            rden_counter <= rden_counter + 1;
                        
                        rden[rden_counter] <= 1;
                        rden[rden_counter-1] <= 0;
                    end
                end
            end
        endcase
    end
end
    
endmodule