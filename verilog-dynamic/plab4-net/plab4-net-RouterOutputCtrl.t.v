//========================================================================
// Router Output Ctrl Seperate wires Unit Tests
//========================================================================

`include "plab4-net-RouterOutputCtrl.v"
`include "vc-test.v"

module top;
	`VC_TEST_SUITE_BEGIN( "plab4-net-RouterOutputCtrl" )

	//----------------------------------------------------------------------
	// Test output control with round robin arbitration
	//----------------------------------------------------------------------
	
	reg			t1_reset;
	reg			t1_reqs_p0;
	reg			t1_reqs_p1;
	reg			t1_reqs_p2;

	wire		t1_grants_p0;
	wire		t1_grants_p1;
	wire		t1_grants_p2;

	wire		t1_out_val;
	reg			t1_out_rdy;
	wire[1:0]	t1_xbar_sel;

	plab4_net_RouterOutputCtrl t1_output_ctrl_sep
	(
		.clk		(clk),
		.reset		(t1_reset),

		.reqs_p0	(t1_reqs_p0),
		.reqs_p1	(t1_reqs_p1),
		.reqs_p2	(t1_reqs_p2),

		.grants_p0	(t1_grants_p0),
		.grants_p1	(t1_grants_p1),
		.grants_p2	(t1_grants_p2),

		.out_val	(t1_out_val),
		.out_rdy	(t1_out_rdy),
		.xbar_sel	(t1_xbar_sel)
	);

	// Helper task
	
	task t1
	(
		input		reqs_p0,
		input		reqs_p1,
		input		reqs_p2,

		input		grants_p0,
		input		grants_p1,
		input		grants_p2,

		input		out_val,
		input		out_rdy,
		input[1:0]	xbar_sel
	);
	begin
		t1_reqs_p0	= reqs_p0;
		t1_reqs_p1	= reqs_p1;
		t1_reqs_p2	= reqs_p2;

		t1_out_rdy	= out_rdy;

		#1;
		`VC_TEST_NOTE_INPUTS_4( reqs_p0, reqs_p1, reqs_p2, out_rdy);
		`VC_TEST_NET( t1_grants_p0, grants_p0 );
		`VC_TEST_NET( t1_grants_p1, grants_p1 );
		`VC_TEST_NET( t1_grants_p2, grants_p2 );
		`VC_TEST_NET( t1_out_val,   out_val   );
		`VC_TEST_NET( t1_xbar_sel,  xbar_sel  );
	end
	endtask

	// Test case
	
	`VC_TEST_CASE_BEGIN( 1, "basic test" )
	begin

		#1;  t1_reset = 1'b1;
		#20; t1_reset = 1'b0;

		//  reqs_p0 reqs_p1 reqs_p2 grants_p0 grants_p1 grants_p2 val   rdy    sel
		t1( 1'b0,	1'b0,	1'b0,	1'b0,	  1'b0,		1'b0,	  1'b0, 1'b0,  2'h? );
		t1( 1'b1,	1'b0,	1'b0,	1'b0,	  1'b0,		1'b0,	  1'b?, 1'b0,  2'h? );
		t1( 1'b1,	1'b0,	1'b0,	1'b1,	  1'b0,		1'b0,	  1'b1, 1'b1,  2'h0 );
		t1( 1'b0,	1'b1,	1'b0,	1'b0,	  1'b1,		1'b0,	  1'b1, 1'b1,  2'h1 );
		t1( 1'b0,	1'b0,	1'b1,	1'b0,	  1'b0,		1'b1,	  1'b1, 1'b1,  2'h2 );
		t1( 1'b0,	1'b1,	1'b1,	1'b0,	  1'b?,		1'b?,	  1'b1, 1'b1,  2'b??);
		t1( 1'b1,	1'b1,	1'b1,	1'b?,	  1'b?,		1'b?,	  1'b1, 1'b1,  2'h? );
		t1( 1'b1,	1'b0,	1'b1,	1'b0,	  1'b0,		1'b0,	  1'b?, 1'b0,  2'b?0);
		t1( 1'b0,	1'b0,	1'b0,	1'b0,	  1'b0,		1'b0,	  1'b0, 1'b1,  2'h? );

	end
	`VC_TEST_CASE_END

	`VC_TEST_SUITE_END
endmodule

