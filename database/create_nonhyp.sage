# Adds endomorphism data to a file of colon-separated lines
from endomorphisms import *

# Defining polynomials have to be provided in pairs, defined by strings in x or
# by lists of integers. These polynomials (and the conjectural Sato-Tate group,
# if provided) need to be at a consistent index in the provided lines.

# Length of the lines in the input file:
line_length = 2
# Specify indices of defining polynomials and Sato-Tate group here;
# making the latter negative ignores the corresponding check.
f_index = 1
st_index = -1
# Precision:
prec = 230

import os, shutil

# Specify input and output:
base_string = 'gce_genus3_nonhyperelliptic_possibly_special'
inputfile = base_string + '.txt'
interfile = base_string + '_inter.txt'
outputfile = base_string + '_endos.txt'
shutil.copy(inputfile, interfile)

# Ambient ring:
R.<x,y,z> = PolynomialRing(QQ, 3)

done = False
counter = 0
while not done:
    done = True
    with open(interfile) as inputstream:
        with open(outputfile, 'w') as outputstream:
            for line in inputstream:
                linestrip = line.rstrip()
                print linestrip
                linesplit = linestrip.split(':')
                if len(linesplit) == line_length:
                    try:
                        pol_list = eval(linesplit[f_index].replace('^', '**'))
                        f = R(pol_list[0])
                        X = mPlaneCurve(f)
                        Endo = EndomorphismData(X, prec = prec, molin_neurohr = True)
                        lat_str = Endo.lattice()._desc_
                        sth_str = Endo.lattice()._sthash_
                        line_new1 = repr(lat_str).replace('\n', '').replace(' ', '')
                        line_new2 = repr(sth_str).replace('\n', '').replace(' ', '')
                        outputstream.write(linestrip + ':' + line_new1 + ':' + line_new2 + '\n')
                    except:
                        print "Error"
                        done = False
                        outputstream.write(line)
                else:
                    outputstream.write(line)
    if counter >= 10:
        done = True
    counter += 1
    if not done:
        shutil.move(outputfile, interfile)
        prec += 10
    else:
        os.remove(interfile)

