//========================================================================
// ubmark.h
//========================================================================
// This header contains assembly functions that handle test passes and
// failures, in addition to turning statistics tracking on and off by
// writing the cp0 status register with the mtc0 instruction.

//------------------------------------------------------------------------
// Support for stats
//------------------------------------------------------------------------

#ifdef _MIPS_ARCH_MAVEN
// parc pass fail, stats using manager interface

inline void test_fail( int index, int val, int ref )
{
  int status = 1;
  asm( "mtc0 %0, $2;"
       "mtc0 %1, $2;"
       "mtc0 %2, $2;"
       "mtc0 %3, $2;"
       "nop;nop;nop;nop;nop;"
       :
       : "r" (status), "r" (index), "r" (val), "r" (ref)
  );
}

inline void test_pass()
{
  int status = 0;
  asm( "mtc0 %0, $2;"
       "nop;nop;nop;nop;nop;"
       :
       : "r" (status)
  );
}

inline void test_stats_on()
{
  int status = 1;
  asm( "mtc0 %0, $21;"
       "nop;nop;nop;nop;nop;"
       :
       : "r" (status)
  );
}

inline void test_stats_off()
{
  int status = 0;
  asm( "mtc0 %0, $21;"
       "nop;nop;nop;nop;nop;"
       :
       : "r" (status)
  );
}

#else
// native pass fail using print

#include <stdio.h>
#include <stdlib.h>

void test_fail( int index, int val, int ref )
{
  printf( "  [ FAILED ] dest[%d] != ref[%d] (%d != %d)\n",
                          index, index, val, ref );
  exit(1);
}

void test_pass()
{
  printf( "  [ passed ] \n" );
  exit(0);
}

void test_stats_on()
{
}

void test_stats_off()
{
}

#endif

//------------------------------------------------------------------------
// Typedefs
//------------------------------------------------------------------------

typedef unsigned char byte;
typedef unsigned int  uint;

