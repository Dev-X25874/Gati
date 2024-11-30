module  Wr_ctrl
(
  //System Signal
  SysClk      , //System Clock
  Reset_N     , //System Reset
  //config AXI&DDR Operate Parameter
  CfgWrAddr   , //(I)Config Write Start Address  // Axi address
  CfgWrBLen   , //(I)Config Write Burst Length   // axi_blen
  axi_wr_id ,   
  w_ctrl_valid,
  w_ctrl_last ,
  
  //Operate Control & State
  RamWrStart  , //(I)Ram Operate Start      // axi valid
  RamWrData   , //(I)Ram Write Data        

  //Axi Slave Interfac Signal
  AWID        , //(O)[WrAddr]Write address ID.
  AWADDR      , //(O)[WrAddr]Write address.
  AWLEN       , //(O)[WrAddr]Burst length.
  AWSIZE      , //(O)[WrAddr]Burst size.
  AWBURST     , //(O)[WrAddr]Burst type.
  AWLOCK      , //(O)[WrAddr]Lock type.
  AWVALID     , //(O)[WrAddr]Write address valid.
  AWREADY     , //(I)[WrAddr]Write address ready.
  /////////////
  WID         , //(O)[WrData]Write ID tag.
  WDATA       , //(O)[WrData]Write data.
  WSTRB       , //(O)[WrData]Write strobes.
  WLAST       , //(O)[WrData]Write last.
  WVALID      , //(O)[WrData]Write valid.
  WREADY      , //(I)[WrData]Write ready.
  /////////////
  BID         , //(I)[WrResp]Response ID tag.
  BVALID      , //(I)[WrResp]Write response valid.
  BREADY        //(O)[WrResp]Response ready.
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  parameter   TCo_C           = 1                 ;
  parameter   AXI_DATA_WIDTH  = 256               ;
                                                  
  localparam  AXI_BYTE_NUMBER = AXI_DATA_WIDTH/8  ;
  localparam  AXI_DATA_SIZE   = $clog2(AXI_BYTE_NUMBER) ;  
                                                  
  localparam  ADW_C           = AXI_DATA_WIDTH    ;
  localparam  ABN_C           = AXI_BYTE_NUMBER   ;

  /////////////////////////////////////////////////////////

  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  input         SysClk    ;     //System Clock
  input         Reset_N   ;     //System Reset

  /////////////////////////////////////////////////////////
  //Operate Control & State
  input             RamWrStart  ; //(I)[DdrWrCtrl]Ram Operate Start
  input [ADW_C-1:0] RamWrData   ; //(I)[DdrWrCtrl]Ram Write Data
  input w_ctrl_valid ;
  input w_ctrl_last ;
  /////////////////////////////////////////////////////////
  //Config DDR Operate Parameter
  input   [31:0]    CfgWrAddr   ; //(I)[DdrWrCtrl]Config Write Start Address
  input   [ 7:0]    CfgWrBLen   ; //(I)[DdrWrCtrl]Config Write Burst Length
  input   [7:0 ]    axi_wr_id   ;
  /////////////////////////////////////////////////////////
  output  [ 7:0]    AWID        ; //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  output  [31:0]    AWADDR      ; //(O)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  output  [ 7:0]    AWLEN       ; //(O)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
  output  [ 2:0]    AWSIZE      ; //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  output  [ 1:0]    AWBURST     ; //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  output  [ 1:0]    AWLOCK      ; //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  output            AWVALID     ; //(O)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
  input             AWREADY     ; //(I)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////                 
  output  [ 7:0]    WID         ; //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  output[ABN_C-1:0] WSTRB       ; //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  output            WLAST       ; //(O)[WrData]Write last. This signal indicates the last transfer in a write burst.
  output            WVALID      ; //(O)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  input             WREADY      ; //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.
  output[ADW_C-1:0] WDATA       ; //(I)[WrData]Write data.
  /////////////                 
  input   [ 7:0]    BID         ; //(I)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  input             BVALID      ; //(I)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
  output            BREADY      ; //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

  wire AddrReady = AWREADY ;
   reg   DataWrStart = 0;
  /////////////////////////////////////////////////////////
  reg   [ 7:0]  WrBurstLen  =  8'h0;
  reg   [31:0]  WrStartAddr = 32'h0;

  always @( posedge SysClk)  begin
    if(RamWrStart)  WrBurstLen  <=  CfgWrBLen;
    else WrBurstLen  <= WrBurstLen ;
  end
  
  
  always @( posedge SysClk)  begin 
    if(RamWrStart)  WrStartAddr <= CfgWrAddr;
    else WrStartAddr <= WrStartAddr ;
  end

  /////////////////////////////////////////////////////////
  reg     AddrValid = 1'h0;
  
 always @( posedge SysClk)
  begin
     if (RamWrStart)  AddrValid <= 1'h1;
     else  AddrValid <=  1'h0 ;
  end 
  

  wire AddrWrEn = (AddrValid & AddrReady);

///////////////////////////////////////////////////////////
  wire  [ 7:0]  AWID    = axi_wr_id     ; //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  wire  [31:0]  AWADDR  = WrStartAddr   ; //(O)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  wire  [ 7:0]  AWLEN   = WrBurstLen    ; //(O)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
                                        
  wire  [ 2:0]  AWSIZE  = AXI_DATA_SIZE ; //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  wire  [ 1:0]  AWBURST = 2'b01         ; //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  wire  [ 1:0]  AWLOCK  = 2'b00         ; //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  wire          AWVALID = AddrValid     ; //(O)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.

  wire  DataWrReady     = WREADY  ;
  reg   DataWrValid     = 1'h0    ;
  reg   DataWrLast      = 1'h0    ;

                        
  assign  DataWrEn        = DataWrValid & DataWrReady              ;
  assign  DataWrEnd       = DataWrValid & DataWrReady & DataWrLast ;

 always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)           DataWrValid  <= # TCo_C 1'h0;
    else if (DataWrStart)   DataWrValid  <= # TCo_C 1'h1;
    else if (DataWrEnd)     DataWrValid  <= # TCo_C 1'h0;
  end
/////////////////////////////////////////////////////////
  wire  [      7:0]   WID     = axi_wr_id     ; //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  wire  [ABN_C-1:0]   WSTRB   = {ABN_C{1'h1}} ; //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  wire                WVALID  = w_ctrl_valid   ; //(O)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  wire                WLAST   = w_ctrl_last    ; //(O)[WrData]Write last. This signal indicates the last transfer in a write burst.
  wire  [ADW_C-1:0]   WDATA   = RamWrData     ; //(I)[WrData]Write data.

  ////////////////////////////////////////////////////////
  wire  [ 7:0]  WrByteNum = AXI_BYTE_NUMBER ;
  reg   [31:0]  WrAddrCnt = 32'h0           ;  //(O)Ram Write Address

  wire    BackValid = BVALID;

  /////////////////////////////////////////////////////////
  reg     BackReady = 1'h0; //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

  always @( posedge SysClk )
  begin
    if (!Reset_N)           BackReady  <=   # TCo_C 1'h0;
    else if (w_ctrl_last)    BackReady  <=  # TCo_C 1'h1;
    else if (BackValid)     BackReady  <=  # TCo_C 1'h0;
  end

  wire    BackRespond = BackReady & BackValid;

  /////////////////////////////////////////////////////////
  wire    BREADY = BackReady; //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

  /////////////////////////////////////////////////////////

endmodule