#!/bin/bash

# Usage:
# ./gen.sh conv.txt fc.txt output.txt tail.txt > inst.rst
#

echo ".. code::"
echo

for var in "$@"; do 
  ./gen_cpp_defines.sh $var
done

for var in "$@"; do 
  if [[ $var != "meta.txt" ]]; then
    ./gen_cpp_tables.sh $var
  fi
done
