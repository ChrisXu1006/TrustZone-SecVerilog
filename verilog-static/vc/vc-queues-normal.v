//========================================================================
// Verilog Components: Queues
//========================================================================

`ifndef VC_QUEUES_NORMAL_V
`define VC_QUEUES_NORMAL_V

`include "vc-regs.v"
`include "vc-muxes.v"
`include "vc-regfiles.v"

//------------------------------------------------------------------------
// Defines
//------------------------------------------------------------------------

`define VC_QUEUE_NORMAL   4'b0000
`define VC_QUEUE_PIPE     4'b0001
`define VC_QUEUE_BYPASS   4'b0010

//------------------------------------------------------------------------
// Single-Element Queue Control Logic
//------------------------------------------------------------------------
// This is the control logic for a single-elment queue. It is designed to
// be attached to a storage element with a write enable. Additionally, it
// includes the ability to statically enable pipeline and/or bypass
// behavior. Pipeline behavior is when the deq_rdy signal is
// combinationally wired to the enq_rdy signal allowing elements to be
// dequeued and enqueued in the same cycle when the queue is full. Bypass
// behavior is when the enq_val signal is combinationally wired to the
// deq_val signal allowing elements to bypass the storage element if the
// storage element is empty.

module vc_QueueCtrl1_normal
(
  input  clk,
  input  reset,

  input  enq_val,        // Enqueue data is valid
  output enq_rdy,        // Ready for producer to do an enqueue
  input	 enq_domain,

  output deq_val,        // Dequeue data is valid
  input  deq_rdy,        // Consumer is ready to do a dequeue
  input	 deq_domain,

  output write_en,       // Write en signal to wire up to storage element
  output num_free_entries // Either zero or one
);

  // Status register

  reg  full;
  wire full_next;

  always @ (posedge clk) begin
    full <= reset ? 0 : full_next;
  end

  assign num_free_entries = full ? 0 : 1;

  // We enq/deq only when they are both ready and valid

  wire do_enq = enq_rdy && enq_val;
  wire do_deq = deq_rdy && deq_val;

  // Determine if we have pipeline or bypass behaviour and
  // set the write enable accordingly.

  wire empty     = ~full;

  assign write_en = do_enq;

  // Ready signals are calculated from full register. If pipeline
  // behavior is enabled, then the enq_rdy signal is also calculated
  // combinationally from the deq_rdy signal. If bypass behavior is
  // enabled then the deq_val signal is also calculated combinationally
  // from the enq_val signal.

  assign enq_rdy  = ~full  ;
  assign deq_val  = ~empty ;

  // Control logic for the full register input

  assign full_next = ( do_deq )   ? 1'b0
                   : ( do_enq )   ? 1'b1
                   :                full;

endmodule

//------------------------------------------------------------------------
// Single-Element Queue Datapath
//------------------------------------------------------------------------
// This is the datpath for single element queues. It includes a register
// and a bypass mux if needed.

module vc_QueueDpath1_normal
#(
  parameter p_msg_nbits = 1
)(
  input                    clk,
  input                    reset,
  input                    write_en,
  input  [p_msg_nbits-1:0] enq_msg,
  input					   enq_domain,
  output [p_msg_nbits-1:0] deq_msg,
  output				   deq_domain
);

  // Queue storage

  wire [p_msg_nbits-1:0] qstore;

  vc_EnReg#(p_msg_nbits) qstore_reg
  (
    .clk   (clk),
    .reset (reset),
    .en    (write_en),
    .d     (enq_msg),
    .q     (qstore)
  );

  vc_EnReg#(1) domain_reg
  (
	.clk   (clk),
	.reset (reset),
	.en	   (write_en),
	.d	   (enq_domain),
    .q	   (deq_domain)
  );	

  assign deq_msg = qstore;

endmodule

//------------------------------------------------------------------------
// Multi-Element Queue Control Logic
//------------------------------------------------------------------------
// This is the control logic for a multi-elment queue. It is designed to
// be attached to a Regfile storage element. Additionally, it includes
// the ability to statically enable pipeline and/or bypass behavior.
// Pipeline behavior is when the deq_rdy signal is combinationally wired
// to the enq_rdy signal allowing elements to be dequeued and enqueued in
// the same cycle when the queue is full. Bypass behavior is when the
// enq_val signal is cominationally wired to the deq_val signal allowing
// elements to bypass the storage element if the storage element is
// empty.

