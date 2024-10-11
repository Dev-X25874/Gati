#!/bin/bash

# Usage:
# ./gen.sh conv.txt fc.txt output.txt tail.txt > inst.rst
#

echo ".. code::"
echo

for var in "$@"; do 
  ./gen_cpp_defines.sh $var
done

cat << EOF 
  struct Table {
    std::map<std::string, int> tbl;
    std::vector<std::string> order;
  };
  void print_table(const Table &tbl);
EOF


for var in "$@"; do 
  if [[ $var != "meta.txt" && $var != "zero.txt" ]]; then
    ./gen_cpp_tables.sh $var
  fi
done
