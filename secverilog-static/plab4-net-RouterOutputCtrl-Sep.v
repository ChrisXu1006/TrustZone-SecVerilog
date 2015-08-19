//========================================================================
// Router Output Ctrl with Seperate wires for requests and grants
//========================================================================

`ifndef PLAB4_NET_ROUTER_OUTPUT_CTRL_SEP_V
`define PLAB4_NET_ROUTER_OUTPUT_CTRL_SEP_V

`include "vc-arbiter.v"

module plab4_net_RouterOutputCtrl_sep
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
    output[1:0]	{Ctrl reqs_p0_domain join Ctrl reqs_p1_domain join Ctrl reqs_p2_domain } xbar_sel
);

	//----------------------------------------------------------------------
	// Round robin arbiter
	//----------------------------------------------------------------------

	vc_arbiter arbiter
	(
		.clk    (clk),
		.reset  (reset),

        .in0_domain (reqs_p0_domain),
        .in1_domain (reqs_p1_domain),
        .in2_domain (reqs_p2_domain),

        .req0       (reqs_p0),
        .req1       (reqs_p1),
        .req2       (reqs_p2),

        .gnt0       (grants_p0),
        .gnt1       (grants_p1),
        .gnt2       (grants_p2)
    );

	// If there is any port get the permission, we set out_val signal
	// to be high
	assign out_val = grants_p0 || grants_p1 || grants_p2;

	// based on the perssimion signal, we will set xbar_sel's value
	// as well as out_domain 
	reg [1:0]	{L} xbar_sel;
    reg			{Ctrl reqs_p0_domain join Ctrl reqs_p1_domain join Ctrl reqs_p2_domain } out_domain;

	always @(*) begin
		if ( grants_p0 == 1'b1 && out_domain == reqs_p0_domain) begin
			xbar_sel = 2'h0;
			out_domain = reqs_p0_domain;
		end

		if ( grants_p1 == 1'b1 && out_domain == reqs_p1_domain) begin
			xbar_sel = 2'h1;
			out_domain = reqs_p1_domain;
		end

		if ( grants_p2 == 1'b1 && out_domain == reqs_p2_domain) begin
			xbar_sel = 2'h2;
			out_domain = reqs_p2_domain;
		end

		if ( reset )
			out_domain = 1'b0;
		
	end

endmodule

`endif /* PLAB4_NET_ROUTER_OUTPUT_CTRL_SEP_V */


