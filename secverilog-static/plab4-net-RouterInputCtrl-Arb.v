//========================================================================
// Router Input Ctrl Arbitration
//========================================================================

`include "plab4-net-RouterInputCtrl.v" 

`ifndef PLAB4_NET_ROUTER_INPUT_CTRL_ARB_V
`define PLAB4_NET_ROUTER_INPUT_CTRL_ARB_V

module plab4_net_RouterInputCtrlArb
#(
	parameter p_router_id	= 0,
	parameter p_num_routers = 8,

	// indicates the reqs signal to pass through a message
	
	parameter p_default_reqs = 3'b001,

	// parameter not meant to be set outside this module
	
	parameter c_dest_nbits = $clog2( p_num_routers )
)
(
	input	[c_dest_nbits-1:0]	{L}	dest_d1,
	input	[c_dest_nbits-1:0]	{L}	dest_d2,

	input						{L}	in_val_d1,
	input						{L}	in_val_d2,
	
	output						{L}	in_rdy_d1,
	output						{L}	in_rdy_d2,

	output	[2:0]				{L}	reqs,
	output	[2:0]				{L}	grants,
	output						{L}	domain
);

    reg		[2:0]				{L}	reqs;

	// declare wires for individual control units
	
	wire	[2:0]				{L}	reqs_d1;
	wire	[2:0]				{L}	reqs_d2;
	
	reg 	[2:0]				{L}	grants_d1;
	reg 	[2:0]				{L}	grants_d2;

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
  
  // if only one domain has requests, only passing them to the final results,
  // Otherwise, using arbitration to determine which one is passed

  reg	  {L}	i;
  reg	  {L}	domain;

  always @(*) begin
	
	if ( reqs_d1 != 3'b000 && reqs_d2 == 3'b000 ) begin
		reqs = reqs_d1;
		domain = 1'd0;
	end
	
	else if ( reqs_d1 == 3'b000 && reqs_d2 != 3'b000 ) begin
		reqs = reqs_d2;
		domain = 1'd1;
	end
	
	else if ( reqs_d1 != 3'b000 && reqs_d2 != 3'b000 ) begin

		i = $random % 2;

		if ( i == 0 ) begin
			reqs = reqs_d1;
			domain = 1'd0;
		end

		else begin
			reqs = reqs_d2;
			domain = 1'd1;
		end
	end

	else
		reqs = 3'b000;
  end

  // When grants return back to the arbiter, it based on the domain signal to
  // set each domain's grants signal

  always @(*) begin
	
	if ( domain == 1'b0 ) begin
		grants_d1 = grants;
		grants_d2 = 3'b000;
	end

	else if ( domain == 1'b1 ) begin
		grants_d1 = 3'b000;
		grants_d2 = grants;
	end
  end

  // rdy is just a reductive OR of the AND of reqs and grants

  assign in_rdy_d1 = | (reqs_d1 & grants_d1 );
  assign in_rdy_d2 = | (reqs_d2 & grants_d2 );

endmodule 

`endif /* PLAB4_NET_ROUTER_INPUT_CTRL_ARB_V */

