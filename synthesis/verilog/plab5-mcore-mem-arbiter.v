//========================================================================
// Arbiter for main memory accesses
//========================================================================

`ifndef PLAB5_MCORE_MEM_ARBITER_V
`define PLAB5_MCORE_MEM_ARBITER_V
`include "vc-mem-msgs.v"
`include "vc-regs.v"

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
	input					clk,
	input					reset,
		
	input					req0_val,
	output reg				req0_rdy,
	input  [rqc-1:0]		req0_control,
	input  [rqd-1:0]		req0_data,
	input					req0_domain,

	input					req1_val,
	output reg				req1_rdy,
	input  [rqc-1:0]		req1_control,
	input  [rqd-1:0]		req1_data,
	input					req1_domain,

	output reg				req_val,
	input					req_rdy,
	output reg [rqc-1:0]	req_control,
	output reg [rqd-1:0]	req_data,
	output reg				req_domain,

	input					resp_val,
	output reg				resp_rdy,
	input  [rsc-1:0]		resp_control,
	input  [rsd-1:0]		resp_data,
	input					resp_insecure,
	input					resp_domain,

	output reg				resp0_val,
	input					resp0_rdy,
	output reg [rsc-1:0]	resp0_control,
	output reg [rsd-1:0]	resp0_data,
	output reg				resp0_insecure,
	output reg				resp0_domain,

	output reg				resp1_val,
	input					resp1_rdy,
	output reg [rsc-1:0]	resp1_control,
	output reg [rsd-1:0]	resp1_data,
	output reg				resp1_insecure,
	output reg				resp1_domain
	
);
	// Macro for States
	localparam	STATE_IDLE	= 3'd0;
	localparam  STATE_ARB	= 3'd1;
	localparam	STATE_REQ0	= 3'd2;
	localparam  STATE_REQ1	= 3'd3;
	localparam	STATE_WAIT0 = 3'd4;
	localparam	STATE_WAIT1 = 3'd5;
	localparam	STATE_RESP0 = 3'd6;
	localparam	STATE_RESP1	= 3'd7;
	
	// State transitions
	reg	[2:0]	state_reg;
	reg	[2:0]	state_next;

	always @(posedge clk) begin
		if ( reset )
			state_reg <= STATE_IDLE;
		else
			state_reg <= state_next;
	end

	always @(*) begin
		state_next = state_reg;

		case(state_reg)

			STATE_IDLE:
				if ( req0_val )	state_next = STATE_REQ0;
		   else if ( req1_val ) state_next = STATE_REQ1;

			STATE_REQ0:
				state_next = STATE_WAIT0;

			STATE_REQ1:
				state_next = STATE_WAIT1;

			STATE_WAIT0:
				if ( resp_val ) state_next = STATE_RESP0;

			STATE_WAIT1:
				if ( resp_val ) state_next = STATE_RESP1;

			STATE_RESP0:
				state_next = STATE_IDLE;

			STATE_RESP1:
				state_next = STATE_IDLE;	

		endcase
	end

	// register corresponding data for the future usage
	wire			req0_val_reg_out;
	wire			req0_domain_reg_out;
	wire			req1_domain_reg_out;
	wire [rqc-1:0]	req0_control_reg_out;
	wire [rqd-1:0]	req0_data_reg_out;
	wire [rqc-1:0]	req1_control_reg_out;
	wire [rqd-1:0]	req1_data_reg_out;
	wire [rsc-1:0]	resp_control_reg_out;
	wire [rsd-1:0]	resp_data_reg_out;
	wire			resp_insecure_reg_out;
	wire			resp_domain_reg_out;

	reg resp_sel;
	reg	req_en;
	reg resp_en;

	vc_EnResetReg#(1)	req0_val_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(req_en),
		.d		(req0_val),
		.q		(req0_val_reg_out)
	);

	vc_EnResetReg#(rqc) req0_control_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(req_en),
		.d		(req0_control),
		.q		(req0_control_reg_out)
	);

	vc_EnResetReg#(rqd)	req0_data_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(req_en),
		.d		(req0_data),
		.q		(req0_data_reg_out)
	);

	vc_EnResetReg#(1)	req0_domain_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(req_en),
		.d		(req0_domain),
		.q		(req0_domain_reg_out)
	);

	vc_EnResetReg#(1)	req1_domain_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(req_en),
		.d		(req1_domain),
		.q		(req1_domain_reg_out)
	);

	vc_EnResetReg#(rqc)	req1_control_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(req_en),
		.d		(req1_control),
		.q		(req1_control_reg_out)
	);

	vc_EnResetReg#(rqd) req1_data_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(req_en),
		.d		(req1_data),
		.q		(req1_data_reg_out)
	);

	vc_EnResetReg#(rsc) resp_control_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(resp_en),
		.d		(resp_control),
		.q		(resp_control_reg_out)
	);

	vc_EnResetReg#(rsd) resp_data_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(resp_en),
		.d		(resp_data),
		.q		(resp_data_reg_out)
	);

	vc_EnResetReg#(1) resp_insecure_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(resp_en),
		.d		(resp_insecure),
		.q		(resp_insecure_reg_out)
	);

	vc_EnResetReg#(1) resp_domain_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(resp_en),
		.d		(resp_domain),
		.q		(resp_domain_reg_out)
	);


	// State Outputs

	always @(*) begin
		
		req_en		= 1'b0;
		resp_en		= 1'b0;
		req0_rdy	= 1'b0;
		req1_rdy	= 1'b0;
		req_val		= 1'b0;
		req_control	= 'hx;
		req_data	= 'hx;
		req_domain	= 1'bx;
		resp_rdy	= 1'b1;
		resp0_val	= 1'b0;
		resp1_val	= 1'b0;
		
		case(state_reg)

			STATE_IDLE: 
				req_en = 1'b1;
			
			STATE_REQ0: begin
				req_val		= 1'b1;
				req0_rdy	= 1'b1;
				req_control = req0_control_reg_out;
				req_data	= req0_data_reg_out;
				req_domain	= req0_domain_reg_out;
				resp_sel	= 1'b0;
			end

			STATE_REQ1: begin
				req_val		= 1'b1;
				req1_rdy	= 1'b1;
				req_control	= req1_control_reg_out;
				req_data	= req1_data_reg_out;
				req_domain  = req1_domain_reg_out;
				resp_sel	= 1'b1;
			end

			STATE_WAIT0: 
				resp_en = 1'b1;

			STATE_WAIT1:
				resp_en = 1'b1;
			
			STATE_RESP0: begin
				resp0_val	  = 1'b1;
				resp_rdy	  = 1'b1;
				resp0_control = resp_control_reg_out;
				resp0_data	  = resp_data_reg_out;
				resp0_insecure= resp_insecure_reg_out;
				resp0_domain  = resp_domain_reg_out;
			end

			STATE_RESP1: begin
				resp1_val	  = 1'b1;
				resp_rdy	  = 1'b1;
				resp1_control = resp_control_reg_out;
				resp1_data	  = resp_data_reg_out;
				resp1_insecure= resp_insecure_reg_out;
				resp1_domain  = resp_domain_reg_out;
			end

		endcase	
	end
	
endmodule

`endif /* PLAB5_MCORE_MEM_ARBITER_V */
