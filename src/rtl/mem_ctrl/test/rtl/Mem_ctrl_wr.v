module Mem_ctrl_wr #(
parameter   AXI_DATA_WIDTH = 256
) (
    input clk,
    input rst,
    input select,
    input wready_w,
    output reg wvalid_w = 0,
    output reg wlast_w = 0,
    input [31:0] in_Addr ,
    output reg [255:0] wdata_out = 0,
    input [7:0] BLEN_w
) ;


reg [3:0] count_blen = 0 ;
reg [1:0] state = 0 ;
reg WriteEn = 0;
reg [31:0] addr = 0 ;

localparam IDLE = 2'b00;
localparam MEM_DATA = 2'b01;
localparam COUNT_BLEN = 2'b10;

always @ (posedge clk) begin 
    if (!rst) begin 
        wvalid_w <= 0;
        wlast_w <= 0 ;
        addr <= 0 ;
        wdata_out <= 0 ;
        count_blen <= 0 ;
        state <= IDLE ;
    end

    else begin 
        case (state)
            IDLE : begin 
                if (select == 1) begin 
                    state <= MEM_DATA ;
                    wdata_out <= 0 ; 
                    count_blen <= 0 ;
                    wvalid_w <= 1 ;
                    addr <= in_Addr;
                    WriteEn <= 0;
                end

                else 
                    state <= IDLE ; 
            end

            MEM_DATA : begin 
                if (wready_w == 1) begin 
                    wvalid_w <= 1 ;
                    wdata_out <= DdrWrData ;
                    count_blen <= count_blen + 1 ;
                    WriteEn <= 1;
                    addr <= addr + 32;
                    if (count_blen == BLEN_w) begin
                        wlast_w <= 1 ;
                        WriteEn <= 1;
                        wdata_out <= wdata_out ;
                        state <= COUNT_BLEN ;
                    end

                end

                else begin 
                    WriteEn <= WriteEn;
                    addr <= addr;
                    wvalid_w <= wvalid_w ;
                    wdata_out <= wdata_out ; 
                    state <= MEM_DATA ;
                end 
            end 

            COUNT_BLEN : begin 
                wvalid_w <= 0 ; 
                wlast_w <= 0 ;
                WriteEn <= 0 ;
                state <= IDLE ;
                wdata_out <= 0 ;
            end 

        endcase 
    end
end 

localparam  [15:0]  AXI_BYTE_NUM  =   AXI_DATA_WIDTH/8  ;
localparam          ADW_C         =   AXI_DATA_WIDTH  ;
 reg   [ADW_C-1:0]  AddrData  = {ADW_C{1'h0}};    
 wire [ADW_C-1:0]  DdrWrData ;       
  tri0  [15:0]      Adder     [7:0];
  wire  [15:0]      AddValue  [7:0];
  
  genvar  j;
  generate  
    for (j=0;j<ADW_C/32;j=j+1)
    begin : DdrWrDataGen_AddrData_Output
      
      assign Adder[j]             = {11'h0,j,2'h0};
      assign AddValue[j][15:0]    = addr[31:16] + addr[15:0] + Adder[j] ;
      
      always @( posedge clk)  
      begin
        if (WriteEn)
        begin
          AddrData[j*32+15:j*32   ]  <=   AddValue[j][15:0] + AXI_BYTE_NUM;
          AddrData[j*32+31:j*32+16]  <=   AddValue[j][2] ? 16'haaaa : 16'h5555;
        end
      end 
      
    end
  endgenerate                       
                              
  assign  DdrWrData   = AddrData; //(O)[DdrWrDataGen]DDR Write Data

endmodule 

