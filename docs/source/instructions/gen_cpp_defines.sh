#!/bin/bash
#

file_name=$1
if [[ $file_name == "meta.txt" ]]; then
  while read line; do
    name="$(echo $line | cut -d ":" -f 1)"
    val="$(echo $line | cut -d ":" -f 2 | sed "s/HEX/0x/g")"
    printf "\t#define $name $val\n"
  done <<< $(cat $file_name)
elif [[ $file_name == "zero.txt" ]]; then
  lower_bound=0
  upper_bound=0
  while read line; do
    name="$(echo $line | cut -d ":" -f 1)"
    upper_bound="$(( upper_bound + $(echo $line | cut -d ":" -f 2) ))"
    printf "\t#define "$name"_LOW "$lower_bound"\n"
    printf "\t#define "$name"_HIGH "$(( upper_bound - 1 ))"\n"
    printf "\t#define "$name"_COUNT "$(( upper_bound - lower_bound ))"\n"
    lower_bound=$upper_bound
  done <<< $(cat $file_name)
else
  op_name="$(head -n 1 $file_name | cut -d ":" -f 1)"
  op_code="$(head -n 1 $file_name | cut -d ":" -f 2 | sed "s/HEX/0x/g")"
  printf "\t#define OP_$op_name $op_code\n"

  lower_bound=0
  upper_bound=0
  while read line; do
    op_name="$(head -n 1 $file_name | cut -d ":" -f 1)"
    name="$(echo $line | cut -d ":" -f 1)"
    upper_bound="$(( upper_bound + $(echo $line | cut -d ":" -f 2) ))"
    printf "\t#define "$op_name"_"$name"_LOW "$lower_bound"\n"
    printf "\t#define "$op_name"_"$name"_HIGH "$(( upper_bound - 1 ))"\n"
    printf "\t#define "$op_name"_"$name"_COUNT "$(( upper_bound - lower_bound ))"\n"
    lower_bound=$upper_bound
  done <<< $(tail -n +2 $file_name)
fi
echo 
