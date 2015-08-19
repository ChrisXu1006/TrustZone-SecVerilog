//========================================================================
// Direct Memory Access Checker Module
// The module will check whether DMA requests from cores match the
// security level of DMA checker, if yes, the DMA requests will be passed 
// to DMA controller. Otherwise, it will be rejected
//========================================================================

`ifndef PLAB5_MCORE_DMA_CHECKER_V
`define PLAB5_MCORE_DMA_CHECKER_V

`include "vc-mem-msgs.v"

module plab5_mcore_DMA_checker
#(
	parameter	p_opaque_nbits	= 8,	// opaque field bit width
	parameter	p_addr_nbits	= 32,	// address field bit width
	parameter	p_data_nbits	= 32,	// data field bit width

	// shorter name for message type, not to be set from outside the module
	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	d = p_data_nbits,

	// local constants not meant to be set from outside the module
	parameter	c_req_nbits	  = `VC_MEM_REQ_MSG_NBITS(o,a,d),
	parameter	c_req_cnbits  = c_req_nbits - d,
	parameter	c_req_dnbits  = d,
	parameter	c_resp_nbits  = `VC_MEM_RESP_MSG_NBITS(o,d),
	parameter	c_resp_cnbits = c_resp_nbits - d,
    parameter	c_resp_dnbits = d	
)
(
	input						{L} clk,
	input						{L} reset,

	// ports connected to on-chip network
	
	input						{Ctrl noc_domain} noc_val,
	output reg					{Ctrl noc_domain} noc_rdy,
	input  [p_addr_nbits-1:0]	{Ctrl noc_domain} noc_src_addr,
	input  [p_addr_nbits-1:0]	{Ctrl noc_domain} noc_dest_addr,
	input  [c_req_cnbits-1:0]	{Ctrl noc_domain} noc_req_control,
	input						{Ctrl noc_domain} noc_inst,
	input						{L}               noc_domain,

	output [c_resp_cnbits-1:0]	{Ctrl noc_resp_domain} noc_resp_control,
	output reg					{Ctrl noc_resp_domain} noc_ack,
	output reg					{L}                    noc_resp_domain,

	// ports connected to DMA controller
	output reg					{Ctrl dma_domain} dma_val,
	input						{Ctrl dma_domain} dma_rdy,
	output [p_addr_nbits-1:0]	{Ctrl dma_domain} dma_src_addr,
	output [p_addr_nbits-1:0]	{Ctrl dma_domain} dma_dest_addr,
	output [c_req_cnbits-1:0]	{Ctrl dma_domain} dma_req_control,
	output reg					{Ctrl dma_domain} dma_inst,
	input						{Ctrl dma_domain} dma_ack,
	input						{L}               dma_domain
);

    //----------------------------------------------------------------------
	// State Definitions
    //----------------------------------------------------------------------
	
	localparam STATE_IDLE		= 3'd0;
	localparam STATE_NOC_CHECK	= 3'd1;
	localparam STATE_NOC_REQ	= 3'd2;
	localparam STATE_NOC_WAIT	= 3'd3;
	localparam STATE_NOC_RESP	= 3'd4;

    //----------------------------------------------------------------------
	// State
    //----------------------------------------------------------------------
	
	reg [2:0]	{Ctrl noc_domain_reg} state_reg;
	reg [2:0]	{Ctrl noc_domain_reg} state_next;

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
				if ( noc_val && noc_domain == noc_domain_reg)	
                    state_next = STATE_NOC_CHECK;

			STATE_NOC_CHECK:
				if ( noc_domain_reg >= dma_domain )
					state_next = STATE_NOC_REQ;
				else
					state_next = STATE_NOC_RESP;

			STATE_NOC_REQ:
				state_next = STATE_NOC_WAIT;

			STATE_NOC_WAIT:
				if ( dma_ack && dma_domain == noc_domain_reg )	
                    state_next = STATE_NOC_RESP;

			STATE_NOC_RESP:
				state_next = STATE_IDLE;

		endcase
	end	

    //----------------------------------------------------------------------
	// Register Inputs
    //----------------------------------------------------------------------
	reg						{L}                     noc_domain_reg;
	reg [a-1:0]				{Ctrl noc_domain_reg} noc_src_addr_reg;
	reg [a-1:0]				{Ctrl noc_domain_reg} noc_dest_addr_reg;
	reg [c_req_cnbits-1:0]	{Ctrl noc_domain_reg} noc_req_control_reg;

	always @(posedge clk) begin
		if ( reset ) begin
			noc_domain_reg		<= 'hx;
			noc_src_addr_reg	<= 'hx;
			noc_dest_addr_reg	<= 'hx;
			noc_req_control_reg	<= 'hx;
		end

		else if ( noc_val && noc_domain_reg == noc_domain ) begin
			noc_domain_reg		<= noc_domain;
			noc_src_addr_reg	<= noc_src_addr;
			noc_dest_addr_reg	<= noc_dest_addr;
			noc_req_control_reg	<= noc_req_control;
		end
	end

    //----------------------------------------------------------------------
	// State Outputs
    //----------------------------------------------------------------------
	
	reg	[p_addr_nbits-1:0]	{Ctrl dma_domain} dma_src_addr;
	reg	[p_addr_nbits-1:0]	{Ctrl dma_domain} dma_dest_addr;
	reg	[c_req_cnbits-1:0]	{Ctrl dma_domain} dma_req_control;

	always @(*) begin
		
		noc_rdy				= 1'b0;
		noc_ack				= 1'b0;
		noc_resp_domain		= noc_domain_reg;

		dma_val				= 1'b0;
		dma_src_addr		= 'hx;
		dma_dest_addr		= 'hx;
		dma_req_control		= 'hx;
		dma_inst			= 1'bx;

		case ( state_reg )

			STATE_IDLE: begin
                if ( noc_domain == noc_domain_reg )
				    noc_rdy = 1'b1;
			end

			STATE_NOC_REQ: begin
                if ( noc_domain_reg == dma_domain ) begin
				    dma_val			= 1'b1;
				    dma_src_addr	= noc_src_addr_reg;
				    dma_dest_addr	= noc_dest_addr_reg;
				    dma_req_control = noc_req_control_reg;	
				    dma_inst		= 1'b0;
                end
			end

			STATE_NOC_RESP: begin
				noc_ack			= 1'b1;
			end

		endcase
	
	end
	
    always @(*) begin
        if ( noc_resp_domain == noc_domain_reg ) begin
	        noc_resp_control[14:12] = noc_req_control_reg[46:44];
            noc_resp_control[11:4]  = noc_req_control_reg[43:36];
	        noc_resp_control[3:0]   = noc_req_control_reg[3:0];	
        end
    end
endmodule
`endif /*PLAB5_MCORE_DMA_CHECKER_V*/
