#=========================================================================
# plab1-imul-input-gen
#=========================================================================
# Script to generate inputs for integer multiplier unit.

import fractions
import random
import sys

# Use seed for reproducability

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------

def print_dataset( in0, in1, out ):

  for i in xrange(len(in0)):

    print "init( {:0>2}, 32'h{:0>8x}, 32'h{:0>8x}, 32'h{:0>8x} );" \
      .format( i, in0[i], in1[i], out[i] )

#-------------------------------------------------------------------------
# Global setup
#-------------------------------------------------------------------------

size = 50
print "num_inputs =", size, ";"

in0 = []
in1 = []
out = []

#-------------------------------------------------------------------------
# small dataset
#-------------------------------------------------------------------------

if sys.argv[1] == "small":
  for i in xrange(size):

    a = random.randint(0,100)
    b = random.randint(0,100)

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

#-------------------------------------------------------------------------
# large dataset
#-------------------------------------------------------------------------

elif sys.argv[1] == "large":
  for i in xrange(size):

    a = random.randint(0,0xffffffff)
    b = random.randint(0,0xffffffff)

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

#-------------------------------------------------------------------------
# lomask dataset
#-------------------------------------------------------------------------

elif sys.argv[1] == "lomask":
  for i in xrange(size):

    shift_amount = random.randint(0,16)
    a = random.randint(0,0xffffff) << shift_amount

    shift_amount = random.randint(0,16)
    b = random.randint(0,0xffffff) << shift_amount

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

#-------------------------------------------------------------------------
# himask dataset
#-------------------------------------------------------------------------

elif sys.argv[1] == "himask":
  for i in xrange(size):

    shift_amount = random.randint(0,16)
    a = random.randint(0,0xffffff) >> shift_amount

    shift_amount = random.randint(0,16)
    b = random.randint(0,0xffffff) >> shift_amount

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

#-------------------------------------------------------------------------
# lohimask dataset
#-------------------------------------------------------------------------

elif sys.argv[1] == "lohimask":
  for i in xrange(size):

    rshift_amount = random.randint(0,12)
    lshift_amount = random.randint(0,12)
    a = (random.randint(0,0xffffff) >> rshift_amount) << lshift_amount

    rshift_amount = random.randint(0,12)
    lshift_amount = random.randint(0,12)
    b = (random.randint(0,0xffffff) >> rshift_amount) << lshift_amount

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

#-------------------------------------------------------------------------
# sparse dataset
#-------------------------------------------------------------------------

elif sys.argv[1] == "sparse":
  for i in xrange(size):

    a = random.randint(0,0xffffffff)

    for i in xrange(32):
      is_masked = random.randint(0,1)
      if is_masked:
        a = a & ( (~(1 << i)) & 0xffffffff )

    b = random.randint(0,0xffffffff)

    for i in xrange(32):
      is_masked = random.randint(0,1)
      if is_masked:
        b = b & ( (~(1 << i)) & 0xffffffff )

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

#-------------------------------------------------------------------------
# Unrecognied dataset
#-------------------------------------------------------------------------

else:
  sys.stderr.write("unrecognized command line argument\n")
  exit(1)

exit(0)

