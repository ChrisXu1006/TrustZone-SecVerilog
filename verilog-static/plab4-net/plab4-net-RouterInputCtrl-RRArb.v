//========================================================================
// Router Input Ctrl Arbitration
//========================================================================

`include "plab4-net-RouterInputCtrl.v" 

`ifndef PLAB4_NET_ROUTER_INPUT_CTRL_RRARB_V
`define PLAB4_NET_ROUTER_INPUT_CTRL_RRARB_V

module plab4_net_RouterInputCtrlRRArb
#(
	parameter p_router_id	= 0,
	parameter p_num_routers = 8,

	// indicates the reqs signal to pass through a message
	
	parameter p_default_reqs = 3'b001,

	// parameter not meant to be set outside this module
	
	parameter c_dest_nbits = $clog2( p_num_routers )
)
(
	input						clk,
	input						reset,

	input	[c_dest_nbits-1:0]	dest_d1,
	input	[c_dest_nbits-1:0]	dest_d2,

	input						in_val_d1,
	input						in_val_d2,
	
	output						in_rdy_d1,
	output						in_rdy_d2,

	output						reqs_p0,
	output						reqs_p1,
	output						reqs_p2,

	input						grants_p0,
	input						grants_p1,
	input						grants_p2,
	output						domain
);

    reg		[2:0]				reqs;
	wire	[2:0]				grants;

	assign grants = {grants_p2, grants_p1, grants_p0};
	assign {reqs_p2, reqs_p1, reqs_p0} = reqs;

	// declare wires for individual control units
	
	wire	[2:0]				reqs_d1;
	wire	[2:0]				reqs_d2;
	
	reg 	[2:0]				grants_d1;
	reg 	[2:0]				grants_d2;

	// Input Control Unit for domain1's buffer
	
	plab4_net_RouterInputCtrl
	#(
		.p_router_id		(p_router_id),
		.p_num_routers		(p_num_routers),
		.p_default_reqs		(p_default_reqs)
	)
	d1_ctrl
	(
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

  reg	domain;

  always @(*) begin
	
	if (reset) begin
		domain = 1'b0;
		reqs = 3'b000;
		grants_d1 = 3'b000;
		grants_d2 = 3'b000;

	end

	else if ( fclk == 1'b0 ) begin
		domain = 1'b0;
		reqs = reqs_d1;
		grants_d1 = grants;
		grants_d2 = 3'b000;
	end

	else if ( fclk == 1'b1 ) begin
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


