`ifndef PLAB5_MCORE_MEM_REQCMSG_PACK_V
`define PLAB5_MCORE_MEM_REQCMSG_PACK_V

`include "vc-mem-msgs.v"

// Pack memory request control signals
module plab5_mcore_MemReqCMsgPack
#(
	parameter	p_opaque_nbits	= 8,
	parameter	p_addr_nbits	= 32,
	parameter	p_data_nbits	= 32,

	// total length for the whole control message
	parameter	o = p_opaque_nbits,
	parameter	a = p_addr_nbits,
	parameter	d = p_data_nbits,
	parameter	l = `VC_MEM_REQ_MSG_LEN_NBITS(o,a,d),
	parameter	c = `VC_MEM_REQ_MSG_NBITS(o,a,d) - d
)
(
    // input domain
    input                                                domain,
	// Input bits
	
	input	[`VC_MEM_REQ_MSG_TYPE_NBITS(o,a,d)-1:0]			type,
	input	[`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,a,d)-1:0]		opaque,
	input	[`VC_MEM_REQ_MSG_ADDR_NBITS(o,a,d)-1:0]			addr,
	input	[`VC_MEM_REQ_MSG_LEN_NBITS(o,a,d)-1:0]			len,

	// output message
	
	output	[c-1:0]											msg
);
	
	assign	msg[c - 1 : l + a + o]		= type;
	assign  msg[l + a + o - 1 : l + a]	= opaque;
	assign  msg[l + a - 1 : l ]			= addr;
	assign  msg[l - 1 : 0]				= len;

endmodule

`endif /* PLAB5_MCORE_MEM_MSGS_V */
