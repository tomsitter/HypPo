import fileinput, glob, string, sys, re

lineno = 0;
#read in the folder of interest
#modify this to point to your directory with matlab scripts
for line in fileinput.input(glob.glob("C:\Users\Owner\Documents\MATLAB\HypPo_v1.0\*.m")):
    #display the current folder, reset line count
    if fileinput.isfirstline():
        sys.stderr.write("-- reading %s\n" % fileinput.filename())
        lineno = 0

    #remove blank spaces
    line = line.strip()
    #increment line count
    lineno = lineno + 1

    #skip comments and blank lines
    if not line or line[0] == "%":
        continue
    #regular expression search, display matches
    #modify the string to search for different segments of code
    if re.search('sample_frequency*', line):
        print lineno, ': ', line

print '\n-- Finished --'
