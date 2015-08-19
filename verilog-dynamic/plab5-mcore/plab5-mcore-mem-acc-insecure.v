//========================================================================
// Memory Access Control Module (Insecure version) 
//========================================================================

`ifndef PLAB5_MCORE_MEM_ACC_INSECURE_V
`define PLAB5_MCORE_MEM_ACC_INSECURE_V

`include "vc-mem-msgs.v"

module plab5_mcore_mem_acc_insecure
#(
	parameter p_opaque_nbits = 8,	// mem message opaque field num bits
	parameter p_addr_nbits	 = 32,	// mem message address num bits
	parameter p_data_nbits	 = 32,	// mem message data num bits

	// Shorter names for message type, not to be set from outside the module
	parameter o = p_opaque_nbits,
	parameter a = p_addr_nbits,
	parameter d = p_data_nbits,

	// Local constants not meant to be set from ouside the module
	parameter req_nbits		= `VC_MEM_REQ_MSG_NBITS(o,a,d),
	parameter req_cnbits	= req_nbits - p_data_nbits,
	parameter req_dnbits	= p_data_nbits,
	parameter resp_nbits	= `VC_MEM_RESP_MSG_NBITS(o,d),
	parameter resp_cnbits	= resp_nbits - p_data_nbits,
	parameter resp_dnbits	= p_data_nbits
)
(
	input						clk,

	// requests security level
	input						req_sec_level,
	// responses from memory's security level
	output	reg					resp_sec_level,
	
	// Module's security level
	input						mem_sec_level,

	// Inputs of requests
	input	[req_cnbits-1:0]	net_req_control,
	input	[req_dnbits-1:0]	net_req_data,
	input						net_req_val,
	output						net_req_rdy,

	// outputs to the memory side
	output	reg [req_cnbits-1:0]	mem_req_control,
	output	reg [req_dnbits-1:0]	mem_req_data,
	output	reg 					mem_req_val,
	input							mem_req_rdy,

	// Output of responses
	output	reg [resp_cnbits-1:0]	net_resp_control,
	output	reg [resp_dnbits-1:0]	net_resp_data,
	output	reg 					net_resp_val,
	input						    net_resp_rdy,

	// Inputs from the memory side
	input	[resp_cnbits-1:0]	mem_resp_control,
	input	[resp_dnbits-1:0]	mem_resp_data,
	input						mem_resp_val,
	output						mem_resp_rdy
);
	
	// always pass rdy signals between network and memory
	assign net_req_rdy	= mem_req_rdy;
	assign mem_resp_rdy	= net_resp_rdy;

	// since if request is not secure, the requests will be not
	// passed to the memory. Therefore, it indicates that each
	// response correspond to a secure request, and we don't need
	// to check whether the reponses is secure or not, and directly
	// pass response signal to network side

	reg	req_sec_level_pre;
	reg [resp_cnbits-1:0]	net_resp_control_dump;
	always @(posedge clk) begin
		req_sec_level_pre <= req_sec_level;
		net_resp_control_dump <= {net_req_control[45:42],net_req_control[41:34],net_req_control[1:0]};
	end

	always @(*) begin
	
		if ( req_sec_level_pre === 1'bx )
			net_resp_val = 1'b0;

		else if ( req_sec_level_pre >= mem_sec_level ) begin
			net_resp_control = mem_resp_control;
			net_resp_data	 = mem_resp_data;
			net_resp_val	 = mem_resp_val;
		end

		else if ( req_sec_level_pre < mem_sec_level ) begin
			net_resp_control = mem_resp_control;
			net_resp_data	 = mem_resp_data;
			net_resp_val	 = mem_resp_val;
		end
	end

	always @(*) begin

		if ( req_sec_level === 1'bx )
			mem_req_val = 1'b0;

		else if ( req_sec_level < mem_sec_level ) begin
			mem_req_control = net_req_control;
			mem_req_data	= net_req_data;
			mem_req_val		= net_req_val;

			$display("Detected Insecure Memory Access!");
		end

		else if ( req_sec_level >= mem_sec_level ) begin
			mem_req_control = net_req_control;
			mem_req_data	= net_req_data;
			mem_req_val		= net_req_val;
		end

		resp_sec_level = 1'b0;
	end

endmodule
`endif /*PLAB5_MCORE_MEM_ACC_INSECURE_V*/

