#!/usr/bin/env python
#===============================================================================
# plab4-net-input-gen.py [opts] file0 [file1 [file2 [file3]]]
#===============================================================================
#
#  -h --help                  Display this message
#  -f --filename <filename>   Output file to filename
#
# Author : Berkin Ilbeyi, Shreesha Srinath
# Date   : 2013, 2012
#
# Generate latency vs bandwidth plots for network. Takes up to 4 files as
# command line options. Files must be space-delimited data pairs on each row.
# The legend is determined by stripping of the input file extensions and
# using the filename.

import argparse
import sys
import re

import numpy as np
import matplotlib.pyplot as plt

#-------------------------------------------------------------------------------
# Command line processing
#-------------------------------------------------------------------------------

class ArgumentParserWithCustomError(argparse.ArgumentParser):
  def error( self, msg = "" ):
    if ( msg ): print("\n ERROR: %s" % msg)
    print("")
    file = open( sys.argv[0] )
    for ( lineno, line ) in enumerate( file ):
      if ( line[0] != '#' ): sys.exit(msg != "")
      if ( (lineno == 2) or (lineno >= 4) ): print( line[1:].rstrip("\n") )

def parse_cmdline():
  p = ArgumentParserWithCustomError( add_help=False )
  p.add_argument( "-h", "--help",    action="store_true" )
  p.add_argument( "-f", "--filename",default="plab4-net-plot.png" )

  p.add_argument( "filenames", nargs=argparse.REMAINDER )

  opts = p.parse_args()
  if opts.help: p.error()
  return opts

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

def main():
  opts = parse_cmdline()

  # List of symbols
  symbols = [ 'r-o', 'g-^', 'b-s', 'c-+' ]

  # Initialize file handler array
  filenames = opts.filenames
  file_ins = []

  try:

    # Open files for reading
    for i in range( len( filenames ) ):
      file_ins.append( open( filenames[i], "r" ) )

    # Index to keep track of file number
    idx = 0

    # Parse each file for data points
    for file in file_ins:

      # Reset data arrays
      x_data = []
      y_data = []

      # Iterate through each line in file
      for line in file:

        # ignore empty lines or lines that start with an asterisk
        if len( line ) == 0 or line[0] == "*":
          continue

        # Parse the line into a list of words
        split_line = line.split()

        # Safety check for format
        if ( len( split_line ) < 2 ):
          sys.stderr.write( "Incorrect data pair format!\n" )
          sys.exit()

        # Add data points to array
        x_data.append( int  ( split_line[0] ) )
        y_data.append( float( split_line[1] ) )

      # Plot data series
      plt.plot( x_data, y_data, symbols[idx], label=filenames[idx][14:-4] )

      # Increment index
      idx = idx + 1

    # Set up plot
    plt.title( 'Ring Network Latency vs. Injection Rate' )
    plt.xlabel( 'Injection Rate [%]' )
    plt.ylabel( 'Latency [cycles]' )
    plt.legend( loc=2 )
    plt.axis( ymax = 60 )

    # Save plot as .png
    plt.savefig( opts.filename, dpi=(640/8), format='png' )

  finally:

    # Open files for reading
    for i in range( len( filenames ) ):
      file_ins[i].close()

main()

