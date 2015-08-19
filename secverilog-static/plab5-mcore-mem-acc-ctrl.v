//========================================================================
// Memory Address Space Controller ( Memory access control + address space
// partition control register ) 
//========================================================================

`ifndef PLAB5_MCORE_MEM_ACC_CTRL_V
`define PLAB5_MCORE_MEM_ACC_CTRL_V

`include "vc-mem-msgs.v"

module plab5_mcore_mem_acc_ctrl
#(
	parameter	mem_size		= 1<<16,	// memory size
	parameter   initial_par		= 32'hc000, // initial partition address
	parameter	p_opaque_nbits	= 8,		// mem message opaque field num bits
	parameter	p_addr_nbits	= 32,		// mem message address num bits
	parameter	p_data_nbits	= 32,		// mem message data num bits
	
	// Shorter names for message type, not to be set from outside the module
	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	d = p_data_nbits,

	// Local constants not meant to be set from outside the module
	parameter	req_nbits	= `VC_MEM_REQ_MSG_NBITS(o,a,d),
	parameter	req_cnbits	= req_nbits - p_data_nbits,
	parameter	req_dnbits	= p_data_nbits,
	parameter	resp_nbits	= `VC_MEM_RESP_MSG_NBITS(o,d),
	parameter	resp_cnbits	= resp_nbits - p_data_nbits,
	parameter	resp_dnbits	= p_data_nbits
)
(
	input							{L}     clk,
	input							{L}     reset,

	// request security level
	input							{L}     req_sec_level,
	// response from memory's security level
    input   						{L}     resp_sec_level,
	// if the request is insecure, set insecure signal
	output	reg						{Ctrl resp_sec_level} insecure,
	
	// Input from Cache requests
	input	[req_cnbits-1:0]		{Ctrl req_sec_level} cache2mem_req_control,
	input	[req_dnbits-1:0]		{Data req_sec_level} cache2mem_req_data,
	input							{Ctrl req_sec_level} cache2mem_req_val,
	output	reg						{Ctrl req_sec_level} cache2mem_req_rdy,

	// Output to Memory
	output	reg [req_cnbits-1:0]	{Ctrl mem_req_domain} mem_req_control,
	output	reg [req_dnbits-1:0]	{Data mem_req_domain} mem_req_data,
	output	reg						{Ctrl mem_req_domain} mem_req_val,
	input							{Ctrl mem_req_domain} mem_req_rdy,
    output  reg                     {L}                   mem_req_domain,

	// Output to Cache responses
	output	reg	[resp_cnbits-1:0]	{Ctrl resp_sec_level}  mem2cache_resp_control,
	output	reg [resp_dnbits-1:0]	{Data resp_sec_level}  mem2cache_resp_data,
	output	reg						{Ctrl resp_sec_level}  mem2cache_resp_val,
	input							{Ctrl resp_sec_level}  mem2cache_resp_rdy,

	// Input from Memory
	input	[resp_cnbits-1:0]		{Ctrl mem_resp_domain} mem_resp_control,
	input	[resp_dnbits-1:0]		{Data mem_resp_domain} mem_resp_data,
	input							{Ctrl mem_resp_domain} mem_resp_val,
	output	reg						{Ctrl mem_resp_domain} mem_resp_rdy,
    output  reg                     {L}                    mem_resp_domain
);

	//----------------------------------------------------------------------
	// State Definitions
	//----------------------------------------------------------------------

	localparam STATE_IDLE			= 3'd0;
	localparam STATE_SEC_CHECK		= 3'd1;
	localparam STATE_MEM_REQ		= 3'd2;
	localparam STATE_MEM_RESP		= 3'd3;
	localparam STATE_FAKE_RESP		= 3'd4;
	localparam STATE_CH_PAR			= 3'd5;

	//----------------------------------------------------------------------
	// State
	//----------------------------------------------------------------------
	
	reg [2:0]	{Ctrl cur_domain}  state_reg;
	reg [2:0]	{Ctrl cur_domain}  state_next;

	always @( posedge clk ) begin
		if ( reset ) begin
			state_reg <= 3'd0;
		end
		else begin
			state_reg <= state_next;
		end
	end

	//----------------------------------------------------------------------
	// State Transitions
	//----------------------------------------------------------------------
	
	always @(*) begin

		state_next = state_reg;
		case ( state_reg )

			STATE_IDLE:
				if ( cache2mem_req_val && req_sec_level == cur_domain)	
                                            state_next = 3'd1;
			STATE_SEC_CHECK:
                if ( cur_domain == 1'b0 && req_addr == 32'h0000 )
                                            state_next = 3'd4;
           else if ( cur_domain == 1'b1 && req_addr == 32'h0000 )
                                            state_next = 3'd5;
		   else	if ( cur_domain == 1'b1 )   
                                            state_next = 3'd2;
		   else if ( cur_domain == 1'b0 && req_addr < par_ctrl_reg ) 
                                            state_next = 3'd2;
		   else if ( cur_domain == 1'b0 && req_addr >= par_ctrl_reg) 
                                            state_next = 3'd4;

			STATE_MEM_REQ:
				state_next = 3'd3;
			
			STATE_MEM_RESP:
				state_next = 3'd0;
			
			STATE_FAKE_RESP:
				state_next = 3'd0;

			STATE_CH_PAR:
				state_next = 3'd0;
		endcase
	end

	//----------------------------------------------------------------------
	// State Outputs
	//----------------------------------------------------------------------
	
	reg [p_addr_nbits-1:0]	{Ctrl cur_domain} req_addr;
	reg [req_cnbits-1:0]	{Ctrl cur_domain} req_control;
	reg [req_dnbits-1:0]	{Data cur_domain} req_data;
	reg						{L}               req_sec_level_pre;
	reg						{L}               cur_domain;
	reg	 [resp_cnbits-1:0]	{Ctrl cur_domain} mem2cache_resp_control_dump;
	
	reg	 [p_addr_nbits-1:0]	{L}               par_ctrl_reg;

	// reset partition control register when reset signal to be high
	always @(*) begin
		if ( reset ) begin
			par_ctrl_reg <= initial_par;
		end
	end

	// register request address, req security level and control field
	always @(posedge clk) begin
		if ( state_reg == 3'd0 && cache2mem_req_val && cur_domain == req_sec_level) begin
				req_addr			<= cache2mem_req_control[p_addr_nbits+4:4];
				cur_domain	        <= req_sec_level;
				req_control			<= cache2mem_req_control;
				req_data			<= cache2mem_req_data;
				mem2cache_resp_control_dump 
									<= {cache2mem_req_control[45:42], 
						cache2mem_req_control[41:34],cache2mem_req_control[1:0]};
		end
		
		else if ( cur_domain == req_sec_level ) begin
				req_addr			<= req_addr;
				cur_domain	        <= cur_domain;
				req_control			<= req_control;
				req_data			<= req_data;
				mem2cache_resp_control_dump <= mem2cache_resp_control_dump;
		end
	end	
	
	always @(*) begin
		
		resp_sec_level			= cur_domain;
		insecure				= 1'b0;
		cache2mem_req_rdy		= 1'b1;
		mem_req_control			= 'hx;
		mem_req_data			= 'hx;
		mem_req_val				= 1'b0;
		mem2cache_resp_control	= 'hx;
		mem2cache_resp_data		= 'hx;
		mem2cache_resp_val		= 1'b0;
		mem_resp_rdy			= 1'b0;

		case ( state_reg )

			STATE_IDLE: begin
                if ( req_sec_level == cur_domain && resp_sec_level == cur_domain && mem_req_domain == cur_domain && mem_resp_domain == cur_domain) begin
				    cache2mem_req_rdy		= 1'b1;
				    mem_req_control			= 'hx;
				    mem_req_data			= 'hx;
				    mem_req_val				= 1'b0;
				    mem2cache_resp_control	= 'hx;
				    mem2cache_resp_data		= 'hx;
				    mem2cache_resp_val		= 1'b0;
				    mem_resp_rdy			= 1'b0;
                end
			end

			STATE_SEC_CHECK: begin
                if ( req_sec_level == cur_domain && resp_sec_level == cur_domain && mem_req_domain == cur_domain && mem_resp_domain == cur_domain) begin
				    cache2mem_req_rdy		= 1'b0;
				    mem_req_control			= 'hx;
				    mem_req_data			= 'hx;
				    mem_req_val				= 1'b0;
				    mem2cache_resp_control	= 'hx;
				    mem2cache_resp_data		= 'hx;
				    mem2cache_resp_val		= 1'b0;
				    mem_resp_rdy			= 1'b0;
                end
			end

			STATE_MEM_REQ: begin
                if ( req_sec_level == cur_domain && resp_sec_level == cur_domain && mem_req_domain == cur_domain && mem_resp_domain == cur_domain) begin
				    cache2mem_req_rdy		= 1'b0;
				    mem_req_control			= req_control;
				    mem_req_data			= req_data;
				    mem_req_val				= 1'b1;
				    mem2cache_resp_control	= 'hx;
				    mem2cache_resp_data		= 'hx;
				    mem2cache_resp_val		= 1'b0;
				    mem_resp_rdy			= 1'b0;
                end
			end

			STATE_MEM_RESP: begin
                if ( req_sec_level == cur_domain && resp_sec_level == cur_domain && mem_req_domain == cur_domain && mem_resp_domain == cur_domain) begin
				    insecure				= 1'b0;
				    cache2mem_req_rdy		= 1'b0;
				    mem_req_control			= 'hx;
				    mem_req_data			= 'hx;
				    mem_req_val				= 1'b0;
				    mem2cache_resp_control	= mem_resp_control;
				    mem2cache_resp_data		= mem_resp_data;
				    mem2cache_resp_val		= mem_resp_val;
				    mem_resp_rdy			= mem2cache_resp_rdy;
                end
			end

			STATE_FAKE_RESP: begin
                if ( req_sec_level == cur_domain && resp_sec_level == cur_domain && mem_req_domain == cur_domain && mem_resp_domain == cur_domain) begin
				    insecure				= 1'b1;
				    cache2mem_req_rdy		= 1'b0;
				    mem_req_control			= 'hx;
				    mem_req_data			= 'hx;
				    mem_req_val				= 1'b0;
				    mem2cache_resp_control	= mem2cache_resp_control_dump;
				    mem2cache_resp_data		= 'hx;
				    mem2cache_resp_val		= 1'b1;
				    mem_resp_rdy			= 1'b0;
                end
			end

			STATE_CH_PAR: begin
                if ( req_sec_level == cur_domain && resp_sec_level == cur_domain && mem_req_domain == cur_domain && mem_resp_domain == cur_domain ) begin
				    cache2mem_req_rdy		= 1'b0;
				    mem_req_control			= 'hx;
				    mem_req_data			= 'hx;
				    mem_req_val				= 1'b0;
				    mem2cache_resp_control	= 'hx;
				    mem2cache_resp_data		= 'hx;
				    mem2cache_resp_val		= 1'b0;
				    mem_resp_rdy			= 1'b0;
				    par_ctrl_reg			= req_data;
                end
			end
				
		endcase
	end

endmodule
`endif /*PLAB5_MCORE_MEM_ADDR_CTRL_FSM_V*/
				

		
