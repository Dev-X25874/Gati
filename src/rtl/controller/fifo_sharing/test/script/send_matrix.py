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
w_rows = 1
w_cols = 16

def write_thread():
    while True:
        c_count = 80
        input("\n[Enter] to Send Matrix_A")
        while c_count:
            matrix_A = np.random.randint(-128, 127, size=(w_rows, w_cols), dtype=np.int8)
            #matrix_A = np.arange(1, 33, dtype=np.int8).reshape(1, 32)
            for row in matrix_A:
                print(row)
                ser.write(row.tobytes())
            c_count -= 1

write_thread()
ser.close()
