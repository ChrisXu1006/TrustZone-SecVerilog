//=========================================================================
// vc-net-msgs Unit Tests
//=========================================================================

`include "vc-net-msgs.v"
`include "vc-test.v"

module top;

  `VC_TEST_SUITE_BEGIN( "vc-net-msgs" )

  //-----------------------------------------------------------------------
  // Test NetMsg with payload = 32b, opaque = 8b, src/dest = 3b
  //-----------------------------------------------------------------------

  localparam c_t1_payload_nbits = 32;
  localparam c_t1_opaque_nbits  = 8;
  localparam c_t1_srcdest_nbits = 3;

  // shorter names

  localparam t1_p = c_t1_payload_nbits;
  localparam t1_o = c_t1_opaque_nbits;
  localparam t1_s = c_t1_srcdest_nbits;

  reg  [`VC_NET_MSG_PAYLOAD_NBITS(t1_p,t1_o,t1_s)-1:0]  t1_pack_payload;
  reg  [`VC_NET_MSG_OPAQUE_NBITS(t1_p,t1_o,t1_s)-1:0]   t1_pack_opaque;
  reg  [`VC_NET_MSG_SRC_NBITS(t1_p,t1_o,t1_s)-1:0]      t1_pack_src;
  reg  [`VC_NET_MSG_DEST_NBITS(t1_p,t1_o,t1_s)-1:0]     t1_pack_dest;
  wire [`VC_NET_MSG_NBITS(t1_p,t1_o,t1_s)-1:0]          t1_pack_msg;

  vc_NetMsgPack#(t1_p,t1_o,t1_s) t1_pack
  (
    .payload    (t1_pack_payload),
    .opaque     (t1_pack_opaque),
    .src        (t1_pack_src),
    .dest       (t1_pack_dest),
    .msg        (t1_pack_msg)
  );

  wire [`VC_NET_MSG_PAYLOAD_NBITS(t1_p,t1_o,t1_s)-1:0]  t1_unpack_payload;
  wire [`VC_NET_MSG_OPAQUE_NBITS(t1_p,t1_o,t1_s)-1:0]   t1_unpack_opaque;
  wire [`VC_NET_MSG_SRC_NBITS(t1_p,t1_o,t1_s)-1:0]      t1_unpack_src;
  wire [`VC_NET_MSG_DEST_NBITS(t1_p,t1_o,t1_s)-1:0]     t1_unpack_dest;

  vc_NetMsgUnpack#(t1_p,t1_o,t1_s) t1_unpack
  (
    .msg        (t1_pack_msg),
    .payload    (t1_unpack_payload),
    .opaque     (t1_unpack_opaque),
    .src        (t1_unpack_src),
    .dest       (t1_unpack_dest)
  );

  reg t1_reset = 1;
  reg t1_val;

  vc_NetMsgTrace#(t1_p,t1_o,t1_s) t1_trace
  (
    .clk    (clk),
    .reset  (t1_reset),
    .val    (t1_val),
    .rdy    (1),
    .msg    (t1_pack_msg)
  );

  // Helper task

  task t1
  (
    input                                                 val,
    input [`VC_NET_MSG_DEST_NBITS(t1_p,t1_o,t1_s)-1:0]    dest,
    input [`VC_NET_MSG_SRC_NBITS(t1_p,t1_o,t1_s)-1:0]     src,
    input [`VC_NET_MSG_OPAQUE_NBITS(t1_p,t1_o,t1_s)-1:0]  opaque,
    input [`VC_NET_MSG_PAYLOAD_NBITS(t1_p,t1_o,t1_s)-1:0] payload
  );
  begin
    t1_val          = val;
    t1_pack_dest    = dest;
    t1_pack_src     = src;
    t1_pack_opaque  = opaque;
    t1_pack_payload = payload;
    #1;
    t1_trace.trace_display();
    `VC_TEST_NET( t1_unpack_dest   , dest    );
    `VC_TEST_NET( t1_unpack_src    , src     );
    `VC_TEST_NET( t1_unpack_opaque , opaque  );
    `VC_TEST_NET( t1_unpack_payload, payload );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "payload = 32b, opaque = 8b, src/dest = 3b" )
  begin
    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b1;

    t1( 0, 3'h0, 3'h0, 8'h00, 32'h00000000 );
    t1( 1, 3'h4, 3'h1, 8'h01, 32'h00000000 );
    t1( 1, 3'h2, 3'h2, 8'h05, 32'h00000000 );
    t1( 1, 3'h1, 3'h6, 8'h33, 32'h00000000 );
    t1( 1, 3'h5, 3'h7, 8'h02, 32'ha0a0a0a0 );
    t1( 1, 3'h6, 3'h5, 8'h50, 32'hc2c2c2c2 );
    t1( 1, 3'h7, 3'h4, 8'h90, 32'hdededede );
    t1( 1, 3'h3, 3'h3, 8'h00, 32'h12345678 );
  end
  `VC_TEST_CASE_END

  //-----------------------------------------------------------------------
  // Test NetMsg with payload = 64b, opaque = 2b, src/dest = 7b
  //-----------------------------------------------------------------------

  localparam c_t2_payload_nbits = 64;
  localparam c_t2_opaque_nbits  = 2;
  localparam c_t2_srcdest_nbits = 7;

  // shorter names

  localparam t2_p = c_t2_payload_nbits;
  localparam t2_o = c_t2_opaque_nbits;
  localparam t2_s = c_t2_srcdest_nbits;

  reg  [`VC_NET_MSG_PAYLOAD_NBITS(t2_p,t2_o,t2_s)-1:0]  t2_pack_payload;
  reg  [`VC_NET_MSG_OPAQUE_NBITS(t2_p,t2_o,t2_s)-1:0]   t2_pack_opaque;
  reg  [`VC_NET_MSG_SRC_NBITS(t2_p,t2_o,t2_s)-1:0]      t2_pack_src;
  reg  [`VC_NET_MSG_DEST_NBITS(t2_p,t2_o,t2_s)-1:0]     t2_pack_dest;
  wire [`VC_NET_MSG_NBITS(t2_p,t2_o,t2_s)-1:0]          t2_pack_msg;

  vc_NetMsgPack#(t2_p,t2_o,t2_s) t2_pack
  (
    .payload    (t2_pack_payload),
    .opaque     (t2_pack_opaque),
    .src        (t2_pack_src),
    .dest       (t2_pack_dest),
    .msg        (t2_pack_msg)
  );

  wire [`VC_NET_MSG_PAYLOAD_NBITS(t2_p,t2_o,t2_s)-1:0]  t2_unpack_payload;
  wire [`VC_NET_MSG_OPAQUE_NBITS(t2_p,t2_o,t2_s)-1:0]   t2_unpack_opaque;
  wire [`VC_NET_MSG_SRC_NBITS(t2_p,t2_o,t2_s)-1:0]      t2_unpack_src;
  wire [`VC_NET_MSG_DEST_NBITS(t2_p,t2_o,t2_s)-1:0]     t2_unpack_dest;

  vc_NetMsgUnpack#(t2_p,t2_o,t2_s) t2_unpack
  (
    .msg        (t2_pack_msg),
    .payload    (t2_unpack_payload),
    .opaque     (t2_unpack_opaque),
    .src        (t2_unpack_src),
    .dest       (t2_unpack_dest)
  );

  reg t2_reset = 1;
  reg t2_val;

  vc_NetMsgTrace#(t2_p,t2_o,t2_s) t2_trace
  (
    .clk    (clk),
    .reset  (t2_reset),
    .val    (t2_val),
    .rdy    (1),
    .msg    (t2_pack_msg)
  );

  // Helper task

  task t2
  (
    input                                                 val,
    input [`VC_NET_MSG_DEST_NBITS(t2_p,t2_o,t2_s)-1:0]    dest,
    input [`VC_NET_MSG_SRC_NBITS(t2_p,t2_o,t2_s)-1:0]     src,
    input [`VC_NET_MSG_OPAQUE_NBITS(t2_p,t2_o,t2_s)-1:0]  opaque,
    input [`VC_NET_MSG_PAYLOAD_NBITS(t2_p,t2_o,t2_s)-1:0] payload
  );
  begin
    t2_val          = val;
    t2_pack_dest    = dest;
    t2_pack_src     = src;
    t2_pack_opaque  = opaque;
    t2_pack_payload = payload;
    #1;
    t2_trace.trace_display();
    `VC_TEST_NET( t2_unpack_dest   , dest    );
    `VC_TEST_NET( t2_unpack_src    , src     );
    `VC_TEST_NET( t2_unpack_opaque , opaque  );
    `VC_TEST_NET( t2_unpack_payload, payload );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "payload = 64b, opaque = 2b, src/dest = 7b" )
  begin
    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b1;

    t2( 0, 7'h00, 7'h70, 2'h0, 64'h0000000000000000 );
    t2( 1, 7'h14, 7'h6b, 2'h1, 64'h0000000000000000 );
    t2( 1, 7'h2a, 7'h52, 2'h3, 64'h0000000000000000 );
    t2( 1, 7'h31, 7'h48, 2'h2, 64'h0000000000000000 );
    t2( 1, 7'h4c, 7'h37, 2'h0, 64'ha0a0a0a0a0a0a0a0 );
    t2( 1, 7'h5e, 7'h25, 2'h1, 64'hc2c2c2c2c2c2c2c2 );
    t2( 1, 7'h6f, 7'h19, 2'h1, 64'hdededededededede );
    t2( 1, 7'h73, 7'h0c, 2'h0, 64'h0123456789abcdef );
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule
