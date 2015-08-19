//========================================================================
// Router Input Ctrl Arbitration
//========================================================================

`include "plab4-net-RouterInputCtrl.v" 

`ifndef PLAB4_NET_ROUTER_INPUT_CTRL_RRARB_SEP_V
`define PLAB4_NET_ROUTER_INPUT_CTRL_RRARB_SEP_V

module plab4_net_RouterInputCtrlRRArb_Sep
#(
	parameter p_router_id	= 0,
	parameter p_num_routers = 8,

	// indicates the reqs signal to pass through a message
	
	parameter p_default_reqs = 3'b001,

	// parameter not meant to be set outside this module
	
	parameter c_dest_nbits = $clog2( p_num_routers )
)
(
	input						{L} clk,
	input						{L} reset,

	input	[c_dest_nbits-1:0]	{D1} dest_d1,
	input	[c_dest_nbits-1:0]	{D2} dest_d2,

	input						{D1} in_val_d1,
	input						{D2} in_val_d2,
	
	output						{D1} in_rdy_d1,
	output						{D2} in_rdy_d2,

	output						{Domain domain} reqs_p0,
	output						{Domain domain} reqs_p1,
	output						{Domain domain} reqs_p2,

	input						{Domain domain} grants_p0,
	input						{Domain domain} grants_p1,
	input						{Domain domain} grants_p2,
	output						{L} domain
);

    reg		[2:0]				{Domain domain} reqs;
	wire	[2:0]				{Domain domain} grants;

	assign grants = {grants_p2, grants_p1, grants_p0};
	assign {reqs_p2, reqs_p1, reqs_p0} = reqs;

	// declare wires for individual control units
	
	wire	[2:0]				{D1} reqs_d1;
	wire	[2:0]				{D2} reqs_d2;
	
	reg 	[2:0]				{D1} grants_d1;
	reg 	[2:0]				{D2} grants_d2;

	// Input Control Unit for domain1's buffer
	
	plab4_net_RouterInputCtrl
	#(
		.p_router_id		(p_router_id),
		.p_num_routers		(p_num_routers),
		.p_default_reqs		(p_default_reqs)
	)
	d1_ctrl
	(
        .domain             (0),
		.dest				(dest_d1),
		.in_val				(in_val_d1),
		.in_rdy				(in_rdy_d1),
		.reqs				(reqs_d1),
		.grants				(grants_d1)
	);

	// Input Control Unit for domain2's buffer
	
	plab4_net_RouterInputCtrl
	#(
		.p_router_id		(p_router_id),
		.p_num_routers		(p_num_routers),
		.p_default_reqs		(p_default_reqs)
	)
	d2_ctrl
	(
        .domain             (1),
		.dest				(dest_d2),
		.in_val				(in_val_d2),
		.in_rdy				(in_rdy_d2),
		.reqs				(reqs_d2),
		.grants				(grants_d2)
	);

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------
  
  // In this module, we apply strict Round-Robin mechanism for arbitration
  // Odd cycles for domain1, and even cycles for domain2

  reg	{L} domain;

  always @(*) begin
	
	if (reset) begin
		domain = 1'b0;
		reqs = 3'b000;
		grants_d1 = 3'b000;
		grants_d2 = 3'b000;

	end

	else if ( clk == 1'b0 ) begin
		domain = 1'b0;
		reqs = reqs_d1;
		grants_d1 = grants;
		grants_d2 = 3'b000;
	end

	else if ( clk == 1'b1 ) begin
		domain = 1'b1;
		reqs = reqs_d2;
		grants_d1 = 3'b000;
		grants_d2 = grants;
	end

  end

  // rdy is just a reductive OR of the AND of reqs and grants

  //assign in_rdy_d1 = | (reqs_d1 & grants_d1 );
  //assign in_rdy_d2 = | (reqs_d2 & grants_d2 );

endmodule 

`endif /* PLAB4_NET_ROUTER_INPUT_CTRL_RRARB_V */


