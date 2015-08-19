#=========================================================================
# vc-test-src-sink-input-gen
#=========================================================================
# Script to generate inputs for simple source/sink tests.

import random
import sys

# Use seed for reproducability

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# Output Verilog
#-------------------------------------------------------------------------


def print_dataset( in_list, out_list ):

  for i in xrange(size):

    print "`SRC_MEM[{:0>2}] = 8'h{:0>2x}; `SINK_MEM[{:0>2}] = 8'h{:0>2x};" \
      .format( i, in_list[i], i, out_list[i] )

#-------------------------------------------------------------------------
# Global setup
#-------------------------------------------------------------------------

# Number of messages in dataset

size = 100

in_list  = []
out_list = []

#-------------------------------------------------------------------------
# ordered dataset
#-------------------------------------------------------------------------

if sys.argv[1] == "ordered":
  for i in xrange(size):
    data = random.randint(0,0xff)

    # add data to both in and out lists

    in_list.append(data)
    out_list.append(data)

  print_dataset( in_list, out_list )

#-------------------------------------------------------------------------
# unordered dataset
#-------------------------------------------------------------------------

if sys.argv[1] == "unordered":
  for i in xrange(size):
    data = random.randint(0,0xff)

    # add data to both in and out lists

    in_list.append(data)
    out_list.append(data)

  # shuffle the out_list to make it unordered

  random.shuffle( out_list )
  print_dataset( in_list, out_list )

# Add random data
exit(0)

