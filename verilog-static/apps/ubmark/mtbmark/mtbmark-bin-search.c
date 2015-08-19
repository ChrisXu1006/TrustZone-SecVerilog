//========================================================================
// mtbmark-bin-search
//========================================================================

#include "mtbmark.h"
#include "mtbmark-bin-search.dat"

//------------------------------------------------------------------------
// bin_search_scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
void bin_search_scalar( int values[], int keys[], int keys_sz,
                        int kv[], int kv_sz )
{
  int i;
  for ( i = 0; i < keys_sz; i++ ) {

    int key     = keys[i];
    int idx_min = 0;
    int idx_mid = kv_sz/2;
    int idx_max = kv_sz-1;

    int done = 0;
    values[i] = -1;
    do {
      int midkey = kv[idx_mid];

      if ( key == midkey ) {
        values[i] = idx_mid;
        done = 1;
      }

      if ( key > midkey )
        idx_min = idx_mid + 1;
      else if ( key < midkey )
        idx_max = idx_mid - 1;

      idx_mid = ( idx_min + idx_max ) / 2;

    } while ( !done && (idx_min <= idx_max) );

  }
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( int values[], int ref[], int size )
{
  int i;
  for ( i = 0; i < size; i++ ) {
    if ( !( values[i] == ref[i] ) ) {
      test_fail( i, values[i], ref[i] );
    }
  }
  test_pass();
}

//------------------------------------------------------------------------
// Test harness
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

  int* values_ = values + offset;
  int* keys_   = keys   + offset;

  bin_search_scalar( values_, keys_, my_core_size, kv, kv_sz );

  // sync();

  // Join threads

  join();

  //--------------------------------------------------------------------
  // Stop counting stats
  //--------------------------------------------------------------------

  test_stats_off();

  // Control thread verifies the solution

  if ( core_id == 0 )
    verify_results( values, ref, size );

  return 0;

}

