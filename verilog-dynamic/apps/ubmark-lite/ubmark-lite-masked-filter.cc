//========================================================================
// ubmark-lite-masked-filter
//========================================================================

#include <iostream>

//------------------------------------------------------------------------
// Include datasets
//------------------------------------------------------------------------

#include "ubmark-lite-masked-filter.dat"

//------------------------------------------------------------------------
// global coeffient values
//------------------------------------------------------------------------

// These are fixed at (64, 48) so that dividing by norm can be achieved
// by a right shift of 8

//------------------------------------------------------------------------
// masked_filter_scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
void masked_filter_scalar( int dest[], int mask[], int src[],
                           int nrows, int ncols )
{
  int coeff0 = 64;
  int coeff1 = 48;
  int norm_shamt = 8;
  for ( int ridx = 1; ridx < nrows-1; ridx++ ) {
    for ( int cidx = 1; cidx < ncols-1; cidx++ ) {
      if ( mask[ ridx*ncols + cidx ] != 0 ) {
        int out = ( src[ (ridx-1)*ncols + cidx     ] * coeff1 )
                + ( src[ ridx*ncols     + (cidx-1) ] * coeff1 )
                + ( src[ ridx*ncols     + cidx     ] * coeff0 )
                + ( src[ ridx*ncols     + (cidx+1) ] * coeff1 )
                + ( src[ (ridx+1)*ncols + cidx     ] * coeff1 );
        dest[ ridx*ncols + cidx ] = out >> norm_shamt;
      }
      else
        dest[ ridx*ncols + cidx ] = src[ ridx*ncols + cidx ];
    }
  }
}

//------------------------------------------------------------------------
// masked_filter_scalar_asm
//------------------------------------------------------------------------

__attribute__ ((noinline))
void masked_filter_scalar_asm( int dest[], int mask[], int src[],
                               int nrows, int ncols )
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

   "addiu $24, $0, 64        \n" // coeff0
   "addiu $25, $0, 48        \n" // coeff1

   // Assume that nrows and ncols are positive and otherwise well-behaved
   "addiu $2, %[nrows], -1   \n" // end condition nrows
   "addiu $3, %[ncols], -1   \n" // end condition ncols

   "addiu $9, $0, 1          \n" // ridx starts at 1
   "0:                       \n" // row loop
   "addiu $10, $0, 1         \n" // cidx starts at 1
   "1:                       \n" // col loop

   // Calculate mask index
   "mul   $11, %[ncols], $9  \n" // ridx*ncols
   "addu  $11, $11, $10      \n" // ridx*ncols + cidx
   "sll   $11, $11, 2        \n" // ridx*ncols + cidx (pointer)
   "addu  $12, %[mask], $11  \n" // ridx*ncols + cidx (pointer) for mask
   "lw    $12, 0($12)        \n" // mask[ridx*ncols + cidx]

   // If
   "beq   $12, $0, 2f        \n"

   // If block
   "addu  $12, %[src], $11   \n" // ridx*ncols + cidx (pointer) for src
   "lw    $13, 0($12)        \n" // src[ridx*ncols + cidx]
   "mul   $13, $13, $24      \n" // src[ridx*ncols + cidx] * coeff0
   "addu  $23, $13, $0       \n" // out = src[ridx*ncols + cidx] * coeff0

   "lw    $13, 4($12)        \n" // src[ridx*ncols + (cidx+1)]
   "mul   $13, $13, $25      \n" // src[ridx*ncols + (cidx+1)] * coeff1
   "addu  $23, $23, $13      \n" // out += src[ridx*ncols + (cidx+1)] * coeff1

   "lw    $13, -4($12)       \n" // src[ridx*ncols + (cidx-1)]
   "mul   $13, $13, $25      \n" // src[ridx*ncols + (cidx-1)] * coeff1
   "addu  $23, $23, $13      \n" // out += src[ridx*ncols + (cidx-1)] * coeff1

   "addiu $22, $9, 1         \n" // ridx+1
   "mul   $12, %[ncols], $22 \n" // (ridx+1)*ncols
   "addu  $12, $12, $10      \n" // (ridx+1)*ncols + cidx
   "sll   $12, $12, 2        \n" // (ridx+1)*ncols + cidx (pointer)
   "addu  $13, %[src], $12   \n" // (ridx+1)*ncols + cidx (pointer) for src
   "lw    $13, 0($13)        \n" // src[(ridx+1)*ncols + cidx]
   "mul   $14, $13, $25      \n" // src[(ridx+1)*ncols + cidx] * coeff1
   "addu  $23, $23, $14      \n" // out += src[(ridx+1)*ncols + cidx] *
                                // coeff1

   "addiu $22, $9, -1        \n" // ridx-1
   "mul   $12, %[ncols], $22 \n" // (ridx-1)*ncols
   "addu  $12, $12, $10      \n" // (ridx-1)*ncols + cidx
   "sll   $12, $12, 2        \n" // (ridx-1)*ncols + cidx (pointer)
   "addu  $13, %[src], $12   \n" // (ridx-1)*ncols + cidx (pointer) for src
   "lw    $13, 0($13)        \n" // src[(ridx-1)*ncols + cidx]
   "mul   $14, $13, $25      \n" // src[(ridx-1)*ncols + cidx] * coeff1
   "addu  $23, $23, $14      \n" // out += src[(ridx-1)*ncols + cidx] *
                                // coeff1

   "addu  $12, %[dest], $11  \n" // ridx*ncols + cidx (pointer) for dest
   "addiu $22, $0, 8         \n" // shamt
   "sra   $23, $23, $22      \n" // out >>= shamt
   "sw    $23, 0($12)        \n" // dest[ridx*ncols + cidx] = out
   "j     3f                 \n" // End of if block

   // Else block
   "2:                       \n"
   "addu  $12, %[src], $11   \n" // ridx*ncols + cidx (pointer) for src
   "lw    $13, 0($12)        \n" // src[ridx*ncols + cidx]
   "addu  $14, %[dest], $11  \n" // ridx*ncols + cidx (pointer) for dest
   "sw    $13, 0($14)        \n" // dest[ridx*ncols + cidx] = src[ridx*ncols + cidx]

   "3:                       \n"
   "addiu $10, $10, 1        \n" // ridx++
   "bne   $10, $3, 1b        \n"
   "addiu $9, $9, 1          \n" // ridx++
   "bne   $9, $2, 0b         \n"

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
   : [dest ] "r" (dest),
     [mask ] "r" (mask),
     [src  ] "r" (src),
     [nrows] "r" (nrows),
     [ncols] "r" (ncols)
   );
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( const char* name,
                     int dest[], int ref[], int size )
{
  for ( int i = 0; i < size*size; i++ ) {
      if ( !( dest[i] == ref[i] ) ) {
      std::cout << "  [ FAILED ] " << name << " : "
          << "dest[" << i << "] != ref[" << i << "] "
          << "( " << static_cast<int>(dest[i])
          << " != " << static_cast<int>(ref[i]) << " )"
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

  int dest[size*size];

  // scalar
  reset_dest( dest, size*size );
  masked_filter_scalar( dest, mask, src, size, size);
  verify_results( "masked-filter-scalar", dest, ref, size );

  // scalar asm
  reset_dest( dest, size*size );
  masked_filter_scalar_asm( dest, mask, src, size, size);
  verify_results( "masked-filter-scalar-asm", dest, ref, size );

  // Return zero upon successful completion

  return 0;
}
