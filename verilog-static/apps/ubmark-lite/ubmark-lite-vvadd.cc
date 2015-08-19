//========================================================================
// ubmark-lite-vvadd
//========================================================================

#include "ubmark-lite-vvadd.dat"
#include <iostream>

//------------------------------------------------------------------------
// vvadd-scalar-opt
//------------------------------------------------------------------------

__attribute__ ((noinline,optimize("unroll-loops")))
void vvadd_scalar_opt( int *dest, int *src0, int *src1, int size )
{
  for ( int i = 0; i < size; i++ )
    *dest++ = *src0++ + *src1++;
}

//------------------------------------------------------------------------
// vvadd-scalar-unopt
//------------------------------------------------------------------------

__attribute__ ((noinline))
void vvadd_scalar_unopt( int *dest, int *src0, int *src1, int size )
{
  for ( int i = 0; i < size; i++ )
    *dest++ = *src0++ + *src1++;
}

//------------------------------------------------------------------------
// vvadd-scalar-opt-asm
//------------------------------------------------------------------------

__attribute__ ((noinline))
void vvadd_scalar_opt_asm( int *dest, int *src0, int *src1, int size )
{
  __asm__ __volatile__
  (
    "addiu $9, $0, 1            \n"   // r9 = 1
    "slt   $9, %[size], $9      \n"   // r9 = (size < 1)
    "bne   $9, $0, 1f           \n"   // br if (size < 1)
    "addiu $2, $0, 0            \n"
    "0:                         \n"
    "lw    $8,   0(%[src0])     \n"
    "lw    $9,   4(%[src0])     \n"
    "lw    $10,  8(%[src0])     \n"
    "lw    $11, 12(%[src0])     \n"
    "lw    $12,  0(%[src1])     \n"
    "lw    $13,  4(%[src1])     \n"
    "lw    $14,  8(%[src1])     \n"
    "lw    $15, 12(%[src1])     \n"
    "addu  $8,  $8, $12         \n"
    "addu  $9,  $9, $13         \n"
    "addu  $10, $10, $14        \n"
    "addu  $11, $11, $15        \n"
    "addiu $2,  $2, 4           \n"
    "addiu %[src0], %[src0], 16 \n"
    "sw    $8,   0(%[dest])     \n"
    "sw    $9,   4(%[dest])     \n"
    "sw    $10,  8(%[dest])     \n"
    "sw    $11, 12(%[dest])     \n"
    "addiu %[src1], %[src1], 16 \n"
    "addiu %[dest], %[dest], 16 \n"
    "bne   $2, %[size], 0b      \n"
    "1:                         \n"
    :
    : [src0] "r" (src0),
      [src1] "r" (src1),
      [dest] "r" (dest),
      [size] "r" (size)
  );
}

//------------------------------------------------------------------------
// vvadd-scalar-unopt-asm
//------------------------------------------------------------------------

__attribute__ ((noinline))
void vvadd_scalar_unopt_asm( int *dest, int *src0, int *src1, int size )
{
  __asm__ __volatile__
  (
    "addiu $9, $0, 1            \n"   // r9 = 1
    "slt   $9, %[size], $9      \n"   // r9 = (size < 1)
    "bne   $9, $0, 1f           \n"   // br if (size < 1)
    "addiu $2, $0, 0            \n"
    "0:                         \n"
    "lw    $3, 0(%[src0])       \n"
    "lw    $8, 0(%[src1])       \n"
    "addiu $2, $2, 1            \n"
    "addiu %[src0], %[src0], 4  \n"
    "addu  $3, $3, $8           \n"
    "sw    $3, 0(%[dest])       \n"
    "addiu %[src1], %[src1], 4  \n"
    "addiu %[dest], %[dest], 4  \n"
    "bne   $2, %[size], 0b      \n"
    "1:                         \n"
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
                     int dest[], int ref[], int size )
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

void reset_dest( int *dest, int size )
{
  for ( int i = 0; i < size; i++ )
    dest[i] = 0;
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{

    int size = 100;
    int dest[size];

    // scalar unopt

    reset_dest( dest, size );

    vvadd_scalar_unopt( dest, src0, src1, size );

    verify_results( "vvadd-scalar-unopt", dest, ref, size );

    // scalar opt

    reset_dest( dest, size );

    vvadd_scalar_opt( dest, src0, src1, size );

    verify_results( "vvadd-scalar-opt", dest, ref, size );

    // scalar opt asm

    reset_dest( dest, size );

    vvadd_scalar_opt_asm( dest, src0, src1, size );

    verify_results( "vvadd-scalar-opt-asm", dest, ref, size );

    // scalar unopt asm

    reset_dest( dest, size );

    vvadd_scalar_unopt_asm( dest, src0, src1, size );

    verify_results( "vvadd-scalar-unopt-asm", dest, ref, size );

    return 0;
}

