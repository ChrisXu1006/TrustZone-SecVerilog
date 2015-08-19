//========================================================================
// Arbiter for main memory accesses
//========================================================================

`ifndef PLAB5_MCORE_MEM_ARBITER_V
`define PLAB5_MCORE_MEM_ARBITER_V
`include "vc-mem-msgs.v"

module plab5_mcore_mem_arbiter
#(
	parameter	p_opaque_nbits = 8,
    parameter	p_addr_nbits   = 32,
	parameter	p_data_nbits   = 32,

	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	d = p_data_nbits,

	parameter	rqc	= `VC_MEM_REQ_MSG_NBITS(o,a,d) - d,
	parameter	rqd = d,
	parameter	rsc = `VC_MEM_RESP_MSG_NBITS(o,d) - d,
	parameter	rsd = d
)
(
	input					{L} clk,
	input					{L} reset,
		
	input					{Ctrl req0_domain} req0_val,
	output reg				{Ctrl req0_domain} req0_rdy,
	input  [rqc-1:0]		{Ctrl req0_domain} req0_control,
	input  [rqd-1:0]		{Data req0_domain} req0_data,
	input					{L}                req0_domain,

	input					{Ctrl req1_domain} req1_val,
	output reg				{Ctrl req1_domain} req1_rdy,
	input  [rqc-1:0]		{Ctrl req1_domain} req1_control,
	input  [rqd-1:0]		{Data req1_domain} req1_data,
	input					{L}                req1_domain,

	output reg				{Ctrl req_domain}  req_val,
	input					{Ctrl req_domain}  req_rdy,
	output reg [rqc-1:0]	{Ctrl req_domain}  req_control,
	output reg [rqd-1:0]	{Data req_domain}  req_data,
	output reg				{L}                req_domain,

	input					{Ctrl resp_domain} resp_val,
	output reg				{Ctrl resp_domain} resp_rdy,
	input  [rsc-1:0]		{Ctrl resp_domain} resp_control,
	input  [rsd-1:0]		{Data resp_domain} resp_data,
    input                   {Ctrl resp_domain} resp_insecure,
	input					{L}                resp_domain,

	output reg				{Ctrl resp0_domain}resp0_val,
	input					{Ctrl resp0_domain}resp0_rdy,
	output reg [rsc-1:0]	{Ctrl resp0_domain}resp0_control,
	output reg [rsd-1:0]	{Data resp0_domain}resp0_data,
    output reg              {Ctrl resp0_domain}resp0_insecure,
	output reg				{L}                resp0_domain,

	output reg				{Ctrl resp1_domain}resp1_val,
	input					{Ctrl resp1_domain}resp1_rdy,
	output reg [rsc-1:0]	{Ctrl resp1_domain}resp1_control,
	output reg [rsd-1:0]	{Data resp1_domain}resp1_data,
    output reg              {Ctrl resp1_domain}resp1_insecure,
	output reg				{L}                resp1_domain
	
);
	// Macro for States
	localparam	STATE_IDLE  = 3'd0;
	localparam  STATE_ARB   = 3'd1;
    localparam  STATE_REQ0  = 3'd2;
    localparam  STATE_REQ1  = 3'd3;
	localparam	STATE_WAIT0 = 3'd4;
    localparam  STATE_WAIT1 = 3'd5;
	localparam	STATE_RESP0 = 3'd6;
    localparam  STATE_RESP1 = 3'd7;
	
	// State transitions
	reg	[2:0] {Ctrl req_domain} state_reg;
	reg	[2:0] {Ctrl req_domain} state_next;

	always @(posedge clk) begin
		if ( reset )
			state_reg <= STATE_IDLE;
		else
			state_reg <= state_next;
	end

	always @(*) begin
		state_next = state_reg;

		case(state_reg)

            STATE_IDLE: begin
				if ( req0_val && req0_domain == req_domain )	
                    state_next = STATE_REQ0;
                else if ( req1_val && req1_domain == req_domain ) 
                    state_next = STATE_REQ1;
            end

            STATE_REQ0:
                state_next = STATE_WAIT0;
            
            STATE_REQ1:
                state_next = STATE_WAIT1;

			STATE_WAIT0:
				if ( resp_val && req_domain == resp_domain ) 
                    state_next = STATE_RESP0;

            STATE_WAIT1:
                if ( resp_val && req_domain == resp_domain )
                    state_next = STATE_RESP1;

			STATE_RESP0:
				state_next = STATE_IDLE;

            STATE_RESP1:
                state_next = STATE_IDLE;

		endcase
	end

	// register corresponding data for the future usage
	wire			{Ctrl req0_domain} req0_val_reg_out;
	wire			{L}                req0_domain_reg_out;
	wire			{L}                req1_domain_reg_out;
	wire [rqc-1:0]	{Ctrl req0_domain} req0_control_reg_out;
	wire [rqd-1:0]	{Data req0_domain} req0_data_reg_out;
	wire [rqc-1:0]	{Ctrl req1_domain} req1_control_reg_out;
	wire [rqd-1:0]	{Data req1_domain} req1_data_reg_out;
	wire [rsc-1:0]	{Ctrl resp_domain} resp_control_reg_out;
	wire [rsd-1:0]	{Data resp_domain} resp_data_reg_out;
    wire            {Ctrl resp_domain} resp_insecure_reg_out;
	wire			{L}                resp_domain_reg_out;

	vc_EnResetReg_Ctrl#(1)	req0_val_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (req0_domain),
		.en		(req_en),
		.d		(req0_val),
		.q		(req0_val_reg_out)
	);

	vc_EnResetReg_Ctrl#(rqc) req0_control_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (req0_domain),
		.en		(req_en),
		.d		(req0_control),
		.q		(req0_control_reg_out)
	);

	vc_EnResetReg#(rqd)	req0_data_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (req0_domain),
		.en		(req_en),
		.d		(req0_data),
		.q		(req0_data_reg_out)
	);

	vc_EnResetReg_Ctrl#(1)	req0_domain_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (0),
		.en		(req_en),
		.d		(req0_domain),
		.q		(req0_domain_reg_out)
	);

	vc_EnResetReg_Ctrl#(1)	req1_domain_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (0),
		.en		(req_en),
		.d		(req1_domain),
		.q		(req1_domain_reg_out)
	);

	vc_EnResetReg_Ctrl#(rqc)	req1_control_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (req1_domain),
		.en		(req_en),
		.d		(req1_control),
		.q		(req1_control_reg_out)
	);

	vc_EnResetReg#(rqd) req1_data_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (req1_domain),
		.en		(req_en),
		.d		(req1_data),
		.q		(req1_data_reg_out)
	);

	vc_EnResetReg_Ctrl#(rsc) resp_control_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (resp_domain),
		.en		(resp_en),
		.d		(resp_control),
		.q		(resp_control_reg_out)
	);

	vc_EnResetReg#(rsd) resp_data_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (resp_domain),
		.en		(resp_en),
		.d		(resp_data),
		.q		(resp_data_reg_out)
	);

	vc_EnResetReg_Ctrl#(1) resp_insecure_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (resp_domain),
		.en		(resp_en),
		.d		(resp_insecure),
		.q		(resp_insecure_reg_out)
	);

	vc_EnResetReg_Ctrl#(1) resp_domain_reg
	(
		.clk	(clk),
		.reset	(reset),
        .domain (0),
		.en		(resp_en),
		.d		(resp_domain),
		.q		(resp_domain_reg_out)
	);


	// State Outputs
	reg	{Ctrl req_domain}  req_en;
	reg {Ctrl resp_domain} resp_en;

	always @(*) begin
		
		req_en		= 1'b0;
		resp_en		= 1'b0;
		req0_rdy	= 1'b0;
		req1_rdy	= 1'b0;
		req_val		= 1'b0;
		req_control	= 'hx;
		req_data	= 'hx;
		//req_domain	= 1'b0;
		resp_rdy	= 1'b1;
		resp0_val	= 1'b0;
		resp1_val	= 1'b0;
		
        resp0_domain  = resp_domain_reg_out;
		resp1_domain  = resp_domain_reg_out;

		case(state_reg)

			STATE_IDLE: 
				req_en = 1'b1;
			
			STATE_REQ0: begin
                if ( req_domain == req0_domain ) begin
				    req_val		= 1'b1;
				    req0_rdy	= 1'b1;
				    req_control = req0_control_reg_out;
				    req_data	= req0_data_reg_out;
				    req_domain	= req0_domain_reg_out;
                end
			end

            STATE_REQ1: begin
                if ( req_domain == req1_domain) begin
				    req_val		= 1'b1;
				    req1_rdy	= 1'b1;
				    req_control	= req1_control_reg_out;
				    req_data	= req1_data_reg_out;
				    req_domain  = req1_domain_reg_out;
                end
			end

			STATE_WAIT0: 
                if ( resp_domain == req_domain )
				    resp_en = 1'b1;
			
			STATE_WAIT1: 
                if ( resp_domain == req_domain )
				    resp_en = 1'b1;

			STATE_RESP0: begin
				if ( req_domain == resp_domain && resp0_domain == resp_domain ) begin
					resp0_val	  = 1'b1;
					resp_rdy	  = 1'b1;
					resp0_control = resp_control_reg_out;
					resp0_data	  = resp_data_reg_out;
                    resp0_insecure= resp_insecure;
			    end
            end

            STATE_RESP1: begin
			    if ( req_domain == resp_domain && resp1_domain == resp_domain ) begin
					resp1_val	  = 1'b1;
					resp_rdy	  = 1'b1;
					resp1_control = resp_control_reg_out;
					resp1_data	  = resp_data_reg_out;
                    resp1_insecure= resp_insecure;
				end
			end

		endcase	
	end
	
endmodule

`endif /* PLAB5_MCORE_MEM_ARBITER_V */
