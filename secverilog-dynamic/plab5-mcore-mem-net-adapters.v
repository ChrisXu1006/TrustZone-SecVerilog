//========================================================================
// Memory-Network message adapters
//========================================================================

`ifndef PLAB5_MCORE_MEM_NET_ADAPTERS_V
`define PLAB5_MCORE_MEM_NET_ADAPTERS_V

`include "vc-mem-msgs.v"
`include "vc-net-msgs.v"

module plab5_mcore_MemReqMsgToNetMsg
#(

  // the source index where this memory request is originating (core id)

  parameter p_net_src = 0,

  // number of sources and destinations (cores and banks)

  parameter p_num_ports = 4,

  // memory-related parameters

  parameter p_mem_opaque_nbits = 8,
  parameter p_mem_addr_nbits = 32,
  parameter p_mem_data_nbits = 32,

  // network-related parameters

  parameter p_net_opaque_nbits = 4,
  parameter p_net_srcdest_nbits = 3,

  // number of words in a cacheline

  parameter p_cacheline_nwords = 4,

  // single cache/mem bank mode

  parameter p_single_bank = 0,

  // remaining parameters are not meant to be set from outside

  // shorter names for memory parameters

  parameter mo = p_mem_opaque_nbits,
  parameter ma = p_mem_addr_nbits,
  parameter md = p_mem_data_nbits,

  // network payload is the memory message

  parameter c_mem_msg_nbits = `VC_MEM_REQ_MSG_NBITS(mo,ma,md),
  parameter c_mem_msg_cnbits = `VC_MEM_REQ_MSG_NBITS(mo,ma,md) - md,
  parameter c_mem_msg_dnbits = md,
  parameter c_net_payload_nbits = c_mem_msg_nbits,
  parameter c_net_payload_cnbits= `VC_MEM_REQ_MSG_NBITS(mo,ma,md) - md,
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
  
  // determine the mode for inst/data (0:inst, 1:data)
  input						   {L} mode,
  input                        {L} domain,

  input  [c_mem_msg_nbits-1:0] {Data domain} mem_msg,

  output [c_net_msg_cnbits:0]  {Ctrl domain} net_msg_control,
  output [c_net_msg_dnbits-1:0]{Data domain} net_msg_data

);
  // destination indexing from the memory address

  localparam c_dest_addr_lsb = 2 + $clog2(p_cacheline_nwords);
  localparam c_dest_addr_msb = c_dest_addr_lsb + p_net_srcdest_nbits - 1;

  // extract the address of the memory message to determine network source

  wire [p_mem_addr_nbits-1:0]                  {Ctrl domain} mem_addr;
  wire [`VC_NET_MSG_DEST_NBITS(npc,no,ns)-1:0] {Ctrl domain} net_dest;

  assign mem_addr = mem_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(mo,ma,md)];

  // if there is a single cache/mem bank, destination is 0
  assign net_dest = p_single_bank ? 0 :
		  ( mode ? ( ( mem_addr < 32'hc000 ) ? 0 : 1 ) 
				 : ( ( mem_addr < 32'h4000 ) ? 0 : 1 ) );
                                    //mem_addr[c_dest_addr_msb:c_dest_addr_lsb];

  // we use high bits of the opaque field to put the destination info

  wire [mo-1:0] {Ctrl domain} mem_msg_opaque;
  wire [mo-1:0] {Ctrl domain} mem_src_opaque;

  assign mem_msg_opaque = mem_msg[`VC_MEM_REQ_MSG_OPAQUE_FIELD(mo,ma,md)];

  assign mem_src_opaque = { p_net_src[ns-1:0], mem_msg_opaque[mo-ns-1:0] };

  // we re-pack the memory message with the new opaque field

  wire [`VC_MEM_REQ_MSG_NBITS(mo,ma,md)-1:0] {L} net_payload;
  wire [npc-1:0]							 {Ctrl domain} net_payload_control;
  wire [npd-1:0]							 {Data domain} net_payload_data;

  plab5_mcore_MemReqCMsgPack #(mo,ma,md) mem_control_pack
  (
    .type   (mem_msg[`VC_MEM_REQ_MSG_TYPE_FIELD(mo,ma,md)]),
    .opaque (mem_src_opaque),
    .addr   (mem_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(mo,ma,md)]),
    .len    (mem_msg[`VC_MEM_REQ_MSG_LEN_FIELD(mo,ma,md)]),

    .msg    (net_payload_control)
  );

  assign net_payload_data = mem_msg[`VC_MEM_REQ_MSG_DATA_FIELD(mo,ma,md)];
  
  wire {L} req_domain = ( p_net_src % 2 == 0 ) ? 1'b0 : 1'b1;
  // then we pack the memory message as a network message

  vc_NetMsgPack
  #(
    .p_payload_nbits  (c_net_payload_cnbits+1),
    .p_opaque_nbits   (p_net_opaque_nbits),
    .p_srcdest_nbits  (p_net_srcdest_nbits)
  )
  net_control_pack
  (
    .dest     (net_dest),
    .src      (p_net_src[ns-1:0]),
    .opaque   (0),
    .payload  ({req_domain,net_payload_control}),

    .msg      (net_msg_control)
  );

  assign net_msg_data = net_payload_data;

endmodule


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

  input                         {L} domain,
  input  [c_mem_msg_cnbits-1:0] {Ctrl domain} mem_msg_control,
  input	 [c_mem_msg_dnbits-1:0]	{Data domain} mem_msg_data,

  output [c_net_msg_cnbits-1:0] {Ctrl domain} net_msg_control,
  output [c_net_msg_dnbits-1:0]	{Data domain} net_msg_data

);

  // extract the opaque field from memory message

  wire [c_mem_msg_nbits-1:0]    {Data domain} mem_msg = {mem_msg_control, mem_msg_data};
  wire [p_mem_opaque_nbits-1:0] {Ctrl domain}  mem_msg_opaque;
  wire [p_net_srcdest_nbits-1:0]{Ctrl domain}  net_dest;

  assign mem_msg_opaque = mem_msg[`VC_MEM_RESP_MSG_OPAQUE_FIELD(mo,md)];
  assign net_dest = mem_msg_opaque[mo-1 -: ns];

  // re-pack the memory message without the destination opaque field

  wire [`VC_MEM_RESP_MSG_NBITS(mo,md)-1:0] {Data domain} net_payload;
  wire [c_net_payload_cnbits-1:0]		   {Ctrl domain} net_payload_control;
  wire [c_net_payload_dnbits-1:0]		   {Data domain} net_payload_data;

  plab5_mcore_MemRespCMsgPack #(mo,md) mem_pack
  (
    .type   (mem_msg[`VC_MEM_RESP_MSG_TYPE_FIELD(mo,md)]),
    .opaque (mem_msg_opaque),
    .len    (mem_msg[`VC_MEM_RESP_MSG_LEN_FIELD(mo,md)]),

    .msg    (net_payload_control)
  );

  assign net_payload_data = mem_msg[`VC_MEM_RESP_MSG_DATA_FIELD(mo,md)]; 
  // then we pack the memory message as a network message

  vc_NetMsgPack
  #(
    .p_payload_nbits  (c_net_payload_cnbits),
    .p_opaque_nbits   (p_net_opaque_nbits),
    .p_srcdest_nbits  (p_net_srcdest_nbits)
  )
  net_control_pack
  (
    .dest     (net_dest),
    .src      (p_net_src[ns-1:0]),
    .opaque   (0),
    .payload  (net_payload_control),

    .msg      (net_msg_control)
  );

  assign net_msg_data = net_payload_data;

endmodule


`endif /* PLAB5_MCORE_MEM_NET_ADAPTERS_V */
