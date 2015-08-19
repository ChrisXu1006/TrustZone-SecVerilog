//========================================================================
// Debug Interface Checker Module
// The module will check whether DMA requests from debug interface match 
// the security level of DMA checker, if yes, the DMA requests will be 
// passed to DMA controller. Otherwise, it will be rejected
//========================================================================

`ifndef PLAB5_MCORE_DEBUG_CHECKER_V
`define PLAB5_MCORE_DEBUG_CEHCKER_V

module plab5_mcore_Debug_checker
#(
	parameter	p_opaque_nbits	= 8,	// opaque field bit width
	parameter	p_addr_nbits	= 32,	// address field bit width
	parameter	p_data_nbits	= 32,	// data field bit width

	// shorter names for message type, not to be set from outside the module
	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	d = p_data_nbits
)
(
	input						clk,
	input						reset,

	// ports connected to debug interface
	input						debug_val,
	input						debug_domain,
	input [p_addr_nbits-1:0]	debug_src_addr,
	input [p_addr_nbits-1:0]	debug_dest_addr,
	input						debug_inst,
	output reg					debug_ack,
	output[p_data_nbits-1:0]	debug_data,

	// ports connected to DMA controller
	input						dma_domain,
	input						dma_ack,
	output reg					dma_db_val,
	output[p_addr_nbits-1:0]	dma_db_src_addr,
	output[p_addr_nbits-1:0]	dma_db_dest_addr,
	output reg					dma_db_inst,
	input [p_data_nbits-1:0]	dma_db_debug_data
);

    //----------------------------------------------------------------------
	// State Definitions
    //----------------------------------------------------------------------
	
	localparam STATE_IDLE		= 3'd0;
	localparam STATE_DEB_CHECK	= 3'd1;
	localparam STATE_DEB_REQ	= 3'd2;
	localparam STATE_DEB_WAIT	= 3'd3;
	localparam STATE_DEB_RESP	= 3'd4;

    //----------------------------------------------------------------------
	// State
    //----------------------------------------------------------------------
	
	reg	[2:0]	state_reg;
	reg	[2:0]	state_next;

	always @(posedge clk) begin
		if ( reset )
			state_reg <= STATE_IDLE;
		else
			state_reg <= state_next;
	end
	
	//----------------------------------------------------------------------
	// State Transitions
    //----------------------------------------------------------------------
	
	always @(*) begin
		
		state_next = state_reg;

		case ( state_reg )

			STATE_IDLE:
				if ( debug_val ) state_next = STATE_DEB_CHECK;

			STATE_DEB_CHECK:
				if ( debug_domain >= dma_domain) 
					state_next = STATE_DEB_REQ;
				else
					state_next = STATE_DEB_RESP;

			STATE_DEB_REQ:
				state_next = STATE_DEB_WAIT;
			
			STATE_DEB_WAIT:
				if ( dma_ack )	state_next = STATE_DEB_RESP;

			STATE_DEB_RESP:
				state_next = STATE_IDLE;

		endcase
	end

	//----------------------------------------------------------------------
	// Register Inputs
    //----------------------------------------------------------------------
	reg			debug_domain_reg;
	reg			debug_inst_reg;
	reg [a-1:0]	debug_src_addr_reg;
	reg	[a-1:0]	debug_dest_addr_reg;

	always @(posedge clk) begin
		if ( reset ) begin
			debug_domain_reg	<= 'hx;
			debug_inst_reg		<= 'hx;
			debug_src_addr_reg	<= 'hx;
			debug_dest_addr_reg <= 'hx;
		end

		else if ( debug_val ) begin
			debug_domain_reg	<= debug_domain;
			debug_inst_reg		<= debug_inst;
			debug_src_addr_reg	<= debug_src_addr;
			debug_dest_addr_reg	<= debug_dest_addr;
		end
	end

	//----------------------------------------------------------------------
	// State Outputs
    //----------------------------------------------------------------------
	
	reg	[p_data_nbits-1:0]	debug_data;
	reg	[p_addr_nbits-1:0]	dma_db_src_addr;
	reg [p_addr_nbits-1:0]	dma_db_dest_addr;

	always @(*) begin
		
		debug_ack		= 1'b0;
		debug_data		= 'hx;

		dma_db_val		= 1'b0;
		dma_db_src_addr	= 'hx;
		dma_db_dest_addr= 'hx;
		dma_db_inst		= 1'bx;

		case ( state_reg )
			
			STATE_DEB_REQ: begin
				dma_db_val		= 1'b1;
				dma_db_src_addr	= debug_src_addr_reg;
				dma_db_dest_addr= debug_dest_addr_reg;
				dma_db_inst		= debug_inst_reg;
			end

			STATE_DEB_RESP: begin
				debug_ack		= 1'b1;
				debug_data		= dma_db_debug_data;
			end

		endcase
	end

endmodule
`endif /*PLAB5_MCORE_DEBUG_CHECKER_V*/
