//========================================================================
// Verilog Components: Pipe Control
//========================================================================
// This module models the pipeline squash and stall control signals for a
// given pipeline stage. A state element in the model represents the
// valid bit of the pipeline stage.

`ifndef VC_PIPECTRL_V
`define VC_PIPECTRL_V

`include "vc-regs.v"

module vc_PipeCtrl
(
  input         clk,
  input         reset,

  input         prev_val,     // valid bit from the prev stage
  output        prev_stall,   // aggr stall signal for the prev stage
  output        prev_squash,  // aggr squash signal for the prev stage

  output        curr_reg_en,  // pipeline reg enable for the current stage
  output        curr_val,     // combinational valid bit for the current stage
  input         curr_stall,   // stall signal from the current stage
  input         curr_squash,  // squash signal from the current stage

  output        next_val,     // valid bit for the next stage
  input         next_stall,   // stall signal from the next stage
  input         next_squash   // squash signal from the next stage
);

  // register that propogates the valid signal
  wire reg_en;

  vc_EnResetReg #(1, 0) val_reg
  (
    .clk    ( clk         ),
    .reset  ( reset       ),
    .en     ( reg_en      ),
    .d      ( prev_val    ),
    .q      ( curr_val    )
  );

  // enable the pipeline regs when the current stage is squashed due to
  // next_squash or when the current stage is not stalling due to the
  // curr_stall or next_stall. otherwise do not set the enable signal.

  assign reg_en = !prev_stall || next_squash;
  assign curr_reg_en = ( !prev_stall && prev_val ) || next_squash;

  // insert microarchitectural nop value when the current stage is
  // squashed due to next_squash or when the current stage is stalled due
  // to curr_stall or when the current stage is stalled due to
  // next_stall. otherwise pipeline the valid bit. note that this signal
  // is also used as the go signal for this pipeline stage
  // the beginning of the pipeline stage should set the p_begin parameter
  // so that when squash happens, the next instruction is valid

  assign next_val = curr_val &&  ~next_squash && ~next_stall && ~curr_stall;

  // accumulate stall signals. requiring val here prevents stall on
  // bubble, and improves performance, also we don't forward the stall on
  // a squash

  assign prev_stall = (next_stall || curr_stall) && curr_val && !next_squash;

  // accumulate squash signals, we only pass current squash if we are not
  // generating a stall already. This is a subtle issue, where not having
  // this causes multiple squashes, which doesn't work well with the drop
  // unit.

  assign prev_squash = next_squash ||
                ( curr_squash && !next_stall && !curr_stall );


  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"

  task trace_pipe_stage(
    inout [vc_trace_nbits-1:0] trace,
    input [vc_trace_nbits-1:0] msg_str,
    input integer              trace_nchars
  );
  begin
    if ( next_squash ) begin
      vc_trace_str( trace, "~" );
      vc_trace_fill( trace, trace_nchars - 1, " " );
    end else if ( prev_stall ) begin
      vc_trace_str( trace, "#" );
      vc_trace_fill( trace, trace_nchars - 1, " " );
    end else if ( curr_val ) begin
      vc_trace_str( trace, msg_str );
    end else begin
      vc_trace_fill( trace, trace_nchars, " " );
    end
  end
  endtask

endmodule

`endif

