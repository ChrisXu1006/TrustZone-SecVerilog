//=========================================================================
// Programmable Interrupt Controller Test Benchmark
//=========================================================================

`include "plab2-proc-PIC.v"

module TB;

	reg		clk;
	reg		reset;

	reg		intr_rq_p0;
	reg		intr_rq_p1;
	reg		intr_set_p0;
	reg		intr_set_p1;

	wire	intr_val_p0;
	wire	intr_val_p1;

	plab2_proc_PIC PIC
	(
		.clk			(clk),
		.reset			(reset),
		.intr_rq_p0		(intr_rq_p0),
		.intr_rq_p1		(intr_rq_p1),
		.intr_set_p0	(intr_set_p0),
		.intr_set_p1	(intr_set_p1),

		.intr_val_p0	(intr_val_p0),
		.intr_val_p1	(intr_val_p1)
	);

	// create vcd file for gtkwave analysis
	initial begin
		$dumpfile("TB.vcd");
		$dumpvars(0, TB);

		clk			= 1'b0;
		reset		= 1'b1;
		intr_rq_p0	= 1'b0;
		intr_rq_p1	= 1'b0;
		intr_set_p0 = 1'b0;
		intr_set_p1 = 1'b0;
		#20;
		reset		= 1'b0;
		#20
		intr_set_p0	= 1'b1;
		#90;
		intr_set_p0	= 1'b0;
		intr_rq_p0	= 1'b1;
		intr_rq_p1  = 1'b1;
		#20;
		intr_rq_p0  = 1'b0;
		intr_rq_p1  = 1'b0;
		#100;
		intr_set_p1 = 1'b1;
		#100
		intr_set_p1 = 1'b0;
		intr_rq_p0	= 1'b1;
		intr_rq_p1	= 1'b1;
		#20
		intr_rq_p0  = 1'b0;
		intr_rq_p1  = 1'b0;
		#1000;
		$finish;
	end

	always #10  clk = ~clk;
endmodule
