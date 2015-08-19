//========================================================================
// Alternative Router
//========================================================================

`ifndef PLAB4_NET_ROUTER_ALT_SEP_V
`define PLAB4_NET_ROUTER_ALT_SEP_V

`include "vc-crossbars.v"
`include "vc-muxes.v"
`include "vc-queues.v"
`include "vc-mem-msgs.v"
`include "plab4-net-RouterInputCtrl-Arb-Sep.v"
`include "plab4-net-RouterAdaptiveInputTerminalCtrl-Sep.v"
`include "plab4-net-RouterOutputCtrl-Sep.v"

// determine arbitration scheme
`define RELAX

module plab4_net_RouterAlt_Sep
#(
  parameter p_payload_cnbits = 32,
  parameter p_payload_dnbits = 32, 
  parameter p_opaque_nbits   = 3,
  parameter p_srcdest_nbits  = 3,

  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,

  parameter req				 = 1,

  parameter p_num_free_nbits = 2,

  // Shorter names, not to be set from outside the module
  parameter pc = p_payload_cnbits,
  parameter pd = p_payload_dnbits,
  parameter o  = p_opaque_nbits,
  parameter s  = p_srcdest_nbits,

  parameter c_net_msg_cnbits = `VC_NET_MSG_NBITS(pc,o,s),
  parameter c_net_msg_dnbits = pd
)
(
  input                        clk,
  input                        reset,

  input                        in0_val_d1,
  output                       in0_rdy_d1,
  input  [c_net_msg_cnbits-1:0]in0_msg_control_d1,
  input  [c_net_msg_dnbits-1:0]in0_msg_data_d1,

  input                        in0_val_d2,
  output                       in0_rdy_d2,
  input  [c_net_msg_cnbits-1:0]in0_msg_control_d2,
  input  [c_net_msg_dnbits-1:0]in0_msg_data_d2,

  input                        in1_val,
  output                       in1_rdy,
  input						   in1_domain,
  input  [c_net_msg_cnbits-1:0]in1_msg_control,
  input  [c_net_msg_dnbits-1:0]in1_msg_data,

  input                        in2_val_d1,
  output                       in2_rdy_d1,
  input  [c_net_msg_cnbits-1:0]in2_msg_control_d1,
  input  [c_net_msg_dnbits-1:0]in2_msg_data_d1,

  input                        in2_val_d2,
  output                       in2_rdy_d2,
  input  [c_net_msg_cnbits-1:0]in2_msg_control_d2,
  input  [c_net_msg_dnbits-1:0]in2_msg_data_d2,

  output                       out0_val,
  input                        out0_rdy,
  output [c_net_msg_cnbits-1:0]out0_msg_control,
  output [c_net_msg_dnbits-1:0]out0_msg_data,
  output					   out0_domain,

  output                       out1_val,
  input                        out1_rdy,
  output [c_net_msg_cnbits-1:0]out1_msg_control,
  output [c_net_msg_dnbits-1:0]out1_msg_data,
  output					   out1_domain,

  output                       out2_val,
  input                        out2_rdy,
  output [c_net_msg_cnbits-1:0]out2_msg_control,
  output [c_net_msg_dnbits-1:0]out2_msg_data,
  output					   out2_domain,

  input [p_num_free_nbits-1:0] num_free_prev,
  input [p_num_free_nbits-1:0] num_free_next
);

  //----------------------------------------------------------------------
  // Input queues
  //----------------------------------------------------------------------

  wire						 in0_rdy_control_d1;
  wire						 in0_rdy_data_d1;
  wire                       in0_deq_val_control_d1;
  wire						 in0_deq_val_data_d1;
  wire                       in0_deq_rdy_d1;
  wire [c_net_msg_cnbits-1:0]in0_deq_msg_control_d1;
  wire [c_net_msg_dnbits-1:0]in0_deq_msg_data_d1;
  wire [1:0]                 num_free0_control_d1;
  wire [1:0]                 num_free0_data_d1;

  wire						 in0_rdy_control_d2;
  wire						 in0_rdy_data_d2;
  wire                       in0_deq_val_control_d2;
  wire                       in0_deq_val_data_d2;
  wire                       in0_deq_rdy_d2;
  wire [c_net_msg_cnbits-1:0]in0_deq_msg_control_d2;
  wire [c_net_msg_dnbits-1:0]in0_deq_msg_data_d2;
  wire [1:0]                 num_free0_control_d2;
  wire [1:0]                 num_free0_data_d2;

  wire						 in1_rdy_control;
  wire						 in1_rdy_data;
  wire						 in1_rdy_domain;
  wire                       in1_deq_val_control;
  wire						 in1_deq_val_data;
  wire						 in1_deq_val_domain;
  wire                       in1_deq_rdy;
  wire [c_net_msg_cnbits-1:0]in1_deq_msg_control;
  wire [c_net_msg_dnbits-1:0]in1_deq_msg_data;
  wire						 in1_deq_msg_domain;

  wire						 in2_rdy_control_d1;
  wire						 in2_rdy_data_d1;
  wire                       in2_deq_val_control_d1;
  wire						 in2_deq_val_data_d1;
  wire                       in2_deq_rdy_d1;
  wire [c_net_msg_cnbits-1:0]in2_deq_msg_control_d1;
  wire [c_net_msg_dnbits-1:0]in2_deq_msg_data_d1;
  wire [1:0]                 num_free2_control_d1;
  wire [1:0]                 num_free2_data_d1;

  wire						 in2_rdy_control_d2;
  wire						 in2_rdy_data_d2;
  wire                       in2_deq_val_control_d2;
  wire                       in2_deq_val_data_d2;
  wire                       in2_deq_rdy_d2;
  wire [c_net_msg_cnbits-1:0]in2_deq_msg_control_d2;
  wire [c_net_msg_dnbits-1:0]in2_deq_msg_data_d2;
  wire [1:0]                 num_free2_control_d2;
  wire [1:0]                 num_free2_data_d2;

  assign in0_rdy_d1 = in0_rdy_control_d1 && in0_rdy_data_d1;
  assign in0_rdy_d2 = in0_rdy_control_d2 && in0_rdy_data_d2;
  assign in1_rdy	= in1_rdy_control	 && in1_rdy_data;
  assign in2_rdy_d1 = in2_rdy_control_d1 && in2_rdy_data_d1;
  assign in2_rdy_d2 = in2_rdy_control_d2 && in2_rdy_data_d2;

  wire		   in0_reqs_domain;
  wire		   in1_reqs_domain;
  wire		   in2_reqs_domain;

  // west side queue for control signals

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in0_queue_control_d1
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in0_val_d1),
    .enq_rdy            (in0_rdy_control_d1),
    .enq_msg            (in0_msg_control_d1),

    .deq_val            (in0_deq_val_control_d1),
    .deq_rdy            (in0_deq_rdy_d1),
    .deq_msg            (in0_deq_msg_control_d1),

    .num_free_entries   (num_free0_control_d1)
  );

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in0_queue_control_d2
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in0_val_d2),
    .enq_rdy            (in0_rdy_control_d2),
    .enq_msg            (in0_msg_control_d2),

    .deq_val            (in0_deq_val_control_d2),
    .deq_rdy            (in0_deq_rdy_d2),
    .deq_msg            (in0_deq_msg_control_d2),

    .num_free_entries   (num_free0_control_d2)
  );

  wire [c_net_msg_cnbits-1:0]	in0_deq_msg_control;

  // 2 to 1 mux for input0 signal port

  vc_Mux2
  #(
	.p_nbits  (c_net_msg_cnbits)
  )
  in0_msg_control_mux
  (
	.in0		  (in0_deq_msg_control_d1),
	.in1		  (in0_deq_msg_control_d2),
	.sel		  (in0_reqs_domain),
	.out		  (in0_deq_msg_control)
  );

   // west side queue for data signals

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_dnbits),
    .p_num_msgs   (2)
  )
  in0_queue_data_d1
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in0_val_d1),
    .enq_rdy            (in0_rdy_data_d1),
    .enq_msg            (in0_msg_data_d1),

    .deq_val            (in0_deq_val_data_d1),
    .deq_rdy            (in0_deq_rdy_d1),
    .deq_msg            (in0_deq_msg_data_d1),

    .num_free_entries   (num_free0_data_d1)
  );

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_dnbits),
    .p_num_msgs   (2)
  )
  in0_queue_data_d2
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in0_val_d2),
    .enq_rdy            (in0_rdy_data_d2),
    .enq_msg            (in0_msg_data_d2),

    .deq_val            (in0_deq_val_data_d2),
    .deq_rdy            (in0_deq_rdy_d2),
    .deq_msg            (in0_deq_msg_data_d2),

    .num_free_entries   (num_free0_data_d2)
  );

  wire [c_net_msg_dnbits-1:0]	in0_deq_msg_data;

  // 2 to 1 mux for input0 signal port

  vc_Mux2
  #(
	.p_nbits  (c_net_msg_dnbits)
  )
  in0_msg_data_mux
  (
	.in0		  (in0_deq_msg_data_d1),
	.in1		  (in0_deq_msg_data_d2),
	.sel		  (in0_reqs_domain),
	.out		  (in0_deq_msg_data)
  );

  // Terminal side's queues

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in1_control_queue
  (
    .clk        (clk),
    .reset      (reset),

    .enq_val    (in1_val),
    .enq_rdy    (in1_rdy_control),
    .enq_msg    (in1_msg_control),

    .deq_val    (in1_deq_val_control),
    .deq_rdy    (in1_deq_rdy),
    .deq_msg    (in1_deq_msg_control)
  );

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_dnbits),
    .p_num_msgs   (2)
  )
  in1_data_queue
  (
    .clk        (clk),
    .reset      (reset),

    .enq_val    (in1_val),
    .enq_rdy    (in1_rdy_data),
    .enq_msg    (in1_msg_data),

    .deq_val    (in1_deq_val_data),
    .deq_rdy    (in1_deq_rdy),
    .deq_msg    (in1_deq_msg_data)
  );

  vc_Queue
  #(
	.p_type		 (`VC_QUEUE_NORMAL),
	.p_msg_nbits (1),
	.p_num_msgs	 (2)
  )
  in1_domain_queue
  (
	.clk		 (clk),
	.reset		 (reset),

	.enq_val	 (in1_val),
	.enq_rdy	 (in1_rdy_domain),
	.enq_msg	 (in1_domain),

	.deq_val	 (in1_deq_val_domain),
	.deq_rdy	 (in1_deq_rdy),
	.deq_msg	 (in1_deq_msg_domain)
  );


  // east sides queues for control signals

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in2_queue_control_d1
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in2_val_d1),
    .enq_rdy            (in2_rdy_control_d1),
    .enq_msg            (in2_msg_control_d1),

    .deq_val            (in2_deq_val_control_d1),
    .deq_rdy            (in2_deq_rdy_d1),
    .deq_msg            (in2_deq_msg_control_d1),

    .num_free_entries   (num_free2_control_d1)
  );

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in2_queue_control_d2
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in2_val_d2),
    .enq_rdy            (in2_rdy_control_d2),
    .enq_msg            (in2_msg_control_d2),

    .deq_val            (in2_deq_val_control_d2),
    .deq_rdy            (in2_deq_rdy_d2),
    .deq_msg            (in2_deq_msg_control_d2),

    .num_free_entries   (num_free2_control_d2)
  );

  wire [c_net_msg_cnbits-1:0]	in2_deq_msg_control;

  // 2 to 1 mux for input0 port

  vc_Mux2
  #(
	.p_nbits  (c_net_msg_cnbits)
  )
  in2_msg_control_mux
  (
	.in0		  (in2_deq_msg_control_d1),
	.in1		  (in2_deq_msg_control_d2),
	.sel		  (in2_reqs_domain),
	.out		  (in2_deq_msg_control)
  );

  // east sides queues for data signals

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_dnbits),
    .p_num_msgs   (2)
  )
  in2_queue_data_d1
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in2_val_d1),
    .enq_rdy            (in2_rdy_data_d1),
    .enq_msg            (in2_msg_data_d1),

    .deq_val            (in2_deq_val_data_d1),
    .deq_rdy            (in2_deq_rdy_d1),
    .deq_msg            (in2_deq_msg_data_d1),

    .num_free_entries   (num_free2_data_d1)
  );

  vc_Queue
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_dnbits),
    .p_num_msgs   (2)
  )
  in2_queue_data_d2
  (
    .clk                (clk),
    .reset              (reset),

    .enq_val            (in2_val_d2),
    .enq_rdy            (in2_rdy_data_d2),
    .enq_msg            (in2_msg_data_d2),

    .deq_val            (in2_deq_val_data_d2),
    .deq_rdy            (in2_deq_rdy_d2),
    .deq_msg            (in2_deq_msg_data_d2),

    .num_free_entries   (num_free2_data_d2)
  );

  wire [c_net_msg_dnbits-1:0]	in2_deq_msg_data;

  // 2 to 1 mux for input0 port

  vc_Mux2
  #(
	.p_nbits  (c_net_msg_dnbits)
  )
  in2_msg_data_mux
  (
	.in0		  (in2_deq_msg_data_d1),
	.in1		  (in2_deq_msg_data_d2),
	.sel		  (in2_reqs_domain),
	.out		  (in2_deq_msg_data)
  );

  //----------------------------------------------------------------------
  // Crossbar
  //----------------------------------------------------------------------

  wire [1:0] xbar_sel0;
  wire [1:0] xbar_sel1;
  wire [1:0] xbar_sel2;

  vc_Crossbar3
  #(
    .p_nbits    (c_net_msg_cnbits)
  )
  xbar_msg_control
  (
    .in0        (in0_deq_msg_control),
    .in1        (in1_deq_msg_control),
    .in2        (in2_deq_msg_control),

    .sel0       (xbar_sel0),
    .sel1       (xbar_sel1),
    .sel2       (xbar_sel2),

    .out0       (out0_msg_control),
    .out1       (out1_msg_control),
    .out2       (out2_msg_control)
  );

  vc_Crossbar3
  #(
    .p_nbits    (c_net_msg_dnbits)
  )
  xbar_msg_data
  (
    .in0        (in0_deq_msg_data),
    .in1        (in1_deq_msg_data),
    .in2        (in2_deq_msg_data),

    .sel0       (xbar_sel0),
    .sel1       (xbar_sel1),
    .sel2       (xbar_sel2),

    .out0       (out0_msg_data),
    .out1       (out1_msg_data),
    .out2       (out2_msg_data)
  );

  /*vc_Crossbar3
  #(
    .p_nbits    (1'b1)
  )
  xbar_reqs
  (
    .in0        (in0_reqs_domain),
    .in1        (in1_reqs_domain),
    .in2        (in2_reqs_domain),

    .sel0       (xbar_sel0),
    .sel1       (xbar_sel1),
    .sel2       (xbar_sel2),

    .out0       (out0_reqs_domain),
    .out1       (out1_reqs_domain),
    .out2       (out2_reqs_domain)
  );*/

  //----------------------------------------------------------------------
  // Input controls
  //----------------------------------------------------------------------

  wire in0_reqs_p0;
  wire in0_reqs_p1;
  wire in0_reqs_p2;
  wire in1_reqs_p0;
  wire in1_reqs_p1;
  wire in1_reqs_p2;
  wire in2_reqs_p0;
  wire in2_reqs_p1;
  wire in2_reqs_p2;

  wire in0_grants_p0;
  wire in0_grants_p1;
  wire in0_grants_p2;
  wire in1_grants_p0;
  wire in1_grants_p1;
  wire in1_grants_p2;
  wire in2_grants_p0;
  wire in2_grants_p1;
  wire in2_grants_p2;

  wire out0_reqs_p0;
  wire out0_reqs_p1;
  wire out0_reqs_p2;
  wire out1_reqs_p0;
  wire out1_reqs_p1;
  wire out1_reqs_p2;
  wire out2_reqs_p0;
  wire out2_reqs_p1;
  wire out2_reqs_p2;

  wire out0_grants_p0;
  wire out0_grants_p1;
  wire out0_grants_p2;
  wire out1_grants_p0;
  wire out1_grants_p1;
  wire out1_grants_p2;
  wire out2_grants_p0;
  wire out2_grants_p1;
  wire out2_grants_p2;

  wire [s-1:0] dest0_d1;
  wire [s-1:0] dest0_d2;
  wire [s-1:0] dest1;
  wire [s-1:0] dest2_d1;
  wire [s-1:0] dest2_d2;

  wire		   out0_reqs_domain;
  wire		   out1_reqs_domain;
  wire		   out2_reqs_domain;

  assign { out0_reqs_p2, out0_reqs_p1, out0_reqs_p0 }
	= { in2_reqs_p0, in1_reqs_p0, in0_reqs_p0 };
  assign { out1_reqs_p2, out1_reqs_p1, out1_reqs_p0 }
	= { in2_reqs_p1, in1_reqs_p1, in0_reqs_p1 };
  assign { out2_reqs_p2, out2_reqs_p1, out2_reqs_p0 }
	= { in2_reqs_p2, in1_reqs_p2, in0_reqs_p2 };

  assign { in0_grants_p2, in0_grants_p1, in0_grants_p0 }
	= { out2_grants_p0, out1_grants_p0, out0_grants_p0 };
  assign { in1_grants_p2, in1_grants_p1, in1_grants_p0 }
	= { out2_grants_p1, out1_grants_p1, out0_grants_p1 };
  assign { in2_grants_p2, in2_grants_p1, in2_grants_p0 }
	= { out2_grants_p2, out1_grants_p2, out0_grants_p2 };

  assign dest0_d1 = in0_deq_msg_control_d1[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest0_d2 = in0_deq_msg_control_d2[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest1    = in1_deq_msg_control[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest2_d1 = in2_deq_msg_control_d1[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest2_d2 = in2_deq_msg_control_d2[`VC_NET_MSG_DEST_FIELD(pc,o,s)];

  plab4_net_RouterInputCtrlArb_Sep
  #(
    .p_router_id    (p_router_id),
    .p_num_routers  (p_num_routers),
    .p_default_reqs (3'b100)
  )
  in0_ctrl
  (
	.clk	   (clk),
	//.reset	   (reset),

    .dest_d1   (dest0_d1),
	.dest_d2   (dest0_d2),

    .in_val_d1 (in0_deq_val_control_d1 && in0_deq_val_data_d1),
    .in_val_d2 (in0_deq_val_control_d2 && in0_deq_val_data_d2),
    .in_rdy_d1 (in0_deq_rdy_d1),
    .in_rdy_d2 (in0_deq_rdy_d2),

    .reqs_p0   (in0_reqs_p0),
    .reqs_p1   (in0_reqs_p1),
    .reqs_p2   (in0_reqs_p2),

    .grants_p0 (in0_grants_p0),
    .grants_p1 (in0_grants_p1),
	.grants_p2 (in0_grants_p2),

	.domain    (in0_reqs_domain)
  );

  wire [2:0]	num_free0 = num_free0_control_d1 + num_free0_control_d2;
  wire [2:0]	num_free2 = num_free2_control_d1 + num_free2_control_d2;

  plab4_net_RouterAdaptiveInputTerminalCtrl_Sep
  #(
    .p_router_id           (p_router_id),
    .p_num_routers         (p_num_routers),
    .p_num_free_nbits      (3),
    .p_num_free_chan_nbits (2)
  )
  in1_ctrl
  (
    .dest      (dest1),

    .in_val    (in1_deq_val_control && in1_deq_val_data),
    .in_rdy    (in1_deq_rdy),
	.in_domain (in1_deq_msg_domain),

    .num_free0 (num_free0),
    .num_free2 (num_free2),

    .num_free_chan0 (num_free_prev),
    .num_free_chan2 (num_free_next),

    .reqs_p0   (in1_reqs_p0),
	.reqs_p1   (in1_reqs_p1),
	.reqs_p2   (in1_reqs_p2),
    .grants_p0 (in1_grants_p0),
	.grants_p1 (in1_grants_p1),
	.grants_p2 (in1_grants_p2),


	.domain	   (in1_reqs_domain)
  );

  plab4_net_RouterInputCtrlArb_Sep
  #(
    .p_router_id    (p_router_id),
    .p_num_routers  (p_num_routers),
    .p_default_reqs (3'b001)
  )
  in2_ctrl
  (
	.clk	   (clk),
	//.reset	   (reset),

    .dest_d1   (dest2_d1),
	.dest_d2   (dest2_d2),

    .in_val_d1 (in2_deq_val_control_d1 && in2_deq_val_data_d1),
    .in_val_d2 (in2_deq_val_control_d2 && in2_deq_val_data_d2),
    .in_rdy_d1 (in2_deq_rdy_d1),
	.in_rdy_d2 (in2_deq_rdy_d2),

    .reqs_p0   (in2_reqs_p0),
    .reqs_p1   (in2_reqs_p1),
    .reqs_p2   (in2_reqs_p2),
    .grants_p0 (in2_grants_p0),
    .grants_p1 (in2_grants_p1),
    .grants_p2 (in2_grants_p2),

	.domain    (in2_reqs_domain)
  );

  //----------------------------------------------------------------------
  // Output controls
  //----------------------------------------------------------------------

  plab4_net_RouterOutputCtrl_sep #(req) out0_ctrl
  (
    .clk			(clk),
    .reset			(reset),

	.reqs_p0_domain	(in0_reqs_domain),
	.reqs_p1_domain	(in1_reqs_domain),
	.reqs_p2_domain (in2_reqs_domain),
	.out_domain		(out0_domain),

    .reqs_p0		(out0_reqs_p0),
    .reqs_p1		(out0_reqs_p1),
    .reqs_p2		(out0_reqs_p2),

    .grants_p0		(out0_grants_p0),
    .grants_p1		(out0_grants_p1),
    .grants_p2		(out0_grants_p2),

    .out_val		(out0_val),
    .out_rdy		(out0_rdy),
    .xbar_sel		(xbar_sel0)
  );

  plab4_net_RouterOutputCtrl_sep 
  #(
	.req(req),
	.ter(1) 
  )
  out1_ctrl
  (
    .clk			(clk),
    .reset			(reset),

	.reqs_p0_domain	(in0_reqs_domain),
	.reqs_p1_domain	(in1_reqs_domain),
	.reqs_p2_domain (in2_reqs_domain),
	.out_domain		(out1_domain),

    .reqs_p0		(out1_reqs_p0),
	.reqs_p1		(out1_reqs_p1),
	.reqs_p2		(out1_reqs_p2),

    .grants_p0      (out1_grants_p0),
	.grants_p1		(out1_grants_p1),
	.grants_p2		(out1_grants_p2),

    .out_val  (out1_val),
    .out_rdy  (out1_rdy),
    .xbar_sel (xbar_sel1)
  );

  plab4_net_RouterOutputCtrl_sep #(req) out2_ctrl
  (
    .clk			(clk),
    .reset			(reset),

	.reqs_p0_domain	(in0_reqs_domain),
	.reqs_p1_domain	(in1_reqs_domain),
	.reqs_p2_domain (in2_reqs_domain),
	.out_domain		(out2_domain),

    .reqs_p0	    (out2_reqs_p0),
	.reqs_p1		(out2_reqs_p1),
    .reqs_p2		(out2_reqs_p2),	
    .grants_p0		(out2_grants_p0),
	.grants_p1		(out2_grants_p1),
	.grants_p2		(out2_grants_p2),

    .out_val  (out2_val),
    .out_rdy  (out2_rdy),
    .xbar_sel (xbar_sel2)
  );

endmodule
`endif /* PLAB4_NET_ROUTER_ALT_SEP_V */

