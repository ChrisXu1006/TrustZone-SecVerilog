//========================================================================
// Router Output Ctrl with Seperate wires for requests and grants
//========================================================================

`ifndef PLAB4_NET_ROUTER_OUTPUT_CTRL_SEP_V
`define PLAB4_NET_ROUTER_OUTPUT_CTRL_SEP_V

`include "vc-RRArb.v"

module plab4_net_RouterOutputCtrl_sep_insecure
(
	input		{L} clk,
	input		{L} reset,

    input       {L} req,
    input       {L} ter,

	input		{L} reqs_p0_domain,
	input		{L} reqs_p1_domain,
	input		{L} reqs_p2_domain,
	output		{L} out_domain,

	input		{Ctrl reqs_p0_domain} reqs_p0,
	input		{Ctrl reqs_p1_domain} reqs_p1,
	input		{Ctrl reqs_p2_domain} reqs_p2,

	output		{Ctrl reqs_p0_domain} grants_p0,
	output		{Ctrl reqs_p1_domain} grants_p1,
	output		{Ctrl reqs_p2_domain} grants_p2,

	output		{Ctrl out_domain} out_val,
	input		{Ctrl out_domain} out_rdy,
	output[1:0]	{L} xbar_sel
);

	//  only when out_rdy is high, combine reqs into a single wire
	//  otherwise, we set input to arbiters to be low
	wire [2:0]	{Ctrl out_domain} arb_reqs;
	wire [2:0]	{Ctrl out_domain} grants;

	assign arb_reqs = ( out_rdy ? {reqs_p2, reqs_p1, reqs_p0} : 3'h0 );
	assign {grants_p2, grants_p1, grants_p0} = grants;

	//----------------------------------------------------------------------
	// Round robin arbiter
	//----------------------------------------------------------------------

	vc_RRArb
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
	reg [1:0]	{L} xbar_sel;
	reg			{L} out_domain;

	always @(*) begin
		if ( grants_p0 == 1'b1 && out_domain == reqs_p0_domain) begin
			xbar_sel = 2'h0;
            if ( req == 1 && ter == 1 )
                out_domain = 1;
            else if ( req == 0 && ter == 1 )
                out_domain = 1;
            else
			    out_domain = reqs_p0_domain;
		end

		if ( grants_p1 == 1'b1 && out_domain == reqs_p1_domain) begin
			xbar_sel = 2'h1;
            if ( req == 1 && ter == 1 )
                out_domain = 1;
            else if ( req == 0 && ter == 1 )
                out_domain = 1;
            else
			    out_domain = reqs_p1_domain;
		end

		if ( grants_p2 == 1'b1 && out_domain == reqs_p2_domain) begin
			xbar_sel = 2'h2;
            if ( req == 1 && ter == 1 )
                out_domain = 1;
            else if ( req == 0 && ter == 1 )
                out_domain = 1;
            else
			    out_domain = reqs_p2_domain;
		end

		if ( reset )
			out_domain = 1'b0;
		
	end

endmodule

`endif /* PLAB4_NET_ROUTER_OUTPUT_CTRL_SEP_V */