module vc_QueueCtrl_normal
#(
  parameter p_type     = `VC_QUEUE_NORMAL,
  parameter p_num_msgs = 2,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits = $clog2(p_num_msgs)
)(
  input                     clk, reset,

  input                     enq_val,        // Enqueue data is valid
  output                    enq_rdy,        // Ready for producer to enqueue
  input						enq_domain,

  output                    deq_val,        // Dequeue data is valid
  input                     deq_rdy,        // Consumer is ready to dequeue
  input						deq_domain,

  output                    write_en,       // Wen to wire to regfile
  output [c_addr_nbits-1:0] write_addr,     // Waddr to wire to regfile
  output [c_addr_nbits-1:0] read_addr,      // Raddr to wire to regfile
  output [c_addr_nbits:0]   num_free_entries // Num of free entries in queue
);

  // Enqueue and dequeue pointers

  wire [c_addr_nbits-1:0] enq_ptr;
  wire [c_addr_nbits-1:0] enq_ptr_next;

  vc_ResetReg#(c_addr_nbits) enq_ptr_reg
  (
    .clk     (clk),
    .reset   (reset),
    .d       (enq_ptr_next),
    .q       (enq_ptr)
  );

  wire [c_addr_nbits-1:0] deq_ptr;
  wire [c_addr_nbits-1:0] deq_ptr_next;

  vc_ResetReg#(c_addr_nbits) deq_ptr_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (deq_ptr_next),
    .q     (deq_ptr)
  );

  assign write_addr = enq_ptr;
  assign read_addr  = deq_ptr;

  // Extra state to tell difference between full and empty

  wire full;
  wire full_next;

  vc_ResetReg#(1) full_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (full_next),
    .q     (full)
  );

  // We enq/deq only when they are both ready and valid

  wire do_enq = enq_rdy && enq_val;
  wire do_deq = deq_rdy && deq_val;

  // Determine if we have pipeline or bypass behaviour and
  // set the write enable accordingly.

  wire   empty     = ~full && (enq_ptr == deq_ptr);

  assign write_en = do_enq;

  // Ready signals are calculated from full register. If pipeline
  // behavior is enabled, then the enq_rdy signal is also calculated
  // combinationally from the deq_rdy signal. If bypass behavior is
  // enabled then the deq_val signal is also calculated combinationally
  // from the enq_val signal.

  assign enq_rdy  = ~full  ;
  assign deq_val  = ~empty ;

  // Control logic for the enq/deq pointers and full register

  wire [c_addr_nbits-1:0] deq_ptr_plus1 = deq_ptr + 1'b1;
  wire [c_addr_nbits-1:0] deq_ptr_inc
    = (deq_ptr_plus1 == p_num_msgs) ? {c_addr_nbits{1'b0}} : deq_ptr_plus1;

  wire [c_addr_nbits-1:0] enq_ptr_plus1 = enq_ptr + 1'b1;
  wire [c_addr_nbits-1:0] enq_ptr_inc
    = (enq_ptr_plus1 == p_num_msgs) ? {c_addr_nbits{1'b0}} : enq_ptr_plus1;

  assign deq_ptr_next
    = ( do_deq ) ? ( deq_ptr_inc ) : deq_ptr;

  assign enq_ptr_next
    = ( do_enq ) ? ( enq_ptr_inc ) : enq_ptr;

  assign full_next
    = ( do_enq && ~do_deq && ( enq_ptr_inc == deq_ptr ) ) ? 1'b1
    : ( do_deq && full )                      ? 1'b0 : full;

  // Number of free entries

  assign num_free_entries
    = full                ? {(c_addr_nbits+1){1'b0}}
    : empty               ? p_num_msgs[c_addr_nbits:0]
    : (enq_ptr > deq_ptr) ? p_num_msgs[c_addr_nbits:0] - (enq_ptr - deq_ptr)
    : (deq_ptr > enq_ptr) ? deq_ptr - enq_ptr
    :                       {(c_addr_nbits+1){1'bx}};

endmodule

//------------------------------------------------------------------------
// Multi-Element Queue Datapath
//------------------------------------------------------------------------
// This is the datpath for multi-element queues. It includes a register
// and a bypass mux if needed.

module vc_QueueDpath_normal
#(
  parameter p_type      = `VC_QUEUE_NORMAL,
  parameter p_msg_nbits = 4,
  parameter p_num_msgs  = 2,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits = $clog2(p_num_msgs)
)(
  input                     clk,
  input                     reset,
  input                     write_en,
  input  [c_addr_nbits-1:0] write_addr,
  input  [c_addr_nbits-1:0] read_addr,
  input   [p_msg_nbits-1:0] enq_msg,
  input						enq_domain,
  output  [p_msg_nbits-1:0] deq_msg,
  output					deq_domain
);

  // Queue storage

  wire [p_msg_nbits-1:0] read_data;

  vc_Regfile_1r1w#(p_msg_nbits,p_num_msgs) qstore
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (read_addr),
    .read_data  (read_data),
    .write_en   (write_en),
    .write_addr (write_addr),
    .write_data (enq_msg)
  );

  vc_Regfile_1r1w#(1,p_num_msgs) domain
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (read_addr),
    .read_data  (deq_domain),
    .write_en   (write_en),
    .write_addr (write_addr),
    .write_data (enq_domain)
  );

  // Bypass muxing

  assign deq_msg = read_data;

