#=========================================================================
# plab4-net-input-gen
#=========================================================================
# Script for random testing of the test network.

import random
import sys
import math

# Use seed for reproducability

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# Global setup
#-------------------------------------------------------------------------

# Number of messages in dataset

size = 256

num_ports = 8

srcdest_nbits = 3
opaque_nbits  = 8
payload_nbits = 8

# we also calculate how many hex chars to represent these fields with

def hexchars( nbits ):
  return int( math.ceil( nbits * 1.0 / 4 ) )

# we set up the template for the number of bits of each field

dataset_template = ( "init_net_msg( {}'h{{:0>{}x}}, {}'h{{:0>{}x}}, " \
                   + "{}'h{{:0>{}x}}, {}'h{{:0>{}x}} );" ) \
                  .format( srcdest_nbits, hexchars( srcdest_nbits ), \
                           srcdest_nbits, hexchars( srcdest_nbits ), \
                           opaque_nbits,  hexchars(  opaque_nbits ), \
                           payload_nbits, hexchars( payload_nbits ) )

src     = []
dest    = []
opaque  = []
payload = []

#-------------------------------------------------------------------------
# Output Verilog
#-------------------------------------------------------------------------

def print_dataset( src, dest, opaque, payload ):

  for i in xrange(size):

    print dataset_template.format( src[i], dest[i], opaque[i], payload[i] )

#-------------------------------------------------------------------------
# uniform random dataset
#-------------------------------------------------------------------------

if sys.argv[1] == "urandom":
  for i in xrange(size):
    src.append(  random.randint(0, num_ports-1 ) )
    dest.append( random.randint(0, num_ports-1 ) )
    opaque.append(  random.randint( 0, ( 1 << opaque_nbits ) - 1 ) )
    payload.append( random.randint( 0, ( 1 << payload_nbits ) - 1 ) )

#-------------------------------------------------------------------------
# tornado dataset
#-------------------------------------------------------------------------

if sys.argv[1] == "tornado":
  for i in xrange(size):
    src_port = i % num_ports
    src.append(  src_port )
    dest.append( ( src_port + (num_ports - 1)/2 ) % num_ports )
    opaque.append(  random.randint( 0, ( 1 << opaque_nbits ) - 1 ) )
    payload.append( random.randint( 0, ( 1 << payload_nbits ) - 1 ) )


print_dataset( src, dest, opaque, payload )

