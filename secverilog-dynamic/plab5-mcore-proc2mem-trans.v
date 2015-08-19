//========================================================================
// translate the processor information to memory side 
//========================================================================

`ifndef PLAB5_MCORE_PROC2MEM_TRANS_V
`define PLAB5_MCORE_PROC2MEM_TRANS_V

`include "vc-mem-msgs.v"

module plab5_mcore_proc2mem_trans
#(
	

	parameter opaque_nbits		= 8,
	parameter addr_nbits		= 32,
	parameter proc_data_nbits	= 32,
	parameter mem_data_nbits	= 128,

	// short name for params
	parameter o		= opaque_nbits,
	parameter a		= addr_nbits,
	parameter pd	= proc_data_nbits,
	parameter md	= mem_data_nbits,

	parameter proc_reqmsg_nbits	= `VC_MEM_REQ_MSG_NBITS(o,a,pd),
	parameter mem_reqmsg_nbits	= `VC_MEM_REQ_MSG_NBITS(o,a,md),
	parameter proc_respmsg_nbits= `VC_MEM_RESP_MSG_NBITS(o,pd),
	parameter mem_respmsg_nbits	= `VC_MEM_RESP_MSG_NBITS(o,md)
)
(
    // input security domain
    input   {L} req_domain,
    input   {L} resp_domain,
	// input request message from process side
	input	[proc_reqmsg_nbits-1:0]	{Domain req_domain} proc_req_msg,
	// input respond message from memory side
	input	[mem_respmsg_nbits-1:0]	{Domain resp_domain} mem_resp_msg,

	// output request message to memory
	output	[mem_reqmsg_nbits-1:0]	{Domain req_domain} mem_req_msg,
	// output response message to memory
	output	[proc_respmsg_nbits-1:0]{Domain resp_domain} proc_resp_msg
);

	// translate request message
	assign mem_req_msg[`VC_MEM_REQ_MSG_TYPE_FIELD(o,a,md)]
			= proc_req_msg[`VC_MEM_REQ_MSG_TYPE_FIELD(o,a,pd)];
	
	assign mem_req_msg[`VC_MEM_REQ_MSG_OPAQUE_FIELD(o,a,md)]
			= proc_req_msg[`VC_MEM_REQ_MSG_OPAQUE_FIELD(o,a,pd)];

	assign mem_req_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(o,a,md)]
			= proc_req_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(o,a,pd)];
	
	assign mem_req_msg[`VC_MEM_REQ_MSG_LEN_FIELD(o,a,md)]
			= proc_req_msg[`VC_MEM_REQ_MSG_LEN_FIELD(o,a,pd)];
	
	assign mem_req_msg[`VC_MEM_REQ_MSG_DATA_FIELD(o,a,md)] = 
			(proc_req_msg[`VC_MEM_REQ_MSG_TYPE_FIELD(o,a,pd)] == 3'd0) ? 
			128'd0 : {96'hx, proc_req_msg[`VC_MEM_REQ_MSG_DATA_FIELD(o,a,pd)]};

	// translate reponse message
	assign proc_resp_msg[`VC_MEM_RESP_MSG_TYPE_FIELD(o,pd)]
			= mem_resp_msg[`VC_MEM_RESP_MSG_TYPE_FIELD(o,md)];
	
	assign proc_resp_msg[`VC_MEM_RESP_MSG_OPAQUE_FIELD(o,pd)]
			= mem_resp_msg[`VC_MEM_RESP_MSG_OPAQUE_FIELD(o,md)];
	
	assign proc_resp_msg[`VC_MEM_RESP_MSG_LEN_FIELD(o,pd)] = 0;

	assign proc_resp_msg[`VC_MEM_RESP_MSG_DATA_FIELD(o,pd)]
			= mem_resp_msg[pd-1:0];

endmodule
`endif /* PLAB5_MCORE_PROC2MEM_TRANS_V */

	

