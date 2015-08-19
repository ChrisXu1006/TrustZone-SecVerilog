//========================================================================
// Debug Interface
//========================================================================

`ifndef PLAB5_MCORE_DEBUG_INTERFACE_V
`define PLAB5_MCORE_DEBUG_INTERFACE_V

`include "vc-mem-msgs.v"

module plab5_mcore_Debug_Interface
#(
	parameter	p_addr_nbits = 32,	// address filed bit width
	parameter	p_data_nbits = 32   // data field bit width
)
(
	input						clk,
	input						reset,

	output						start,		// enter into debug mode signal
	output						inst,		// debug intruction type
	output [p_addr_nbits-1:0]	src_addr,	// source address  
	output [p_addr_nbits-1:0]	dest_addr,	// destination address
	output						domain,
	output						result_rdy, // have get the result,
	output [p_data_nbits-1:0]	db_result,	

	input						val,		// indicate a new debug instruction
	input  [p_addr_nbits-1:0]	db_src_addr,// debug request source address
	input  [p_addr_nbits-1:0]	db_dest_addr,//debug request destination address
	input						db_domain,	// debug request security level
	input						ack,		// indicate requests is done
	input  [p_data_nbits-1:0]	read_data	// read data from the main memory
);

	//========================================================================
	// Finite State Machine of Debug Interface
	//========================================================================
	
	// FSM State Deifintions
	localparam STATE_IDLE		  = 4'd0;
	localparam STATE_DEBUG_REQ	  = 4'd1;
	localparam STATE_DEBUG_WAIT   = 4'd2;
	localparam STATE_EXTRACT_RES  = 4'd3;
	localparam STATE_EXTRACT_WAIT = 4'd4;
	localparam STATE_RES_CHECK	  = 4'd5;
	
	// FSM State transition
	reg [3:0]	state_reg;
	reg [3:0]	state_next;

	always @(posedge clk) begin
		if ( reset ) begin
			state_reg <= STATE_IDLE;
		end
		else begin
			state_reg <= state_next;
		end
	end

	always @(*) begin 
	
		state_next = state_reg;

		case ( state_reg )
			
			STATE_IDLE:
				if ( val ) state_next = STATE_DEBUG_REQ;

			STATE_DEBUG_REQ:
				state_next = STATE_DEBUG_WAIT;

			STATE_DEBUG_WAIT:
				if ( ack ) state_next = STATE_EXTRACT_RES;

			STATE_EXTRACT_RES:
				state_next = STATE_EXTRACT_WAIT;
			
			STATE_EXTRACT_WAIT:
				if ( ack )	state_next = STATE_RES_CHECK;

			STATE_RES_CHECK:
				state_next = STATE_IDLE;				
		endcase
	end

	// Corresponding States' Behavior
	reg						start;
	reg						inst;
	reg [p_addr_nbits-1:0]	src_addr;
	reg [p_addr_nbits-1:0]	dest_addr;
	reg						result_rdy;

	reg						db_en;
	wire[p_addr_nbits-1:0]	src_addr_reg_out;
	wire[p_addr_nbits-1:0]	dest_addr_reg_out;
	wire					cur_domain;

	vc_EnResetReg#(p_addr_nbits) src_addr_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(db_en),
		.d		(db_src_addr),
		.q		(src_addr_reg_out)
	);

	vc_EnResetReg#(p_addr_nbits) dest_addr_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(db_en),
		.d		(db_dest_addr),
		.q		(dest_addr_reg_out)
	);

	vc_EnResetReg#(1) domain_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(db_en),
		.d		(db_domain),
		.q		(domain)
	);

	vc_EnResetReg#(p_data_nbits) db_result_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(ack),
		.d		(read_data),
		.q		(db_result)
	);

	always @(*) begin
		
		db_en = 1'b0;
		inst  = 1'bx;
		result_rdy = 1'b0;

		case ( state_reg ) 
				
			STATE_IDLE: begin
				start	  = 1'b0;
				src_addr  = 'hx;
				dest_addr = 'hx;
				db_en	  = 1'b1;
			end

			STATE_DEBUG_REQ: begin
				start	  = 1'b1;
				inst	  = 1'b0;
				src_addr  = src_addr_reg_out;
				dest_addr = dest_addr_reg_out;
			end

			STATE_DEBUG_WAIT: begin
				start	  = 1'b0;
				src_addr  = src_addr_reg_out;
				dest_addr = dest_addr_reg_out;
			end

			STATE_EXTRACT_RES: begin
				start	  = 1'b1;
				inst	  = 1'b1;
				src_addr  = dest_addr_reg_out;
				dest_addr = 'hx;
			end

			STATE_EXTRACT_WAIT: begin
				start	  = 1'b0;
				inst	  = 1'b1;
				src_addr  = dest_addr_reg_out;
				dest_addr = 'hx;
			end

			STATE_RES_CHECK: begin
				start	  = 1'b0;
				src_addr  = 'hx;
				dest_addr = 'hx;
				result_rdy = 1'b1;
			end
		endcase
	end

endmodule
`endif /*PLAB5_MCORE_DEBUG_INTERFACE_V*/
	
	


