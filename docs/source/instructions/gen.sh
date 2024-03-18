#!/bin/bash

# Usage:
# ./gen.sh conv.txt fc.txt output.txt tail.txt > inst.rst
#

echo ".. code::"
echo

while (( $# != 0 )); do
  ./gen_verilog_defines.sh $1
  shift 1 
done 
