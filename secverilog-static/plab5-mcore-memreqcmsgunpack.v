`ifndef PLAB5_MCORE_MEM_REQCMSG_UNPACK_V
`define PLAB5_MCORE_MEM_REQCMSG_UNPACK_V

`include "vc-mem-msgs.v"

// Unpack memory request control signals
module plab5_mcore_MemReqCMsgUnpack
#(
	parameter	p_opaque_nbits	= 8,
	parameter	p_addr_nbits	= 32,
	parameter	p_data_nbits	= 32,

	// total length for the whole control message
	parameter	c = `VC_MEM_REQ_MSG_NBITS(o,a,d) - d,
	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	l = `VC_MEM_REQ_MSG_LEN_NBITS(o,a,d),
	parameter	d = p_data_nbits
)
(
	// Input bits

    input                                               {L} domain,

	input	[c-1:0]										{Ctrl domain}	msg,
	
	// Output message
	
	output	[`VC_MEM_REQ_MSG_TYPE_NBITS(o,a,d)-1:0]		{Ctrl domain}	type,
	output	[`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,a,d)-1:0]	{Ctrl domain}	opaque,
	output	[`VC_MEM_REQ_MSG_ADDR_NBITS(o,a,d)-1:0]		{Ctrl domain}	addr,
	output	[`VC_MEM_REQ_MSG_LEN_NBITS(o,a,d)-1:0]		{Ctrl domain}	len
);
	
	assign type		= msg[c - 1 : l + a + o];
    assign opaque	= msg[l + a + o - 1 : l + a]; 
	assign addr		= msg[l + a - 1 : l];
	assign len		= msg[l - 1 : 0];

endmodule

`endif /* PLAB5_MCORE_MEM_MSGS_V */
