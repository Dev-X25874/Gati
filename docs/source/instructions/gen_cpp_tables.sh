#!/bin/bash

file_name=$1
if [[ $file_name == "zero.txt" ]]; then
  exit 0
fi

lower_bound=0
upper_bound=0
op_name="$(head -n 1 $file_name | cut -d ":" -f 1)"
op_name_lower="$(echo $op_name | tr 'A-Z' 'a-z')"

printf "\tinline Table get_"$op_name_lower"_table(const std::bitset<INST_SIZE_BITS>& inst) {\n"
printf "\t\tTable tbl;\n"

while read line; do
  op_name="$(head -n 1 $file_name | cut -d ":" -f 1)"
  name="$(echo $line | cut -d ":" -f 1)"
  upper_bound="$(( upper_bound + $(echo $line | cut -d ":" -f 2) ))"
  printf "\t\ttbl.tbl.insert({\"$name\", bitset_range_get<"$op_name"_"$name"_COUNT, INST_SIZE_BITS>(inst, "$op_name"_"$name"_LOW, "$op_name"_"$name"_HIGH)});\n"
  printf "\t\ttbl.order.push_back(\"$name\");\n"
  lower_bound=$upper_bound
done <<< $(tail -n +2 $file_name)

printf '\t\treturn tbl;\n'
printf '\t}\n'

printf "\tinline void pretty_print_"$op_name_lower"(const std::bitset<INST_SIZE_BITS>& inst) {\n"
printf "\t\tauto tbl = get_"$op_name_lower"_table(inst);\n"
printf "\t\tprint_table(tbl);\n"
printf "\t}\n"

