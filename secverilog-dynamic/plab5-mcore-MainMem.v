//========================================================================
// Verilog Components: Test Memory
//========================================================================
// This is single-ported and unified test memory that handles a limited 
// subset of memory request messages and returns memory response messages
// The memory is statically partitioned into two part, one for public data
// , and the other for sensitive data

`ifndef PLAB5_MCORE_MAIN_MEM_V
`define PLAB5_MCORE_MAIN_MEM_V

`include "vc-mem-msgs.v"
`include "vc-queues.v"
`include "vc-assert.v"

//------------------------------------------------------------------------
// Unified Test memory with one req/resp port
//------------------------------------------------------------------------

module plab5_mcore_MainMem
#(
	parameter p_mem_nbytes   = 1024, // size of physical memory in bytes
	parameter p_opaque_nbits = 8,    // mem message opaque field num bits
	parameter p_addr_nbits   = 32,   // mem message address num bits
	parameter p_data_nbits   = 32,   // mem message data num bits

	// Shorter names for message type, not to be set from outside the module
	parameter o = p_opaque_nbits,
	parameter a = p_addr_nbits,
	parameter d = p_data_nbits,

	// Local constants not meant to be set from outside the module
	parameter c_req_nbits  = `VC_MEM_REQ_MSG_NBITS(o,a,d),
	parameter c_req_cnbits = c_req_nbits - d,
	parameter c_req_dnbits = d,
	parameter c_resp_nbits = `VC_MEM_RESP_MSG_NBITS(o,d),
	parameter c_resp_cnbits = c_resp_nbits - d,
	parameter c_resp_dnbits = d
)(

	input	{L} clk,
	input	{L} reset,

	// mode 0 is instruction memory, mode 1 is data memory
	input	{L} mode,
	// clears the content of memory
	input	{L} mem_clear,

	// Memory request port interface
	
	input						{Ctrl memreq_domain} memreq_val,
	output						{Ctrl memreq_domain} memreq_rdy,
	input [c_req_cnbits-1:0]	{Ctrl memreq_domain} memreq_control,
	input [c_req_dnbits-1:0]	{Data memreq_domain} memreq_data,
	input						{L} memreq_domain,

	// Memmory response port interface
	
	output						{Ctrl memresp_domain} memresp_val,
	input						{Ctrl memresp_domain} memresp_rdy,
	output[c_resp_cnbits-1:0]	{Ctrl memresp_domain} memresp_control,
	output[c_resp_dnbits-1:0]	{Data memresp_domain} memresp_data,
	output	reg					{L} memresp_domain
);	
	
	//----------------------------------------------------------------------
	// Local parameters
	//----------------------------------------------------------------------

	// Size of a physical address for the memory in bits

	localparam c_physical_addr_nbits = $clog2(p_mem_nbytes);

	// Size of data entry in bytes

	localparam c_data_byte_nbits = (p_data_nbits/8);

	// Number of data entries in memory

	localparam c_num_blocks = p_mem_nbytes/c_data_byte_nbits;

	// Size of block address in bits

	localparam c_physical_block_addr_nbits = $clog2(c_num_blocks);

	// Size of block offset in bits

	localparam c_block_offset_nbits = $clog2(c_data_byte_nbits);

	// Shorthand for the message es

	wire [2:0] c_read       = 0; //`VC_MEM_REQ_MSG_TYPE_READ;
	wire [2:0] c_write      = 1; //`VC_MEM_REQ_MSG_TYPE_WRITE;
	wire [2:0] c_write_init = 2; //`VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
	wire [2:0] c_amo_add    = 3; //`VC_MEM_REQ_MSG_TYPE_AMO_ADD;
	wire [2:0] c_amo_and    = 4; //`VC_MEM_REQ_MSG_TYPE_AMO_AND;
	wire [2:0] c_amo_or     = 5; //`VC_MEM_REQ_MSG_TYPE_AMO_OR;

	// Shorthand for the message field sizes

	localparam c_req_type_nbits    = `VC_MEM_REQ_MSG_TYPE_NBITS(o,a,d);
	localparam c_req_opaque_nbits  = `VC_MEM_REQ_MSG_OPAQUE_NBITS(o,a,d);
	localparam c_req_addr_nbits    = `VC_MEM_REQ_MSG_ADDR_NBITS(o,a,d);
	localparam c_req_len_nbits     = `VC_MEM_REQ_MSG_LEN_NBITS(o,a,d);
	localparam c_req_data_nbits    = `VC_MEM_REQ_MSG_DATA_NBITS(o,a,d);

	localparam c_resp_type_nbits   = `VC_MEM_RESP_MSG_TYPE_NBITS(o,d);
	localparam c_resp_opaque_nbits = `VC_MEM_RESP_MSG_OPAQUE_NBITS(o,d);
	localparam c_resp_len_nbits    = `VC_MEM_RESP_MSG_LEN_NBITS(o,d);
	localparam c_resp_data_nbits   = `VC_MEM_RESP_MSG_DATA_NBITS(o,d);

	//----------------------------------------------------------------------
	// Memory request buffers
	//----------------------------------------------------------------------
	// We use pipe queues here since in general we want our larger modules
	// to use registered inputs, but we want to reduce the overhead of
	// having two elements which would be required for full throughput with
	// normal queues. By using a pipe queues at the inputs and a bypass
	// queue at the output we cut and combinational paths through the test
	// memory (helping to avoid combinational loops) and also preserve our
	// registered input policy.

	wire						{Ctrl memresp_domain_M} memreq_val_M;
	wire						{Ctrl memresp_domain_M} memreq_rdy_M;
	wire [c_req_cnbits-1:0]	    {Ctrl memresp_domain_M} memreq_control_M;
	wire [c_req_dnbits-1:0]	    {Data memresp_domain_M} memreq_data_M;

	vc_Queue_Ctrl
	#(
		.p_type      (`VC_QUEUE_PIPE),
		.p_msg_nbits (c_req_cnbits),
		.p_num_msgs  (1)
	)
	memreq_control_queue
	(
		.clk        (clk),
		.reset      (reset),
        .enq_domain (memreq_domain),
		.enq_val    (memreq_val),
		.enq_rdy    (memreq_rdy),
		.enq_msg    (memreq_control),
        .deq_domain (memresp_domain_M),
		.deq_val    (memreq_val_M),
		.deq_rdy    (memreq_rdy_M),
		.deq_msg    (memreq_control_M)
	);

	vc_Queue
	#(
		.p_type      (`VC_QUEUE_PIPE),
		.p_msg_nbits (c_req_dnbits),
		.p_num_msgs  (1)
	)
	memreq_data_queue
	(
		.clk        (clk),
		.reset      (reset),
        .enq_domain (memreq_domain),
		.enq_val    (memreq_val),
		.enq_rdy    (memreq_rdy),
		.enq_msg    (memreq_data),
        .deq_domain (memresp_domain_M),
		.deq_val    (memreq_val_M),
		.deq_rdy    (memreq_rdy_M),
		.deq_msg    (memreq_data_M)
	);

	//----------------------------------------------------------------------
	// Unpack the request messages
	//----------------------------------------------------------------------

	wire [c_req_type_nbits-1:0]   {Ctrl memresp_domain_M} memreq_msg_type_M;
	wire [c_req_opaque_nbits-1:0] {Ctrl memresp_domain_M} memreq_msg_opaque_M;
	wire [c_req_addr_nbits-1:0]   {Ctrl memresp_domain_M} memreq_msg_addr_M;
	wire [c_req_len_nbits-1:0]    {Ctrl memresp_domain_M} memreq_msg_len_M;

	plab5_mcore_MemReqCMsgUnpack#(o,a,d) memreq_cmsg_unpack
	(
        .domain (memresp_domain_M),
		.msg    (memreq_control_M),
		.type   (memreq_msg_type_M),
		.opaque (memreq_msg_opaque_M),
		.addr   (memreq_msg_addr_M),
		.len    (memreq_msg_len_M)
	);

	//----------------------------------------------------------------------
	// Actual memory array for public data and sensitive data
	//----------------------------------------------------------------------

	reg [p_data_nbits-1:0] {D1} m_pub[c_num_blocks-1:0];
	reg [p_data_nbits-1:0] {D2} m_sec[c_num_blocks-1:0];

	// Delay the domain due to registered data
	reg {L} memreq_domain_M;
	reg {L} memresp_domain_M;

	always @(posedge clk) begin
		memresp_domain   <= memreq_domain;
        memresp_domain_M <= memreq_domain;
	end
	//----------------------------------------------------------------------
	// Handle request and create response
	//----------------------------------------------------------------------

	// Handle case where length is zero which actually represents a full
	// width access.

	wire [c_req_len_nbits:0] {Ctrl memresp_domain_M} memreq_msg_len_modified_M
	= ( memreq_msg_len_M == 0 ) ? (128/8) : memreq_msg_len_M;

	// Caculate the physical byte address for the request. Notice that we
	// truncate the higher order bits that are beyond the size of the
	// physical memory.

	wire [c_physical_addr_nbits-1:0] {Ctrl memresp_domain_M} physical_byte_addr_M
	= memreq_msg_addr_M[c_physical_addr_nbits-1:0];

	// Cacluate the address belongs to which part
	wire [1:0] {Ctrl memresp_domain_M} part = memreq_msg_addr_M[15:14];

	// Cacluate the block address and block offset

	wire [c_physical_block_addr_nbits-1:0] {Ctrl memresp_domain_M} physical_block_addr_M
    = physical_byte_addr_M/16 - (1<<16)/64*part;

	wire [c_block_offset_nbits-1:0] {Ctrl memresp_domain_M} block_offset_M
    = physical_byte_addr_M[c_block_offset_nbits-1:0];

	// Read the data
	reg [p_data_nbits-1:0] {Data memresp_domain_M} read_block_M;

	always @(*) begin
		if ( (part-(mode<<1)) == 1'b0 && memresp_domain_M == 1'b0) begin
			read_block_M = m_pub[physical_block_addr_M];
		end

		else if ( (part-(mode<<1)) == 1'b1 && memresp_domain_M == 1'b1 ) begin
			read_block_M = m_sec[physical_block_addr_M];
		end

		else begin
			read_block_M = 'hx;
		end
	end

	wire [c_resp_data_nbits-1:0] {Data memresp_domain_M} read_data_M
	= read_block_M >> (block_offset_M*8);

	// Write the data if required. This is a sequential always block so
	// that the write happens on the next edge.

	wire {Ctrl memresp_domain_M} write_en_M = memreq_val_M &&
         ( memreq_msg_type_M == c_write || memreq_msg_type_M == c_write_init );

	// Note: amos need to happen once, so we only enable the amo transaction
	// when both val and rdy is high

	wire {Ctrl memresp_domain_M} amo_en_M = memreq_val_M && memreq_rdy_M &&
                                  ( memreq_msg_type_M == c_amo_and
                                 || memreq_msg_type_M == c_amo_add
                                 || memreq_msg_type_M == c_amo_or  );

	integer wr_i;

	// We use this variable to keep track of whether or not we have already
	// cleared the memory. Otherwise if the clear signal is high for
	// multiple cycles we will do the expensive reset multiple times. We
	// initialize this to one since by default when the simulation starts
	// the memory is already reset to X's.

	integer memory_cleared = 1;

	always @( posedge clk ) begin

    // We clear all of the test memory to X's on mem_clear. As mentioned
    // above, this only happens if we clear a test memory more than once.
    // This is useful when we are reusing a memory for many tests to
    // avoid writes from one test "leaking" into a later test -- this
    // might possible cause a test to pass when it should not because the
    // test is using data from an older test.

		if ( mem_clear ) begin
			if ( !memory_cleared ) begin
				memory_cleared = 1;
				for ( wr_i = 0; wr_i < c_num_blocks; wr_i = wr_i + 1 ) begin
					m_pub[wr_i] <= {p_data_nbits{1'bx}};
					m_sec[wr_i] <= {p_data_nbits{1'bx}};
				end
			end
		end

		else if ( !reset ) begin
			memory_cleared = 0;

			if ( write_en_M && (part - (mode<<1) == 0)) begin
				for ( wr_i = 0; wr_i < memreq_msg_len_modified_M; wr_i = wr_i + 1 ) begin
					m_pub[physical_block_addr_M][ (block_offset_M*8) + (wr_i*8) +: 8 ] <= memreq_data_M[ (wr_i*8) +: 8 ];
				end
			end

			else if ( write_en_M && (part - (mode<<1) == 1) && memreq_domain_M == 1'b1 ) begin
				for ( wr_i = 0; wr_i < memreq_msg_len_modified_M; wr_i = wr_i + 1 ) begin
					m_sec[physical_block_addr_M][ (block_offset_M*8) + (wr_i*8) +: 8 ] <= memreq_data_M[ (wr_i*8) +: 8 ];
				end
			end


			if ( amo_en_M && (part - (mode<<1) == 0)) begin
				case ( memreq_msg_type_M )
					c_amo_add: m_pub[physical_block_addr_M] <= memreq_data_M + read_data_M;
					c_amo_and: m_pub[physical_block_addr_M] <= memreq_data_M & read_data_M;
					c_amo_or : m_pub[physical_block_addr_M] <= memreq_data_M | read_data_M;
				endcase
			end

			else if ( amo_en_M && (part - (mode<<1) == 1)) begin
				case ( memreq_msg_type_M )
					c_amo_add: m_sec[physical_block_addr_M] <= memreq_data_M + read_data_M;
					c_amo_and: m_sec[physical_block_addr_M] <= memreq_data_M & read_data_M;
					c_amo_or : m_sec[physical_block_addr_M] <= memreq_data_M | read_data_M;
				endcase
			end

		end

	end

	//----------------------------------------------------------------------
	// Pack the response message
	//----------------------------------------------------------------------

	wire [c_resp_cnbits-1:0] {Ctrl memresp_domain_M} memresp_control_M;

	plab5_mcore_MemRespCMsgPack#(o,d) memresp_msg_pack
	(
        .domain (memresp_domain_M),
		.type   (memreq_msg_type_M),
		.opaque (memreq_msg_opaque_M),
		.len    (memreq_msg_len_M),
		.msg    (memresp_control_M)
	);

	wire [c_resp_dnbits-1:0]	{Data memresp_domain_M} memresp_data_M = read_data_M;
	//----------------------------------------------------------------------
	// Memory response buffers
	//----------------------------------------------------------------------
	// We use bypass queues here since in general we want our larger
	// modules to use registered inputs. By using a pipe queues at the
	// inputs and a bypass queue at the output we cut and combinational
	// paths through the test memory (helping to avoid combinational loops)
	// and also preserve our registered input policy.

	vc_Queue_Ctrl
	#(
		.p_type      (`VC_QUEUE_PIPE),
		.p_msg_nbits (c_resp_cnbits),
		.p_num_msgs  (1)
	)
	memresp_control_queue
	(
		.clk        (clk),
		.reset      (reset),
        .enq_domain (memresp_domain_M),
		.enq_val    (memreq_val_M),
		.enq_rdy    (memreq_rdy_M),
		.enq_msg    (memresp_control_M),
        .deq_domain (memresp_domain),
		.deq_val    (memresp_val),
		.deq_rdy    (memresp_rdy),
		.deq_msg    (memresp_control)
	);

	vc_Queue
	#(
		.p_type      (`VC_QUEUE_BYPASS),
		.p_msg_nbits (c_resp_dnbits),
		.p_num_msgs  (1)
	)
	memresp_data_queue
	(
		.clk        (clk),
		.reset      (reset),
        .enq_domain (memresp_domain_M),
		.enq_val    (memreq_val_M),
		.enq_rdy    (memreq_rdy_M),
		.enq_msg    (memresp_data_M),
        .deq_domain (memresp_domain),
		.deq_val    (memresp_val),
		.deq_rdy    (memresp_rdy),
		.deq_msg    (memresp_data)
	);
	//----------------------------------------------------------------------
	// General assertions
	//----------------------------------------------------------------------

	// val/rdy signals should never be x's

	always @( posedge clk ) begin
		if ( !reset ) begin
		`VC_ASSERT_NOT_X( memreq_val  );
		`VC_ASSERT_NOT_X( memresp_rdy );
		end
	end

endmodule

`endif /* PLAB5_MCORE_MAIN_MEM_V */

