//========================================================================
// Memory Access Control Module 
//========================================================================

`ifndef PLAB5_MCORE_MEM_ACC_V
`define PLAB5_MCORE_MEM_ACC_V

`include "vc-mem-msgs.v"

module plab5_mcore_mem_acc
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
	input						{L} clk,

	// requests security level
	input						{L} req_sec_level,
	// responses from memory's security level
	output	reg					{L} resp_sec_level,
	
	// Module's security level
	input						{L} mem_sec_level,

	// Inputs of requests
	input	[req_cnbits-1:0]	{Control req_sec_level} net_req_control,
	input	[req_dnbits-1:0]	{Domain  req_sec_level} net_req_data,
	input						{Control req_sec_level} net_req_val,
	output						{Control req_sec_level} net_req_rdy,

	// outputs to the memory side
	output	reg [req_cnbits-1:0]	{Control mem_sec_level} mem_req_control,
	output	reg [req_dnbits-1:0]	{Domain  mem_sec_level} mem_req_data,
	output	reg 					{Control mem_sec_level} mem_req_val,
	input							{Control mem_sec_level} mem_req_rdy,

	// Output of responses
	output	reg [resp_cnbits-1:0]	{Control resp_sec_level} net_resp_control,
	output	reg [resp_dnbits-1:0]	{Domain  resp_sec_level} net_resp_data,
	output	reg 					{Control resp_sec_level} net_resp_val,
	input						    {Control resp_sec_level} net_resp_rdy,

	// Inputs from the memory side
	input	[resp_cnbits-1:0]	{Control mem_sec_level} mem_resp_control,
	input	[resp_dnbits-1:0]	{Domain  mem_sec_level} mem_resp_data,
	input						{Control mem_sec_level} mem_resp_val,
	output						{Control mem_sec_level} mem_resp_rdy
);
	
	// always pass rdy signals between network and memory
	// assign mem_resp_rdy	= net_resp_rdy;

	// since if request is not secure, the requests will be not
	// passed to the memory. Therefore, it indicates that each
	// response correspond to a secure request, and we don't need
	// to check whether the reponses is secure or not, and directly
	// pass response signal to network side

    reg {L} req_sec_level_pre;
    reg [resp_cnbits-1:0]   {Control resp_sec_level} net_resp_control_dump;
    always @(posedge clk) begin
        req_sec_level_pre <= req_sec_level;
        net_resp_control_dump <= {net_req_control[45:42], net_req_control[41:34], net_req_control[1:0]};
        resp_sec_level <= req_sec_level_pre;
    end

	always @(*) begin
	
		// if req security level is noise, we wil view this as
		// insecure, and set data field to be X and valid signal
		// to be low

		if ( req_sec_level == 1'b0 && mem_sec_level == 1'b1 ) begin
			mem_req_control = 'hx;
			mem_req_data	= 0;
			mem_req_val		= 1'b1;
            net_req_rdy     = 1'b1;

			if ( req_sec_level < mem_sec_level ) begin
				$display("Detected Insecure Memory Access!");
			end
		end

		// if req security level is higher than memory security
		// level, the operation is allowed, so we pass the data
		// field and enable the valid signal

		else if ( req_sec_level == mem_sec_level ) begin
			mem_req_control = net_req_control;
			mem_req_data	= net_req_data;
			mem_req_val		= net_req_val;
            net_req_rdy     = mem_req_rdy;
		end

        else if ( req_sec_level === 1'b1 && mem_sec_level === 1'b0 ) begin
            mem_req_control = net_req_control;
            mem_req_data    = net_req_data;
            mem_req_val     = net_req_val;
            net_req_rdy    = mem_req_rdy;
        end
		
	end

    always @(*) begin
        
        if ( resp_sec_level === 1'bx )
            net_resp_val = 1'b0;

        if ( resp_sec_level == mem_sec_level ) begin
            net_resp_control = mem_resp_control;
            net_resp_data    = mem_resp_data;
            net_resp_val     = mem_resp_val;
            mem_resp_rdy     = net_resp_rdy;
        end

        if ( resp_sec_level == 1'b1 && mem_sec_level == 1'b0 ) begin
            net_resp_control = mem_resp_control;
            net_resp_data    = mem_resp_data;
            net_resp_val     = mem_resp_val;
            mem_resp_rdy     = net_resp_rdy;
        end

        if ( resp_sec_level == 1'b0 &&  mem_sec_level == 1'b1 ) begin
            net_resp_control = net_resp_control_dump;
            net_resp_data    = 'hx;
            net_resp_val     = 1'b1;
        end
    end

endmodule
`endif /*PLAB5_MCORE_MEM_ACC_V*/
