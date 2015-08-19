//========================================================================
// ubmark-quicksort
//========================================================================

#include "ubmark.h"
#include "ubmark-quicksort.dat"

//------------------------------------------------------------------------
// quicksort-scalar
//------------------------------------------------------------------------

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

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

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

__attribute__ ((noinline))
void quicksort_scalar( int* dest, int* src, int size )
{
  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++
  int i;

  // we do an in-place quicksort, so we first copy the source to
  // destination

  for ( i = 0; i < size; i++ )
    dest[i] = src[i];

  quicksort_inplace( dest, 0, size-1 );

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++
  //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
//   // implement quicksort algorithm here
//   int i;
// 
//   // dummy copy src into dest
//   for ( i = 0; i < size; i++ )
//     dest[i] = src[i];
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++
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

    int dest[size];

    int i;
    for ( i = 0; i < size; i++ )
      dest[i] = 0;

    test_stats_on();
    quicksort_scalar( dest, src, size );
    test_stats_off();

    verify_results( dest, ref, size );

    return 0;
}

