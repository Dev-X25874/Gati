
/////
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
 //   output reg [255:0] wdata_out = 0 ,
    output [255:0] DdrWrData ,
    //  output reg DataWrEnd = 0 ,
    input [7:0] BLEN_w
) ;

reg [4:0] count_blen = 0 ;
reg [1:0] state = 0 ;
wire  WriteEn ;
reg [31:0] addr = 0 ;

assign WriteEn = wvalid_w & wready_w ; 

localparam IDLE = 2'b00;
localparam DELAY_SELECT = 2'b01 ;
localparam MEM_DATA = 2'b10;

always @ (posedge clk) begin 
    if (!rst) begin 
        wvalid_w <= 0;
        //wlast_w <= 0 ;
       // WriteEn <= 0;
       // wdata_out <= 0 ;
        count_blen <= 0 ;
        state <= IDLE ;
    end
    else begin 
        case (state)
            IDLE : begin 
                if (select == 1) begin 
                    state <= DELAY_SELECT ;
                   // wdata_out <= 0   ; 
                    count_blen <= 0 ;
                   // wlast_w  <= 0;
                    wvalid_w <= 0 ;
                    addr <= in_Addr;
                    //WriteEn <= 0 ;
                end

                else begin
                  //  wdata_out<= 0 ; 
                   // WriteEn <= 0;
                   // wlast_w  <= 0;
                    addr <= addr ;
                    count_blen <= 0 ;
                    state <= IDLE ; 
                end 
            end
            
            DELAY_SELECT  : begin 
                if (select == 1) 
                    state <=  MEM_DATA ;
                
                else 
                    state <=  IDLE ;
            end 
            
            MEM_DATA : begin 
                if (count_blen == BLEN_w +1) begin 
                        wvalid_w <= 0 ;
                       // wlast_w  <= 0; 
                       // WriteEn <= 0;
                        count_blen <= 0 ;
                       // wdata_out  <= wdata_out ;
                        state  <= IDLE ;
                  
                end 

               else if (count_blen == BLEN_w) begin 
                if (wready_w == 1) begin 
                    wvalid_w <= 1 ; 
                    count_blen <= count_blen + 1 ;
                    addr <= addr + 32;
                    state <= MEM_DATA ;
                end 
                else begin 
                    wvalid_w <= wvalid_w ;
                    count_blen <= count_blen ;
                    addr <= addr ;
                    state <= MEM_DATA ;
                end 
             end 
             
            else begin 
                if (wready_w == 1)  begin 
                    wvalid_w  <= 1;
                    addr  <= addr + 32 ;
                    count_blen  <= count_blen + 1 ;
                    state  <= MEM_DATA;
                end 
                else begin 
                    addr <= addr ;
                    wvalid_w  <= wvalid_w ;
                    state  <= MEM_DATA ;
               end 
            end 

         end 
      endcase 
    end
end 

always  @( posedge clk)  begin 
    if (wvalid_w && wready_w && (count_blen == BLEN_w)) 
        wlast_w  <= 1 ;
     
     else wlast_w  <= 0 ;

end 

/////////////////
localparam  [15:0]  AXI_BYTE_NUM  =   AXI_DATA_WIDTH/8  ;
localparam          ADW_C         =   AXI_DATA_WIDTH  ;
 reg   [ADW_C-1:0]  AddrData  = {ADW_C{1'h0}};    
 //wire [ADW_C-1:0]  DdrWrData ;       
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
       //   wvalid_w  <= 1 ;
          AddrData[j*32+15:j*32   ]  <=   AddValue[j][15:0] + AXI_BYTE_NUM;
          AddrData[j*32+31:j*32+16]  <=   AddValue[j][2] ? 16'haaaa : 16'h5555;
        end
        
      //  else wvalid_w  <= 0 ;
      end 
      
    end
  endgenerate                       
                              
  assign  DdrWrData   = AddrData; //(O)[DdrWrDataGen]DDR Write Data
 

endmodule 

////////////////////////////////////////////////////////////
