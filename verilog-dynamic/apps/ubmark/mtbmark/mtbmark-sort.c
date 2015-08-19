//========================================================================
// mtbmark-merge-sort
//========================================================================

#include "mtbmark.h"
#include "mtbmark-sort.dat"

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// merge-sort-scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
void merge_scalar( int* dest, int* src0, int* src1, int size0, int size1 )
{
  // Initialize array indices

  int src0_idx = 0;
  int src1_idx = 0;
  int dest_idx = 0;

  // Compare top of each list until all elements are merged

  while ( src0_idx < size0 || src1_idx < size1 ) {

    // Both lists still have elements

    if ( src0_idx < size0 && src1_idx < size1 ) {

      // List 0 has the next smallest value

      if ( src0[src0_idx] <= src1[src1_idx] ) {
        dest[dest_idx] = src0[src0_idx];
        src0_idx++;
      }

      // List 1 has the next smallest value

      else {
        dest[dest_idx] = src1[src1_idx];
        src1_idx++;
      }
    }

    // Only list 0 has elements left to merge

    else if ( src0_idx < size0 ) {
      dest[dest_idx] = src0[src0_idx];
      src0_idx++;
    }

    // Only list 1 has elements left to merge

    else if ( src1_idx < size1 ) {
      dest[dest_idx] = src1[src1_idx];
      src1_idx++;
    }

    // Increment destination array index

    dest_idx++;
  }

  // Copy over merged elements to source array

  int i;
  for ( i = 0; i < size0; i++ )
    src0[i] = dest[i];

  for ( i = 0; i < size1; i++ )
    src1[i] = dest[size0+i];
}

__attribute__ ((noinline))
void merge_sort_scalar( int* dest, int* src, int size )
{
  // If size of list is a single element return from function

  if ( size > 1 ) {

    // Calculate destination array offsets

    int* dest0 = dest;
    int* dest1 = dest + size/2;

    // Calculate source array offsets

    int* src0 = src;
    int* src1 = src + size/2;

    // Calculate sizes for each list

    int size0 = size/2;
    int size1 = size - size/2;

    // Recursively call merge_sort on both lists

    merge_sort_scalar( dest0, src0, size0 );
    merge_sort_scalar( dest1, src1, size1 );

    // Merge the sorted lists

    merge_scalar( dest, src0, src1, size0, size1 );
  }
}


inline void swap( int *arr, int idx0, int idx1 ) {
  int tmp = arr[idx0];
  arr[idx0] = arr[idx1];
  arr[idx1] = tmp;
}

int partition( int *arr, int left_idx, int right_idx, int pivot_idx ) {

  int i;
  int pivot = arr[pivot_idx];

  // move the pivot to the right
  swap( arr, pivot_idx, right_idx );

  int store_idx = left_idx;

  // swap elements that are less than pivot
  for ( i = left_idx; i < right_idx; i++ )
    if ( arr[i] <= pivot )
      swap( arr, i, store_idx++ );

  // swap back the pivot
  swap( arr, store_idx, right_idx );
  return store_idx;
}

void quicksort_inplace( int *arr, int left_idx, int right_idx ) {

  if ( left_idx < right_idx ) {
    // pick a pivot index
    int pivot_idx = left_idx + ( right_idx - left_idx ) / 2;
    // partition the array using the pivot
    pivot_idx = partition( arr, left_idx, right_idx, pivot_idx );
    // recurse for left and right of the array
    quicksort_inplace( arr, left_idx, pivot_idx - 1 );
    quicksort_inplace( arr, pivot_idx + 1, right_idx );
  }
}

__attribute__ ((noinline))
void quicksort_scalar( int* dest, int* src, int size )
{
  int i;

  // we do an in-place quicksort, so we first copy the source to
  // destination
  quicksort_inplace( src, 0, size-1 );

  for ( i = 0; i < size; i++ )
    dest[i] = src[i];

}

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

__attribute__ ((noinline))
void sort_scalar( int* dest, int* src, int size )
{
  // implement sorting algorithm here
  int i;

  // dummy copy src into dest
  for ( i = 0; i < size; i++ )
    dest[i] = src[i];
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

  // distribute work and call sort_scalar()

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

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
  int* src_  = src  + offset;

  //merge_sort_scalar( dest_, src_, my_core_size );
  quicksort_scalar( dest_, src_, my_core_size );

  // sync();

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  // Join threads

  join();

  // do the final reduction step here

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  // Control thread serializes the final reduction

  if ( core_id == 0 ) {
    int i;
    int* temp_src;
    int  temp_size = core_size;

    if ( remainder > 0 )
      temp_size++;

    for ( i = 1; i < num_cores; i++ ) {

      if ( i < remainder ) {
        my_core_size = core_size + 1;
        offset = i * my_core_size;
      }
      else {
        my_core_size = core_size;
        offset = ( remainder * ( my_core_size + 1 ) )
               + ( ( i - remainder ) * my_core_size );
      }

      temp_src = src + offset;
      merge_scalar( dest, src, temp_src, temp_size, my_core_size );
      temp_size += my_core_size;
    }
  }

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  //--------------------------------------------------------------------
  // Stop counting stats
  //--------------------------------------------------------------------

  test_stats_off();

  // Control thread verifies solution

  if ( core_id == 0 )
    verify_results( dest, ref, size );

  return 0;
}

