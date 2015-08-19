//========================================================================
// ubmark-lite-cmlpx-mult
//========================================================================

#include "ubmark-lite-cmplx-mult-Complex.h"
#include <iostream>

#include "ubmark-lite-cmplx-mult.dat"

//------------------------------------------------------------------------
// cmplx_mult_scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
void cmplx_mult_scalar( Complex dest[], Complex src0[],
                              Complex src1[], int size )
{
  for ( int i = 0; i < size; i++ )
    dest[i] = src0[i] * src1[i];
}

//------------------------------------------------------------------------
// cmplx_mult_scalar_asm
//------------------------------------------------------------------------

__attribute__ ((noinline))
void cmplx_mult_scalar_asm( Complex dest[], Complex src0[],
                                  Complex src1[], int size )
{
   __asm__ __volatile__
  (
   // Assuming nice inputs
   "addiu $2, $0, 0            \n"
   "0:                         \n"
   "lw    $8,  0(%[src0])      \n" // src0.real
   "lw    $9,  4(%[src0])      \n" // src0.imag
   "lw    $10, 0(%[src1])      \n" // src1.real
   "lw    $11, 4(%[src1])      \n" // src1.imag
   "mul   $12, $8, $10         \n" // real * real
   "addiu $2, $2, 1            \n"
   "addiu %[src0], %[src0], 8  \n"
   "mul   $13, $9, $11         \n" // imag * imag
   "mul   $14, $9, $10         \n" // imag * real
   "mul   $15, $8, $11         \n" // real * imag
   "subu  $8, $12, $13         \n"
   "sw    $8, 0(%[dest])       \n"
   "addu  $9, $14, $15         \n"
   "sw    $9, 4(%[dest])       \n"
   "addiu %[src1], %[src1], 8  \n"
   "addiu %[dest], %[dest], 8  \n"
   "bne   $2, %[size], 0b      \n"
   :
   : [src0] "r" (src0),
     [src1] "r" (src1),
     [dest] "r" (dest),
     [size] "r" (size)
   );
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( const char* name,
                     Complex dest[], Complex ref[], int size )
{
  for ( int i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) ) {
      std::cout << "  [ FAILED ] " << name << " : "
          << "dest[" << i << "] != ref[" << i << "] "
          << "( " << dest[i] << " != " << ref[i] << " )"
          << std::endl;
      return;
    }
  }
  std::cout << "  [ passed ] " << name << std::endl;
}

//------------------------------------------------------------------------
// reset_dest
//------------------------------------------------------------------------

void reset_dest( Complex *dest, int size )
{
  for ( int i = 0; i < size; i++ )
    dest[i] = Complex( 0, 0);
}

//------------------------------------------------------------------------
// Test harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{

  int size = 100;
  Complex dest[size];

  // scalar

  reset_dest( dest, size );

  cmplx_mult_scalar( dest, src0, src1, size );

  verify_results( "cmplx-mult-scalar", dest, ref, size );

  // scalar asm

  reset_dest( dest, size );

  cmplx_mult_scalar_asm( dest, src0, src1, size );

  verify_results( "cmplx-mult-scalar-asm", dest, ref, size );

  return 0;
}

