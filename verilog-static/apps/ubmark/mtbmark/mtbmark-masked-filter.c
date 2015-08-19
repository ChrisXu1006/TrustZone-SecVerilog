//========================================================================
// mtbmark-masked-filter
//========================================================================

#include "mtbmark.h"
#include "mtbmark-masked-filter.dat"

//------------------------------------------------------------------------
// masked_filter_mt
//------------------------------------------------------------------------

__attribute__ ((noinline))
void masked_filter_mt( uint dest[], uint mask[], uint src[],
                       int nrows, int ncols )
{
  uint coeff0 = 8;
  uint coeff1 = 6;
  uint norm_shamt = 5;
  int ridx;
  int cidx;
  for ( ridx = 0; ridx < nrows; ridx++ ) {
    for ( cidx = 1; cidx < ncols-1; cidx++ ) {
      if ( mask[ ridx*ncols + cidx ] != 0 ) {
        uint out0 = ( src[ (ridx-1)*ncols + cidx     ] * coeff1 );
        uint out1 = ( src[ ridx*ncols     + (cidx-1) ] * coeff1 );
        uint out2 = ( src[ ridx*ncols     + cidx     ] * coeff0 );
        uint out3 = ( src[ ridx*ncols     + (cidx+1) ] * coeff1 );
        uint out4 = ( src[ (ridx+1)*ncols + cidx     ] * coeff1 );
        uint out  = out0 + out1 + out2 + out3 + out4;
        dest[ ridx*ncols + cidx ] = (byte)(out >> norm_shamt);
      }
      else
        dest[ ridx*ncols + cidx ] = src[ ridx*ncols + cidx ];
    }
  }
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( uint dest[], uint ref[], int size )
{
  int i;
  for ( i = 0; i < size*size; i++ ) {
    if ( !( dest[i] == ref[i] ) ) {
      test_fail( i, dest[i], ref[i] );
    }
  }
  test_pass();
}

//------------------------------------------------------------------------
// Test harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  // Number of rows that need to be computed for masked filter

  int nrows_compute = size - 2;

  // Number of cores

  int num_cores = get_num_cores();

  // Size of the part of the vector each core will compute

  int core_size = get_core_size( nrows_compute );

  // Determine core ID

  int core_id = get_core_id();

  //--------------------------------------------------------------------
  // Start counting stats
  //--------------------------------------------------------------------

  test_stats_on();

  // Spawn threads and perform parallel computation

  spawn();

  // Account for uneven split of work between cores

  int remainder = nrows_compute - ( core_size * num_cores );
  int my_core_size;
  int offset;

  if ( core_id < remainder ) {
    my_core_size = core_size + 1;
    offset = ( core_id * my_core_size ) * size;
  }
  else {
    my_core_size = core_size;
    offset = ( ( remainder * ( my_core_size + 1 ) )
           + ( ( core_id - remainder ) * my_core_size ) ) * size;
  }

  // Actual computation

  uint* dest_ = dest + size + offset;
  uint* mask_ = mask + size + offset;
  uint* src_  = src  + size + offset;

  masked_filter_mt( dest_, mask_, src_, my_core_size, size );

  // sync();

  // Join threads

  join();

  //--------------------------------------------------------------------
  // Stop counting stats
  //--------------------------------------------------------------------

  test_stats_off();

  // Control thread verifies the solution

  if ( core_id == 0 )
    verify_results( dest, ref, size );

  return 0;

}

