//========================================================================
// vc-TestNet Unit Tests
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelayUnorderedSink.v"
`include "vc-TestNet.v"
`include "vc-test.v"
`include "vc-net-msgs.v"
`include "vc-param-utils.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_num_ports      = 2,
  // we set a pretty large input queue size
  parameter p_queue_num_msgs = 64
)
(
  input             clk,
  input             reset,
  input      [31:0] src_max_delay,
  input      [31:0] sink_max_delay,
  output reg [31:0] num_failed,
  output            done
);

  // Local parameters

  localparam c_payload_nbits = 8;
  localparam c_opaque_nbits  = 8;
  localparam c_srcdest_nbits = 2;

  // shorter names

  localparam p = c_payload_nbits;
  localparam o = c_opaque_nbits;
  localparam s = c_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);

  // Global wires for sources and sinks

  wire [p_num_ports-1:0]      global_src_done;
  wire [p_num_ports-1:0]      global_sink_done;
  wire [p_num_ports*32-1:0]   global_sink_num_failed;

  // Trace related regs

  `include "vc-trace-tasks.v"

  reg [p_num_ports*vc_trace_nbits-1:0] src_trace;
  reg [p_num_ports*vc_trace_nbits-1:0] sink_trace;

  // we use the fire hack to fire tasks

  reg trace_fire = 0;

  // Test network wires

  wire [p_num_ports-1:0]                 net_in_val;
  wire [p_num_ports-1:0]                 net_in_rdy;
  wire [p_num_ports*c_net_msg_nbits-1:0] net_in_msg;

  wire [p_num_ports-1:0]                 net_out_val;
  wire [p_num_ports-1:0]                 net_out_rdy;
  wire [p_num_ports*c_net_msg_nbits-1:0] net_out_msg;

  // wires to kick off test source/sink loading

  reg [c_net_msg_nbits-1:0] src_ld_msg;
  reg [31:0]                src_ld_addr;
  reg [31:0]                src_ld_port;
  reg                       src_ld_fire = 0;

  reg [c_net_msg_nbits-1:0] sink_ld_msg;
  reg [31:0]                sink_ld_addr;
  reg [31:0]                sink_ld_port;
  reg                       sink_ld_fire = 0;

  //----------------------------------------------------------------------
  // Generate loop for source/sink
  //----------------------------------------------------------------------

  genvar i;

  generate
  for ( i = 0; i < p_num_ports; i = i + 1 ) begin: SRC_SINK_INIT

    // local wires for the source and sink iteration

    wire                        src_val;
    wire                        src_rdy;
    wire [c_net_msg_nbits-1:0]  src_msg;
    wire                        src_done;

    wire                        sink_val;
    wire                        sink_rdy;
    wire [c_net_msg_nbits-1:0]  sink_msg;

    wire [31:0]                 sink_num_failed;
    wire                        sink_done;

    // connect the local wires to the wide network ports

    assign net_in_val[`VC_PORT_PICK_FIELD(1,i)] = src_val;
    assign net_in_msg[`VC_PORT_PICK_FIELD(c_net_msg_nbits,i)] = src_msg;
    assign src_rdy = net_in_rdy[`VC_PORT_PICK_FIELD(1,i)];

    assign sink_val = net_out_val[`VC_PORT_PICK_FIELD(1,i)];
    assign sink_msg = net_out_msg[`VC_PORT_PICK_FIELD(c_net_msg_nbits,i)];
    assign net_out_rdy[`VC_PORT_PICK_FIELD(1,i)] = sink_rdy;

    assign global_src_done[`VC_PORT_PICK_FIELD(1,i)]         = src_done;
    assign global_sink_done[`VC_PORT_PICK_FIELD(1,i)]        = sink_done;
    assign global_sink_num_failed[`VC_PORT_PICK_FIELD(32,i)]
                                                      = sink_num_failed;

    vc_TestRandDelaySource#(c_net_msg_nbits) src
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (src_val),
      .rdy        (src_rdy),
      .msg        (src_msg),
      .done       (src_done)
    );

    // We use an unordered sink because the messages can come out of order

    vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (sink_val),
      .rdy        (sink_rdy),
      .msg        (sink_msg),
      .num_failed (sink_num_failed),
      .done       (sink_done)
    );

    task load_src;
    begin
      src.src.m[src_ld_addr]     = src_ld_msg;

      // we load xs for the next address so that src/sink messages don't
      // bleed to the next one

      src.src.m[src_ld_addr + 1] = 'hx;
    end
    endtask

    task load_sink;
    begin
      sink.sink.m[sink_ld_addr]     = sink_ld_msg;

      // we load xs for the next address so that src/sink messages don't
      // bleed to the next one

      sink.sink.m[sink_ld_addr + 1] = 'hx;
    end
    endtask

    // we fire on the toggling of fire signal and only call the task if
    // the port matches with i

    always @(src_ld_fire) begin
      if ( src_ld_port == i )
        load_src;
    end

    always @(sink_ld_fire) begin
      if ( sink_ld_port == i )
        load_sink;
    end

    // local trace string for source and sink for this generate iteration
    reg [vc_trace_nbits-1:0] local_trace;

    always @(trace_fire) begin
      local_trace = 0;

      // we set the last two bytes as the length of the string as
      // trace_module expects
      local_trace[15:0] = vc_trace_nchars-1;

      src.trace_module( local_trace );
      src_trace[`VC_PORT_PICK_FIELD(vc_trace_nbits,i)] = local_trace;

      local_trace = 0;

      // we set the last two bytes as the length of the string as
      // trace_module expects
      local_trace[15:0] = vc_trace_nchars-1;

      sink.trace_module( local_trace );
      sink_trace[`VC_PORT_PICK_FIELD(vc_trace_nbits,i)] = local_trace;
    end

  end
  endgenerate

  always @(posedge clk) begin
    if ( reset ) begin
      src_trace  <= 0;
      sink_trace <= 0;
    end
  end

  //----------------------------------------------------------------------
  // Test Network
  //----------------------------------------------------------------------

  vc_TestNet
  #(
    .p_num_ports      (p_num_ports      ),
    .p_queue_num_msgs (p_queue_num_msgs ),
    .p_payload_nbits  (c_payload_nbits  ),
    .p_opaque_nbits   (c_opaque_nbits   ),
    .p_srcdest_nbits  (c_srcdest_nbits  )
  )
  net
  (
    .clk      (clk),
    .reset    (reset),

    .in_val   (net_in_val),
    .in_rdy   (net_in_rdy),
    .in_msg   (net_in_msg),

    .out_val  (net_out_val),
    .out_rdy  (net_out_rdy),
    .out_msg  (net_out_msg)
  );

  // Done when all sources and sinks are done for both ports

  assign done = ( & global_src_done ) && ( & global_sink_done );

  // Num failed is sum from all sinks

  integer j;
  always @(*) begin
    num_failed = 0;
    for ( j = 0; j < p_num_ports; j = j + 1 )
      num_failed = num_failed +
            global_sink_num_failed[`VC_PORT_PICK_FIELD(32,j)];
  end

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    for ( j = 0; j < p_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace_str( trace, "|" );

      // add the left-justified src trace string
      vc_trace_str_ljust( trace,
                src_trace[`VC_PORT_PICK_FIELD(vc_trace_nbits,j)] );
    end

    vc_trace_str( trace, " > " );

    net.trace_module( trace );

    vc_trace_str( trace, " > " );

    for ( j = 0; j < p_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace_str( trace, "|" );

      // add the left-justified sink trace string
      vc_trace_str_ljust( trace,
                sink_trace[`VC_PORT_PICK_FIELD(vc_trace_nbits,j)] );
    end

  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "vc-TestNet" )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Local parameters

  localparam p_num_ports     = 4;

  localparam c_payload_nbits = 8;
  localparam c_opaque_nbits  = 8;
  localparam c_srcdest_nbits = 2;

  // shorter names

  localparam p = c_payload_nbits;
  localparam o = c_opaque_nbits;
  localparam s = c_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);

  reg         th_reset = 1;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire        th_done;

  reg [10:0] th_src_index  [10:0];
  reg [10:0] th_sink_index [10:0];

  TestHarness
  #(
    .p_num_ports    (p_num_ports)
  )
  th
  (
    .clk            (clk),
    .reset          (th_reset),
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .num_failed     (th_num_failed),
    .done           (th_done)
  );

  // Helper task to initialize source/sink delays
  integer i;
  task init_rand_delays
  (
    input [31:0] src_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    // we also clear the src/sink indexes
    for ( i = 0; i < p_num_ports; i = i + 1 ) begin
      th_src_index[i] = 0;
      th_sink_index[i] = 0;
    end
    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask


  task init_src
  (
    input [31:0]   port,

    input [c_net_msg_nbits-1:0] msg
  );
  begin

    th.src_ld_msg  = msg;
    th.src_ld_addr = th_src_index[port];
    th.src_ld_port = port;

    // we toggle the wire to signal task call to load
    th.src_ld_fire = ~th.src_ld_fire;

    // increment the index
    th_src_index[port] = th_src_index[port] + 1;

    // wait to force always @(*) to be triggered
    #1;
  end
  endtask

  task init_sink
  (
    input [31:0]   port,

    input [c_net_msg_nbits-1:0] msg
  );
  begin

    th.sink_ld_msg  = msg;
    th.sink_ld_addr = th_sink_index[port];
    th.sink_ld_port = port;

    // we toggle the wire to signal task call to load
    th.sink_ld_fire = ~th.sink_ld_fire;

    // increment the index
    th_sink_index[port] = th_sink_index[port] + 1;

    // wait to force always @(*) to be triggered
    #1;
  end
  endtask

  reg [c_net_msg_nbits-1:0] th_port_msg;

  task init_net_msg
  (
    input [`VC_NET_MSG_SRC_NBITS(p,o,s)-1:0]     src,
    input [`VC_NET_MSG_DEST_NBITS(p,o,s)-1:0]    dest,
    input [`VC_NET_MSG_OPAQUE_NBITS(p,o,s)-1:0]  opaque,
    input [`VC_NET_MSG_PAYLOAD_NBITS(p,o,s)-1:0] payload
  );
  begin

    th_port_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)]    = dest;
    th_port_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)]     = src;
    th_port_msg[`VC_NET_MSG_PAYLOAD_FIELD(p,o,s)] = payload;
    th_port_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)]  = opaque;

    // call the respective src and sink
    init_src(  src,  th_port_msg );
    init_sink( dest, th_port_msg );

  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #5;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.trace_cycles < 500) ) begin
      // we toggle this wire to force a call to the trace task in the
      // generate blocks
      th.trace_fire = ~th.trace_fire;

      // we wait some time to make sure the task calls took place
      #1;
      th.trace_display();
      #9;
    end

    `VC_TEST_INCREMENT_NUM_FAILED( th_num_failed );
    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // basic test, no delay
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test, no delay" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 2'h0, 2'h1, 8'h00, 8'hce );
    init_net_msg( 2'h2, 2'h0, 8'h05, 8'hfe );
    init_net_msg( 2'h1, 2'h3, 8'h30, 8'h09 );
    init_net_msg( 2'h0, 2'h3, 8'h10, 8'hfe );
    init_net_msg( 2'h1, 2'h0, 8'h15, 8'h9f );
    init_net_msg( 2'h1, 2'h0, 8'h32, 8'hdf );
    init_net_msg( 2'h0, 2'h3, 8'h60, 8'hc9 );
    init_net_msg( 2'h3, 2'h1, 8'h65, 8'hfe );
    init_net_msg( 2'h2, 2'h2, 8'h60, 8'h09 );
    init_net_msg( 2'h0, 2'h1, 8'h60, 8'hfe );
    init_net_msg( 2'h2, 2'h0, 8'h65, 8'hda );
    init_net_msg( 2'h1, 2'h0, 8'h62, 8'hd3 );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // random test, no delay
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "random test, no delay" )
  begin
    init_rand_delays( 0, 0 );
    `include "vc-test-net-input-gen.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // random test, src delay = 3, sink delay = 10
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "random test, src delay = 3, sink delay = 10" )
  begin
    init_rand_delays( 3, 10 );
    `include "vc-test-net-input-gen.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // random test, src delay = 10, sink delay = 3
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "random test, src delay = 10, sink delay = 3" )
  begin
    init_rand_delays( 10, 3 );
    `include "vc-test-net-input-gen.py.v"
    run_test;
  end
  `VC_TEST_CASE_END


  `VC_TEST_SUITE_END
endmodule

