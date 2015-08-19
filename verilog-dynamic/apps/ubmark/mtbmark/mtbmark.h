//========================================================================
// ubmark.h
//========================================================================
// This header contains assembly functions that handle test passes and
// failures, in addition to turning statistics tracking on and off by
// writing the cp0 status register with the mtc0 instruction.

//------------------------------------------------------------------------
// Global data structures
//------------------------------------------------------------------------

volatile int g_thread_flags[] = {0,0,0,0};

#ifdef _MIPS_ARCH_MAVEN

//------------------------------------------------------------------------
// Threading primitives
//------------------------------------------------------------------------

inline int get_num_cores()
{
  int num_cores;
  asm( "mfc0 %0, $16;"
       : "=r"(num_cores)
       :
  );
  return num_cores;
}

inline int get_core_id()
{
  int core_id;
  asm( "mfc0 %0, $17;"
       : "=r"(core_id)
       :
  );
  return core_id;
}

void spawn()
{
  int i;
  int core_id = get_core_id();
  int num_cores = get_num_cores();
  if ( core_id == 0 )
    for ( i = 0; i < num_cores; i++ )
      g_thread_flags[i] = 1;
  else
    while ( g_thread_flags[core_id] == 0 );
}

void join()
{
  int i;
  int core_id = get_core_id();
  int num_cores = get_num_cores();
  g_thread_flags[core_id] = 0;
  if ( core_id == 0 )
    for ( i = 1; i < num_cores; i++ )
      while ( g_thread_flags[i] == 1 );
  else
    while( 1 );
}

// tries to get the lock
__attribute__ ((noinline))
int trylock( volatile int *ptr )
{
  int res;
  int value = 1;
  asm( "amo.or %0, %1, %2;"
        : "=r"(res) : "r"(ptr), "r"(value) : "memory" );
  return res;
}

// busy-waits to get the lock at the ptr
void lock( volatile int *ptr )
{
  while( trylock( ptr ) ) ;
}

void unlock( volatile int *ptr )
{
  *ptr = 0;
}


//------------------------------------------------------------------------
// Support for stats
//------------------------------------------------------------------------

inline void test_fail( int index, int val, int ref )
{
  int status = 1;
  asm( "mtc0 %0, $2;"
       "mtc0 %1, $2;"
       "mtc0 %2, $2;"
       "mtc0 %3, $2;"
       :
       : "r" (status), "r" (index), "r" (val), "r" (ref)
  );
}

inline void test_pass()
{
  int status = 0;
  asm( "mtc0 %0, $2;"
       :
       : "r"(status)
  );
}

inline void test_stats_on()
{
  int status = 1;
  asm( "mtc0 %0, $21;"
       :
       : "r"(status)
  );
}

inline void test_stats_off()
{
  int status = 0;
  asm( "mtc0 %0, $21;"
       :
       : "r"(status)
  );
}

// performs size / num_cores, but uses shifts instead becase the processor
// doesn't support divisions

inline int get_core_size( int size )
{
  switch ( get_num_cores() ) {
    case 1 : return size;
    case 2 : return size >> 1;
    case 4 : return size >> 2;
    case 8 : return size >> 3;
    case 16: return size >> 4;
    default: return 0;
  }
}


#else
// native pass fail using print

#include <stdio.h>
#include <stdlib.h>

int get_num_cores() {
  return 1;
}

int get_core_id() {
  return 0;
}

void spawn() {}

void join() {}

void lock( volatile int *ptr )
{
}

void unlock( volatile int *ptr )
{
}

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

int get_core_size( int size )
{
  return size / get_num_cores();
}

#endif

//------------------------------------------------------------------------
// Typedefs
//------------------------------------------------------------------------

typedef unsigned char byte;
typedef unsigned int  uint;

