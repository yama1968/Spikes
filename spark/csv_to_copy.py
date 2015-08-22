#!/usr/bin/python

import sys

csvfile = sys.argv[1]
tablename = sys.argv[2]

alt_csvfile = sys.argv[3] if len(sys.argv) >= 4  else csvfile

# print "Reading from %s, writing to %s..." % (csvfile, scriptfile)

with open(csvfile) as f:
    header = ['"%s"' % c.lower() for c in f.readline()[:-2].split(",")]

    print "copy %s (%s) from '%s' with header=true;" % (tablename, ', '.join(header), alt_csvfile)
