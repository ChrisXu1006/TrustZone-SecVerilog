//========================================================================
// mtbmark-vvadd
//========================================================================

#include "mtbmark.h"
#include "mtbmark-vvadd.dat"

//------------------------------------------------------------------------
// vvadd-scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
void vvadd_scalar( int *dest, int *src0, int *src1, int size )
{
  int i;
  for ( i = 0; i < size; i++ )
    *dest++ = *src0++ + *src1++;
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( int dest[], int ref[], int size )
{
  int i;
  for ( i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) ) {
      test_fail( i, dest[i], ref[i] );
    }
  }
  test_pass();
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  // Number of cores

  int num_cores = get_num_cores();

  // Size of the part of the vector each core will compute

  int core_size = get_core_size( size );

  // Determine core ID

  int core_id = get_core_id();

  //--------------------------------------------------------------------
  // Start counting stats
  //--------------------------------------------------------------------

  test_stats_on();

  // Spawn threads and perform parallel computation

  spawn();

  // Account for uneven split of work between cores

  int remainder = size - ( core_size * num_cores );
  int my_core_size;
  int offset;

  if ( core_id < remainder ) {
    my_core_size = core_size + 1;
    offset = core_id * my_core_size;
  }
  else {
    my_core_size = core_size;
    offset = ( remainder * ( my_core_size + 1 ) )
           + ( ( core_id - remainder ) * my_core_size );
  }

  // Actual computation

  int* dest_ = dest + offset;
  int* src0_ = src0 + offset;
  int* src1_ = src1 + offset;

  vvadd_scalar( dest_, src0_, src1_, my_core_size );

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

