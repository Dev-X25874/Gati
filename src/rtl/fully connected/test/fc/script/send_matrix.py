#!/bin/env python
from os import write
from serial import Serial
from random import randint
import sys
import threading
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
n_rows = 90
n_cols = 1
w_rows = 1
w_cols = 32

# List to store matrix_A objects
matrix_A_list = []


def compute_fc(input, weightmat):
    return np.matmul(input, weightmat)

def transform(w):
    new_mat=[]
    for i in range((n_cols - 1),-1,-1):
        new_mat.append(w[i])
    return np.array(new_mat)

def write_thread():
    while True:
        c_count = 90
        input("\n[Enter] to Send Matrix_A")
        while c_count:
            matrix_A = np.random.randint(-128, 127, size=(w_rows, w_cols), dtype=np.int8)
            matrix_sA = matrix_A.astype(np.int32)
            matrix_A_list.append(matrix_sA)
            for row in matrix_A:
                print(row)
                ser.write(row.tobytes())
            c_count -= 1

        r_count = 2
        while r_count:
            input("\n[Enter] to Send Matrix_C")
            matrix_C = np.random.randint(-128, 127, size=(n_rows, n_cols), dtype=np.int8)
            for row in matrix_C:
                print(row)
                ser.write(row.tobytes())
            print("\n")
            print("Result:")
            results = []
            for row, matrix_sA in zip(matrix_C, matrix_A_list):
                transformed_A = transform(matrix_sA)
                result = compute_fc([row], transformed_A)
                results.append(result)

            for result in results:
                with open("output.txt", "a") as f:
                    f.write(np.array2string(result[0]) + "\n")
                print(result)

            result_mat = np.array(results, dtype = int)
            temp = []
            print("\nEnter accumulator counter value:\n")
            j = 0
            k = int(input())
            print("\n Accumulated output:\n")
            while j < len(results):
                temp_var = np.sum(result_mat[j:j+k], axis=0)
                temp.append(temp_var)
                j = j + k
                print(temp_var)
            print(temp[0])

            r_count -= 1



write_thread()
ser.close()
