#!/usr/bin/python3

import sys

if len(sys.argv) < 3:
    print("Usage: " + sys.argv[0] + " <cursor name> <scales>")
    sys.exit(1)

scales = [int(i) for i in sys.argv[2:]]

for line in open(sys.argv[1]):
    t = line.strip().split(maxsplit=3)
    if len(t) != 4:
        continue

    size = int(t[0])
    xhot = int(t[1])
    yhot = int(t[2])
    rest = t[3]

    if not rest.startswith("x1/"):
        continue

    for scale in scales:
        print("%d %d %d %s" % (size * scale / 100, xhot * scale / 100, yhot * scale / 100, rest.replace("x1/", "x%d/" % scale)))
