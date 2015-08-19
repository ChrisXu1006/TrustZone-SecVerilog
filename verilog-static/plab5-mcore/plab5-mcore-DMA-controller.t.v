//=======================================================================
// DMA Memory Access Controller Unit Tests
//========================================================================

`include "vc-test.v"
`include "plab5-mcore-DMA-controller.v"
`include "plab5-mcore-TestMem_1port.v"

module top;
	`VC_TEST_SUITE_BEGIN( "plab5-mcore-DMA-Controller" )

	localparam	p_opaque_nbits = 8;
	localparam  p_addr_nbits   = 32;
	localparam  p_data_nbits   = 32;

	localparam  o = p_opaque_nbits;
	localparam  a = p_addr_nbits;
	localparam  d = p_data_nbits;

	localparam	c_req_nbits   = `VC_MEM_REQ_MSG_NBITS(o,a,d);
	localparam	c_req_cnbits  = c_req_nbits - d;
	localparam	c_req_dnbits  = d;
	localparam	c_resp_nbits  = `VC_MEM_RESP_MSG_NBITS(o,d);
    localparam	c_resp_cnbits = c_resp_nbits - d;
	localparam	c_resp_dnbits = d;	


	reg						test_reset;
	reg						test_val;
	wire					test_rdy;
	reg	 [a-1:0]			test_src_addr;
	reg	 [a-1:0]			test_dest_addr;
	wire					test_ack;

	wire					test_mem_req_val;
	wire					test_mem_req_rdy;
	wire [c_req_cnbits-1:0]	test_mem_req_control;
	wire [c_req_dnbits-1:0]	test_mem_req_data;

	wire					test_mem_resp_val;
	wire					test_mem_resp_rdy;
	wire [c_resp_cnbits-1:0]test_mem_resp_control;
	wire [c_resp_dnbits-1:0]test_mem_resp_data;	

	plab5_mcore_DMA_Controller DMA_test
	(
		.clk				(clk),
		.reset				(test_reset),

		.val				(test_val),
		.rdy				(test_rdy),
		.src_addr			(test_src_addr),
		.dest_addr			(test_dest_addr),
		.ack				(test_ack),
		
		.mem_req_val		(test_mem_req_val),
		.mem_req_rdy		(test_mem_req_rdy),
		.mem_req_control	(test_mem_req_control),
		.mem_req_data		(test_mem_req_data),

		.mem_resp_val		(test_mem_resp_val),
		.mem_resp_rdy		(test_mem_resp_rdy),
		.mem_resp_control	(test_mem_resp_control),
		.mem_resp_data		(test_mem_resp_data)

	);
	
	plab5_mcore_TestMem_1port test_mem
	(
		.clk				(clk),
		.reset				(test_reset),
		
		.part				(0),
		.mem_clear			(0),

		.memreq_val			(test_mem_req_val),
		.memreq_rdy			(test_mem_req_rdy),
		.memreq_control		(test_mem_req_control),
		.memreq_data		(test_mem_req_data),
		
		.memresp_val		(test_mem_resp_val),
		.memresp_rdy		(test_mem_resp_rdy),
		.memresp_control	(test_mem_resp_control),
		.memresp_data		(test_mem_resp_data)
	);	

	// Helper task
	
	task test_init
	(
		input			reset,
		input [31:0]	src_addr,
		input [31:0]	dest_addr
	);
	begin
		test_reset	   = reset;
		test_src_addr  = src_addr;
		test_dest_addr = dest_addr;
		if ( !reset)
			$display("Copy data from address %x to address %x", src_addr, dest_addr);
		#100;
	end
	endtask

	// task used for initializing test memory
	task mem_init
	(
		input [a-1:0]	addr,
		input [d-1:0]	data
	);
	begin
		test_mem.m[addr/4] = data;
		$display("Address %x is initialized with %x", addr, data);
	end
	endtask

	// display the content of the memory
	task display_mem
	(
		input [a-1:0]	addr
	);
	begin
		$display("The data in address %x is %x", addr, test_mem.m[addr/4]);
	end
	endtask

	// set global signal
	initial begin
		test_val = 1'b1;
	end

	always begin
		#10 test_val = 1'b0;
		#90 test_val = 1'b1;
	end
	
	// Test Case 1 - single transportation
	`VC_TEST_CASE_BEGIN( 1, "single DMA request" )
	begin
		mem_init	(32'h0000, 32'haabbccdd);
		display_mem	(32'h0000);

		test_init	(1,  32'h0000, 32'h0000 );
		test_init	(0,  32'h0000, 32'h0004 );
		#180;

		display_mem (32'h0004);
			
	end
	`VC_TEST_CASE_END

	// Test Case 2 - several sequence test
	`VC_TEST_CASE_BEGIN( 2, "sequential Test" )
	begin
		mem_init	(32'h0000, 32'hdeadbeaf);
		mem_init	(32'h0008, 32'h11223344);
		mem_init	(32'h0010, 32'h12345678);

		test_init	(1, 32'h0000, 32'h0000);
		test_init	(0, 32'h0000, 32'h0004);
		test_init	(0, 32'h0008, 32'h000c);
		test_init	(0, 32'h0010, 32'h0014);

		#50;

		display_mem (32'h0004);
		display_mem (32'h000c);
		display_mem (32'h0014);
	end
	`VC_TEST_CASE_END

	reg [31:0]	src_addr;
	reg [31:0]	dest_addr;
	reg [31:0]	src_data;
	integer i;
	// Test Case 3 - Random Test
	`VC_TEST_CASE_BEGIN( 3, "Random Test" )
	begin
		test_init	(1, 32'h0000, 32'h0000);
		for ( i = 0; i < 10; i = i + 1 ) begin
			src_addr  = ($random % 32'd100) * 4;
			src_data  = $random;
			dest_addr = ($random % 32'd100) * 4;
			mem_init(src_addr, src_data);
			test_init(0, src_addr, dest_addr);
			#100;
			display_mem(dest_addr);
		end	
	end
	`VC_TEST_CASE_END	

	`VC_TEST_SUITE_END
endmodule
