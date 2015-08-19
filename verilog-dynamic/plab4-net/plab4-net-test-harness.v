//========================================================================
// Test Harness for Ring Network Separative wires
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelayUnorderedSink.v"
`include "vc-test.v"
`include "vc-net-msgs.v"
`include "vc-param-utils.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_payload_nbits = 8,
  parameter p_payload_cnbits= 8,
  parameter p_payload_dnbits= 8,
  parameter p_opaque_nbits  = 8,
  parameter p_srcdest_nbits = 2
)
(
  input             clk,
  input             reset,
  input      [31:0] src_max_delay,
  input      [31:0] sink_max_delay,
  output reg [31:0] num_failed,
  output reg        done
);


  // shorter names

  // shorter names

  localparam p = p_payload_nbits;
  localparam pc= p_payload_cnbits;
  localparam pd= p_payload_dnbits;
  localparam o = p_opaque_nbits;
  localparam s = p_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);
  localparam c_net_msg_cnbits= `VC_NET_MSG_NBITS(pc,o,s);
  localparam c_net_msg_dnbits= pd;

  //----------------------------------------------------------------------
  // Generate loop for source/sink
  //----------------------------------------------------------------------

	wire                         src_cval_p0;
	wire						 src_dval_p0;
    wire                         src_rdy_p0;
    wire [c_net_msg_cnbits-1:0]  src_cmsg_p0;
	wire [c_net_msg_dnbits-1:0]	 src_dmsg_p0;
    wire                         src_cdone_p0;
	wire						 src_ddone_p0;

    wire                         sink_val_p0;
    wire                         sink_crdy_p0;
	wire						 sink_drdy_p0;
    wire [c_net_msg_cnbits-1:0]  sink_cmsg_p0;
	wire [c_net_msg_dnbits-1:0]  sink_dmsg_p0;

    wire [31:0]                 sink_cnum_failed_p0;
	wire [31:0]					sink_dnum_failed_p0;
    wire                        sink_cdone_p0;
	wire						sink_ddone_p0;

	vc_TestRandDelaySource#(c_net_msg_cnbits) src_control_p0
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (src_cval_p0),
      .rdy        (src_rdy_p0),
      .msg        (src_cmsg_p0),
      .done       (src_cdone_p0)
    );

	vc_TestRandDelaySource#(c_net_msg_dnbits) src_data_p0
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (src_dval_p0),
      .rdy        (src_rdy_p0),
      .msg        (src_dmsg_p0),
      .done       (src_ddone_p0)
    );

    // We use an unordered sink because the messages can come out of order

    vc_TestRandDelayUnorderedSink#(c_net_msg_cnbits) sink_control_p0
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (sink_val_p0),
      .rdy        (sink_crdy_p0),
      .msg        (sink_cmsg_p0),
      .num_failed (sink_cnum_failed_p0),
      .done       (sink_cdone_p0)
    );

    vc_TestRandDelayUnorderedSink#(c_net_msg_dnbits) sink_data_p0
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (sink_val_p0),
      .rdy        (sink_drdy_p0),
      .msg        (sink_dmsg_p0),
      .num_failed (sink_dnum_failed_p0),
      .done       (sink_ddone_p0)
    );

	wire                         src_cval_p1;
	wire						 src_dval_p1;
    wire                         src_rdy_p1;
    wire [c_net_msg_cnbits-1:0]  src_cmsg_p1;
	wire [c_net_msg_dnbits-1:0]	 src_dmsg_p1;
    wire                         src_cdone_p1;
	wire						 src_ddone_p1;

    wire                         sink_val_p1;
    wire                         sink_crdy_p1;
	wire						 sink_drdy_p1;
    wire [c_net_msg_cnbits-1:0]  sink_cmsg_p1;
	wire [c_net_msg_dnbits-1:0]  sink_dmsg_p1;

    wire [31:0]                 sink_cnum_failed_p1;
	wire [31:0]					sink_dnum_failed_p1;
    wire                        sink_cdone_p1;
	wire						sink_ddone_p1;

	vc_TestRandDelaySource#(c_net_msg_cnbits) src_control_p1
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (src_cval_p1),
      .rdy        (src_rdy_p1),
      .msg        (src_cmsg_p1),
      .done       (src_cdone_p1)
    );

	vc_TestRandDelaySource#(c_net_msg_dnbits) src_data_p1
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (src_dval_p1),
      .rdy        (src_rdy_p1),
      .msg        (src_dmsg_p1),
      .done       (src_ddone_p1)
    );

    // We use an unordered sink because the messages can come out of order

    vc_TestRandDelayUnorderedSink#(c_net_msg_cnbits) sink_control_p1
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (sink_val_p1),
      .rdy        (sink_crdy_p1),
      .msg        (sink_cmsg_p1),
      .num_failed (sink_cnum_failed_p1),
      .done       (sink_cdone_p1)
    );

    vc_TestRandDelayUnorderedSink#(c_net_msg_dnbits) sink_data_p1
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (sink_val_p1),
      .rdy        (sink_drdy_p1),
      .msg        (sink_dmsg_p1),
      .num_failed (sink_dnum_failed_p1),
      .done       (sink_ddone_p1)
    );


	//----------------------------------------------------------------------
	// Ring Network under test
	//----------------------------------------------------------------------

	`PLAB4_NET_IMPL
	#(
		.p_payload_cnbits (p_payload_cnbits ),
		.p_payload_dnbits (p_payload_dnbits ),
		.p_opaque_nbits   (p_opaque_nbits   ),
		.p_srcdest_nbits  (p_srcdest_nbits  )
	)
	net
	(
		.clk				(clk),
		.reset				(reset),
		
		.in_val_p0			(src_cval_p0),
		.in_rdy_p0			(src_rdy_p0),
		.in_msg_control_p0	(src_cmsg_p0),
		.in_msg_data_p0		(src_dmsg_p0),


		.out_val_p0			(sink_val_p0),
		.out_rdy_p0			(sink_crdy_p0),
		.out_msg_control_p0	(sink_cmsg_p0),
		.out_msg_data_p0	(sink_dmsg_p0),

		.in_val_p1			(src_cval_p1),
		.in_rdy_p1			(src_rdy_p1),
		.in_msg_control_p1	(src_cmsg_p1),
		.in_msg_data_p1		(src_dmsg_p1),


		.out_val_p1			(sink_val_p1),
		.out_rdy_p1			(sink_crdy_p1),
		.out_msg_control_p1	(sink_cmsg_p1),
		.out_msg_data_p1	(sink_dmsg_p1)
	);

	// Accumulate num failed and done signals from all sources and sinks
	
	always @(*) begin

		done = src_cdone_p0 && src_ddone_p0 && sink_cdone_p0 && src_ddone_p0;

		num_failed = sink_cnum_failed_p0 + sink_dnum_failed_p0 
						+ sink_cnum_failed_p1 + sink_dnum_failed_p1;
	end

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  integer j;
  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    for ( j = 0; j < 2; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace_str( trace, "|" );

      //`VC_GEN_CALL_8( SRC_SINK_INIT, j, trace_module_src_control( trace ) );
    end

    vc_trace_str( trace, " > " );

    //net.trace_module( trace );

    vc_trace_str( trace, " > " );

    for ( j = 0; j < 2; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace_str( trace, "|" );

      //`VC_GEN_CALL_8( SRC_SINK_INIT, j, trace_module_sink_control( trace ) );
    end

  end
  endtask

endmodule
//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `PLAB4_NET_IMPL_STR )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Local parameters

  //localparam c_num_ports     = 8;

  localparam c_payload_nbits = 8;
  localparam c_payload_cnbits= 8;
  localparam c_payload_dnbits= 8;
  localparam c_opaque_nbits  = 8;
  localparam c_srcdest_nbits = 1;

  // shorter names

  localparam p = c_payload_nbits;
  localparam pc= c_payload_cnbits;
  localparam pd= c_payload_dnbits;
  localparam o = c_opaque_nbits;
  localparam s = c_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);
  localparam c_net_msg_cnbits= `VC_NET_MSG_NBITS(pc,o,s);
  localparam c_net_msg_dnbits= pd;

  reg         th_reset = 1;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire        th_done;

  reg [10:0] th_src_index_p0;
  reg [10:0] th_sink_index_p0;
  reg [10:0] th_src_index_p1;
  reg [10:0] th_sink_index_p1;

  TestHarness
  #(
    .p_payload_nbits    (c_payload_nbits),
	.p_payload_cnbits	(c_payload_cnbits),
	.p_payload_dnbits	(c_payload_dnbits),
    .p_opaque_nbits     (c_opaque_nbits),
    .p_srcdest_nbits    (c_srcdest_nbits)
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
	

  // helper task to initialize source/sink delay
  task init_rand_delays
  (
	input	[31:0]	src_max_delay,
	input	[31:0]	sink_max_delay
  );
  begin
	th_src_max_delay = src_max_delay;
	th_sink_max_delay = sink_max_delay;

	// also clear the src/sink indexes and contents
	th_src_index_p0 = 0;
	th_src_index_p1 = 0;
	th_sink_index_p0 = 0;
	th_sink_index_p1 = 0;

	th.src_control_p0.src.m[0] = 'hx;
	th.src_data_p0.src.m[0] = 'hx;
	th.sink_control_p0.sink.m[0] = 'hx;
	th.sink_data_p0.sink.m[0] = 'hx;
	th.src_control_p1.src.m[0] = 'hx;
	th.src_data_p1.src.m[0] = 'hx;
	th.sink_control_p1.sink.m[0] = 'hx;
	th.sink_data_p1.sink.m[0] = 'hx;
  end
  endtask

  task init_src
  (
	 input							port,
	 input [c_net_msg_cnbits-1:0]	msg_control,
	 input [c_net_msg_dnbits-1:0]	msg_data
  );
  begin
	
	 if ( port == 0 ) begin
		th.src_control_p0.src.m[th_src_index_p0] = msg_control;
		th.src_data_p0.src.m[th_src_index_p0]	  = msg_data;
		th.src_control_p0.src.m[th_src_index_p0+1] = 'hx;
		th.src_data_p0.src.m[th_src_index_p0+1]	= 'hx;

		th_src_index_p0 = th_src_index_p0 + 1;
	end
	
	else begin
		th.src_control_p1.src.m[th_src_index_p1] = msg_control;
		th.src_data_p1.src.m[th_src_index_p1]	  = msg_data;
		th.src_control_p1.src.m[th_src_index_p1+1] = 'hx;
		th.src_data_p1.src.m[th_src_index_p1+1]	= 'hx;

		th_src_index_p1 = th_src_index_p1 + 1;
	end
  
  end
  endtask

  task init_sink
  (
	 input							port,
	 input [c_net_msg_cnbits-1:0]	msg_control,
	 input [c_net_msg_dnbits-1:0]	msg_data
  );
  begin
	
	 if ( port == 0 ) begin
		th.sink_control_p0.sink.m[th_sink_index_p0]	= msg_control;
		th.sink_data_p0.sink.m[th_sink_index_p0]		= msg_data;
		th.sink_control_p0.sink.m[th_sink_index_p0+1]	= 'hx;
		th.sink_data_p0.sink.m[th_sink_index_p0+1]		= 'hx;

		th_sink_index_p0 = th_sink_index_p0 + 1;
	end
	
	else begin
		th.sink_control_p1.sink.m[th_sink_index_p1]	= msg_control;
		th.sink_data_p1.sink.m[th_sink_index_p1]		= msg_data;
		th.sink_control_p1.sink.m[th_sink_index_p1+1]	= 'hx;
		th.sink_data_p1.sink.m[th_sink_index_p1+1]		= 'hx;

		th_sink_index_p1 = th_sink_index_p1 + 1;
	end
  
  end
  endtask

  reg [c_net_msg_cnbits-1:0]	th_port_msg_control;

  task init_net_msg
  (
    input [`VC_NET_MSG_SRC_NBITS(p,o,s)-1:0]	  src,
    input [`VC_NET_MSG_DEST_NBITS(p,o,s)-1:0]     dest,
    input [`VC_NET_MSG_OPAQUE_NBITS(p,o,s)-1:0]	  opaque,
    input [`VC_NET_MSG_PAYLOAD_NBITS(pc,o,s)-1:0] payload_control,
	input [`VC_NET_MSG_PAYLOAD_NBITS(pd,o,s)-1:0] payload_data
  );
  begin

    th_port_msg_control[`VC_NET_MSG_DEST_FIELD(pc,o,s)]    = dest;
    th_port_msg_control[`VC_NET_MSG_SRC_FIELD(pc,o,s)]     = src;
    th_port_msg_control[`VC_NET_MSG_PAYLOAD_FIELD(pc,o,s)] = payload_control;
    th_port_msg_control[`VC_NET_MSG_OPAQUE_FIELD(pc,o,s)]  = opaque;

	// call the respective src and sink
    init_src(  src,  th_port_msg_control, payload_data );
    init_sink( dest, th_port_msg_control, payload_data );

  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.trace_cycles < 2000) ) begin
      th.trace_display();
      #10;
    end

    `VC_TEST_INCREMENT_NUM_FAILED( th_num_failed );
    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // single source
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "single source" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload_control  payload_data
    init_net_msg( 1'h0, 1'h0, 8'h00, 8'hce,			  8'hdf);
    init_net_msg( 1'h0, 1'h1, 8'h01, 8'hff,			  8'h00);
    init_net_msg( 1'h0, 1'h0, 8'h02, 8'h80,			  8'ha1);
    init_net_msg( 1'h0, 1'h1, 8'h03, 8'hc0,			  8'hd1);
    init_net_msg( 1'h0, 1'h0, 8'h04, 8'h55,			  8'h66);
    init_net_msg( 1'h0, 1'h0, 8'h05, 8'h96,			  8'hb7);
    init_net_msg( 1'h0, 1'h1, 8'h06, 8'h32,			  8'h43);
    init_net_msg( 1'h0, 1'h1, 8'h07, 8'h2e,			  8'h3f);

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // single destination
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "single dest" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload_control payload_data
    init_net_msg( 1'h0, 1'h0, 8'h00, 8'hce,			 8'hdf);
    init_net_msg( 1'h1, 1'h0, 8'h01, 8'hff,			 8'h00);
    init_net_msg( 1'h0, 1'h0, 8'h02, 8'h80,			 8'ha1);
    init_net_msg( 1'h1, 1'h0, 8'h03, 8'hc0,			 8'hd1);
    init_net_msg( 1'h1, 1'h0, 8'h04, 8'h55,			 8'h66);
    init_net_msg( 1'h0, 1'h0, 8'h05, 8'h96,			 8'ha7);
    init_net_msg( 1'h1, 1'h0, 8'h06, 8'h32,			 8'h43);
    init_net_msg( 1'h0, 1'h0, 8'h07, 8'h2e,			 8'h3f);

    run_test;
  end
  `VC_TEST_CASE_END

`VC_TEST_SUITE_END
endmodule

		


