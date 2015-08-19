//========================================================================
// Alternative Router
//========================================================================

`ifndef PLAB4_NET_ROUTER_ALT_V
`define PLAB4_NET_ROUTER_ALT_V

`include "vc-crossbar3.v"
`include "vc-crossbar3-sd.v"
`include "vc-mux2.v"
`include "vc-mux2-sd.v"
`include "vc-mux2-dd.v"
`include "vc-queues.v"
`include "vc-net-msgs.v"
`include "vc-mem-msgs.v"
`include "plab4-net-RouterInputCtrl-Arb.v"
`include "plab4-net-RouterAdaptiveInputTerminalCtrl.v"
`include "plab4-net-RouterOutputCtrl.v"

module plab4_net_RouterAlt
#(
  parameter p_payload_cnbits = 32,
  parameter p_payload_dnbits = 32, 
  parameter p_opaque_nbits   = 3,
  parameter p_srcdest_nbits  = 3,

  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,

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
  input                        {L}	clk,
  input                        {L}	reset,

  input                        {L}  domain,

  input                        {D1}	in0_val_d1,
  output                       {D1}	in0_rdy_d1,
  input  [c_net_msg_cnbits-1:0]{D1}	in0_msg_control_d1,
  input  [c_net_msg_dnbits-1:0]{D1}	in0_msg_data_d1,

  input                        {D2}	in0_val_d2,
  output                       {D2}	in0_rdy_d2,
  input  [c_net_msg_cnbits-1:0]{D2}	in0_msg_control_d2,
  input  [c_net_msg_dnbits-1:0]{D2}	in0_msg_data_d2,

  input                        {Control domain}	in1_val,
  output                       {Control domain}	in1_rdy,
  input  [c_net_msg_cnbits-1:0]{Control domain}	in1_msg_control,
  input  [c_net_msg_dnbits-1:0]{Domain  domain}	in1_msg_data,
  output					   {L}	in1_reqs_domain,

  input                        {D1}	in2_val_d1,
  output                       {D1}	in2_rdy_d1,
  input  [c_net_msg_cnbits-1:0]{D1}	in2_msg_control_d1,
  input  [c_net_msg_dnbits-1:0]{D1}	in2_msg_data_d1,

  input                        {D2}	in2_val_d2,
  output                       {D2}	in2_rdy_d2,
  input  [c_net_msg_cnbits-1:0]{D2}	in2_msg_control_d2,
  input  [c_net_msg_dnbits-1:0]{D2}	in2_msg_data_d2,

  output                       {Control out0_domain}	out0_val,
  input                        {Control out0_domain}	out0_rdy,
  output [c_net_msg_cnbits-1:0]{Control out0_domain}	out0_msg_control,
  output [c_net_msg_dnbits-1:0]{Domain out0_domain}		out0_msg_data,
  output					   {L}	                    out0_domain,

  output                       {Control out1_domain}	out1_val,
/ input                        {Control out1_domain}	out1_rdy,
  output [c_net_msg_cnbits-1:0]{Control out1_domain}	out1_msg_control,
  output [c_net_msg_dnbits-1:0]{Domain  out1_domain}	out1_msg_data,
  output					   {L}	                    out1_domain,

  output                       {Control out2_domain}	out2_val,
  input                        {Control out2_domain}	out2_rdy,
  output [c_net_msg_cnbits-1:0]{Control out2_domain}	out2_msg_control,
  output [c_net_msg_dnbits-1:0]{Domain  out2_domain}	out2_msg_data,
  output					   {L}	                    out2_domain,

  input [p_num_free_nbits-1:0] {Control domain}	num_free_prev,
  input [p_num_free_nbits-1:0] {Control domain}	num_free_next
);


  assign in0_rdy_d1 = (domain == in1_reqs_domain) ? (in0_rdy_control_d1 && in0_rdy_data_d1) : 0;
  assign in0_rdy_d2 = (domain == in1_reqs_domain) ? (in0_rdy_control_d2 && in0_rdy_data_d2) : 0;
  assign in1_rdy	= (domain == in1_reqs_domain) ? (in1_rdy_control	&& in1_rdy_data   ) : 0;
  assign in2_rdy_d1 = (domain == in1_reqs_domain) ? (in2_rdy_control_d1 && in2_rdy_data_d1) : 0;
  assign in2_rdy_d2 = (domain == in1_reqs_domain) ? (in2_rdy_control_d2 && in2_rdy_data_d2) : 0;
  //----------------------------------------------------------------------
  // Input queues
  //----------------------------------------------------------------------

  wire						 {D1}	in0_rdy_control_d1;
  wire						 {D1}	in0_rdy_data_d1;
  wire                       {D1}	in0_deq_val_control_d1;
  wire						 {D1}	in0_deq_val_data_d1;
  wire                       {D1}	in0_deq_rdy_d1;
  wire [c_net_msg_cnbits-1:0]{D1}	in0_deq_msg_control_d1;
  wire [c_net_msg_dnbits-1:0]{D1}	in0_deq_msg_data_d1;
  wire [1:0]                 {L}	num_free0_control_d1;
  wire [1:0]                 {L}	num_free0_data_d1;

  wire						 {D2}	in0_rdy_control_d2;
  wire						 {D2}	in0_rdy_data_d2;
  wire                       {D2}	in0_deq_val_control_d2;
  wire                       {D2}	in0_deq_val_data_d2;
  wire                       {D2}	in0_deq_rdy_d2;
  wire [c_net_msg_cnbits-1:0]{D2}	in0_deq_msg_control_d2;
  wire [c_net_msg_dnbits-1:0]{D2}	in0_deq_msg_data_d2;
  wire [1:0]                 {L}	num_free0_control_d2;
  wire [1:0]                 {L}	num_free0_data_d2;

  wire						 {Control in1_reqs_domain}	in1_rdy_control;
  wire						 {Control in1_reqs_domain}	in1_rdy_data;
  wire                       {Control in1_reqs_domain}	in1_deq_val_control;
  wire						 {Control in1_reqs_domain}	in1_deq_val_data;
  wire                       {Control in1_reqs_domain}	in1_deq_rdy;
  wire [c_net_msg_cnbits-1:0]{Control in1_reqs_domain}	in1_deq_msg_control;
  wire [c_net_msg_dnbits-1:0]{Domain in1_reqs_domain}	in1_deq_msg_data;

  wire						 {D1}	in2_rdy_control_d1;
  wire						 {D1}	in2_rdy_data_d1;
  wire                       {D1}	in2_deq_val_control_d1;
  wire						 {D1}	in2_deq_val_data_d1;
  wire                       {D1}	in2_deq_rdy_d1;
  wire [c_net_msg_cnbits-1:0]{D1}	in2_deq_msg_control_d1;
  wire [c_net_msg_dnbits-1:0]{D1}	in2_deq_msg_data_d1;
  wire [1:0]                 {L}	num_free2_control_d1;
  wire [1:0]                 {L}	num_free2_data_d1;

  wire						 {D2}	in2_rdy_control_d2;
  wire						 {D2}	in2_rdy_data_d2;
  wire                       {D2}	in2_deq_val_control_d2;
  wire                       {D2}	in2_deq_val_data_d2;
  wire                       {D2}	in2_deq_rdy_d2;
  wire [c_net_msg_cnbits-1:0]{D2}	in2_deq_msg_control_d2;
  wire [c_net_msg_dnbits-1:0]{D2}	in2_deq_msg_data_d2;
  wire [1:0]                 {L}	num_free2_control_d2;
  wire [1:0]                 {L}	num_free2_data_d2;

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

	.domain				(0),

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

	.domain 			(1),

    .enq_val            (in0_val_d2),
    .enq_rdy            (in0_rdy_control_d2),
    .enq_msg            (in0_msg_control_d2),

    .deq_val            (in0_deq_val_control_d2),
    .deq_rdy            (in0_deq_rdy_d2),
    .deq_msg            (in0_deq_msg_control_d2),

    .num_free_entries   (num_free0_control_d2)
  );

  wire [c_net_msg_cnbits-1:0]	{L}	in0_deq_msg_control;

  // 2 to 1 mux for input0 signal port

  vc_Mux2_dd
  #(
	.p_nbits  (c_net_msg_cnbits)
  )
  in0_msg_control_mux
  (
	.in0		  (in0_deq_msg_control_d1),
	.in1		  (in0_deq_msg_control_d2),
    .in0_domain   (0),
    .in1_domain   (1),
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

	.domain				(0),

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

	.domain				(1),

    .enq_val            (in0_val_d2),
    .enq_rdy            (in0_rdy_data_d2),
    .enq_msg            (in0_msg_data_d2),

    .deq_val            (in0_deq_val_data_d2),
    .deq_rdy            (in0_deq_rdy_d2),
    .deq_msg            (in0_deq_msg_data_d2),

    .num_free_entries   (num_free0_data_d2)
  );

  wire [c_net_msg_dnbits-1:0] {Domain in0_reqs_domain}	in0_deq_msg_data;

  // 2 to 1 mux for input0 signal port

  vc_Mux2_dd
  #(
	.p_nbits  (c_net_msg_dnbits)
  )
  in0_msg_data_mux
  (
	.in0		  (in0_deq_msg_data_d1),
	.in1		  (in0_deq_msg_data_d2),
	.in0_domain	  (0),
	.in1_domain	  (1),
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

	.domain		(in1_reqs_domain),

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

	.domain		(in1_reqs_domain),

    .enq_val    (in1_val),
    .enq_rdy    (in1_rdy_data),
    .enq_msg    (in1_msg_data),

    .deq_val    (in1_deq_val_data),
    .deq_rdy    (in1_deq_rdy),
    .deq_msg    (in1_deq_msg_data)
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

	.domain				(0),

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

	.domain				(1),

    .enq_val            (in2_val_d2),
    .enq_rdy            (in2_rdy_control_d2),
    .enq_msg            (in2_msg_control_d2),

    .deq_val            (in2_deq_val_control_d2),
    .deq_rdy            (in2_deq_rdy_d2),
    .deq_msg            (in2_deq_msg_control_d2),

    .num_free_entries   (num_free2_control_d2)
  );

  wire [c_net_msg_cnbits-1:0]	{L}	in2_deq_msg_control;

  // 2 to 1 mux for input0 port

  vc_Mux2_sd
  #(
	.p_nbits  (c_net_msg_cnbits)
  )
  in2_msg_control_mux
  (
	.in0		  (in2_deq_msg_control_d1),
	.in1		  (in2_deq_msg_control_d2),
	.domain	  	  (2),
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

	.domain				(0),

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

	.domain				(1),

    .enq_val            (in2_val_d2),
    .enq_rdy            (in2_rdy_data_d2),
    .enq_msg            (in2_msg_data_d2),

    .deq_val            (in2_deq_val_data_d2),
    .deq_rdy            (in2_deq_rdy_d2),
    .deq_msg            (in2_deq_msg_data_d2),

    .num_free_entries   (num_free2_data_d2)
  );

  wire [c_net_msg_dnbits-1:0]	{Domain in2_reqs_domain}	in2_deq_msg_data;

  // 2 to 1 mux for input0 port

  vc_Mux2_dd
  #(
	.p_nbits  (c_net_msg_dnbits)
  )
  in2_msg_data_mux
  (
	.in0		  (in2_deq_msg_data_d1),
	.in1		  (in2_deq_msg_data_d2),
	.in0_domain	  (0),
	.in1_domain	  (1),
	.sel		  (in2_reqs_domain),
	.out		  (in2_deq_msg_data)
  );

  //----------------------------------------------------------------------
  // Crossbar
  //----------------------------------------------------------------------

  wire [1:0] {L}	xbar_sel0;
  wire [1:0] {L}	xbar_sel1;
  wire [1:0] {L}	xbar_sel2;

  wire [0:0] {L}	out0_msg_data_domain;
  wire [0:0] {L}	out1_msg_data_domain;
  wire [0:0] {L}	out2_msg_data_domain;

  vc_Crossbar3_sd
  #(
    .p_nbits    (c_net_msg_cnbits)
  )
  xbar_msg_control
  (
	.domain		(2),

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

	.in0_domain	(in0_reqs_domain),
	.in1_domain	(in1_reqs_domain),
	.in2_domain	(in2_reqs_domain),

    .sel0       (xbar_sel0),
    .sel1       (xbar_sel1),
    .sel2       (xbar_sel2),

    .out0       (out0_msg_data),
    .out1       (out1_msg_data),
    .out2       (out2_msg_data),

	.out0_domain(out0_msg_data_domain),
	.out1_domain(out1_msg_data_domain),
	.out2_domain(out2_msg_data_domain)
  );

  vc_Crossbar3_sd
  #(
    .p_nbits    (1'b1)
  )
  xbar_reqs
  (
	.domain		(2),

    .in0        (in0_reqs_domain),
    .in1        (in1_reqs_domain),
    .in2        (in2_reqs_domain),

    .sel0       (xbar_sel0),
    .sel1       (xbar_sel1),
    .sel2       (xbar_sel2),

    .out0       (out0_reqs_domain),
    .out1       (out1_reqs_domain),
    .out2       (out2_reqs_domain)
  );

  //----------------------------------------------------------------------
  // Input controls
  //----------------------------------------------------------------------

  wire [2:0] {L}	in0_reqs;
  wire [2:0] {L}	in1_reqs;
  wire [2:0] {L}	in2_reqs;

  wire [2:0] {L}	in0_grants;
  wire [2:0] {L}	in1_grants;
  wire [2:0] {L}	in2_grants;

  wire [2:0] {L}	out0_reqs;
  wire [2:0] {L}	out1_reqs;
  wire [2:0] {L}	out2_reqs;

  wire [2:0] {L}	out0_grants;
  wire [2:0] {L}	out1_grants;
  wire [2:0] {L}	out2_grants;

  wire [s-1:0] {L}	dest0_d1;
  wire [s-1:0] {L}	dest0_d2;
  wire [s-1:0] {L}	dest1;
  wire [s-1:0] {L}	dest2_d1;
  wire [s-1:0] {L}	dest2_d2;

  wire		   {L}	in0_reqs_domain;
  wire		   {L}	in1_reqs_domain;
  wire		   {L}	in2_reqs_domain;

  wire		   {L}	out0_reqs_domain;
  wire		   {L}	out1_reqs_domain;
  wire		   {L}	out2_reqs_domain;

  assign out0_reqs  = { in2_reqs[0], in1_reqs[0], in0_reqs[0] };
  assign out1_reqs  = { in2_reqs[1], in1_reqs[1], in0_reqs[1] };
  assign out2_reqs  = { in2_reqs[2], in1_reqs[2], in0_reqs[2] };

  assign in0_grants = { out2_grants[0], out1_grants[0], out0_grants[0] };
  assign in1_grants = { out2_grants[1], out1_grants[1], out0_grants[1] };
  assign in2_grants = { out2_grants[2], out1_grants[2], out0_grants[2] };

  assign dest0_d1 = in0_deq_msg_control_d1[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest0_d2 = in0_deq_msg_control_d2[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest1    = in1_deq_msg_control[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest2_d1 = in2_deq_msg_control_d1[`VC_NET_MSG_DEST_FIELD(pc,o,s)];
  assign dest2_d2 = in2_deq_msg_control_d2[`VC_NET_MSG_DEST_FIELD(pc,o,s)];

  plab4_net_RouterInputCtrlArb
  #(
    .p_router_id    (p_router_id),
    .p_num_routers  (p_num_routers),
    .p_default_reqs (3'b100)
  )
  in0_ctrl
  (
    .dest_d1   (dest0_d1),
	.dest_d2   (dest0_d2),

    .in_val_d1 (in0_deq_val_control_d1 && in0_deq_val_data_d1),
    .in_val_d2 (in0_deq_val_control_d2 && in0_deq_val_data_d2),
    .in_rdy_d1 (in0_deq_rdy_d1),
    .in_rdy_d2 (in0_deq_rdy_d2),

    .reqs	   (in0_reqs),
    .grants	   (in0_grants),

	.domain    (in0_reqs_domain)
  );

  wire [2:0]	{L}	num_free0 = num_free0_control_d1 + num_free0_control_d2;
  wire [2:0]	{L}	num_free2 = num_free2_control_d1 + num_free2_control_d2;

  plab4_net_RouterAdaptiveInputTerminalCtrl
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

    .num_free0 (num_free0),
    .num_free2 (num_free2),

    .num_free_chan0 (num_free_prev),
    .num_free_chan2 (num_free_next),

    .reqs      (in1_reqs),
    .grants    (in1_grants),

	.domain	   (in1_reqs_domain)
  );

  plab4_net_RouterInputCtrlArb
  #(
    .p_router_id    (p_router_id),
    .p_num_routers  (p_num_routers),
    .p_default_reqs (3'b001)
  )
  in2_ctrl
  (
    .dest_d1   (dest2_d1),
	.dest_d2   (dest2_d2),

    .in_val_d1 (in2_deq_val_control_d1 && in2_deq_val_data_d1),
    .in_val_d2 (in2_deq_val_control_d2 && in2_deq_val_data_d2),
    .in_rdy_d1 (in2_deq_rdy_d1),
	.in_rdy_d2 (in2_deq_rdy_d2),

    .reqs      (in2_reqs),
    .grants    (in2_grants),

	.domain    (in2_reqs_domain)
  );

  //----------------------------------------------------------------------
  // Output controls
  //----------------------------------------------------------------------

  plab4_net_RouterOutputCtrl out0_ctrl
  (
    .clk      (clk),
    .reset    (reset),

	.reqs_domain(out0_reqs_domain),
	.out_domain	(out0_domain),

    .reqs     (out0_reqs),
    .grants   (out0_grants),

    .out_val  (out0_val),
    .out_rdy  (out0_rdy),
    .xbar_sel (xbar_sel0)
  );

  plab4_net_RouterOutputCtrl out1_ctrl
  (
    .clk      (clk),
    .reset    (reset),

	.reqs_domain (out1_reqs_domain),
	.reqs_domain (out1_domain),

    .reqs     (out1_reqs),
    .grants   (out1_grants),

    .out_val  (out1_val),
    .out_rdy  (out1_rdy),
    .xbar_sel (xbar_sel1)
  );

  plab4_net_RouterOutputCtrl out2_ctrl
  (
    .clk      (clk),
    .reset    (reset),

	.reqs_domain(out2_reqs_domain),
	.out_domain	(out2_domain),

    .reqs     (out2_reqs),
    .grants   (out2_grants),

    .out_val  (out2_val),
    .out_rdy  (out2_rdy),
    .xbar_sel (xbar_sel2)
  );

endmodule
`endif /* PLAB4_NET_ROUTER_ALT_V */