endmodule

//------------------------------------------------------------------------
// Queue
//------------------------------------------------------------------------

module vc_Queue_normal
#(
  parameter p_msg_nbits = 1,
  parameter p_num_msgs  = 2,

  // parameters not meant to be set outside this module
  parameter c_addr_nbits = $clog2(p_num_msgs)
)(
  input                    clk,
  input                    reset,

  input                    enq_val,
  output                   enq_rdy,
  input  [p_msg_nbits-1:0] enq_msg,
  input					   enq_domain,

  output                   deq_val,
  input                    deq_rdy,
  output [p_msg_nbits-1:0] deq_msg,
  output				   deq_domain,

  output [c_addr_nbits:0]  num_free_entries
);


  generate
  if ( p_num_msgs == 1 )
  begin

    wire write_en;

    vc_QueueCtrl1_normal ctrl
    (
      .clk              (clk),
      .reset            (reset),
      .enq_val          (enq_val),
      .enq_rdy          (enq_rdy),
	  .enq_domain		(enq_domain),
      .deq_val          (deq_val),
      .deq_rdy          (deq_rdy),
	  .deq_domain		(deq_domain),
      .write_en         (write_en),
      .num_free_entries (num_free_entries)
    );

    vc_QueueDpath1_normal#(p_msg_nbits) dpath
    (
      .clk            (clk),
      .reset          (reset),
      .write_en       (write_en),
      .enq_msg        (enq_msg),
	  .enq_domain	  (enq_domain),
      .deq_msg        (deq_msg),
	  .deq_domain	  (deq_domain)
    );

  end
  else
  begin

    wire                    write_en;
    wire [c_addr_nbits-1:0] write_addr;
    wire [c_addr_nbits-1:0] read_addr;

    vc_QueueCtrl_normal#(`VC_QUEUE_NORMAL,p_num_msgs) ctrl
    (
      .clk              (clk),
      .reset            (reset),
      .enq_val          (enq_val),
      .enq_rdy          (enq_rdy),
	  .enq_domain		(enq_domain),
      .deq_val          (deq_val),
      .deq_rdy          (deq_rdy),
	  .deq_domain		(deq_domain),
      .write_en         (write_en),
      .write_addr       (write_addr),
      .read_addr        (read_addr),
      .num_free_entries (num_free_entries)
    );

    vc_QueueDpath_normal#(`VC_QUEUE_NORMAL,p_msg_nbits,p_num_msgs) dpath
    (
      .clk              (clk),
      .reset            (reset),
      .write_en         (write_en),
      .write_addr       (write_addr),
      .read_addr        (read_addr),
      .enq_msg          (enq_msg),
	  .enq_domain		(enq_domain),
      .deq_msg          (deq_msg),
	  .deq_domain		(deq_domain)
    );

  end
  endgenerate

  // Assertions

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( enq_val );
      `VC_ASSERT_NOT_X( enq_rdy );
      `VC_ASSERT_NOT_X( deq_val );
      `VC_ASSERT_NOT_X( deq_rdy );
    end
  end

  // Line Tracing

  `include "vc-trace-tasks.v"

  reg [`VC_TRACE_NBITS_TO_NCHARS(p_msg_nbits)*8-1:0] str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    $sformat( str, "%x", enq_msg );
    vc_trace_str_val_rdy( trace, enq_val, enq_rdy, str );

    vc_trace_str( trace, "(" );
    $sformat( str, "%x", p_num_msgs-num_free_entries );
    vc_trace_str( trace, str );
    vc_trace_str( trace, ")" );

    $sformat( str, "%x", deq_msg );
    vc_trace_str_val_rdy( trace, deq_val, deq_rdy, str );

  end
  endtask

endmodule

`endif /* VC_QUEUES_V */

