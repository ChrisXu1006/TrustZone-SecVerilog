//========================================================================
// vc-net-msgs : Network Messages
//========================================================================
// Payload field width (payload_nbits), opaque filed width (opaque_nbits)
// source and destination field widths (p_srcdest_nbits) are adjustable
// via parameterized macro definitions.
//
// Example message format for payload_nbits = 32, srcdest_nbits = 3,
// opaque_nbits = 4
//
// 41   39 38  36 35    32 31                            0
// +------+------+--------+-------------------------------+
// | dest | src  | opaque | payload                       |
// +------+------+--------+-------------------------------+
//

`ifndef VC_NET_MSGS_UNPACK_V
`define VC_NET_MSGS_UNPACK_V

//-------------------------------------------------------------------------
// Message defines
//-------------------------------------------------------------------------

// Size of message

`define VC_NET_MSG_NBITS(p_,o_,s_)       p_ + o_ + ( 2 * s_ )

// Payload field

`define VC_NET_MSG_PAYLOAD_NBITS(p_,o_,s_)  p_

`define VC_NET_MSG_PAYLOAD_MSB(p_,o_,s_)                                \
  ( `VC_NET_MSG_PAYLOAD_NBITS(p_,o_,s_) - 1 )

`define VC_NET_MSG_PAYLOAD_FIELD(p_,o_,s_)                              \
  ( `VC_NET_MSG_PAYLOAD_MSB(p_,o_,s_) ) : 0

// Opaque field

`define VC_NET_MSG_OPAQUE_NBITS(p_,o_,s_) o_

`define VC_NET_MSG_OPAQUE_MSB(p_,o_,s_)                                 \
  ( `VC_NET_MSG_PAYLOAD_MSB(p_,o_,s_) +                                 \
  `VC_NET_MSG_OPAQUE_NBITS(p_,o_,s_) )

`define VC_NET_MSG_OPAQUE_FIELD(p_,o_,s_)                               \
  ( `VC_NET_MSG_OPAQUE_MSB(p_,o_,s_) ) :                                \
  ( `VC_NET_MSG_PAYLOAD_MSB(p_,o_,s_) + 1 )

// Source field

`define VC_NET_MSG_SRC_NBITS(p_,o_,s_) s_

`define VC_NET_MSG_SRC_MSB(p_,o_,s_)                                    \
  ( `VC_NET_MSG_OPAQUE_MSB(p_,o_,s_) + `VC_NET_MSG_SRC_NBITS(p_,o_,s_) )

`define VC_NET_MSG_SRC_FIELD(p_,o_,s_)                                  \
  ( `VC_NET_MSG_SRC_MSB(p_,o_,s_) ) :                                   \
  ( `VC_NET_MSG_OPAQUE_MSB(p_,o_,s_) + 1 )

// Destination field

`define VC_NET_MSG_DEST_NBITS(p_,o_,s_) s_

`define VC_NET_MSG_DEST_MSB(p_,o_,s_)                                   \
  ( `VC_NET_MSG_SRC_MSB(p_,o_,s_) + `VC_NET_MSG_DEST_NBITS(p_,o_,s_) )

`define VC_NET_MSG_DEST_FIELD(p_,o_,s_)                                 \
  ( `VC_NET_MSG_DEST_MSB(p_,o_,s_) ) :                                  \
  ( `VC_NET_MSG_SRC_MSB(p_,o_,s_) + 1 )

//-------------------------------------------------------------------------
// Unpack network message
//-------------------------------------------------------------------------

module vc_NetMsgUnpack
#(
  parameter p_payload_nbits = 32,
  parameter p_opaque_nbits  = 4,
  parameter p_srcdest_nbits = 3,

  // Shorter names, not to be set from outside the module
  parameter p = p_payload_nbits,
  parameter o = p_opaque_nbits,
  parameter s = p_srcdest_nbits
)
(

  // Input domain
  input                                 {L} domain,

  // Input message

  input  [`VC_NET_MSG_NBITS(p,o,s)-1:0] {Ctrl domain} msg,

  // Output message

  output [`VC_NET_MSG_DEST_NBITS(p,o,s)-1:0]    {Data domain} dest,
  output [`VC_NET_MSG_SRC_NBITS(p,o,s)-1:0]     {Ctrl domain} src,
  output [`VC_NET_MSG_OPAQUE_NBITS(p,o,s)-1:0]  {Ctrl domain} opaque,
  output [`VC_NET_MSG_PAYLOAD_NBITS(p,o,s)-1:0] {Ctrl domain} payload
);

  assign dest    = msg[`VC_NET_MSG_DEST_FIELD(p,o,s)];
  assign src     = msg[`VC_NET_MSG_SRC_FIELD(p,o,s)];
  assign opaque  = msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)];
  assign payload = msg[`VC_NET_MSG_PAYLOAD_FIELD(p,o,s)];

endmodule

`endif /* VC_NET_MSGS_UNPACK_V */
