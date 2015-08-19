//========================================================================
// Direct Memory Access Checker Module
// This module is responsible for DMA controller security check. It will
// compare the received DMA command's request with inside security
// register, if match DMA will be served, Otherwise, it will be denied 
//========================================================================

`ifndef PLAB5_MCORE_DMA_CHECKER_V
`define PLAB5_MCORE_DMA_CHECKER_V

`include "vc-mem-msgs.v"

module plab5_mcore_DMA_checker
#(
	parameter	p_opaque_nbits	= 8,	// opaque field bit width
	parameter	p_addr_nbits	= 32,	// address field bit width
	parameter	p_data_nbits	= 32,	// data field bit width

	// shorter names for message type, not to be set from outside the module
	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	d = p_data_nbits,

	// local constants not meant to be set from outside from the module
	parameter	c_req_nbits   = `VC_MEM_REQ_MSG_NBITS(o,a,d),
	parameter	c_req_cnbits  = c_req_nbits - d,
	parameter	c_req_dnbits  = d,
	parameter	c_resp_nbits  = `VC_MEM_RESP_MSG_NBITS(o,d),
	parameter	c_resp_cnbits = c_resp_nbits - d,
	parameter	c_resp_dnbits = d
)
(
	input						{L} clk,
	input						{L} reset,

	// ports connected to Noc
	input						{Domain noc_domain} noc_val,
	output reg					{Domain noc_domain} noc_rdy,
	input						{L} noc_domain,
	input [p_addr_nbits-1:0]	{Domain noc_domain} noc_src_addr,
	input [p_addr_nbits-1:0]	{Domain noc_domain} noc_dest_addr,
	input [c_req_cnbits-1:0]	{Domain noc_domain} noc_req_control,
	output[c_resp_cnbits-1:0]	{Domain noc_resp_domain} noc_resp_control,
	input						{Domain noc_domain} noc_inst,
	output reg					{Domain noc_resp_domain} noc_ack,
	output reg					{L} noc_resp_domain,
	
	// ports connected to debug interface
	input						{Domain debug_domain} debug_val,
	input						{L} debug_domain,
	input [p_addr_nbits-1:0]	{Domain debug_domain} debug_src_addr,
	input [p_addr_nbits-1:0]	{Domain debug_domain} debug_dest_addr,
	input						{Domain debug_domain} debug_inst,
	output reg					{Domain debug_domain} debug_ack,
	output[p_data_nbits-1:0]	{Domain debug_domain} debug_data,
	
	// ports connected to DMA controller
	output reg					{Domain dma_domain} dma_val,
	input						{Domain dma_resp_domain} dma_rdy,
	output reg					{L} dma_domain,
	output[p_addr_nbits-1:0]	{Domain dma_domain} dma_src_addr,
	output[p_addr_nbits-1:0]	{Domain dma_domain} dma_dest_addr,
	output[c_req_cnbits-1:0]	{Domain dma_domain} dma_req_control,
	input [c_resp_cnbits-1:0]	{Domain dma_resp_domain} dma_resp_control,
	output reg					{Domain dma_domain} dma_inst,
	input						{Domain dma_resp_domain} dma_ack,
	input						{L} dma_resp_domain,

	output reg					{Domain dma_db_domain} dma_db_val,
	output reg					{L} dma_db_domain,
	output[p_addr_nbits-1:0]	{Domain dma_db_domain} dma_db_src_addr,
	output[p_addr_nbits-1:0]	{Domain dma_db_domain} dma_db_dest_addr,
	output reg					{Domain dma_db_domain} dma_db_inst,
	input [p_data_nbits-1:0]	{Domain dma_db_domain} dma_db_debug_data
);

	// security register to indicate security level of DMA controller
	reg	{D2} secure_reg	= 1'b1;

    //----------------------------------------------------------------------
	// State Definitions
    //----------------------------------------------------------------------
	
	localparam	STATE_IDLE		= 4'd0;
	localparam	STATE_NOC_CHECK	= 4'd1;
	localparam	STATE_NOC_REQ	= 4'd2;
	localparam	STATE_NOC_WAIT	= 4'd3;
	localparam	STATE_NOC_RESP	= 4'd4;
	localparam	STATE_DEB_CHECK = 4'd5;
	localparam	STATE_DEB_REQ	= 4'd6;
	localparam  STATE_DEB_WAIT	= 4'd7;
	localparam	STATE_DEB_RESP	= 4'd8;

    //----------------------------------------------------------------------
	// State  
    //----------------------------------------------------------------------
	
	reg	[3:0]   {Domain cur_domain} state_reg;
	reg	[3:0]	{Domain cur_domain} state_next;

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
			
            STATE_IDLE: begin
				if ( noc_val && cur_domain == noc_domain)	
                    state_next = STATE_NOC_CHECK;
		        if ( debug_val && cur_domain == debug_domain )
                   state_next = STATE_DEB_CHECK;
            end

			STATE_NOC_CHECK:
				if ( noc_domain_reg >= secure_reg )
					state_next = STATE_NOC_REQ;	
			  else
					state_next = STATE_NOC_RESP;

			STATE_NOC_REQ:
				state_next = STATE_NOC_WAIT;

			STATE_NOC_WAIT:
				if ( dma_ack && dma_resp_domain == cur_domain )		
                    state_next = STATE_NOC_RESP;

			STATE_NOC_RESP:
				state_next = STATE_IDLE;	

			STATE_DEB_CHECK:
				if ( debug_domain >= secure_reg )
					state_next = STATE_DEB_REQ;
			  else
					state_next = STATE_DEB_RESP;

			STATE_DEB_REQ:
				state_next = STATE_DEB_WAIT;

			STATE_DEB_WAIT:
				if ( dma_ack && dma_resp_domain == cur_domain )		
                    state_next = STATE_DEB_RESP;

			STATE_DEB_RESP:
				state_next = STATE_IDLE;

		endcase
	end	

    //----------------------------------------------------------------------
	// Register Inputs
    //----------------------------------------------------------------------
	reg						{L} noc_domain_reg;
    reg                     {L} cur_domain;
	reg	[a-1:0]				{Domain noc_domain} noc_src_addr_reg;
	reg	[a-1:0]				{Domain noc_domain} noc_dest_addr_reg;
	reg [c_req_cnbits-1:0]	{Domain noc_domain} noc_req_control_reg;

	always @(posedge clk) begin
		if ( reset ) begin
			noc_domain_reg		<= 'hx; 
            cur_domain          <= 'hx;
			noc_src_addr_reg	<= 'hx;
			noc_dest_addr_reg	<= 'hx;
			noc_req_control_reg	<= 'hx;
		end

		else if ( noc_val ) begin
			noc_domain_reg		<= noc_domain;
            cur_domain          <= noc_domain;
			noc_src_addr_reg	<= noc_src_addr;
			noc_dest_addr_reg	<= noc_dest_addr;
			noc_req_control_reg	<= noc_req_control;
		end
	end

	reg						{L} debug_domain_reg;
	reg						{Domain debug_domain} debug_inst_reg;
	reg	[a-1:0]				{Domain debug_domain} debug_src_addr_reg;
	reg	[a-1:0]				{Domain debug_domain} debug_dest_addr_reg;

	always @(posedge clk) begin
		if ( reset ) begin
			debug_domain_reg	<= 'hx;
			debug_inst_reg		<= 'hx;
			debug_src_addr_reg	<= 'hx;
			debug_dest_addr_reg	<= 'hx;
		end

		else if ( debug_val ) begin
			debug_domain_reg	<= debug_domain;
            cur_domain          <= debug_domain;
			debug_inst_reg		<= debug_inst;
			debug_src_addr_reg	<= debug_src_addr;
			debug_dest_addr_reg	<= debug_dest_addr;
		end
	end

    //----------------------------------------------------------------------
	// State Outputs
    //----------------------------------------------------------------------
	
	reg	[c_resp_cnbits-1:0]	{Domain noc_resp_domain} noc_resp_control;

	reg	[p_data_nbits-1:0]	{Domain dma_db_domain} debug_data;
	reg	[p_addr_nbits-1:0]	{Domain dma_domain} dma_src_addr;
	reg	[p_addr_nbits-1:0]	{Domain dma_domain} dma_dest_addr;
	reg [c_req_cnbits-1:0]	{Domain dma_domain} dma_req_control;

	reg	[p_addr_nbits-1:0]	{Domain dma_db_domain} dma_db_src_addr;
	reg	[p_addr_nbits-1:0]	{Domain dma_db_domain} dma_db_dest_addr;
	
	always @(*) begin

		noc_rdy			= 1'b0;
		noc_ack			= 1'b0;
		noc_resp_domain	= 1'b0;

		debug_ack		= 1'b0;
		debug_data		= 'hx;

		dma_val			= 1'b0;
		dma_domain		= 1'b0;
		dma_src_addr	= 'hx;
		dma_dest_addr	= 'hx;
		dma_req_control	= 'hx;
		dma_inst		= 1'bx;
		
		dma_db_val		= 1'b0;
		dma_db_domain	= 1'b0;
		dma_db_src_addr	= 'hx;
		dma_db_dest_addr= 'hx;
		dma_db_inst		= 1'bx;

		case ( state_reg ) 

			STATE_IDLE: begin
                if ( cur_domain == noc_domain) 
				    noc_rdy	= 1'b1;
			end

			STATE_NOC_CHECK: begin
			end

			STATE_NOC_REQ: begin
                if ( cur_domain == dma_domain ) begin
				    dma_val			= 1'b1;
				    dma_src_addr	= noc_src_addr_reg;
				    dma_dest_addr	= noc_dest_addr_reg;
				    dma_req_control	= noc_req_control_reg;
				    dma_inst		= 1'b0;
				    dma_domain		= noc_domain_reg;
                end
			end

			STATE_NOC_WAIT: begin
			end

			STATE_NOC_RESP: begin
                if ( cur_domain == noc_resp_domain && dma_resp_domain == noc_resp_domain
                        && cur_domain == noc_domain ) begin
				    noc_rdy			= 1'b1;
				    noc_ack			= 1'b1;
				    noc_resp_control= dma_resp_control;
				    noc_resp_domain	= noc_domain;
                end
			end

			STATE_DEB_CHECK: begin
			end

			STATE_DEB_REQ: begin
                if ( cur_domain == debug_domain ) begin
				    dma_db_val		= 1'b1;
				    dma_db_domain	= debug_domain_reg;
				    dma_db_src_addr = debug_src_addr_reg;
				    dma_db_dest_addr= debug_dest_addr_reg;
				    dma_db_inst		= debug_inst_reg;
                end
			end

			STATE_DEB_WAIT: begin
			end

			STATE_DEB_RESP: begin
                if ( cur_domain == dma_db_domain && cur_domain == debug_domain) begin
				    debug_ack		= 1'b1;
				    debug_data		= dma_db_debug_data;
                end
			end

		endcase
	end

endmodule
`endif /*PLAB5_MCORE_DMA_CHECKER_V*/
