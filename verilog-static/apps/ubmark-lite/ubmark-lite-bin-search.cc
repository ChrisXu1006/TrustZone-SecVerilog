//========================================================================
// ubmark-lite-bin-search
//========================================================================

#include "ubmark-lite-bin-search-KeyValue.h"

#include "ubmark-lite-bin-search.dat"
#include <iostream>

//------------------------------------------------------------------------
// bin_search_scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
void bin_search_scalar( int values[], int keys[], int keys_sz,
                        KeyValue kv[], int kv_sz )
{
  for ( int i = 0; i < keys_sz; i++ ) {

    int key     = keys[i];
    int idx_min = 0;
    int idx_mid = kv_sz/2;
    int idx_max = kv_sz-1;

    bool done = false;
    values[i] = -1;
    do {
      int midkey = kv[idx_mid].key;

      if ( key == midkey ) {
        values[i] = kv[idx_mid].value;
        done = true;
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
// bin_search_scalar_asm
//------------------------------------------------------------------------

__attribute__ ((noinline))
void bin_search_scalar_asm( int values[], int keys[], int keys_sz,
                        KeyValue kv[], int kv_sz )
{
  __asm__ __volatile__
  (

    // Shift saved temporaries onto the stack first
    "addiu $29,$29,-32        \n"
    "sw    $23,28($29)        \n"
    "sw    $22,24($29)        \n"
    "sw    $21,20($29)        \n"
    "sw    $20,16($29)        \n"
    "sw    $19,12($29)        \n"
    "sw    $18,8($29)         \n"
    "sw    $17,4($29)         \n"
    "sw    $16,0($29)         \n"

    "addiu $24, %[kv], 8      \n"
    "lw    $25, 0($24)        \n"

    // Assume well-formed inputs
    "addiu $2, $0, 0            \n" // loop counter i is in $2

    "0:                         \n"
    "sll   $25, $2, 2           \n" // multiply by 4 to get i in the
                                    // index form
    "addu  $3, %[keys], $25     \n" // pointer to i in keys
    "lw    $9, 0($3)            \n" // key = keys[i]
    "addiu $10, $0, 0           \n" // idx_min
    "sra   $11, %[kv_sz], 1     \n" // idx_mid = kv_sz/2
    "addiu $12, %[kv_sz], -1    \n" // idx_max = (kv_sz-1)
    "addiu $13, $0, 0           \n" // done = false

    "addiu $14, $0, -1          \n" // -1
    "addu  $15, %[values], $25  \n" // i pointer in values
    "sw    $14, 0($15)          \n" // values[i] = -1

    "1:                         \n"
    "sll   $24, $11, 3          \n" // idx_mid in pointer form
    "addu  $16, %[kv], $24      \n" // idx_mid pointer in kv
    "lw    $17, 0($16)          \n" // midkey = kv[idx_mid].key

    "bne   $9, $17, 2f          \n" // if ( key == midkey )
    // If block starts
    "lw    $18, 4($16)          \n" // kv[idx_mid].value

    "sll   $25, $2, 2           \n" // multiply by 4 to get i in the
                                    // index form
    "addu  $15, %[values], $25  \n" // i pointer in values
    "sw    $18, 0($15)          \n" // values[i] = kv[idx_mid].value
    "addiu $13, $0, 1           \n" // done = true
    // if block ends

    "2:                         \n"
    "slt   $18, $17, $9         \n" // midkey < key
    "beq   $18, $0, 3f          \n" // if ( midkey < key )
    // if block for midkey < key
    "addiu $10, $11, 1          \n" // idx_min = idx_mid + 1; plus 8
                                    // because each kv is 2 bytes wide
    "j     4f                   \n"
    // end of if block
    // else block
    "3:                         \n"
    "slt   $18, $9, $17         \n" // midkey > key
    "beq   $18, $0, 4f          \n" // if ( midkey > key )
    // if block for midkey > key
    "addiu $12, $11, -1         \n" // idx_max = idx_mid - 1; minus 8
                                    // because each kv is 2 bytes wide
    // end of if block
    "4:                         \n"
    "addu  $20, $10, $12        \n" // idx_min + idx_max
    "sra   $11, $20, 1          \n" // idx_mid = ( idx_min + idx_max ) / 2

    "slt   $21, $12, $10        \n" // idx_max < idx_min
    "or    $22, $21, $13        \n" // done || (idx_max < idx_min)
    "beq   $22, $0, 1b          \n" // while
                                    //( !(done || (idx_max < idx_min)) )
    "addiu $2,  $2, 1           \n" // i++
    "bne   $2, %[keys_sz], 0b   \n"

    // Unshift saved temporaries from the stack
    "lw    $23,28($29)        \n"
    "lw    $22,24($29)        \n"
    "lw    $21,20($29)        \n"
    "lw    $20,16($29)        \n"
    "lw    $19,12($29)        \n"
    "lw    $18,8($29)         \n"
    "lw    $17,4($29)         \n"
    "lw    $16,0($29)         \n"
    "addiu $29,$29,32         \n"
    :
    : [values]  "r" (values),
      [keys]    "r" (keys),
      [keys_sz] "r" (keys_sz),
      [kv]      "r" (kv),
      [kv_sz]   "r" (kv_sz)
  );
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( const char* name,
                     int values[], int ref[], int size )
{
  for ( int i = 0; i < size; i++ ) {
    if ( !( values[i] == ref[i] ) ) {
      std::cout << "  [ FAILED ] " << name << " : "
                << "dest[" << i << "] != ref[" << i << "] "
                << "( " << values[i] << " != " << ref[i] << " )"
                << std::endl;
      return;
    }
  }
  std::cout << "  [ passed ] " << name << std::endl;
}

//------------------------------------------------------------------------
// reset_dest
//------------------------------------------------------------------------

void reset_dest( int *dest, int size )
{
  for ( int i = 0; i < size; i++ )
    dest[i] = 0;
}

//------------------------------------------------------------------------
// Test harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{
  int dest[keys_sz];

  // scalar

  reset_dest( dest, keys_sz );

  bin_search_scalar( dest, keys, keys_sz, kv, kv_sz );

  verify_results( "bin-search-scalar", dest, ref, keys_sz );

  // scalar-asm

  reset_dest( dest, keys_sz );

  bin_search_scalar_asm( dest, keys, keys_sz, kv, kv_sz );

  verify_results( "bin-search-scalar-asm", dest, ref, keys_sz );

  return 0;
}

