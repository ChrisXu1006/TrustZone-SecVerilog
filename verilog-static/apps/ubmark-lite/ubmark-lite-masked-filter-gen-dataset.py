#!/usr/bin/python

#========================================================================
# ubmark-lite-masked-filter-gen-dataset
#========================================================================
# This python script generates a dataset in an includable .dat format.

import sys
from random import randint

# This version of masked filter has fixed coeffs because we want to use a 
#    right shift to divide out norm.
def masked_filter(dest, mask, src, nrows, ncols):
    coeff0, coeff1 = (64, 48)
    norm_shamt = 8  # 64+48*4 = 256 = 2^8
    
    for ridx in range(1,nrows-1):
        for cidx in range(1,nrows-1):
            if ( mask[ ridx*ncols + cidx ] != 0 ):
                out = (  
                      ( src[ (ridx-1)*ncols + cidx     ] * coeff1 )
                    + ( src[ ridx*ncols     + (cidx-1) ] * coeff1 )
                    + ( src[ ridx*ncols     + cidx     ] * coeff0 )
                    + ( src[ ridx*ncols     + (cidx+1) ] * coeff1 )
                    + ( src[ (ridx+1)*ncols + cidx     ] * coeff1 )
                )
                dest[ ridx*ncols + cidx ] = out >> norm_shamt
            else:
                dest[ ridx*ncols + cidx ] = src[ ridx*ncols + cidx ]

# Draws a square with the top left corner specified by sq_x and sq_y, 
#    with sides of length sq_sz
#    of color color
#    in image image, which has
#    nrows rows and
#    ncols cols
def draw_square(image, nrows, ncols, sq_x, sq_y, sq_sz, color):
    # Determine corners of square

    tl_x = sq_x - sq_sz
    if ( tl_x < 0 ):
        tl_x = 0
    
    tl_y = sq_y - sq_sz
    if ( tl_y < 0 ):
        tl_y = 0;
    
    br_x = sq_x + sq_sz
    if ( br_x > ncols ):
        br_x = ncols-1
    
    br_y = sq_y + sq_sz
    if ( br_y > nrows ):
        br_y = nrows-1

    # Draw the square
        
    for x in range(tl_x, br_x): # This includes br_x
        for y in range(tl_y, br_y): # This includes br_y
            image[ x*ncols + y ] = color;

# Dumps dataset for future testing
#    size is the width of one size of the output square image
#    nsquares is the number of squares going to be drawn into the mask
def dump_dataset(size, nsquares):

    # Generate input image - all white
    src = [ 255 for i in range(size*size) ]
    
    # Add 1000 random squares to source
    for i in range(1000):
        sq_sz = randint(0, size/6)
        sq_x = randint(0, size-1)
        sq_y = randint(0, size-1)
        color = randint(0, 255)
        draw_square(src, size, size, sq_x, sq_y, sq_sz, color)

    # Generate mask - all black
    mask = [ 0 for i in range(size*size) ]

    # Draw nsquares random white squares
    for i in range(nsquares):
        sq_sz = randint(0, size/4)
        sq_x = randint(0, size-1)
        sq_y = randint(0, size-1)
        draw_square(mask, size, size, sq_x, sq_y, sq_sz, 255)

    # Generate template for output - all black
    ref = [ 0 for i in range(size*size) ]

    masked_filter(ref, mask, src, size, size)

    outFile = open("ubmark-lite-masked-filter.dat", "w")

    outFile.write("// Data set for ubmark-lite-masked-filter\n\n")
    outFile.write("int size = " + str(size) + ";\n\n")

    outFile.write("int src[] = {\n")
    for i in range(size*size):
        outFile.write("  " + str(src[i]) + ",\n")
    outFile.write("};\n\n")
    
    outFile.write("int mask[] = {\n")
    for i in range(size*size):
        outFile.write("  " + str(mask[i]) + ",\n")
    outFile.write("};\n\n")

    outFile.write("int ref[] = {\n")
    for i in range(size*size):
        outFile.write("  " + str(ref[i]) + ",\n")
    outFile.write("};\n\n")

#------------------------------------------------------------------------
# Main section
#------------------------------------------------------------------------

if (len(sys.argv) != 2):
    print "Enter just one argument - the size of the test data set."
    sys.exit(0)

dump_dataset(int(sys.argv[1]), 10)
