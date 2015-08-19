`ifndef PLAB5_MCORE_MEM_RESPCMSG_PACK_V
`define PLAB5_MCORE_MEM_RESPCMSG_PACK_V

`include "vc-mem-msgs.v"

// Pack memory responese control signals
module plab5_mcore_MemRespCMsgPack
#(
	parameter	p_opaque_nbits	= 8,
	parameter	p_data_nbits	= 32,

	// total length for the whole control message
	parameter	o = p_opaque_nbits,
	parameter	d = p_data_nbits,
	parameter	l = `VC_MEM_RESP_MSG_LEN_NBITS(o,d),
	parameter	c = `VC_MEM_RESP_MSG_NBITS(o,d) - d
	
)
(
    // input domain
    input                                                domain,

	// Input signals
	
	input	[`VC_MEM_RESP_MSG_TYPE_NBITS(o,d)-1:0]			type,
	input	[`VC_MEM_RESP_MSG_OPAQUE_NBITS(o,d)-1:0]	opaque,
	input	[`VC_MEM_RESP_MSG_LEN_NBITS(o,d)-1:0]			len,

	// output messgae
	
	output	[c-1:0]											msg
);

	assign	msg[c - 1 : l + o ]	= type;
	assign  msg[l + o - 1: l]	= opaque;
	assign	msg[l - 1 : 0]		= len;

endmodule

`endif /* PLAB5_MCORE_MEM_RESPCMSG_PACK_V */
