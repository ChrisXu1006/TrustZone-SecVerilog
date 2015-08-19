#!/usr/bin/python

#========================================================================
# ubmark-lite-cmlpx-mult-gen-dataset
#========================================================================
# This python script generates a dataset in an includable .dat format.
# Meanwhile, it only generates integers for multiplication

import sys
from random import randint

def dump_dataset(size):
    size

    src0_r = [ randint(0,255) for i in range(size) ]
    src0_i = [ randint(0,255) for i in range(size) ]
    src1_r = [ randint(0,255) for i in range(size) ]
    src1_i = [ randint(0,255) for i in range(size) ]
        
    ref_r = [ src0_r[i] * src1_r[i] - src0_i[i] * src1_i[i] for i in range(size) ] 
    ref_i = [ src0_r[i] * src1_i[i] + src0_i[i] * src1_r[i] for i in range(size) ] 

    outFile = open("ubmark-lite-cmplx-mult.dat", "w")

    outFile.write("// Data set for ubmark-lite-cmplx-mult\n\n")
    outFile.write("int dataset_sz = " + str(size) + ";\n\n")

    outFile.write("Complex src0[] = {\n")
    for i in range(size):
        outFile.write("  Complex(" + str(src0_r[i]) + "," + str(src0_i[i]) + "),\n")
    outFile.write("};\n\n")
    
    outFile.write("Complex src1[] = {\n")
    for i in range(size):
        outFile.write("  Complex(" + str(src1_r[i]) + "," + str(src1_i[i]) + "),\n")
    outFile.write("};\n\n")

    outFile.write("Complex ref[] = {\n")
    for i in range(size):
        outFile.write("  Complex(" + str(ref_r[i]) + "," + str(ref_i[i]) + "),\n")
    outFile.write("};\n")

#------------------------------------------------------------------------
# Main section
#------------------------------------------------------------------------

if (len(sys.argv) != 2):
    print "Enter just one argument - the size of the test data set."
    sys.exit(0)

dump_dataset(int(sys.argv[1]))
