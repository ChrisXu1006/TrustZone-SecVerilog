//========================================================================
// Direct Memory Access Controller Module
// Since the system doesn't contain the peripheral devices(I/O devices),
// DMA only includes memory copy operations. DMA firstly receive source 
// address and destination address from processor. Then read data from
// source memory, transfer them to destination memory
//========================================================================

`ifndef PLAB5_MCORE_DMA_CONTROLLER_V
`define PLAB5_MCORE_DMA_CONTROLLER_V

`include "vc-mem-msgs.v"
`include "vc-regs.v"
`include "vc-queues.v"
`include "plab5-mcore-mem-msgs.v"

module plab5_mcore_DMA_Controller
#(
	parameter	p_opaque_nbits	= 8,		// opaque field bit width
	parameter	p_addr_nbits	= 32,		// address field bit width
	parameter	p_data_nbits	= 32,		// data field bit width

	// Shorter names for messsage type, not to be set from outside the module
	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	d = p_data_nbits,

	// Local constants not meant to be set from outside from the module
	parameter	c_req_nbits   = `VC_MEM_REQ_MSG_NBITS(o,a,d),
	parameter	c_req_cnbits  = c_req_nbits - d,
	parameter	c_req_dnbits  = d,
	parameter	c_resp_nbits  = `VC_MEM_RESP_MSG_NBITS(o,d),
    parameter	c_resp_cnbits = c_resp_nbits - d,
	parameter	c_resp_dnbits = d	
)
(
	input						clk,
	input						reset,

	output						domain,

	// ports connected to core
	input						val,			// indicate there is a request
	output	reg					rdy,			
	input	[p_addr_nbits-1:0]	src_addr,		// source memory address
	input	[p_addr_nbits-1:0]	dest_addr,		// destination memory address
	input	[c_req_cnbits-1:0]	req_control,	// request information from on-chip network
	input						inst,			// instruction type for normal use
	output	reg					ack,			// when operations done, notify core

	// ports connected to debug interface
	input						db_val,			// indicate there is a debug request
	input	[p_addr_nbits-1:0]	db_src_addr,	// debug source memory address
	input	[p_addr_nbits-1:0]	db_dest_addr,	// debug destination mmeoyr address
	input						db_inst,		// intruction type for debug use
	output	[p_data_nbits-1:0]	debug_data,		// result for debug interface;

	// ports connected to memory
	output	reg					mem_req_val,
	input						mem_req_rdy,
	output	[c_req_cnbits-1:0]	mem_req_control,
	output	[c_req_dnbits-1:0]	mem_req_data,
	output	reg					mem_req_domain,

	input						mem_resp_val,
	output						mem_resp_rdy,
	input	[c_resp_cnbits-1:0]	mem_resp_control,
	input	[c_resp_dnbits-1:0]	mem_resp_data,
	input						mem_resp_domain	

);

    //----------------------------------------------------------------------
	// Datapath of DMA controller 
    //----------------------------------------------------------------------

	// two registers for registering src_addr/dest_addr
	wire	[p_addr_nbits-1:0]	src_addr_reg_out;
	wire	[p_addr_nbits-1:0]	dest_addr_reg_out;
	wire	[p_addr_nbits-1:0]	db_src_addr_reg_out;
	wire	[p_addr_nbits-1:0]	db_dest_addr_reg_out;
	wire						inst_reg_out;
	wire	[p_data_nbits-1:0]	mem_resp_data_reg_out;
	wire	[c_req_cnbits-1:0]	req_control_reg_out;

	vc_EnResetReg#(p_addr_nbits) src_addr_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(dmareq_en),
		.d		(src_addr),
		.q		(src_addr_reg_out)
	);

	vc_EnResetReg#(p_addr_nbits) dest_addr_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(dmareq_en),
		.d		(dest_addr),
		.q		(dest_addr_reg_out)
	);

	vc_EnResetReg#(p_addr_nbits) db_src_addr_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(dmareq_en),
		.d		(db_src_addr),
		.q		(db_src_addr_reg_out)
	);

	vc_EnResetReg#(p_addr_nbits) db_dest_addr_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(dmareq_en),
		.d		(db_dest_addr),
		.q		(db_dest_addr_reg_out)
	);

	vc_EnResetReg#(1) inst_type_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(dmareq_en),
		.d		(db_inst),
		.q		(inst_reg_out)
	);

	vc_EnResetReg#(c_req_cnbits) req_control_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(dmareq_en),
		.d		(req_control),
		.q		(req_control_reg_out)
	);

	vc_EnResetReg#(p_data_nbits) mem_resp_data_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(mem_resp_val),
		.d		(mem_resp_data),
		.q		(mem_resp_data_reg_out)
	);

	// Pack Memory request control msg

	plab5_mcore_MemReqCMsgPack#(o,a,d) memreq_cmsg_pack
	(
		.type	(mem_req_type),
		.opaque (0),
		.addr	(mem_req_addr),
		.len	(0),
		.msg	(mem_req_control)
	);

	// Queues temporarily storing data, and transfering data
	wire	deq_val;
	
	vc_Queue
	#(
		.p_msg_nbits	(p_data_nbits),
		.p_num_msgs		(1)
	)
	hold_queue
	(
		.clk			(clk),
		.reset			(reset),

		.enq_val		(enq_en),
		.enq_rdy		(mem_resp_rdy),
		.enq_msg		(mem_resp_data_reg_out),

		.deq_val		(deq_val),
		.deq_rdy		(mem_req_rdy),
		.deq_msg		(mem_req_data)
	);

	// security register in DMA controller
	reg	secure_reg = 1;

	assign domain = secure_reg;

    //----------------------------------------------------------------------
	// Control Unit of DMA controller
    //----------------------------------------------------------------------
	reg											dmareq_en;
	reg											enq_en;
	reg [`VC_MEM_REQ_MSG_TYPE_NBITS(o,a,d)-1:0]	mem_req_type;
	reg [`VC_MEM_REQ_MSG_ADDR_NBITS(o,a,d)-1:0]	mem_req_addr;
	reg [p_data_nbits-1:0]						debug_data;
	
	// FSM State Definitions
	localparam STATE_IDLE			= 4'd0;
	localparam STATE_DEBUG_REG		= 4'd1;
	localparam STATE_NET_REG		= 4'd2;
	localparam STATE_READ_MEM_REQ	= 4'd3;
	localparam STATE_READ_MEM_WAIT  = 4'd4;
	localparam STATE_READ_MEM_DONE	= 4'd5;
	localparam STATE_WRITE_MEM_REQ	= 4'd6;
	localparam STATE_WRITE_MEM_WAIT = 4'd7;
	localparam STATE_WRITE_MEM_DONE = 4'd8;
	localparam STATE_ACK			= 4'd9;
	localparam STATE_DEBUG_RES		= 4'd10;

	// FSM State transition
	reg [3:0]	state_reg;
	reg [3:0]	state_next;

	always @( posedge clk ) begin
		if ( reset ) begin
			state_reg  <= STATE_IDLE;
		end
		else begin
			state_reg <= state_next;
		end
	end

	always @(*) begin

		state_next = state_reg;
		
		case ( state_reg )
			
			STATE_IDLE:
				if ( db_val )		state_next = STATE_DEBUG_REG;
		   else if ( val    )		state_next = STATE_NET_REG;

			STATE_DEBUG_REG:
				state_next = STATE_READ_MEM_REQ;
			
			STATE_NET_REG:
				state_next = STATE_READ_MEM_REQ;	

			STATE_READ_MEM_REQ:
				if ( mem_req_rdy )  state_next = STATE_READ_MEM_WAIT;

			STATE_READ_MEM_WAIT:
				if ( mem_resp_val )	state_next = STATE_READ_MEM_DONE;

			STATE_READ_MEM_DONE:
				if ( status === 1'b0 )
									state_next = STATE_WRITE_MEM_REQ;
		   else	if ( !inst_reg_out )
									state_next = STATE_WRITE_MEM_REQ;
		   else if ( inst_reg_out == 1'b1 )
									state_next = STATE_DEBUG_RES;

			STATE_WRITE_MEM_REQ:
				if ( mem_req_rdy )	state_next = STATE_WRITE_MEM_WAIT;

			STATE_WRITE_MEM_WAIT:
				if ( mem_resp_val )	state_next = STATE_WRITE_MEM_DONE;

			STATE_WRITE_MEM_DONE:
				state_next = STATE_ACK;

			STATE_ACK:
				state_next = STATE_IDLE;
		   
			STATE_DEBUG_RES:
				state_next = STATE_IDLE;

		endcase
	end

	reg		status;
	// State Outputs
	always @(*) begin

		rdy = 1'b0;
		ack = 1'b0;
		enq_en = 1'b0;
		dmareq_en = 1'b0;
		mem_req_domain = 1'b1;
		mem_req_val  = 1'b0;
		mem_req_type = 3'hx;
		mem_req_addr = 'hx;
		
		case ( state_reg )

			STATE_IDLE: begin
				rdy			 = 1'b1;
				dmareq_en	 = 1'b1;
				status		 = 1'bx;
			end

			STATE_DEBUG_REG: begin
				enq_en		 = 1'b0;
				status		 = 1'b1;
			end

			STATE_NET_REG: begin
				status		 = 1'b0;
			end

			STATE_READ_MEM_REQ: begin
				enq_en		 = 1'b0;
				mem_req_val	 = 1'b1;
				mem_req_type = 3'h0;
				if ( status === 1'b0 )
					mem_req_addr = src_addr_reg_out;
				else
					mem_req_addr = db_src_addr_reg_out;
			end

			STATE_READ_MEM_DONE: begin
				enq_en		 = 1'b1;
			end

			STATE_WRITE_MEM_REQ: begin
				mem_req_val	 = 1'b1;
				mem_req_type = 3'h1;
				if ( status === 1'b0 )
					mem_req_addr = dest_addr_reg_out;
				else
					mem_req_addr = db_dest_addr_reg_out;
			end

			STATE_WRITE_MEM_DONE: begin
				enq_en		 = 1'b0;
			end

			STATE_ACK: begin
				ack			 = 1'b1;
			end

			STATE_DEBUG_RES: begin
				ack			 = 1'b1;
				debug_data	 = mem_resp_data_reg_out;
			end
		endcase		
	end

endmodule
`endif /*PLAB5_MCORE_DMA_CONTROLLER_V*/
