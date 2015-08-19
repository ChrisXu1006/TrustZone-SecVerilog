//========================================================================
// Alternative Router
//========================================================================

`ifndef PLAB4_NET_ROUTER_ALT_SEP_V
`define PLAB4_NET_ROUTER_ALT_SEP_V

`include "vc-net-msgsunpack.v"
`include "vc-mux2-dd.v"
`include "vc-queues.v"
`include "vc-mem-msgs.v"
`include "plab4-net-RouterInputCtrl-Arb-Sep.v"
`include "plab4-net-RouterAdaptiveInputTerminalCtrl-Sep.v"
`include "plab4-net-RouterOutputCtrl-Sep.v"
`include "plab4-net-RouterOutputCtrl-Sep-insecure.v"

module plab4_net_RouterAlt_Sep
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
  input                        {L} clk,
  input                        {L} reset,

  input                        {L} req,
  input                        {L} domain,

  input                        {D1} in0_val_d1,
  output                       {D1} in0_rdy_d1,
  input  [c_net_msg_cnbits-1:0]{D1} in0_msg_control_d1,
  input  [c_net_msg_dnbits-1:0]{D1} in0_msg_data_d1,

  input                        {L} in0_val_d2,
  output                       {L} in0_rdy_d2,
  input  [c_net_msg_cnbits-1:0]{L} in0_msg_control_d2,
  input  [c_net_msg_dnbits-1:0]{D2} in0_msg_data_d2,

  input                        {Ctrl domain} in1_val,
  output                       {Ctrl domain} in1_rdy,
  input  [c_net_msg_cnbits-1:0]{Ctrl domain} in1_msg_control,
  input  [c_net_msg_dnbits-1:0]{Data domain} in1_msg_data,

  input                        {D1} in2_val_d1,
  output                       {D1} in2_rdy_d1,
  input  [c_net_msg_cnbits-1:0]{D1} in2_msg_control_d1,
  input  [c_net_msg_dnbits-1:0]{D1} in2_msg_data_d1,

  input                        {L} in2_val_d2,
  output                       {L} in2_rdy_d2,
  input  [c_net_msg_cnbits-1:0]{L} in2_msg_control_d2,
  input  [c_net_msg_dnbits-1:0]{D2} in2_msg_data_d2,

  output                       {Ctrl out0_domain} out0_val,
  input                        {Ctrl out0_domain} out0_rdy,
  output reg [c_net_msg_cnbits-1:0]{Ctrl out0_domain} out0_msg_control,
  output reg [c_net_msg_dnbits-1:0]{Data out0_domain} out0_msg_data,
  output					   {L} out0_domain,

  output                       {Ctrl out1_domain} out1_val,
  input                        {Ctrl out1_domain} out1_rdy,
  output reg [c_net_msg_cnbits-1:0]{Ctrl out1_domain} out1_msg_control,
  output reg [c_net_msg_dnbits-1:0]{Data out1_domain} out1_msg_data,
  output                       {L} out1_domain,

  output                       {Ctrl out2_domain} out2_val,
  input                        {Ctrl out2_domain} out2_rdy,
  output reg [c_net_msg_cnbits-1:0]{Ctrl out2_domain} out2_msg_control,
  output reg [c_net_msg_dnbits-1:0]{Data out2_domain} out2_msg_data,
  output					   {L} out2_domain,

  input [p_num_free_nbits-1:0] {Ctrl domain} num_free_prev,
  input [p_num_free_nbits-1:0] {Ctrl domain} num_free_next
);

  assign in0_rdy_d1 = in0_rdy_control_d1 && in0_rdy_data_d1;
  assign in0_rdy_d2 = in0_rdy_control_d2 && in0_rdy_data_d2;
  assign in1_rdy	= in1_rdy_control	 && in1_rdy_data;
  assign in2_rdy_d1 = in2_rdy_control_d1 && in2_rdy_data_d1;
  assign in2_rdy_d2 = in2_rdy_control_d2 && in2_rdy_data_d2;
  //----------------------------------------------------------------------
  // Input queues
  //----------------------------------------------------------------------

  wire						 {D1} in0_rdy_control_d1;
  wire						 {D1} in0_rdy_data_d1;
  wire                       {D1} in0_deq_val_control_d1;
  wire						 {D1} in0_deq_val_data_d1;
  wire                       {D1} in0_deq_rdy_d1;
  wire [c_net_msg_cnbits-1:0]{D1} in0_deq_msg_control_d1;
  wire [c_net_msg_dnbits-1:0]{D1} in0_deq_msg_data_d1;
  wire [1:0]                 {D1}  num_free0_control_d1;
  wire [1:0]                 {D1}  num_free0_data_d1;

  wire						 {L} in0_rdy_control_d2;
  wire						 {L} in0_rdy_data_d2;
  wire                       {L} in0_deq_val_control_d2;
  wire                       {L} in0_deq_val_data_d2;
  wire                       {L} in0_deq_rdy_d2;
  wire [c_net_msg_cnbits-1:0]{L} in0_deq_msg_control_d2;
  wire [c_net_msg_dnbits-1:0]{D2} in0_deq_msg_data_d2;
  wire [1:0]                 {L}  num_free0_control_d2;
  wire [1:0]                 {L}  num_free0_data_d2;

  wire						 {Ctrl domain} in1_rdy_control;
  wire						 {Ctrl domain} in1_rdy_data;
  wire                       {Ctrl domain} in1_deq_val_control;
  wire						 {Ctrl domain} in1_deq_val_data;
  wire                       {Ctrl domain} in1_deq_rdy;
  wire [c_net_msg_cnbits-1:0]{Ctrl domain} in1_deq_msg_control;
  wire [c_net_msg_dnbits-1:0]{Data domain} in1_deq_msg_data;

  wire						 {D1} in2_rdy_control_d1;
  wire						 {D1} in2_rdy_data_d1;
  wire                       {D1} in2_deq_val_control_d1;
  wire						 {D1} in2_deq_val_data_d1;
  wire                       {D1} in2_deq_rdy_d1;
  wire [c_net_msg_cnbits-1:0]{D1} in2_deq_msg_control_d1;
  wire [c_net_msg_dnbits-1:0]{D1} in2_deq_msg_data_d1;
  wire [1:0]                 {D1} num_free2_control_d1;
  wire [1:0]                 {D1} num_free2_data_d1;

  wire						 {L} in2_rdy_control_d2;
  wire						 {L} in2_rdy_data_d2;
  wire                       {L} in2_deq_val_control_d2;
  wire                       {L} in2_deq_val_data_d2;
  wire                       {L} in2_deq_rdy_d2;
  wire [c_net_msg_cnbits-1:0]{L} in2_deq_msg_control_d2;
  wire [c_net_msg_dnbits-1:0]{D2} in2_deq_msg_data_d2;
  wire [1:0]                 {L}  num_free2_control_d2;
  wire [1:0]                 {L}  num_free2_data_d2;

  // west side queue for control signals

  vc_Queue_Ctrl
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in0_queue_control_d1
  (
    .clk                (clk),
    .reset              (reset),

    .enq_domain         (0),
    .enq_val            (in0_val_d1),
    .enq_rdy            (in0_rdy_control_d1),
    .enq_msg            (in0_msg_control_d1),

    .deq_domain         (0),
    .deq_val            (in0_deq_val_control_d1),
    .deq_rdy            (in0_deq_rdy_d1),
    .deq_msg            (in0_deq_msg_control_d1),

    .num_free_entries   (num_free0_control_d1)
  );

  vc_Queue_Ctrl
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in0_queue_control_d2
  (
    .clk                (clk),
    .reset              (reset),

    .enq_domain         (1),
    .enq_val            (in0_val_d2),
    .enq_rdy            (in0_rdy_control_d2),
    .enq_msg            (in0_msg_control_d2),

    .deq_domain         (1),
    .deq_val            (in0_deq_val_control_d2),
    .deq_rdy            (in0_deq_rdy_d2),
    .deq_msg            (in0_deq_msg_control_d2),

    .num_free_entries   (num_free0_control_d2)
  );

  wire [c_net_msg_cnbits-1:0]	{Ctrl in0_reqs_domain} in0_deq_msg_control;

  // 2 to 1 mux for input0 signal port

  vc_Mux2_dd_Ctrl
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

    .enq_domain         (0),
    .enq_val            (in0_val_d1),
    .enq_rdy            (in0_rdy_data_d1),
    .enq_msg            (in0_msg_data_d1),

    .deq_domain         (0),
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

    .enq_domain         (1),
    .enq_val            (in0_val_d2),
    .enq_rdy            (in0_rdy_data_d2),
    .enq_msg            (in0_msg_data_d2),

    .deq_domain         (1),
    .deq_val            (in0_deq_val_data_d2),
    .deq_rdy            (in0_deq_rdy_d2),
    .deq_msg            (in0_deq_msg_data_d2),

    .num_free_entries   (num_free0_data_d2)
  );

  wire [c_net_msg_dnbits-1:0]	{Data in0_reqs_domain} in0_deq_msg_data;

  // 2 to 1 mux for input0 signal port

  vc_Mux2_dd
  #(
	.p_nbits  (c_net_msg_dnbits)
  )
  in0_msg_data_mux
  (
	.in0		  (in0_deq_msg_data_d1),
	.in1		  (in0_deq_msg_data_d2),
    .in0_domain   (0),
    .in1_domain   (1),
	.sel		  (in0_reqs_domain),
	.out		  (in0_deq_msg_data)
  );

  // Terminal side's queues

  vc_Queue_Ctrl
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in1_control_queue
  (
    .clk        (clk),
    .reset      (reset),

    .enq_domain (domain),
    .enq_val    (in1_val),
    .enq_rdy    (in1_rdy_control),
    .enq_msg    (in1_msg_control),

    .deq_domain (domain),
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

    .enq_domain (domain),
    .enq_val    (in1_val),
    .enq_rdy    (in1_rdy_data),
    .enq_msg    (in1_msg_data),

    .deq_domain (domain),
    .deq_val    (in1_deq_val_data),
    .deq_rdy    (in1_deq_rdy),
    .deq_msg    (in1_deq_msg_data)
  );

  // east sides queues for control signals

  vc_Queue_Ctrl
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in2_queue_control_d1
  (
    .clk                (clk),
    .reset              (reset),

    .enq_domain         (0),
    .enq_val            (in2_val_d1),
    .enq_rdy            (in2_rdy_control_d1),
    .enq_msg            (in2_msg_control_d1),

    .deq_domain         (0),
    .deq_val            (in2_deq_val_control_d1),
    .deq_rdy            (in2_deq_rdy_d1),
    .deq_msg            (in2_deq_msg_control_d1),

    .num_free_entries   (num_free2_control_d1)
  );

  vc_Queue_Ctrl
  #(
    .p_type       (`VC_QUEUE_NORMAL),
    .p_msg_nbits  (c_net_msg_cnbits),
    .p_num_msgs   (2)
  )
  in2_queue_control_d2
  (
    .clk                (clk),
    .reset              (reset),

    .enq_domain         (1),
    .enq_val            (in2_val_d2),
    .enq_rdy            (in2_rdy_control_d2),
    .enq_msg            (in2_msg_control_d2),

    .deq_domain         (1),
    .deq_val            (in2_deq_val_control_d2),
    .deq_rdy            (in2_deq_rdy_d2),
    .deq_msg            (in2_deq_msg_control_d2),

    .num_free_entries   (num_free2_control_d2)
  );

  wire [c_net_msg_cnbits-1:0]	{Ctrl in2_reqs_domain} in2_deq_msg_control;

  // 2 to 1 mux for input0 port

  vc_Mux2_dd_Ctrl
  #(
	.p_nbits  (c_net_msg_cnbits)
  )
  in2_msg_control_mux
  (
	.in0		  (in2_deq_msg_control_d1),
	.in1		  (in2_deq_msg_control_d2),
    .in0_domain   (0),
    .in1_domain   (1),
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

    .enq_domain         (0),
    .enq_val            (in2_val_d1),
    .enq_rdy            (in2_rdy_data_d1),
    .enq_msg            (in2_msg_data_d1),

    .deq_domain         (0),
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

    .enq_domain         (1),
    .enq_val            (in2_val_d2),
    .enq_rdy            (in2_rdy_data_d2),
    .enq_msg            (in2_msg_data_d2),

    .deq_domain         (1),
    .deq_val            (in2_deq_val_data_d2),
    .deq_rdy            (in2_deq_rdy_d2),
    .deq_msg            (in2_deq_msg_data_d2),

    .num_free_entries   (num_free2_data_d2)
  );

  wire [c_net_msg_dnbits-1:0]	{Data in2_reqs_domain} in2_deq_msg_data;

  // 2 to 1 mux for input0 port

  vc_Mux2_dd
  #(
	.p_nbits  (c_net_msg_dnbits)
  )
  in2_msg_data_mux
  (
	.in0		  (in2_deq_msg_data_d1),
	.in1		  (in2_deq_msg_data_d2),
    .in0_domain   (0),
    .in1_domain   (1),
	.sel		  (in2_reqs_domain),
	.out		  (in2_deq_msg_data)
  );

  //----------------------------------------------------------------------
  // Crossbar
  //----------------------------------------------------------------------

  wire [1:0] {Ctrl in0_reqs_domain join Ctrl domain join Ctrl in2_reqs_domain} xbar_sel0;
  wire [1:0] {Ctrl in0_reqs_domain join Ctrl domain join Ctrl in2_reqs_domain} xbar_sel1;
  wire [1:0] {Ctrl in0_reqs_domain join Ctrl domain join Ctrl in2_reqs_domain} xbar_sel2;

  always @(*) begin
    if ( xbar_sel0 == 2'd0 ) begin
        out0_domain = in0_reqs_domain;
        out0_msg_control = in0_deq_msg_control;
    end
    else if ( xbar_sel0 == 2'd1 ) begin
        out0_domain = domain;
        out0_msg_control = in1_deq_msg_control;
    end
    else if ( xbar_sel0 == 2'd2 ) begin
        out0_domain = in2_reqs_domain;
        out0_msg_control = in2_deq_msg_control;
    end

    if ( xbar_sel1 == 2'd0 ) begin
        out1_domain = in0_reqs_domain; 
        out1_msg_control = in0_deq_msg_control;
    end
    else if ( xbar_sel1 == 2'd1 ) begin
        out1_domain = domain;
        out1_msg_control = in1_deq_msg_control;
    end
    else if ( xbar_sel2 == 2'd2 ) begin
        out1_domain = in2_reqs_domain;
        out1_msg_control = in2_deq_msg_control;
    end

    if ( xbar_sel2 == 2'd0 ) begin
        out2_domain = in0_reqs_domain; 
        out2_msg_control = in0_deq_msg_control;
    end
    else if ( xbar_sel2 == 2'd1 ) begin
        out2_domain = domain;
        out2_msg_control = in1_deq_msg_control;
    end
    else if ( xbar_sel2 == 2'd2 ) begin
        out2_domain = in2_reqs_domain;
        out2_msg_control = in2_deq_msg_control;
    end
  end

  always @(*) begin
    if ( xbar_sel0 == 2'd0 ) begin 
        out0_domain = in0_reqs_domain;
        out0_msg_data = in0_deq_msg_data;
    end
    else if ( xbar_sel0 == 2'd1 ) begin
        out0_domain = domain;
        out0_msg_data = in1_deq_msg_data;
    end
    else if ( xbar_sel0 == 2'd2 ) begin
        out0_domain = in2_reqs_domain;
        out0_msg_data = in2_deq_msg_data;
    end

    if ( xbar_sel1 == 2'd0 ) begin
        out1_domain = in0_reqs_domain; 
        out1_msg_data = in0_deq_msg_data;
    end
    else if ( xbar_sel1 == 2'd1 ) begin
        out1_domain = domain;
        out1_msg_data = in1_deq_msg_data;
    end
    else if ( xbar_sel2 == 2'd2 ) begin
        out1_domain = in2_reqs_domain;
        out1_msg_data = in2_deq_msg_data;
    end

    if ( xbar_sel2 == 2'd0 ) begin
        out2_domain = in0_reqs_domain;
        out2_msg_data = in0_deq_msg_data;
    end
    else if ( xbar_sel2 == 2'd1 ) begin
        out2_domain = domain;
        out2_msg_data = in1_deq_msg_data;
    end
    else if ( xbar_sel2 == 2'd2 ) begin
        out2_domain = in2_reqs_domain;
        out2_msg_data = in2_deq_msg_data;
    end
  end
  /*vc_Crossbar3
  #(
    .p_nbits    (1'b1)
  )
  xbar_reqs
  (
    .in0        (in0_reqs_domain),
    .in1        (domain),
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

  wire {Ctrl in0_reqs_domain} in0_reqs_p0;
  wire {Ctrl in0_reqs_domain} in0_reqs_p1;
  wire {Ctrl in0_reqs_domain} in0_reqs_p2;
  wire {Ctrl domain} in1_reqs_p0;
  wire {Ctrl domain} in1_reqs_p1;
  wire {Ctrl domain} in1_reqs_p2;
  wire {Ctrl in2_reqs_domain} in2_reqs_p0;
  wire {Ctrl in2_reqs_domain} in2_reqs_p1;
  wire {Ctrl in2_reqs_domain} in2_reqs_p2;

  wire {Ctrl in0_reqs_domain} in0_grants_p0;
  wire {Ctrl in0_reqs_domain} in0_grants_p1;
  wire {Ctrl in0_reqs_domain} in0_grants_p2;
  wire {Ctrl domain} in1_grants_p0;
  wire {Ctrl domain} in1_grants_p1;
  wire {Ctrl domain} in1_grants_p2;
  wire {Ctrl in2_reqs_domain} in2_grants_p0;
  wire {Ctrl in2_reqs_domain} in2_grants_p1;
  wire {Ctrl in2_reqs_domain} in2_grants_p2;

  wire {Ctrl in0_reqs_domain} out0_reqs_p0;
  wire {Ctrl domain} out0_reqs_p1;
  wire {Ctrl in2_reqs_domain} out0_reqs_p2;
  wire {Ctrl in0_reqs_domain} out1_reqs_p0;
  wire {Ctrl domain} out1_reqs_p1;
  wire {Ctrl in2_reqs_domain} out1_reqs_p2;
  wire {Ctrl in0_reqs_domain} out2_reqs_p0;
  wire {Ctrl domain} out2_reqs_p1;
  wire {Ctrl in2_reqs_domain} out2_reqs_p2;

  wire {Ctrl in0_reqs_domain} out0_grants_p0;
  wire {Ctrl domain} out0_grants_p1;
  wire {Ctrl in2_reqs_domain} out0_grants_p2;
  wire {Ctrl in0_reqs_domain} out1_grants_p0;
  wire {Ctrl domain} out1_grants_p1;
  wire {Ctrl in2_reqs_domain} out1_grants_p2;
  wire {Ctrl in0_reqs_domain} out2_grants_p0;
  wire {Ctrl domain} out2_grants_p1;
  wire {Ctrl in2_reqs_domain} out2_grants_p2;

  wire [s-1:0] {D1} dest0_d1;
  wire [s-1:0] {L} dest0_d2;
  wire [s-1:0] {Ctrl domain} dest1;
  wire [s-1:0] {D1} dest2_d1;
  wire [s-1:0] {L} dest2_d2;

  wire		   {L} in0_reqs_domain;
  wire		   {L} domain;
  wire		   {L} in2_reqs_domain;

  wire		   {L} out0_reqs_domain;
  wire		   {L} out1_reqs_domain;
  wire		   {L} out2_reqs_domain;

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

  wire [2:0]	{L} num_free0 = num_free0_control_d1 + num_free0_control_d2;
  wire [2:0]	{L} num_free2 = num_free2_control_d1 + num_free2_control_d2;

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


	.domain	   (domain)
  );

  plab4_net_RouterInputCtrlArb_Sep
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

  plab4_net_RouterOutputCtrl_sep_insecure out0_ctrl
  (
    .clk			(clk),
    .reset			(reset),

    .req            (req),
    .ter            (0),

	.reqs_p0_domain	(in0_reqs_domain),
	.reqs_p1_domain	(domain),
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

  plab4_net_RouterOutputCtrl_sep_insecure out1_ctrl
  (
    .clk			(clk),
    .reset			(reset),

    .req            (req),
    .ter            (1),

	.reqs_p0_domain	(in0_reqs_domain),
	.reqs_p1_domain	(domain),
	.reqs_p2_domain (in2_reqs_domain),

    .reqs_p0		(out1_reqs_p0),
	.reqs_p1		(out1_reqs_p1),
	.reqs_p2		(out1_reqs_p2),
    .out_domain     (out1_domain),

    .grants_p0      (out1_grants_p0),
	.grants_p1		(out1_grants_p1),
	.grants_p2		(out1_grants_p2),

    .out_val  (out1_val),
    .out_rdy  (out1_rdy),
    .xbar_sel (xbar_sel1)
  );

  plab4_net_RouterOutputCtrl_sep_insecure out2_ctrl
  (
    .clk			(clk),
    .reset			(reset),

    .req            (req),
    .ter            (0),

	.reqs_p0_domain	(in0_reqs_domain),
	.reqs_p1_domain	(domain),
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

