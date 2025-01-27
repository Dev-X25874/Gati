/*
    Reads data from BRAM array. Based on flattening input,
    the way data is read changes in both the case, whether flattening
    is required or not.
*/
module bram_rden_controller#(
    parameter W_KERNAL_CNT = 10,
    parameter W_IMG_DIM = 20,
    parameter N_BRAM = 8,
    parameter N_BANK = 4,
    parameter W_ADDR = 9,
    parameter W_IMG_BRAM_ADDR = 10
)(
    input clk,
    input rstn,
    input w_done,
    input accumulator_valid,
    input flatten,
    input [W_KERNAL_CNT-1 : 0] kernal_count,
    input weight_ff_array_empty,
    input weight_ff_array_almost_empty,
    input [W_IMG_DIM-1 : 0] image_dimension,
    input [W_IMG_BRAM_ADDR-1 : 0] i_addr_counter,
    output [N_BRAM-1 : 0] o_read_enable,
    output reg rd_flag,
    output o_done,
    output [(N_BANK * (W_ADDR + 1))-1 : 0] o_bank_address,
    output [N_BANK-1 : 0] o_bank_enable,
    output [W_KERNAL_CNT-1:0] r_kernal_counter,
    output weight_ff_trigger
);

reg [1:0] state = 0;
reg [N_BRAM-1 : 0] rden = 0;
reg done = 0;
reg [N_BANK-1 : 0]bank_en = 0;
reg [(N_BANK * (W_ADDR + 1))-1 : 0] addr = 0;
integer i;
wire [N_BRAM-1 : 0] rd_bram;
assign o_done = done;
// assign o_read_enable = rden;
assign o_read_enable = rden;
assign o_bank_address = addr;
assign o_bank_enable = bank_en;
assign weight_ff_trigger = |(rden);
assign r_kernal_counter=kernal_counter;
reg [1:0] rd_state = 0;

//count number of elements in a bank, 1-49
reg [W_IMG_DIM-1:0] element_counter = 0;
//count number of reads in one row of a bank, 1-8
reg [$clog2(N_BRAM)-1:0] rden_counter = 0;
//holds value of an address to be incremented in a bank, 1-7/8
reg [W_ADDR:0] addr_counter = 0;
//hold adress of previous BRAM BANK
reg [W_ADDR:0] next_addr = 0;
//counts number of banks, 1-4 
reg [$clog2(N_BANK)-1:0] bank_counter = 0;
//counts how many times does shifting of bank enable signal need to be done, for flatten = 0 counts is 1-28, for flatten = 1 counts is 1-4
reg [W_ADDR:0] bank_shift_counter = 0;
//counts how many times the image will be used again for different sets of kernals, 1 - 128
reg [W_KERNAL_CNT-1:0] kernal_counter = 0;
//holds number of address to be read from a bank
wire[W_ADDR:0] temp_value;
	reg r_w_done;
    reg r_accumulator_valid;
    reg r_flatten;
    reg [W_KERNAL_CNT-1 : 0] r_kernal_count;
    reg [(N_BANK * N_BRAM)-1 : 0] r_weight_ff_array_empty;
    reg [W_IMG_DIM-1 : 0] r_image_dimension,shift_rim,mod_rim,sub1_rim;
    reg [W_IMG_BRAM_ADDR-1 : 0] r_i_addr_counter;
    reg flag;

assign temp_value = shift_rim + (mod_rim == 0 ? 0 : 1);
    wire fc_ff_empty;
    wire fc_ff_almost_empty;

    assign fc_ff_empty = (weight_ff_array_empty);
    assign fc_ff_almost_empty = (weight_ff_array_almost_empty);

	always @(posedge clk) begin 
		mod_rim<=r_image_dimension % N_BRAM;
		shift_rim<=r_image_dimension >> ($clog2(N_BRAM));
		sub1_rim<=image_dimension-1;
		r_w_done<=w_done;
		r_accumulator_valid<=accumulator_valid;
		r_flatten<=flatten;
		r_kernal_count<=kernal_count;
		r_weight_ff_array_empty<=weight_ff_array_empty;
		r_image_dimension<=image_dimension;
		r_i_addr_counter<=i_addr_counter;
        flag <= (bank_shift_counter==r_i_addr_counter)?1:0;
	end
