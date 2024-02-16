#!/bin/bash
#

file_name=$1
op_name="$(head -n 1 $file_name | cut -d ":" -f 1)"
op_code="$(head -n 1 $file_name | cut -d ":" -f 2)"
printf "\t\`define OP_$op_name $op_code\n"

lower_bound=0
upper_bound=0
while read line; do
  name="$(echo $line | cut -d ":" -f 1)"
  upper_bound="$(( upper_bound + $(echo $line | cut -d ":" -f 2) ))"
  printf "\t\`define $name "$(( upper_bound - 1 )):$lower_bound"\n"
  lower_bound=$upper_bound
done <<< $(tail -n +2 $file_name)
echo 
