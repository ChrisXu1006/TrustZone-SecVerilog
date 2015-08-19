//========================================================================
// plab4-net-RingNetAlt
//========================================================================

`ifndef PLAB4_NET_RING_NET
`define PLAB4_NET_RING_NET

`include "vc-net-msgsunpack.v"
`include "vc-param-utils.v"
`include "vc-queues.v"
`include "plab4-net-Router.v"
`include "plab4-net-demux.v"

// macros to calculate previous and next router ids

`define PREV(i_)  ( ( i_ + p_num_ports - 1 ) % p_num_ports )
`define NEXT(i_)  ( ( i_ + 1 ) % p_num_ports )

module plab4_net_RingNet
#(
  parameter p_payload_cnbits = 32,
  parameter p_payload_dnbits = 32,
  parameter p_opaque_nbits   = 3,
  parameter p_srcdest_nbits  = 3,

  parameter p_num_ports = 2,

  // Shorter names, not to be set from outside the module
  parameter pc = p_payload_cnbits,
  parameter pd = p_payload_dnbits,
  parameter o  = p_opaque_nbits,
  parameter s  = p_srcdest_nbits,

  parameter c_net_msg_cnbits = `VC_NET_MSG_NBITS(pc,o,s),
  parameter c_net_msg_dnbits = `VC_NET_MSG_NBITS(pd,o,s),

  parameter m  = c_net_msg_cnbits
  
)
(
  input {L} clk,
  input {L} reset,

  input {L} req,

  input				{Ctrl in_domain_p0} in_val_p0,
  output			{Ctrl in_domain_p0} in_rdy_p0,
  input             {L}                 in_domain_p0,
  input	 [m-1:0]	{Ctrl in_domain_p0} in_msg_control_p0,
  input  [pd-1:0]   {Data in_domain_p0} in_msg_data_p0,

  output			{Ctrl out1_domain_p0} out_val_p0,
  input				{Ctrl out1_domain_p0} out_rdy_p0,
  output [m-1:0]	{Ctrl out1_domain_p0} out_msg_control_p0,
  output [pd-1:0]	{Data out1_domain_p0} out_msg_data_p0,
  output            {L}                   out1_domain_p0,

  input				{Ctrl in_domain_p1} in_val_p1,
  output			{Ctrl in_domain_p1} in_rdy_p1,
  input             {L}                 in_domain_p1,
  input	 [m-1:0]	{Ctrl in_domain_p1} in_msg_control_p1,
  input  [pd-1:0]   {Data in_domain_p1} in_msg_data_p1,

  output			{Ctrl out1_domain_p1} out_val_p1,
  input				{Ctrl out1_domain_p1} out_rdy_p1,
  output [m-1:0]	{Ctrl out1_domain_p1} out_msg_control_p1,
  output [pd-1:0]	{Data out1_domain_p1} out_msg_data_p1,
  output            {L}                   out1_domain_p1

);

  //----------------------------------------------------------------------
  // Router-router connection wires
  //----------------------------------------------------------------------

  // forward (increasing router id) wires

  wire			{Ctrl out2_domain_p0} forw_out_val_p0;
  wire			{Ctrl out2_domain_p0} forw_out_rdy_p0;
  wire [m-1:0]	{Ctrl out2_domain_p0} forw_out_msg_control_p0;
  wire [pd-1:0]	{Data out2_domain_p0} forw_out_msg_data_p0;

  wire			{D1} forw_in_val_d1_p0;
  wire			{D1} forw_in_rdy_d1_p0;
  wire [m-1:0]	{D1} forw_in_msg_control_d1_p0;
  wire [pd-1:0]	{D1} forw_in_msg_data_d1_p0;

  wire			{L} forw_in_val_d2_p0;
  wire			{L} forw_in_rdy_d2_p0;
  wire [m-1:0]	{L} forw_in_msg_control_d2_p0;
  wire [pd-1:0]	{D2} forw_in_msg_data_d2_p0;

  wire			{Ctrl out2_domain_p1} forw_out_val_p1;
  wire			{Ctrl out2_domain_p1} forw_out_rdy_p1;
  wire [m-1:0]	{Ctrl out2_domain_p1} forw_out_msg_control_p1;
  wire [pd-1:0]	{Data out2_domain_p1} forw_out_msg_data_p1;

  wire			{D1} forw_in_val_d1_p1;
  wire			{D1} forw_in_rdy_d1_p1;
  wire [m-1:0]	{D1} forw_in_msg_control_d1_p1;
  wire [pd-1:0]	{D1} forw_in_msg_data_d1_p1;

  wire			{L} forw_in_val_d2_p1;
  wire			{L} forw_in_rdy_d2_p1;
  wire [m-1:0]	{L} forw_in_msg_control_d2_p1;
  wire [pd-1:0]	{D2} forw_in_msg_data_d2_p1;

  // backward (decreasing router id) wires

  wire			{Ctrl out0_domain_p0} backw_out_val_p0;
  wire			{Ctrl out0_domain_p0} backw_out_rdy_p0;
  wire [m-1:0]	{Ctrl out0_domain_p0} backw_out_msg_control_p0;
  wire [pd-1:0]	{Data out0_domain_p0} backw_out_msg_data_p0;

  wire			{D1} backw_in_val_d1_p0;
  wire			{D1} backw_in_rdy_d1_p0;
  wire [m-1:0]	{D1} backw_in_msg_control_d1_p0;
  wire [pd-1:0]	{D1} backw_in_msg_data_d1_p0;
 
  wire			{L} backw_in_val_d2_p0;
  wire			{L} backw_in_rdy_d2_p0;
  wire [m-1:0]	{L} backw_in_msg_control_d2_p0;
  wire [pd-1:0]	{D2} backw_in_msg_data_d2_p0;

  wire			{Ctrl out0_domain_p1} backw_out_val_p1;
  wire			{Ctrl out0_domain_p1} backw_out_rdy_p1;
  wire [m-1:0]	{Ctrl out0_domain_p1} backw_out_msg_control_p1;
  wire [pd-1:0]	{Data out0_domain_p1} backw_out_msg_data_p1;

  wire			{D1} backw_in_val_d1_p1;
  wire			{D1} backw_in_rdy_d1_p1;
  wire [m-1:0]	{D1} backw_in_msg_control_d1_p1;
  wire [pd-1:0]	{D1} backw_in_msg_data_d1_p1;
 
  wire			{L} backw_in_val_d2_p1;
  wire			{L} backw_in_rdy_d2_p1;
  wire [m-1:0]	{L} backw_in_msg_control_d2_p1;
  wire [pd-1:0]	{D2} backw_in_msg_data_d2_p1;

  // domain output signal in each router

  wire			{L} out0_domain_p0;
  wire			{L} out2_domain_p0;
  wire			{L} out0_domain_p1;
  wire			{L} out2_domain_p1;
  // num free wires for adaptive routing

  wire [1:0]	{L} num_free_prev_p0;
  wire [1:0]	{L} num_free_next_p0;

  wire [1:0]	{L} num_free_prev_p1;
  wire [1:0]	{L} num_free_next_p1;

  //----------------------------------------------------------------------
  // Router generation
  //----------------------------------------------------------------------

    plab4_net_RouterAlt_Sep
      #(
        .p_payload_cnbits	(p_payload_cnbits),
		.p_payload_dnbits	(p_payload_dnbits),
        .p_opaque_nbits		(p_opaque_nbits),
        .p_srcdest_nbits	(p_srcdest_nbits),

        .p_router_id		(0),
        .p_num_routers		(p_num_ports)
      )
      router_p0
      (
        .clk				(clk),
        .reset				(reset),

        .req                (req),
        .domain             (in_domain_p0),

        .in0_val_d1			(forw_in_val_d1_p0),
        .in0_rdy_d1			(forw_in_rdy_d1_p0),
        .in0_msg_control_d1 (forw_in_msg_control_d1_p0),
        .in0_msg_data_d1	(forw_in_msg_data_d1_p0),

        .in0_val_d2			(forw_in_val_d2_p0),
        .in0_rdy_d2			(forw_in_rdy_d2_p0),
        .in0_msg_control_d2 (forw_in_msg_control_d2_p0),
        .in0_msg_data_d2	(forw_in_msg_data_d2_p0),
		
        .in1_val			(in_val_p0),
        .in1_rdy			(in_rdy_p0),
        .in1_msg_control    (in_msg_control_p0),
        .in1_msg_data	    (in_msg_data_p0),

        .in2_val_d1			(backw_in_val_d1_p0),
        .in2_rdy_d1			(backw_in_rdy_d1_p0),
        .in2_msg_control_d1 (backw_in_msg_control_d1_p0),
        .in2_msg_data_d1	(backw_in_msg_data_d1_p0),

        .in2_val_d2			(backw_in_val_d2_p0),
        .in2_rdy_d2			(backw_in_rdy_d2_p0),
        .in2_msg_control_d2	(backw_in_msg_control_d2_p0),
        .in2_msg_data_d2	(backw_in_msg_data_d2_p0),

        .out0_val			(backw_out_val_p0),
        .out0_rdy			(backw_out_rdy_p0),
        .out0_msg_control	(backw_out_msg_control_p0),
        .out0_msg_data		(backw_out_msg_data_p0),
		.out0_domain		(out0_domain_p0),

        .out1_val			(out_val_p0),
        .out1_rdy			(out_rdy_p0),
        .out1_msg_control	(out_msg_control_p0),
        .out1_msg_data		(out_msg_data_p0),
        .out1_domain        (out1_domain_p0),

        .out2_val			(forw_out_val_p0),
        .out2_rdy			(forw_out_rdy_p0),
        .out2_msg_control	(forw_out_msg_control_p0),
        .out2_msg_data		(forw_out_msg_data_p0),
		.out2_domain		(out2_domain_p0),

        .num_free_prev (1),
        .num_free_next (1)

      );

	plab4_net_RouterAlt_Sep
      #(
        .p_payload_cnbits	(p_payload_cnbits),
		.p_payload_dnbits	(p_payload_dnbits),
        .p_opaque_nbits		(p_opaque_nbits),
        .p_srcdest_nbits	(p_srcdest_nbits),

        .p_router_id		(1),
        .p_num_routers		(p_num_ports)
      )
      router_p1
      (
        .clk				(clk),
        .reset				(reset),

        .req                (req),
        .domain             (in_domain_p1),

        .in0_val_d1			(forw_in_val_d1_p1),
        .in0_rdy_d1			(forw_in_rdy_d1_p1),
        .in0_msg_control_d1 (forw_in_msg_control_d1_p1),
        .in0_msg_data_d1	(forw_in_msg_data_d1_p1),

        .in0_val_d2			(forw_in_val_d2_p1),
        .in0_rdy_d2			(forw_in_rdy_d2_p1),
        .in0_msg_control_d2 (forw_in_msg_control_d2_p1),
        .in0_msg_data_d2	(forw_in_msg_data_d2_p1),
		
        .in1_val			(in_val_p1),
        .in1_rdy			(in_rdy_p1),
        .in1_msg_control    (in_msg_control_p1),
        .in1_msg_data	    (in_msg_data_p1),

        .in2_val_d1			(backw_in_val_d1_p1),
        .in2_rdy_d1			(backw_in_rdy_d1_p1),
        .in2_msg_control_d1 (backw_in_msg_control_d1_p1),
        .in2_msg_data_d1	(backw_in_msg_data_d1_p1),

        .in2_val_d2			(backw_in_val_d2_p1),
        .in2_rdy_d2			(backw_in_rdy_d2_p1),
        .in2_msg_control_d2	(backw_in_msg_control_d2_p1),
        .in2_msg_data_d2	(backw_in_msg_data_d2_p1),

        .out0_val			(backw_out_val_p1),
        .out0_rdy			(backw_out_rdy_p1),
        .out0_msg_control	(backw_out_msg_control_p1),
        .out0_msg_data		(backw_out_msg_data_p1),
		.out0_domain		(out0_domain_p1),

        .out1_val			(out_val_p1),
        .out1_rdy			(out_rdy_p1),
        .out1_msg_control	(out_msg_control_p1),
        .out1_msg_data		(out_msg_data_p1),
        .out1_domain        (out1_domain_p1),

        .out2_val			(forw_out_val_p1),
        .out2_rdy			(forw_out_rdy_p1),
        .out2_msg_control	(forw_out_msg_control_p1),
        .out2_msg_data		(forw_out_msg_data_p1),
		.out2_domain		(out2_domain_p1),

        .num_free_prev (1),
        .num_free_next (1)

      );

  //----------------------------------------------------------------------
  // Demux generation
  //----------------------------------------------------------------------

	plab4_net_demux
      #(
		.p_msg_cnbits  (c_net_msg_cnbits),
		.p_msg_dnbits  (pd)
	  )
	  forw_demux_p0
	  (
		.domain		  (out2_domain_p1),

		.out_val	  (forw_out_val_p1),
		.in_val_d1	  (forw_in_val_d1_p0),
		.in_val_d2	  (forw_in_val_d2_p0),

		.in_rdy_d1	  (forw_in_rdy_d1_p0),
		.in_rdy_d2	  (forw_in_rdy_d2_p0),
		.out_rdy	  (forw_out_rdy_p1),

		.out_msg_control	(forw_out_msg_control_p1),
		.in_msg_control_d1	(forw_in_msg_control_d1_p0),
		.in_msg_control_d2	(forw_in_msg_control_d2_p0),

		.out_msg_data		(forw_out_msg_data_p1),
		.in_msg_data_d1		(forw_in_msg_data_d1_p0),
		.in_msg_data_d2		(forw_in_msg_data_d2_p0)
	  );

	plab4_net_demux
	  #(
		.p_msg_cnbits  (c_net_msg_cnbits),
		.p_msg_dnbits  (pd)
	  )
	  backw_demux_p0
	  (
		.domain		  (out0_domain_p1),

		.out_val	  (backw_out_val_p1),
		.in_val_d1	  (backw_in_val_d1_p0),
		.in_val_d2	  (backw_in_val_d2_p0),

		.in_rdy_d1	  (backw_in_rdy_d1_p0),
		.in_rdy_d2	  (backw_in_rdy_d2_p0),
		.out_rdy	  (backw_out_rdy_p1),

		.out_msg_control	(backw_out_msg_control_p1),
		.in_msg_control_d1	(backw_in_msg_control_d1_p0),
		.in_msg_control_d2	(backw_in_msg_control_d2_p0),

		.out_msg_data		(backw_out_msg_data_p1),
		.in_msg_data_d1		(backw_in_msg_data_d1_p0),
		.in_msg_data_d2		(backw_in_msg_data_d2_p0)

	  );

	plab4_net_demux
      #(
		.p_msg_cnbits  (c_net_msg_cnbits),
		.p_msg_dnbits  (pd)
	  )
	  forw_demux_p1
	  (
		.domain		  (out2_domain_p0),

		.out_val	  (forw_out_val_p0),
		.in_val_d1	  (forw_in_val_d1_p1),
		.in_val_d2	  (forw_in_val_d2_p1),

		.in_rdy_d1	  (forw_in_rdy_d1_p1),
		.in_rdy_d2	  (forw_in_rdy_d2_p1),
		.out_rdy	  (forw_out_rdy_p0),

		.out_msg_control	(forw_out_msg_control_p0),
		.in_msg_control_d1	(forw_in_msg_control_d1_p1),
		.in_msg_control_d2	(forw_in_msg_control_d2_p1),

		.out_msg_data		(forw_out_msg_data_p0),
		.in_msg_data_d1		(forw_in_msg_data_d1_p1),
		.in_msg_data_d2		(forw_in_msg_data_d2_p1)
	  );

	plab4_net_demux
	  #(
		.p_msg_cnbits  (c_net_msg_cnbits),
		.p_msg_dnbits  (pd)
	  )
	  backw_demux_p1
	  (
		.domain		  (out0_domain_p0),

		.out_val	  (backw_out_val_p0),
		.in_val_d1	  (backw_in_val_d1_p1),
		.in_val_d2	  (backw_in_val_d2_p1),

		.in_rdy_d1	  (backw_in_rdy_d1_p1),
		.in_rdy_d2	  (backw_in_rdy_d2_p1),
		.out_rdy	  (backw_out_rdy_p0),

		.out_msg_control	(backw_out_msg_control_p0),
		.in_msg_control_d1	(backw_in_msg_control_d1_p1),
		.in_msg_control_d2	(backw_in_msg_control_d2_p1),

		.out_msg_data		(backw_out_msg_data_p0),
		.in_msg_data_d1		(backw_in_msg_data_d1_p1),
		.in_msg_data_d2		(backw_in_msg_data_d2_p1)

	  );

endmodule

`endif /* PLAB4_NET_RING_NET_ALT */