//Asserts bank enable signal and handles address incrementation
always @(posedge clk) begin
    if(~rstn)begin
        bank_en <= 0;
        addr <= 0;
        bank_shift_counter <= 0;
        bank_counter <= 0;
        element_counter <= 0;
    end else begin
       case(r_flatten)
            1'b0:begin
                case (state)
                    0:begin
                        done <= 0;
                        bank_en <= 0;
                        element_counter <= 0;
                        next_addr <= 0;
                        bank_counter <= 0;
                        bank_shift_counter <= 0;
                        kernal_counter <= 0;
                       if(r_w_done)begin
                        state <= 1;
                       end 
                    end
                    1: begin
                        if(kernal_counter < r_kernal_count) begin
                            if((fc_ff_almost_empty) && |(rden)) begin
                                rden <= 0;
                            end
                            else if(~(fc_ff_empty)) begin
                                // flag <= 1;
                                if(bank_shift_counter < r_i_addr_counter)begin   //need to keep shifting bank enable signal for 4 times, 1-7  addresses in one shifting of a bank's enable
                                    if(element_counter == (N_BRAM-1))begin
                                        
                                        rden_counter <= 0;
                                        addr_counter <= addr_counter + 1;
                                        if(bank_counter == N_BANK-1) begin
                                            next_addr <= addr_counter + 1;
                                            addr_counter <= addr_counter + 1;
                                            // bank_counter <= 0;
                                            bank_shift_counter <= bank_shift_counter + 1;
                                        end
                                        else begin
                                            addr_counter <= next_addr;
                                        end

                                        bank_counter <= bank_counter + 1;
                                        element_counter <= 0;
                                        for(i=0;i<=N_BANK-1;i=i+1) begin
                                            if(bank_counter==i) begin 
                                                addr[((W_ADDR + 1) * (i + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                            end
										end
                                        
                                        //addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                        // addr_counter <= next_addr;
                                        if(rden_counter == 0)
                                            rden[N_BRAM-1] <= 0;
                                        else 
                                            rden[rden_counter-1] <= 0;
                                        rden[rden_counter] <= 1;

                                    end else begin
                                        element_counter <= element_counter + 1;
                                        bank_counter <= bank_counter;
                                        for(i=0;i<=N_BANK-1;i=i+1) begin
											if(bank_counter==i) begin 
												addr[((W_ADDR + 1) * (i + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
											end			
										end
											//addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                  
                                            //update read counter conditions
                                        if(addr_counter == r_i_addr_counter)begin
                                            rden <= 0;
                                        end else begin
                                            rden_counter <= rden_counter + 1;
                                            addr_counter <= addr_counter;
                                            rden[rden_counter] <= 1;
                                            if(N_BRAM > 1)begin
                                                if(rden_counter == 0)
                                                    rden[N_BRAM-1] <= 0;
                                                else
                                                    rden[rden_counter-1] <= 0;
                                            end else begin
                                                rden <= 0;
                                                rden_counter <= 0;
                                            end
                                        end
                                        bank_en[bank_counter] <= 1;

                                        if(N_BANK > 1)begin
                                            if(bank_counter == 0)
                                                bank_en[N_BANK - 1] <= 0;
                                            else
                                                bank_en[bank_counter - 1] <= 0;
                                        end else begin
                                            bank_counter <= 0;
                                            bank_en <= 0;
                                        end
                                        
                                        bank_shift_counter <= bank_shift_counter;
                                    end
                                end else begin
                                    state <= 2;
                                    rden <= 0;
                                    bank_en <= 0;
                                    addr <= 0;
                                end
                            end
                            else begin
                                if(flag) begin
                                    state <= 2;
                                    rden <= 0;
                                    bank_en <= 0;
                                    addr <= 0;
                                end
                            end
                        end
                        else begin
                            done <= 1'b1;
                            kernal_counter <= 0;
                            state <= 0;
                        end
                    end

                    2: begin
                        bank_counter <= 0;
                        rden_counter <= 0;
                        bank_shift_counter <= 0;
                        element_counter <= 0;
                        addr <= 0;
                        addr_counter <= 0;
                        next_addr <= 0;
                        if(accumulator_valid)begin
                            kernal_counter <= kernal_counter + 1;
                            state <= 1;
                        end
                    end
                    default: state <= 0;
                endcase
            end
            1'b1: begin
                case (state)
                    0:begin
                        done <= 0;
                        bank_en <= 0;
                        element_counter <= 0;
                        bank_counter <= 0;
                        bank_shift_counter <= 0;
                        kernal_counter <= 0;
                        next_addr <= 0;
                    if(r_w_done)begin
                        state <= 1;
                    end 
                    end
                    1: begin
                        if(kernal_counter < r_kernal_count)begin
                            if(((fc_ff_almost_empty)) && |(rden)) begin
                                rden <= 0;
                            end
                            else if(~(fc_ff_empty))begin
                                // rd_flag <= 1;
                                if(bank_shift_counter < r_i_addr_counter)begin   //need to keep shifting bank enable signal for 4 times, 1-7  addresses in one shifting of a bank's enable
                                        if(element_counter == (sub1_rim))begin
                                            
                                            if(bank_counter == N_BANK-1) begin
                                                next_addr <= addr_counter + 1;
                                                addr_counter <= addr_counter + 1;
                                                bank_shift_counter <= bank_shift_counter + temp_value;
                                            end
                                            else begin
                                                addr_counter <= next_addr;
                                            end

                                            bank_counter <= bank_counter + 1;
                                            element_counter <= 0;
                                          	for(i=0;i<=N_BANK-1;i=i+1) begin
												if(bank_counter==i) begin 
													addr[((W_ADDR + 1) * (i + 1))-1 -: (W_ADDR + 1)] <= addr_counter;

												end
											end
										    //	addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                            // addr_counter <= next_addr;
                                            rden_counter <= 0;
                                            if(rden_counter == 0)
                                                rden[N_BRAM-1] <= 0;
                                            rden[rden_counter] <= 1;

                                        end else begin
                                            element_counter <= element_counter + 1;
                                            bank_counter <= bank_counter;
                                           // addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                            for(i=0;i<=N_BANK-1;i=i+1) begin
												if(bank_counter==i) begin 
													addr[((W_ADDR + 1) * (i + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
												end											
											end

                                            //update read counter conditions
                                            if(addr_counter == r_i_addr_counter)begin
                                                rden <= 0;
                                                bank_en <= 0;
                                            end else begin
                                                if(rden_counter == N_BRAM-1)begin
                                                    rden_counter <= 0;
                                                    addr_counter <= addr_counter + 1;
                                                end else begin
                                                    rden_counter <= rden_counter + 1;
                                                    addr_counter <= addr_counter;
                                                end
                                                rden[rden_counter] <= 1;
                                                if(N_BRAM > 1)begin
                                                    if(rden_counter == 0)
                                                        rden[N_BRAM-1] <= 0;
                                                    else
                                                        rden[rden_counter-1] <= 0;
                                                end else begin
                                                    rden <= 0;
                                                    rden_counter <= 0;
                                                end
                                            end
                                            bank_en[bank_counter] <= 1;

                                            if(N_BANK > 1)begin
                                                if(bank_counter == 0)
                                                    bank_en[N_BANK - 1] <= 0;
                                                else
                                                    bank_en[bank_counter - 1] <= 0;
                                            end else begin
                                                bank_counter <= 0;
                                                bank_en <= 0;
                                            end
                                        
                                            bank_shift_counter <= bank_shift_counter;
                                        end
                                end else begin
                                    state <= 2;
                                    rden <= 0;
                                    bank_en <= 0;
                                    addr <= 0;
                                end
                            end
                            else begin
                                if(flag) begin
                                    state <= 2;
                                    rden <= 0;
                                    bank_en <= 0;
                                    addr <= 0;
                                end
                            end
                        end
                        else begin
                            done <= 1'b1;
                            kernal_counter <= 0;
                            state <= 0;
                        end                       
                    end
                    2: begin
                        rden_counter <= 0;
                        addr_counter <= 0;
                        next_addr <= 0;
                        bank_shift_counter <= 0;
                        bank_counter <= 0;
                        bank_en <= 0;
                        addr <= 0;
                        if(accumulator_valid)begin
                            kernal_counter <= kernal_counter + 1;
                            state <= 1;
                        end 
                    end
                    default: state <= 0;
                endcase
            end
       endcase 
    end
end

// assign rd_bram = ~(|weight_ff_array_empty)? rden : 0;
// assign rd_flag = flag;
endmodule
