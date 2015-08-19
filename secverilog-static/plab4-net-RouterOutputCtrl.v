//========================================================================
// Router Output Ctrl
//========================================================================

`ifndef PLAB4_NET_ROUTER_OUTPUT_CTRL_V
`define PLAB4_NET_ROUTER_OUTPUT_CTRL_V

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "vc-arbiters.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

module plab4_net_RouterOutputCtrl
(
  input        {L}	clk,
  input        {L}	reset,

  input		   {L}	reqs_domain,
  output	   {L}	out_domain,

  input  [2:0] {L}	reqs,
  output [2:0] {L}	grants,

  output       {Control out_domain}	out_val,
  input        {Control out_domain}	out_rdy,
  output [1:0] {L}	xbar_sel
);

  //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
// 
//   // add logic here
// 
//   assign grants = 0;
//   assign out_val = 0;
//   assign xbar_sel = 0;
// 
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  wire [2:0] 	{L}	arb_reqs;

  //----------------------------------------------------------------------
  // Round robin arbiter
  //----------------------------------------------------------------------

  vc_RoundRobinArb
  #(
    .p_num_reqs   (3)
  )
  arbiter
  (
    .clk    (clk),
    .reset  (reset),

    .reqs   (arb_reqs),
    .grants (grants)
  );

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  assign out_val = | grants;

  // we use reqs only if out_rdy is high

  assign arb_reqs = ( out_rdy ? reqs : 3'h0 );

  reg [1:0] {L}	xbar_sel;

  always @(*) begin
    if ( grants == 3'b001 )
      xbar_sel = 2'h0;
    else if ( grants == 3'b010 )
      xbar_sel = 2'h1;
    else
      xbar_sel = 2'h2;
  end

  reg	{L}	out_domain;

  always @(*) begin
	if ( reset == 1'b1 ) begin
	  out_domain = 1'b0;
	end

	else begin
	  out_domain = reqs_domain;
	end

  end
  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif /* PLAB4_NET_ROUTER_OUTPUT_CTRL_V */
