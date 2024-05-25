#!/bin/bash

./gen.sh conv.txt fc.txt output.txt start.txt tail.txt meta.txt > inst.rst
./gen_cpp.sh conv.txt fc.txt output.txt start.txt tail.txt meta.txt >> inst.rst

