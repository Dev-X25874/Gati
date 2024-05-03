#!/bin/env python
from os import write
from serial import Serial
from random import randint
import sys
import numpy as np

def print_usage(name):
    print(name + " <PORT> <BAUDRATE>")

if len(sys.argv) < 3:
    print("Not enough arguments provided!")
    print_usage(sys.argv[0])
    exit()

port = sys.argv[1]
baudrate = int(sys.argv[2])

# Open the serial port
ser = Serial(port, baudrate)

np.random.seed(24)
w_rows = 22
w_cols = 32
matrix_A = np.random.randint(-128, 127, size=(w_rows, w_cols), dtype=np.int8)
matrix_A_32 = matrix_A.astype(np.int32)
ser.write(matrix_A)
print(matrix_A)

print(matrix_A_32.shape)

def rearrange_matrix(matrix_A_32):
  n_rows, n_cols = matrix_A_32.shape
  arranged_arr = np.zeros((n_rows, n_cols), dtype=matrix_A_32.dtype)

  for i2 in range(0, n_cols, 8):
    i1 = i2 // 2
    arranged_arr[:, i2:i2+4], arranged_arr[:, i2+4:i2+8] = matrix_A_32[:, i1:i1+4], matrix_A_32[:, i1+16:i1+20]
  return arranged_arr

def flatten_matrix(arranged_arr):
    n_rows = arranged_arr.shape[0]
    channels = (n_rows//7)*4
    output_arr = np.zeros((channels*49,1), dtype=int)
    for c in range(channels):
        # print(f"Channel No. : {c}")
        start_row = (c//4)*7
        start_col = (c*8)%32
        end_row = start_row + 7
        end_col = start_col + 8
        o_start = c*49
        o_end = o_start + 49
        temp_arr = arranged_arr[start_row:end_row, start_col:end_col].reshape((-1, 1))[:-7]
        output_arr[o_start:o_end] = temp_arr
        # print(temp_arr)
    # print(output_arr)
    return output_arr

do_rearrangement = int(input("Rearrange the matrix (Enter 1 for yes, 0 for no): "))

if do_rearrangement == 1:
  arranged_arr = rearrange_matrix(matrix_A_32)
  flattened_name = flatten_matrix(arranged_arr)
else:
  flattened_name = matrix_A_32.reshape((-1 , 1))

print("\nFlattened", ("rearranged" if do_rearrangement else "original") + " matrix:")
print(flattened_name)

filename = "flattened_matrix.txt"

# Write the flattened data 3 times to the file
for _ in range(3):
    np.savetxt(filename, flattened_name, fmt="%d")

print(f"\nFlattened {(do_rearrangement  if do_rearrangement else 'original')} matrix saved to: {filename} (written 3 times)")
