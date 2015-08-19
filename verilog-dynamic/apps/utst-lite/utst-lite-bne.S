//=========================================================================
// utst-lite-bne.S
//=========================================================================


#include "utst-lite-macros.h"

    TEST_PARC_BEGIN

    addiu $3, $0, 0x0001
    addiu $4, $0, 0x0002
    bne   $3, $4, 2f
1:
    // send zero if fail
    mtc0  $0, $0
    nop
    nop
    nop
    nop
    nop
    nop

2:
    mtc0  $3, $0
    addiu $5, $0, 0x0002
    bne   $4, $5, 3f
    bne   $4, $3, 4f
3:
    // send zero if fail
    mtc0  $0, $0
4:
    mtc0  $3, $0

    // test a loop
    addiu $5, $0, 12
    addiu $4, $0, 0
5:
    addiu $4, $4, 1
    bne   $4, $5, 5b
    mtc0  $4, $0



    TEST_PARC_END

