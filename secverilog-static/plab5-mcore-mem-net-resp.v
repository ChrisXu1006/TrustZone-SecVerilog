//========================================================================
// Memory-Network message adapters
//========================================================================

`ifndef PLAB5_MCORE_MEM_NET_RESP_V
`define PLAB5_MCORE_MEM_NET_RESP_V

`include "plab5-mcore-memrespcmsgpack.v"
`include "vc-net-msgsunpack.v"

module plab5_mcore_MemRespMsgToNetMsg
#(

  // the source index where this memory response is originating (bank id)

  parameter p_net_src = 0,

  // number of sources and destinations (cores and banks)

  parameter p_num_ports = 4,

  // memory-related parameters

  parameter p_mem_opaque_nbits = 8,
  parameter p_mem_data_nbits = 32,

  // network-related parameters

  parameter p_net_opaque_nbits = 4,
  parameter p_net_srcdest_nbits = 3,

  // number of words in a cacheline

  parameter p_cacheline_nwords = 4,

  // remaining parameters are not meant to be set from outside

  // shorter names for memory parameters

  parameter mo = p_mem_opaque_nbits,
  parameter md = p_mem_data_nbits,

  // network payload is the memory message

  parameter c_mem_msg_nbits     = `VC_MEM_RESP_MSG_NBITS(mo,md),
  parameter c_mem_msg_cnbits	= `VC_MEM_RESP_MSG_NBITS(mo,md) - md,
  parameter c_mem_msg_dnbits	= md,
  parameter c_net_payload_nbits = `VC_MEM_RESP_MSG_NBITS(mo,md),
  parameter c_net_payload_cnbits= `VC_MEM_RESP_MSG_NBITS(mo,md) - md,
  parameter c_net_payload_dnbits= md,

  // shorter names for network parameters

  parameter np = c_net_payload_nbits,
  parameter npc= c_net_payload_cnbits,
  parameter npd= c_net_payload_dnbits,
  parameter no = p_net_opaque_nbits,
  parameter ns = p_net_srcdest_nbits,

  parameter c_net_msg_nbits = `VC_NET_MSG_NBITS(np,no,ns),
  parameter c_net_msg_cnbits= `VC_NET_MSG_NBITS(npc,no,ns),
  parameter c_net_msg_dnbits= npd
)
(
  input                         {L}           mode,
  input                         {L}           domain,
  input  [c_mem_msg_cnbits-1:0] {Ctrl domain} mem_msg_control,
  input	 [c_mem_msg_dnbits-1:0]	{Data domain} mem_msg_data,
  input                         {Ctrl domain} mem_msg_fail,

  output [c_net_msg_cnbits-1:0] {Ctrl domain} net_msg_control,
  output [c_net_msg_dnbits-1:0]	{Data domain} net_msg_data

);

  // extract the opaque field from memory message

  wire [c_mem_msg_nbits-1:0]    {Data domain}  mem_msg = {mem_msg_control, mem_msg_data};
  wire [p_mem_opaque_nbits-1:0] {Ctrl domain}  mem_msg_opaque;
  wire [p_net_srcdest_nbits-1:0]{Ctrl domain}  net_dest;

  assign mem_msg_opaque = mem_msg_control[`VC_MEM_RESP_MSG_OPAQUE_FIELD(mo,md)];
  assign net_dest = mem_msg_opaque[mo-1 -: ns];
  //assign net_dest = (mode === 1'b0 ) mem_msg_opaque[mo-1 -: ns] : 1'b0;

  // re-pack the memory message without the destination opaque field

  wire [`VC_MEM_RESP_MSG_NBITS(mo,md)-1:0] {L} net_payload;
  wire [c_net_payload_cnbits-1:0]		   {Ctrl domain} net_payload_control;
  wire [c_net_payload_dnbits-1:0]		   {Data domain} net_payload_data;

  plab5_mcore_MemRespCMsgPack #(mo,md) mem_pack
  (
    .type   (mem_msg_control[`VC_MEM_RESP_MSG_TYPE_FIELD(mo,md)]),
    .opaque (mem_msg_opaque),
    .len    (mem_msg_control[`VC_MEM_RESP_MSG_LEN_FIELD(mo,md)]),

    .msg    (net_payload_control)
  );

  assign net_payload_data = mem_msg[`VC_MEM_RESP_MSG_DATA_FIELD(mo,md)]; 
  // then we pack the memory message as a network message

  vc_NetMsgPack
  #(
    .p_payload_nbits  (c_net_payload_cnbits+2),
    .p_opaque_nbits   (p_net_opaque_nbits),
    .p_srcdest_nbits  (p_net_srcdest_nbits)
  )
  net_control_pack
  (
    .domain   (domain),
    .dest     (net_dest),
    .src      (p_net_src[ns-1:0]),
    .opaque   (0),
    .payload  ({domain, mem_msg_fail,net_payload_control}),

    .msg      (net_msg_control)
  );

  assign net_msg_data = net_payload_data;

endmodule

`endif /* PLAB5_MCORE_MEM_NET_RESP_V */
