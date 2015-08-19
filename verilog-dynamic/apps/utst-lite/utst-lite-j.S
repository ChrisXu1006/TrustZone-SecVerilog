//=========================================================================
// utst-lite-j.S
//=========================================================================


#include "utst-lite-macros.h"

    TEST_PARC_BEGIN

    addiu $3, $0, 1
    j   2f
    // send zero if fail
    mtc0  $0, $0
    nop
    nop
    nop
    nop
    nop
    nop

1:
    // pass
    mtc0  $3, $0
    j     3f
    // fail
    mtc0  $0, $0

2:
    // pass
    mtc0  $3, $0
    j     1b
    // fail
    mtc0  $0, $0
3:
    // pass
    mtc0  $3, $0

    // test branch's priority over jump
    bne   $3, $0, 5f
    j     4f
    mtc0  $0, $0

4:
    // fail
    mtc0  $0, $0
5:
    // pass
    mtc0  $3, $0


    TEST_PARC_END

