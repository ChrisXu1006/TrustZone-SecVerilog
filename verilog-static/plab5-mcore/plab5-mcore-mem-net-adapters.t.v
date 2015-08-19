//========================================================================
// plab5-mcore-mem-net-adapters Unit Tests
//========================================================================

`include "vc-test.v"
`include "vc-mem-msgs.v"
`include "vc-net-msgs.v"
`include "plab5-mcore-mem-net-adapters.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab5-mcore-mem-net-adapters" )


  //----------------------------------------------------------------------
  // Test MemReqMsgToNetMsg
  //----------------------------------------------------------------------

  parameter t1_p_net_src   = 2'h2;
  parameter t1_p_num_ports = 4;

  reg  [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   t1_mem_pack_type;
  reg  [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] t1_mem_pack_opaque;
  reg  [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   t1_mem_pack_addr;
  reg  [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    t1_mem_pack_len;
  reg  [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   t1_mem_pack_data;
  wire [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0]        t1_mem_pack_msg;

  vc_MemReqMsgPack#(8,32,32) t1_mem_pack
  (
    .type   (t1_mem_pack_type),
    .opaque (t1_mem_pack_opaque),
    .addr   (t1_mem_pack_addr),
    .len    (t1_mem_pack_len),
    .data   (t1_mem_pack_data),
    .msg    (t1_mem_pack_msg)
  );

  parameter t1_c_net_payload_nbits = `VC_MEM_REQ_MSG_NBITS(8,32,32);
  parameter t1_p = t1_c_net_payload_nbits;

  wire [`VC_NET_MSG_NBITS(t1_p,4,2)-1:0]      t1_net_unpack_msg;

  plab5_mcore_MemReqMsgToNetMsg
  #(
    .p_net_src            (t1_p_net_src),
    .p_num_ports          (t1_p_num_ports),
    .p_mem_opaque_nbits   (8),
    .p_mem_addr_nbits     (32),
    .p_mem_data_nbits     (32),
    .p_net_opaque_nbits   (4),
    .p_net_srcdest_nbits  (2)
  )
  t1_mem_msg_to_net_msg
  (
    .mem_msg  (t1_mem_pack_msg),
    .net_msg  (t1_net_unpack_msg)
  );

  wire [`VC_NET_MSG_PAYLOAD_NBITS(t1_p,4,2)-1:0] t1_net_unpack_payload;
  wire [`VC_NET_MSG_OPAQUE_NBITS(t1_p,4,2)-1:0]  t1_net_unpack_opaque;
  wire [`VC_NET_MSG_SRC_NBITS(t1_p,4,2)-1:0]     t1_net_unpack_src;
  wire [`VC_NET_MSG_DEST_NBITS(t1_p,4,2)-1:0]    t1_net_unpack_dest;

  vc_NetMsgUnpack#(t1_p,4,2) t1_net_unpack
  (
    .msg        (t1_net_unpack_msg),
    .payload    (t1_net_unpack_payload),
    .opaque     (t1_net_unpack_opaque),
    .src        (t1_net_unpack_src),
    .dest       (t1_net_unpack_dest)
  );

  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   t1_mem_unpack_type;
  wire [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] t1_mem_unpack_opaque;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   t1_mem_unpack_addr;
  wire [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    t1_mem_unpack_len;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   t1_mem_unpack_data;

  vc_MemReqMsgUnpack#(8,32,32) t1_mem_unpack
  (
    .msg    (t1_net_unpack_payload),
    .type   (t1_mem_unpack_type),
    .opaque (t1_mem_unpack_opaque),
    .addr   (t1_mem_unpack_addr),
    .len    (t1_mem_unpack_len),
    .data   (t1_mem_unpack_data)
  );

  // Helper task

  task t1
  (
    input [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   mem_type,
    input [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] mem_opaque,
    input [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   mem_addr,
    input [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    mem_len,
    input [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   mem_data,
    input [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] mem_unpack_opaque,
    input [`VC_NET_MSG_SRC_NBITS(t1_p,4,2)-1:0]       net_src,
    input [`VC_NET_MSG_DEST_NBITS(t1_p,4,2)-1:0]      net_dest
  );
  begin
    t1_mem_pack_type   = mem_type;
    t1_mem_pack_opaque = mem_opaque;
    t1_mem_pack_addr   = mem_addr;
    t1_mem_pack_len    = mem_len;
    t1_mem_pack_data   = mem_data;
    #1;
    `VC_TEST_NET( t1_net_unpack_src,    net_src      );
    `VC_TEST_NET( t1_net_unpack_dest,   net_dest     );

    `VC_TEST_NET( t1_mem_unpack_opaque, mem_unpack_opaque );
    `VC_TEST_NET( t1_mem_unpack_addr,   mem_addr   );
    `VC_TEST_NET( t1_mem_unpack_len,    mem_len    );
    `VC_TEST_NET( t1_mem_unpack_data,   mem_data   );
    #9;
  end
  endtask

  // Helper localparams

  localparam t1_rd = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam t1_wr = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam t1_x  = `VC_MEM_REQ_MSG_TYPE_X;

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "plab5_mcore_MemRespMsgToNetMsg" )
  begin

    #20;

    //  type   opq    addr          len   data         unp opq src   dest
    t1( t1_x,  8'h00, 32'hxxxxxxxx, 2'hx, 32'hxxxxxxxx, 8'h80, 2'h?, 2'hx );
    t1( t1_rd, 8'h00, 32'h00001010, 2'h0, 32'hxxxxxxxx, 8'h80, 2'h2, 2'h1 );
    t1( t1_rd, 8'h01, 32'h00001024, 2'h1, 32'hxxxxxxxx, 8'h81, 2'h2, 2'h2 );
    t1( t1_rd, 8'h02, 32'h00001008, 2'h2, 32'hxxxxxxxx, 8'h82, 2'h2, 2'h0 );
    t1( t1_rd, 8'h03, 32'h0000103c, 2'h3, 32'hxxxxxxxx, 8'h83, 2'h2, 2'h3 );

    t1( t1_x,  8'h00, 32'hxxxxxxxx, 2'hx, 32'hxxxxxxxx, 8'h80, 2'h?, 2'hx );
    t1( t1_wr, 8'h10, 32'h00001070, 2'h0, 32'habcdef01, 8'h90, 2'h2, 2'h3 );
    t1( t1_wr, 8'h11, 32'h00001064, 2'h1, 32'hxxxxxx01, 8'h91, 2'h2, 2'h2 );
    t1( t1_wr, 8'h12, 32'h00001068, 2'h2, 32'hxxxxef01, 8'h92, 2'h2, 2'h2 );
    t1( t1_wr, 8'h13, 32'h000010fc, 2'h3, 32'hxxcdef01, 8'h93, 2'h2, 2'h3 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test MemRespMsgToNetMsg
  //----------------------------------------------------------------------

  parameter t2_p_net_src   = 2'h2;
  parameter t2_p_num_ports = 4;

  reg  [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]   t2_mem_pack_type;
  reg  [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0] t2_mem_pack_opaque;
  reg  [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]    t2_mem_pack_len;
  reg  [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]   t2_mem_pack_data;
  wire [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]        t2_mem_pack_msg;

  vc_MemRespMsgPack#(8,32) t2_mem_pack
  (
    .type   (t2_mem_pack_type),
    .opaque (t2_mem_pack_opaque),
    .len    (t2_mem_pack_len),
    .data   (t2_mem_pack_data),
    .msg    (t2_mem_pack_msg)
  );

  parameter t2_c_net_payload_nbits = `VC_MEM_RESP_MSG_NBITS(8,32);
  parameter t2_p = t2_c_net_payload_nbits;

  wire [`VC_NET_MSG_NBITS(t2_p,4,2)-1:0]      t2_net_unpack_msg;

  plab5_mcore_MemRespMsgToNetMsg
  #(
    .p_net_src            (t2_p_net_src),
    .p_num_ports          (t2_p_num_ports),
    .p_mem_opaque_nbits   (8),
    .p_mem_data_nbits     (32),
    .p_net_opaque_nbits   (4),
    .p_net_srcdest_nbits  (2)
  )
  t2_mem_msg_to_net_msg
  (
    .mem_msg  (t2_mem_pack_msg),
    .net_msg  (t2_net_unpack_msg)
  );

  wire [`VC_NET_MSG_PAYLOAD_NBITS(t2_p,4,2)-1:0] t2_net_unpack_payload;
  wire [`VC_NET_MSG_OPAQUE_NBITS(t2_p,4,2)-1:0]  t2_net_unpack_opaque;
  wire [`VC_NET_MSG_SRC_NBITS(t2_p,4,2)-1:0]     t2_net_unpack_src;
  wire [`VC_NET_MSG_DEST_NBITS(t2_p,4,2)-1:0]    t2_net_unpack_dest;

  vc_NetMsgUnpack#(t2_p,4,2) t2_net_unpack
  (
    .msg        (t2_net_unpack_msg),
    .payload    (t2_net_unpack_payload),
    .opaque     (t2_net_unpack_opaque),
    .src        (t2_net_unpack_src),
    .dest       (t2_net_unpack_dest)
  );

  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]   t2_mem_unpack_type;
  wire [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0] t2_mem_unpack_opaque;
  wire [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]    t2_mem_unpack_len;
  wire [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]   t2_mem_unpack_data;

  vc_MemRespMsgUnpack#(8,32) t2_mem_unpack
  (
    .msg    (t2_net_unpack_payload),
    .type   (t2_mem_unpack_type),
    .opaque (t2_mem_unpack_opaque),
    .len    (t2_mem_unpack_len),
    .data   (t2_mem_unpack_data)
  );

  // Helper task

  task t2
  (
    input [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]   mem_type,
    input [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0] mem_opaque,
    input [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]    mem_len,
    input [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]   mem_data,
    input [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0]   mem_unpack_opaque,
    input [`VC_NET_MSG_SRC_NBITS(t2_p,4,2)-1:0]       net_src,
    input [`VC_NET_MSG_DEST_NBITS(t2_p,4,2)-1:0]      net_dest
  );
  begin
    t2_mem_pack_type   = mem_type;
    t2_mem_pack_opaque = mem_opaque;
    t2_mem_pack_len    = mem_len;
    t2_mem_pack_data   = mem_data;
    #1;
    `VC_TEST_NET( t2_net_unpack_src,    net_src      );
    `VC_TEST_NET( t2_net_unpack_dest,   net_dest     );

    `VC_TEST_NET( t2_mem_unpack_opaque, mem_unpack_opaque );
    `VC_TEST_NET( t2_mem_unpack_len,    mem_len    );
    `VC_TEST_NET( t2_mem_unpack_data,   mem_data   );
    #9;
  end
  endtask

  // Helper localparams

  localparam t2_rd = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam t2_wr = `VC_MEM_RESP_MSG_TYPE_WRITE;
  localparam t2_x  = `VC_MEM_RESP_MSG_TYPE_X;

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "plab5_mcore_MemRespMsgToNetMsg" )
  begin

    #20;

    //  type   opq    len   data         unp opq  src   dest
    t2( t2_x,  8'hxx, 2'hx, 32'hxxxxxxxx, 8'hxx, 2'h?, 2'hx );
    t2( t2_rd, 8'h00, 2'h0, 32'hxxxxxxxx, 8'h00, 2'h2, 2'h0 );
    t2( t2_rd, 8'hf1, 2'h1, 32'hxxxxxxxx, 8'hf1, 2'h2, 2'h3 );
    t2( t2_rd, 8'h42, 2'h2, 32'hxxxxxxxx, 8'h42, 2'h2, 2'h1 );
    t2( t2_rd, 8'h83, 2'h3, 32'hxxxxxxxx, 8'h83, 2'h2, 2'h2 );

    t2( t2_x,  8'hxx, 2'hx, 32'hxxxxxxxx, 8'hxx, 2'h?, 2'hx );
    t2( t2_wr, 8'h90, 2'h0, 32'habcdef01, 8'h90, 2'h2, 2'h2 );
    t2( t2_wr, 8'h51, 2'h1, 32'hxxxxxx01, 8'h51, 2'h2, 2'h1 );
    t2( t2_wr, 8'h52, 2'h2, 32'hxxxxef01, 8'h52, 2'h2, 2'h1 );
    t2( t2_wr, 8'h13, 2'h3, 32'hxxcdef01, 8'h13, 2'h2, 2'h0 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule
