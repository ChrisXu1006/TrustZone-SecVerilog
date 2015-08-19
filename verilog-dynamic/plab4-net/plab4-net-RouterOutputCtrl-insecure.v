//========================================================================
// Router Output Ctrl with Seperate wires for requests and grants
//========================================================================

`ifndef PLAB4_NET_ROUTER_OUTPUT_CTRL_V
`define PLAB4_NET_ROUTER_OUTPUT_CTRL_V

`include "vc-arbiters.v"

module plab4_net_RouterOutputCtrl
#(
	parameter	req = 1,

	parameter   ter = 0
)
(
	input		clk,
	input		reset,

	input		reqs_p0_domain,
	input		reqs_p1_domain,
	input		reqs_p2_domain,
	output		out_domain,

	input		reqs_p0,
	input		reqs_p1,
	input		reqs_p2,

	output		grants_p0,
	output		grants_p1,
	output		grants_p2,

	output		out_val,
	input		out_rdy,
	output[1:0]	xbar_sel
);

	//  only when out_rdy is high, combine reqs into a single wire
	//  otherwise, we set input to arbiters to be low
	wire [2:0]	arb_reqs;
	wire [2:0]	grants;

	assign arb_reqs = ( out_rdy ? {reqs_p2, reqs_p1, reqs_p0} : 3'h0 );
	assign {grants_p2, grants_p1, grants_p0} = grants;

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

	// If there is any port get the permission, we set out_val signal
	// to be high
	assign out_val = grants_p0 || grants_p1 || grants_p2;

	// based on the perssimion signal, we will set xbar_sel's value
	// as well as out_domain 
	reg [1:0]	xbar_sel;
	reg			out_domain;

	always @(*) begin
		if ( grants_p0 == 1'b1 ) begin
			xbar_sel = 2'h0;
			if ( ter == 1 && req == 1 )
				out_domain = 1;
			else if ( ter == 1 && req == 0 )
				out_domain = 0;
			else
				out_domain = reqs_p0_domain;
		end

		else if ( grants_p1 == 1'b1 ) begin
			xbar_sel = 2'h1;
			if ( ter == 1 && req == 1 )
				out_domain = 1;
			else if ( ter == 1 && req == 0 )
				out_domain = 0;
			else
				out_domain = reqs_p1_domain;
		end

		else if ( grants_p2 == 1'b1 ) begin
			xbar_sel = 2'h2;
			if ( ter == 1 && req == 1 )
				out_domain = 1;
			else if ( ter == 1 && req == 0 )
				out_domain = 0;
			else
				out_domain = reqs_p2_domain;

		end

		else if ( reset )
			out_domain = 1'b0;
		
	end

endmodule

`endif /* PLAB4_NET_ROUTER_OUTPUT_CTRL_V */


