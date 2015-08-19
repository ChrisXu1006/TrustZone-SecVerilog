#=========================================================================
# plab3-mem-input-gen
#=========================================================================
# Script to generate inputs for cache

import random
import sys

# Use seed for reproducability

random.seed(0xdeadbeef)

max_address = 0xffff
cache = {}
cache_write_templ = "  init_port( c_req_wr, 8'h00, 32'h{:0>8x}, 2'd0, " + \
                               "32'h{:0>8x}, c_resp_wr, 8'h00, 2'd0, " + \
                               "32'h???????? );"

cache_read_templ = "  init_port( c_req_rd, 8'h00, 32'h{:0>8x}, 2'd0, " + \
                               "32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, " + \
                               "32'h{:0>8x} );"

load_mem_templ = "  load_mem( 32'h{:0>8x}, " + \
                              "128'h{:0>8x}_{:0>8x}_{:0>8x}_{:0>8x} );"

def print_header( dset ):
  # replace dashes in the task name with underscore
  print "task init_{};".format( dset.replace( "-", "_" ) )
  print "begin"

def print_footer():
  print "end"
  print "endtask"

def print_cache_write( addr, data ):
  print cache_write_templ.format( addr, data )

def print_cache_read( addr, data ):
  print cache_read_templ.format( addr, data )

def print_load_mem( addr, word0, word1, word2, word3 ):
  print load_mem_templ.format( addr, word3, word2, word1, word0 )

# load random data to the memory given the range
def init_rand_data( begin_addr, end_addr ):
  for addr in xrange( begin_addr, end_addr, 16 ):
    # generate data for the whole cache line
    word0 = random.randint(0, 0xffffffff)
    word1 = random.randint(0, 0xffffffff)
    word2 = random.randint(0, 0xffffffff)
    word3 = random.randint(0, 0xffffffff)

    # add the values to the cache
    cache[ addr     ] = word0
    cache[ addr + 4 ] = word1
    cache[ addr + 8 ] = word2
    cache[ addr + 12] = word3

    # print memory init
    print_load_mem( addr, word0, word1, word2, word3 )

# prints a read or a write function from the given probability for reads
def cache_access( addr, read_prob ):
  is_read = random.random() < read_prob
  if is_read:
    data = cache[ addr ]
    print_cache_read( addr, data )
  else:
    # pick some new data
    data = random.randint(0, 0xffffffff)
    cache[ addr ] = data
    print_cache_write( addr, data )



if len( sys.argv ) < 2:
  print "please provide an argument"
  sys.exit()

#-------------------------------------------------------------------------
# random write/read dataset
#-------------------------------------------------------------------------

def gen_random_writeread( num_its, num_writes, num_reads ):
  for x in xrange(num_its):
    for i in xrange(num_writes):

      # generate some word address within the max address and some random
      # data
      addr = random.randint(0, max_address) & 0xfffffffc
      data = random.randint(0, 0xffffffff)

      # put address and data to a list so that we can read them later
      cache[ addr ] = data

      # print the cache write
      print_cache_write( addr, data )

    for i in xrange(num_reads):

      # pick an entry from the valid cache entries and read it

      addr = random.choice( cache.keys() )
      data = cache[ addr ]

      print_cache_read( addr, data )

#-------------------------------------------------------------------------
# random dataset
#-------------------------------------------------------------------------

def gen_random( num_its, read_prob=0.9 ):
  # load some initial data
  base_addr = 0x5000
  max_addr = base_addr + 0x800
  init_rand_data( base_addr, max_addr )

  for i in xrange( num_its ):
    addr = random.choice( cache.keys() )
    cache_access( addr, read_prob )

#-------------------------------------------------------------------------
# stride/shared dataset
#-------------------------------------------------------------------------

def gen_stride_shared( num_its, stride, num_shared, read_prob=0.9, \
                                    print_stride=True ):
  # load some initial data
  addr = 0x5000
  max_addr = addr + 0x1000
  init_rand_data( addr, max_addr )

  # pick some shared addresses, make sure they don't conflict
  shared_addr = [ addr+120+a*40 for a in xrange(num_shared) ]


  # generate strided loads to the cache
  for addr in xrange( addr, addr + num_its * stride * 4, stride * 4):

    # do shared accesses
    for i in xrange( num_shared ):
      cache_access( shared_addr[i], read_prob )

    if print_stride:
      cache_access( addr, read_prob )

#-------------------------------------------------------------------------
# loop-2d dataset
#-------------------------------------------------------------------------
# accesses for b[] in:
# for ( i = 0; i < 5; i++ )
#   for ( j = 0; j < 100; j++ )
#     result += a[i]*b[j];

def gen_loop_2d( read_prob=0.9 ):
  # load some initial data
  base_addr = 0x5000
  max_addr = base_addr + 0x800
  init_rand_data( base_addr, max_addr )

  for i in xrange(5):
    for j in xrange(100):
      addr = base_addr + j * 4
      cache_access( addr, read_prob )

#-------------------------------------------------------------------------
# loop-3d dataset
#-------------------------------------------------------------------------
# accesses for b[] in:
# for ( i = 0; i < 5; i++ )
#   for ( j = 0; j < 2; j++ )
#     for ( k = 0; k < 8; k++ )
#       result += a[i]*b[j*64 + k*4];

def gen_loop_3d( read_prob=0.9 ):
  # load some initial data
  base_addr = 0x5000
  max_addr = base_addr + 0x800
  init_rand_data( base_addr, max_addr )

  for i in xrange(5):
    for j in xrange(2):
      for k in xrange(8):
        addr = base_addr + (j*64 + k*4) * 4
        cache_access( addr, read_prob )



print_header( sys.argv[1] )

if sys.argv[1] == "random-writeread":
  gen_random_writeread( 5, 10, 10 )

elif sys.argv[1] == "random":
  gen_random( 256 )

elif sys.argv[1] == "ustride":
  gen_stride_shared( 256, 1, 0 )

elif sys.argv[1] == "stride2":
  gen_stride_shared( 256, 2, 0 )

elif sys.argv[1] == "stride4":
  gen_stride_shared( 256, 4, 0 )

elif sys.argv[1] == "shared":
  gen_stride_shared( 256, 1, 2, print_stride=False )

elif sys.argv[1] == "ustride-shared":
  gen_stride_shared( 256, 1, 2 )

elif sys.argv[1] == "loop-2d":
  gen_loop_2d()

elif sys.argv[1] == "loop-3d":
  gen_loop_3d()

print_footer()
