//----------------------------------------------------
// A four level, round-robin arbiter. This was
// orginally coded by WD Peterson in VHDL.
//----------------------------------------------------
module vc_arbiter 
(
    // --------------Port Declaration----------------------- 
    input  {L} clk,    
    input  {L} rst,    

    input  {L} in0_domain,
    input  {L} in1_domain,
    input  {L} in2_domain,

    input  {Ctrl in0_domain} req0,   
    input  {Ctrl in1_domain} req1,   
    input  {Ctrl in2_domain} req2, 
    
    output {Ctrl in0_domain} gnt0,   
    output {Ctrl in1_domain} gnt1,   
    output {Ctrl in2_domain} gnt2   
);
//--------------Internal Registers----------------------
wire    [1:0]   {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} gnt;   
wire            {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} comreq; 
wire            {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} beg;
wire   [1:0]    {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lgnt;
wire            {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lcomreq;
reg             {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lgnt0;
reg             {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lgnt1;
reg             {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lgnt2;
reg             {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lasmask;
reg             {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lmask0;
reg             {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} lmask1;
reg             {Ctrl in0_domain join Ctrl in1_domain join Ctrl in2_domain} ledge;

//--------------Code Starts Here----------------------- 
always @ (posedge clk)
if (rst) begin
  lgnt0 <= 0;
  lgnt1 <= 0;
  lgnt2 <= 0;
end else begin                                     
  lgnt0 <=(~lcomreq & ~lmask1 & ~lmask0 & ~req2 & ~req1 & req0)
        | (~lcomreq & ~lmask1 &  lmask0 & ~req2 &  req0)
        | (~lcomreq &  lmask1 &  lmask0 & req0  )
        | ( lcomreq & lgnt0 );
  lgnt1 <=(~lcomreq & ~lmask1 & ~lmask0 &  req1)
        | (~lcomreq & ~lmask1 &  lmask0 & ~req2 &  req1 & ~req0)
        | (~lcomreq &  lmask1 &  lmask0 &  req1 & ~req0)
        | ( lcomreq &  lgnt1);
  lgnt2 <=(~lcomreq & ~lmask1 & ~lmask0 &  req2  & ~req1)
        | (~lcomreq & ~lmask1 &  lmask0 &  req2)
        | (~lcomreq &  lmask1 &  lmask0 &  req2 & ~req1 & ~req0)
        | ( lcomreq &  lgnt2);
end 

//----------------------------------------------------
// lasmask state machine.
//----------------------------------------------------
assign beg = (req2 | req1 | req0) & ~lcomreq;
always @ (posedge clk)
begin                                     
  lasmask <= (beg & ~ledge & ~lasmask);
  ledge   <= (beg & ~ledge &  lasmask) 
          |  (beg &  ledge & ~lasmask);
end 

//----------------------------------------------------
// comreq logic.
//----------------------------------------------------
assign lcomreq =  ( req2 & lgnt2 )
                | ( req1 & lgnt1 )
                | ( req0 & lgnt0 );

//----------------------------------------------------
// Encoder logic.
//----------------------------------------------------
assign  lgnt =  {(lgnt0 | lgnt2),(lgnt0 | lgnt1)};

//----------------------------------------------------
// lmask register.
//----------------------------------------------------
always @ (posedge clk )
if( rst ) begin
  lmask1 <= 0;
  lmask0 <= 0;
end else if(lasmask) begin
  lmask1 <= lgnt[1];
  lmask0 <= lgnt[0];
end else begin
  lmask1 <= lmask1;
  lmask0 <= lmask0;
end 

assign comreq = lcomreq;
assign gnt    = lgnt;
//----------------------------------------------------
// Drive the outputs
//----------------------------------------------------
assign gnt2   = lgnt2;
assign gnt1   = lgnt1;
assign gnt0   = lgnt0;

endmodule
