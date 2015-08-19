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
	input						{L} clk,
	input						{L} reset,

	// ports connected to debug interface
	input						{Ctrl debug_domain} debug_val,
	input						{L}                 debug_domain,
	input [p_addr_nbits-1:0]	{Ctrl debug_domain} debug_src_addr,
	input [p_addr_nbits-1:0]	{Ctrl debug_domain} debug_dest_addr,
	input						{Ctrl debug_domain} debug_inst,

	output reg					{Ctrl debug_resp_domain} debug_ack,
	output[p_data_nbits-1:0]	{Data debug_resp_domain} debug_data,
    output reg                  {L}                      debug_resp_domain,

	// ports connected to DMA controller
	input						{L}                 dma_domain,
	input						{Ctrl dma_domain} dma_ack,
	output reg					{Ctrl dma_domain} dma_db_val,
	output[p_addr_nbits-1:0]	{Ctrl dma_domain} dma_db_src_addr,
	output[p_addr_nbits-1:0]	{Ctrl dma_domain} dma_db_dest_addr,
	output reg					{Ctrl dma_domain} dma_db_inst,
	input [p_data_nbits-1:0]	{Data dma_domain} dma_db_debug_data
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
	
	reg	[2:0]	{Ctrl debug_domain_reg} state_reg;
	reg	[2:0]	{Ctrl debug_domain_reg} state_next;

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
				if ( debug_val && debug_domain == debug_domain_reg ) 
                    state_next = STATE_DEB_CHECK;

			STATE_DEB_CHECK:
				if ( debug_domain >= dma_domain) 
					state_next = STATE_DEB_REQ;
				else
					state_next = STATE_DEB_RESP;

			STATE_DEB_REQ:
				state_next = STATE_DEB_WAIT;
			
			STATE_DEB_WAIT:
				if ( dma_ack && debug_domain_reg == dma_domain )	
                    state_next = STATE_DEB_RESP;

			STATE_DEB_RESP:
				state_next = STATE_IDLE;

		endcase
	end

	//----------------------------------------------------------------------
	// Register Inputs
    //----------------------------------------------------------------------
	reg			{L}                     debug_domain_reg;
	reg			{Ctrl debug_domain_reg} debug_inst_reg;
	reg [a-1:0]	{Ctrl debug_domain_reg} debug_src_addr_reg;
	reg	[a-1:0]	{Ctrl debug_domain_reg} debug_dest_addr_reg;

	always @(posedge clk) begin
		if ( reset ) begin
			debug_domain_reg	<= 'hx;
			debug_inst_reg		<= 'hx;
			debug_src_addr_reg	<= 'hx;
			debug_dest_addr_reg <= 'hx;
		end

		else if ( debug_val ) begin
            if ( debug_domain_reg == debug_domain ) begin
			    debug_domain_reg	<= debug_domain;
			    debug_inst_reg		<= debug_inst;
			    debug_src_addr_reg	<= debug_src_addr;
			    debug_dest_addr_reg	<= debug_dest_addr;
            end
		end
	end

	//----------------------------------------------------------------------
	// State Outputs
    //----------------------------------------------------------------------
	
	reg	[p_data_nbits-1:0]	{Data debug_resp_domain} debug_data;
	reg	[p_addr_nbits-1:0]	{Ctrl dma_domain} dma_db_src_addr;
	reg [p_addr_nbits-1:0]	{Ctrl dma_domain} dma_db_dest_addr;

	always @(*) begin
		
		debug_ack		= 1'b0;
		debug_data		= 'hx;
        debug_resp_domain = debug_domain_reg;

		dma_db_val		= 1'b0;
		dma_db_src_addr	= 'hx;
		dma_db_dest_addr= 'hx;
		dma_db_inst		= 1'bx;

		case ( state_reg )
			
			STATE_DEB_REQ: begin
                if ( debug_domain_reg == dma_domain ) begin 
				    dma_db_val		= 1'b1;
				    dma_db_src_addr	= debug_src_addr_reg;
				    dma_db_dest_addr= debug_dest_addr_reg;
				    dma_db_inst		= debug_inst_reg;
                end
			end

			STATE_DEB_RESP: begin
                if ( debug_domain_reg == dma_domain )  begin
				    debug_ack		= 1'b1;
				    debug_data		= dma_db_debug_data;
                end
			end

		endcase
	end

endmodule
`endif /*PLAB5_MCORE_DEBUG_CHECKER_V*/
