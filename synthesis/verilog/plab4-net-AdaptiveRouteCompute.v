//========================================================================
// Adaptive Route Compute
//========================================================================

`ifndef PLAB4_NET_ADAPTIVE_ROUTE_COMPUTE_V
`define PLAB4_NET_ADAPTIVE_ROUTE_COMPUTE_V

`define ROUTE_PREV  2'b00
`define ROUTE_NEXT  2'b01
`define ROUTE_TERM  2'b10

module plab4_net_AdaptiveRouteCompute
#(
  parameter p_router_id   = 0,
  parameter p_num_routers = 8,

  parameter p_num_free_nbits = 2,

  // number of hops multiplier

  parameter p_hops_mult   = 1,

  // congestion multiplier

  parameter p_cong_mult   = 4,

  // parameter not meant to be set outside this module

  parameter c_dest_nbits = $clog2( p_num_routers )
)
(
  input [c_dest_nbits-1:0] dest,

  input [p_num_free_nbits-1:0] num_free_chan0,
  input [p_num_free_nbits-1:0] num_free_chan2,

  output reg [1:0]         route
);

  // calculate forward and backward hops

  wire [c_dest_nbits-1:0] forw_hops;
  wire [c_dest_nbits-1:0] backw_hops;

  assign forw_hops =  ( dest - p_router_id );
  assign backw_hops = ( p_router_id - dest );

  // we also calculate weight in each direction which takes both
  // congestion and number of hops into account

  wire [31:0] forw_weight;
  wire [31:0] backw_weight;

  assign forw_weight =  p_hops_mult * forw_hops +
                        p_cong_mult * num_free_chan0;
  assign backw_weight = p_hops_mult * backw_hops +
                        p_cong_mult * num_free_chan2;

  always @(*) begin
    if ( dest == p_router_id )
      route = `ROUTE_TERM;
    else if ( forw_weight == backw_weight )
      // when forward and backward weights are equal, we arbitrarily use
      // the router id to pick one direction
      route = ( p_router_id % 2 ? `ROUTE_NEXT : `ROUTE_PREV );
    else if ( forw_weight < backw_weight )
      route = `ROUTE_NEXT;
    else
      route = `ROUTE_PREV;
  end

endmodule

`endif /* PLAB4_NET_ADAPTIVE_ROUTE_COMPUTE_V */
