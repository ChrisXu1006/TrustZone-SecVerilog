//========================================================================
// vc-mem-msgs Unit Tests
//========================================================================

`include "vc-mem-msgs.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-mem-msgs" )

  //----------------------------------------------------------------------
  // Test MemReqMsg with opaque = 8b, addr = 32b, data = 32b
  //----------------------------------------------------------------------

  reg  [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   t1_pack_type;
  reg  [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] t1_pack_opaque;
  reg  [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   t1_pack_addr;
  reg  [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    t1_pack_len;
  reg  [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   t1_pack_data;
  wire [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0]        t1_pack_msg;

  vc_MemReqMsgPack#(8,32,32) t1_pack
  (
    .type   (t1_pack_type),
    .opaque (t1_pack_opaque),
    .addr   (t1_pack_addr),
    .len    (t1_pack_len),
    .data   (t1_pack_data),
    .msg    (t1_pack_msg)
  );

  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   t1_unpack_type;
  wire [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] t1_unpack_opaque;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   t1_unpack_addr;
  wire [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    t1_unpack_len;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   t1_unpack_data;

  vc_MemReqMsgUnpack#(8,32,32) t1_unpack
  (
    .msg    (t1_pack_msg),
    .type   (t1_unpack_type),
    .opaque (t1_unpack_opaque),
    .addr   (t1_unpack_addr),
    .len    (t1_unpack_len),
    .data   (t1_unpack_data)
  );

  reg t1_reset = 1;
  reg t1_val;

  vc_MemReqMsgTrace#(8,32,32) t1_trace
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
    input                                             val,
    input [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   type,
    input [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] opaque,
    input [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   addr,
    input [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    len,
    input [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   data
  );
  begin
    t1_val         = val;
    t1_pack_type   = type;
    t1_pack_opaque = opaque;
    t1_pack_addr   = addr;
    t1_pack_len    = len;
    t1_pack_data   = data;
    #1;
    t1_trace.trace_display();
    `VC_TEST_NET( t1_unpack_type,   type   );
    `VC_TEST_NET( t1_unpack_opaque, opaque );
    `VC_TEST_NET( t1_unpack_addr,   addr   );
    `VC_TEST_NET( t1_unpack_len,    len    );
    `VC_TEST_NET( t1_unpack_data,   data   );
    #9;
  end
  endtask

  // Helper localparams

  localparam t1_rd = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam t1_wr = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam t1_wn = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  localparam t1_ad = `VC_MEM_REQ_MSG_TYPE_AMO_ADD;
  localparam t1_an = `VC_MEM_REQ_MSG_TYPE_AMO_AND;
  localparam t1_ao = `VC_MEM_REQ_MSG_TYPE_AMO_OR;
  localparam t1_x  = `VC_MEM_REQ_MSG_TYPE_X;

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "opaque = 8b, addr = 32b, data = 32b" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1( 0, t1_x,  8'hxx, 32'hxxxxxxxx, 2'hx, 32'hxxxxxxxx );
    t1( 1, t1_rd, 8'h00, 32'h00001000, 2'h0, 32'hxxxxxxxx );
    t1( 1, t1_rd, 8'h01, 32'h00001004, 2'h1, 32'hxxxxxxxx );
    t1( 1, t1_rd, 8'h02, 32'h00001008, 2'h2, 32'hxxxxxxxx );
    t1( 1, t1_rd, 8'h03, 32'h0000100c, 2'h3, 32'hxxxxxxxx );

    t1( 0, t1_x,  8'hxx, 32'hxxxxxxxx, 2'hx, 32'hxxxxxxxx );
    t1( 1, t1_wr, 8'h10, 32'h00001000, 2'h0, 32'habcdef01 );
    t1( 1, t1_ad, 8'h20, 32'h00201000, 2'h0, 32'hcafebabe );
    t1( 1, t1_an, 8'h21, 32'h00201020, 2'h1, 32'hdeadbeef );
    t1( 1, t1_ao, 8'h22, 32'h00201040, 2'h2, 32'hbeefcafe );
    t1( 1, t1_wr, 8'h11, 32'h00001004, 2'h1, 32'hxxxxxx01 );
    t1( 1, t1_wn, 8'h12, 32'h00001008, 2'h2, 32'hxxxxef01 );
    t1( 1, t1_wr, 8'h13, 32'h0000100c, 2'h3, 32'hxxcdef01 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test MemReqMsg with opaque = 4b, addr = 16b, data = 48b
  //----------------------------------------------------------------------

  reg  [`VC_MEM_REQ_MSG_TYPE_NBITS(4,16,48)-1:0]   t2_pack_type;
  reg  [`VC_MEM_REQ_MSG_OPAQUE_NBITS(4,16,48)-1:0] t2_pack_opaque;
  reg  [`VC_MEM_REQ_MSG_ADDR_NBITS(4,16,48)-1:0]   t2_pack_addr;
  reg  [`VC_MEM_REQ_MSG_LEN_NBITS(4,16,48)-1:0]    t2_pack_len;
  reg  [`VC_MEM_REQ_MSG_DATA_NBITS(4,16,48)-1:0]   t2_pack_data;
  wire [`VC_MEM_REQ_MSG_NBITS(4,16,48)-1:0]        t2_pack_msg;

  vc_MemReqMsgPack#(4,16,48) t2_pack
  (
    .type   (t2_pack_type),
    .opaque (t2_pack_opaque),
    .addr   (t2_pack_addr),
    .len    (t2_pack_len),
    .data   (t2_pack_data),
    .msg    (t2_pack_msg)
  );

  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(4,16,48)-1:0]   t2_unpack_type;
  wire [`VC_MEM_REQ_MSG_OPAQUE_NBITS(4,16,48)-1:0] t2_unpack_opaque;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(4,16,48)-1:0]   t2_unpack_addr;
  wire [`VC_MEM_REQ_MSG_LEN_NBITS(4,16,48)-1:0]    t2_unpack_len;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(4,16,48)-1:0]   t2_unpack_data;

  vc_MemReqMsgUnpack#(4,16,48) t2_unpack
  (
    .msg    (t2_pack_msg),
    .type   (t2_unpack_type),
    .opaque (t2_unpack_opaque),
    .addr   (t2_unpack_addr),
    .len    (t2_unpack_len),
    .data   (t2_unpack_data)
  );

  reg t2_reset = 1;
  reg t2_val;

  vc_MemReqMsgTrace#(4,16,48) t2_trace
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
    input                                             val,
    input [`VC_MEM_REQ_MSG_TYPE_NBITS(4,16,48)-1:0]   type,
    input [`VC_MEM_REQ_MSG_OPAQUE_NBITS(4,16,48)-1:0] opaque,
    input [`VC_MEM_REQ_MSG_ADDR_NBITS(4,16,48)-1:0]   addr,
    input [`VC_MEM_REQ_MSG_LEN_NBITS(4,16,48)-1:0]    len,
    input [`VC_MEM_REQ_MSG_DATA_NBITS(4,16,48)-1:0]   data
  );
  begin
    t2_val         = val;
    t2_pack_type   = type;
    t2_pack_opaque = opaque;
    t2_pack_addr   = addr;
    t2_pack_len    = len;
    t2_pack_data   = data;
    #1;
    t2_trace.trace_display();
    `VC_TEST_NET( t2_unpack_type,   type   );
    `VC_TEST_NET( t2_unpack_opaque, opaque );
    `VC_TEST_NET( t2_unpack_addr,   addr   );
    `VC_TEST_NET( t2_unpack_len,    len    );
    `VC_TEST_NET( t2_unpack_data,   data   );
    #9;
  end
  endtask

  // Helper localparams

  localparam t2_rd = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam t2_wr = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam t2_wn = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  localparam t2_x  = `VC_MEM_REQ_MSG_TYPE_X;

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "opaque = 4b, addr = 16b, data = 48b" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2( 0, t2_x,  4'hx, 16'hxxxx, 3'hx, 48'hxxxxxxxxxxxx );
    t2( 1, t2_rd, 4'h0, 16'h1000, 3'h0, 48'hxxxxxxxxxxxx );
    t2( 1, t2_rd, 4'h1, 16'h1004, 3'h1, 48'hxxxxxxxxxxxx );
    t2( 1, t2_rd, 4'h2, 16'h1008, 3'h2, 48'hxxxxxxxxxxxx );
    t2( 1, t2_rd, 4'h3, 16'h100c, 3'h3, 48'hxxxxxxxxxxxx );
    t2( 1, t2_rd, 4'h4, 16'h1010, 3'h4, 48'hxxxxxxxxxxxx );
    t2( 1, t2_rd, 4'h5, 16'h1014, 3'h5, 48'hxxxxxxxxxxxx );

    t2( 0, t2_x,  4'hx, 16'hxxxx, 3'hx, 48'hxxxxxxxxxxxx );
    t2( 1, t2_wr, 4'h0, 16'h1000, 3'h0, 48'habcdef010203 );
    t2( 1, t2_wr, 4'h1, 16'h1004, 3'h1, 48'hxxxxxxxxxx03 );
    t2( 1, t2_wr, 4'h2, 16'h1008, 3'h2, 48'hxxxxxxxx0203 );
    t2( 1, t2_wn, 4'h3, 16'h100c, 3'h3, 48'hxxxxxx010203 );
    t2( 1, t2_wn, 4'h4, 16'h1010, 3'h4, 48'hxxxxef010203 );
    t2( 1, t2_wr, 4'h5, 16'h1014, 3'h5, 48'hxxcdef010203 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test MemRespMsg with opaque = 8b, data = 32b
  //----------------------------------------------------------------------

  reg  [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]   t3_pack_type;
  reg  [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0] t3_pack_opaque;
  reg  [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]    t3_pack_len;
  reg  [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]   t3_pack_data;
  wire [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]        t3_pack_msg;

  vc_MemRespMsgPack#(8,32) t3_pack
  (
    .type   (t3_pack_type),
    .opaque (t3_pack_opaque),
    .len    (t3_pack_len),
    .data   (t3_pack_data),
    .msg    (t3_pack_msg)
  );

  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]   t3_unpack_type;
  wire [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0] t3_unpack_opaque;
  wire [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]    t3_unpack_len;
  wire [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]   t3_unpack_data;

  vc_MemRespMsgUnpack#(8,32) t3_unpack
  (
    .msg    (t3_pack_msg),
    .type   (t3_unpack_type),
    .opaque (t3_unpack_opaque),
    .len    (t3_unpack_len),
    .data   (t3_unpack_data)
  );

  reg t3_reset = 1;
  reg t3_val;

  vc_MemRespMsgTrace#(8,32) t3_trace
  (
    .clk    (clk),
    .reset  (t3_reset),
    .val    (t3_val),
    .rdy    (1),
    .msg    (t3_pack_msg)
  );

  // Helper task

  task t3
  (
    input                                           val,
    input [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]   type,
    input [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0] opaque,
    input [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]    len,
    input [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]   data
  );
  begin
    t3_val         = val;
    t3_pack_type   = type;
    t3_pack_opaque = opaque;
    t3_pack_len    = len;
    t3_pack_data   = data;
    #1;
    t3_trace.trace_display();
    `VC_TEST_NET( t3_unpack_type,   type   );
    `VC_TEST_NET( t3_unpack_opaque, opaque );
    `VC_TEST_NET( t3_unpack_len,    len    );
    `VC_TEST_NET( t3_unpack_data,   data   );
    #9;
  end
  endtask

  // Helper localparams

  localparam t3_rd = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam t3_wr = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam t3_wn = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  localparam t3_x  = `VC_MEM_REQ_MSG_TYPE_X;

  // Test case

  `VC_TEST_CASE_BEGIN( 3, "opaque = 8b, data = 32b" )
  begin

    #1;  t3_reset = 1'b1;
    #20; t3_reset = 1'b0;

    t3( 0, t3_x,  8'hxx, 2'hx, 32'hxxxxxxxx );
    t3( 1, t3_rd, 8'h00, 2'h0, 32'hxxxxxxxx );
    t3( 1, t3_rd, 8'h01, 2'h1, 32'hxxxxxxxx );
    t3( 1, t3_rd, 8'h02, 2'h2, 32'hxxxxxxxx );
    t3( 1, t3_rd, 8'h03, 2'h3, 32'hxxxxxxxx );

    t3( 0, t3_x,  8'hxx, 2'hx, 32'hxxxxxxxx );
    t3( 1, t3_wr, 8'h10, 2'h0, 32'habcdef01 );
    t3( 1, t3_wr, 8'h11, 2'h1, 32'hxxxxxx01 );
    t3( 1, t3_wn, 8'h12, 2'h2, 32'hxxxxef01 );
    t3( 1, t3_wr, 8'h13, 2'h3, 32'hxxcdef01 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test MemRespMsg with opaque = 4b, data = 48b
  //----------------------------------------------------------------------

  reg  [`VC_MEM_RESP_MSG_TYPE_NBITS(4,48)-1:0]   t4_pack_type;
  reg  [`VC_MEM_RESP_MSG_OPAQUE_NBITS(4,48)-1:0] t4_pack_opaque;
  reg  [`VC_MEM_RESP_MSG_LEN_NBITS(4,48)-1:0]    t4_pack_len;
  reg  [`VC_MEM_RESP_MSG_DATA_NBITS(4,48)-1:0]   t4_pack_data;
  wire [`VC_MEM_RESP_MSG_NBITS(4,48)-1:0]        t4_pack_msg;

  vc_MemRespMsgPack#(4,48) t4_pack
  (
    .type   (t4_pack_type),
    .opaque (t4_pack_opaque),
    .len    (t4_pack_len),
    .data   (t4_pack_data),
    .msg    (t4_pack_msg)
  );

  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(4,48)-1:0]   t4_unpack_type;
  wire [`VC_MEM_RESP_MSG_OPAQUE_NBITS(4,48)-1:0] t4_unpack_opaque;
  wire [`VC_MEM_RESP_MSG_LEN_NBITS(4,48)-1:0]    t4_unpack_len;
  wire [`VC_MEM_RESP_MSG_DATA_NBITS(4,48)-1:0]   t4_unpack_data;

  vc_MemRespMsgUnpack#(4,48) t4_unpack
  (
    .msg    (t4_pack_msg),
    .type   (t4_unpack_type),
    .opaque (t4_unpack_opaque),
    .len    (t4_unpack_len),
    .data   (t4_unpack_data)
  );

  reg t4_reset = 1;
  reg t4_val;

  vc_MemRespMsgTrace#(4,48) t4_trace
  (
    .clk    (clk),
    .reset  (t4_reset),
    .val    (t4_val),
    .rdy    (1),
    .msg    (t4_pack_msg)
  );

  // Helper task

  task t4
  (
    input                                           val,
    input [`VC_MEM_RESP_MSG_TYPE_NBITS(4,48)-1:0]   type,
    input [`VC_MEM_RESP_MSG_OPAQUE_NBITS(4,48)-1:0] opaque,
    input [`VC_MEM_RESP_MSG_LEN_NBITS(4,48)-1:0]    len,
    input [`VC_MEM_RESP_MSG_DATA_NBITS(4,48)-1:0]   data
  );
  begin
    t4_val         = val;
    t4_pack_type   = type;
    t4_pack_opaque = opaque;
    t4_pack_len    = len;
    t4_pack_data   = data;
    #1;
    t4_trace.trace_display();
    `VC_TEST_NET( t4_unpack_type,   type   );
    `VC_TEST_NET( t4_unpack_opaque, opaque );
    `VC_TEST_NET( t4_unpack_len,    len    );
    `VC_TEST_NET( t4_unpack_data,   data   );
    #9;
  end
  endtask

  // Helper localparams

  localparam t4_rd = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam t4_wr = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam t4_wn = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  localparam t4_x  = `VC_MEM_REQ_MSG_TYPE_X;

  // Test case

  `VC_TEST_CASE_BEGIN( 4, "opaque = 4b, data = 48b" )
  begin

    #1;  t4_reset = 1'b1;
    #20; t4_reset = 1'b0;

    t4( 0, t4_x,  4'hx, 3'hx, 48'hxxxxxxxxxxxx );
    t4( 1, t4_rd, 4'h0, 3'h0, 48'hxxxxxxxxxxxx );
    t4( 1, t4_rd, 4'h1, 3'h1, 48'hxxxxxxxxxxxx );
    t4( 1, t4_rd, 4'h2, 3'h2, 48'hxxxxxxxxxxxx );
    t4( 1, t4_rd, 4'h3, 3'h3, 48'hxxxxxxxxxxxx );
    t4( 1, t4_rd, 4'h4, 3'h4, 48'hxxxxxxxxxxxx );
    t4( 1, t4_rd, 4'h5, 3'h5, 48'hxxxxxxxxxxxx );

    t4( 0, t4_x,  4'hx, 3'hx, 48'hxxxxxxxxxxxx );
    t4( 1, t4_wr, 4'h0, 3'h0, 48'habcdef010203 );
    t4( 1, t4_wr, 4'h1, 3'h1, 48'hxxxxxxxxxx03 );
    t4( 1, t4_wr, 4'h2, 3'h2, 48'hxxxxxxxx0203 );
    t4( 1, t4_wn, 4'h3, 3'h3, 48'hxxxxxx010203 );
    t4( 1, t4_wn, 4'h4, 3'h4, 48'hxxxxef010203 );
    t4( 1, t4_wr, 4'h5, 3'h5, 48'hxxcdef010203 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

