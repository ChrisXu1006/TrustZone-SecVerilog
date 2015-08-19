//========================================================================
// Adaptive Route Compute Unit Tests
//========================================================================

`include "plab4-net-AdaptiveRouteCompute.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab4-net-AdaptiveRouteCompute" )

  //----------------------------------------------------------------------
  // Test greedy routing computation
  //----------------------------------------------------------------------

  reg  [2:0]  t1_dest;
  reg  [1:0]  t1_num_free_chan0;
  reg  [1:0]  t1_num_free_chan2;
  wire [1:0]  t1_route;

  plab4_net_AdaptiveRouteCompute
  #(
    .p_router_id    (2),
    .p_num_routers  (8)
  )
  t1_route_compute
  (
    .dest           (t1_dest ),

    .num_free_chan0 (t1_num_free_chan0),
    .num_free_chan2 (t1_num_free_chan2),

    .route          (t1_route)
  );

  // Helper task

  task t1
  (
    input [2:0]  dest,
    input [1:0]  num_free_chan0,
    input [1:0]  num_free_chan2,
    input [1:0]  route
  );
  begin
    t1_dest           = dest;
    t1_num_free_chan0 = num_free_chan0;
    t1_num_free_chan2 = num_free_chan2;
    #1;
    `VC_TEST_NOTE_INPUTS_3( dest, num_free_chan0, num_free_chan2 );
    `VC_TEST_NET( t1_route,  route );
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "adaptive routing, no congestion" )
  begin

    //  dest  free0, free2, route
    t1( 3'h0, 2'd2,  2'd2,  `ROUTE_PREV );
    t1( 3'h1, 2'd2,  2'd2,  `ROUTE_PREV );
    t1( 3'h2, 2'd2,  2'd2,  `ROUTE_TERM );
    t1( 3'h3, 2'd2,  2'd2,  `ROUTE_NEXT );
    t1( 3'h4, 2'd2,  2'd2,  `ROUTE_NEXT );
    t1( 3'h5, 2'd2,  2'd2,  `ROUTE_NEXT );
    // the other way around can be either PREV or NEXT
    t1( 3'h6, 2'd2,  2'd2,  2'b0?       );
    t1( 3'h7, 2'd2,  2'd2,  `ROUTE_PREV );

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN( 2, "adaptive routing, with congestion" )
  begin

    //  dest  free0, free2, route
    t1( 3'h0, 2'd0,  2'd2,  `ROUTE_NEXT );
    t1( 3'h0, 2'd1,  2'd2,  `ROUTE_PREV );
    t1( 3'h1, 2'd0,  2'd2,  `ROUTE_NEXT );
    t1( 3'h1, 2'd1,  2'd2,  `ROUTE_PREV );
    t1( 3'h2, 2'd0,  2'd2,  `ROUTE_TERM );
    t1( 3'h3, 2'd2,  2'd0,  `ROUTE_PREV );
    t1( 3'h4, 2'd2,  2'd0,  `ROUTE_PREV );
    t1( 3'h5, 2'd2,  2'd1,  `ROUTE_PREV );
    t1( 3'h6, 2'd2,  2'd2,  `ROUTE_PREV );
    t1( 3'h7, 2'd0,  2'd1,  `ROUTE_NEXT );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule


