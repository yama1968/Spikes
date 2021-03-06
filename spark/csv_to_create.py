#!/usr/bin/python

import sys

csvfile = sys.argv[1]
tablename = sys.argv[2]
primary = sys.argv[3]

is_integer = (sys.argv[4] if len(sys.argv) >= 5 else "").split(",")

# print "Reading from %s, writing to %s..." % (csvfile, scriptfile)

with open(csvfile) as f:
    header = f.readline()[:-2].split(",")

print "create table %s (" % tablename

typed = [("%s int" % c if c in is_integer else "%s text" % c)
         for c in header]

print ", ".join(typed)

print ", primary key(%s)" % primary

print ");"
