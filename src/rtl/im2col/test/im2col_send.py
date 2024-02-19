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
baudrate = sys.argv[2]

# Open the serial port
ser = Serial(port, baudrate)


n_rows = 28
n_cols = 28
file = open('output.txt', 'w')
 

def write_thread():
    input("[Enter] to Send Matrix_A\n")
    matrix_A = np.random.randint(0, 9, size=(n_rows, n_cols), dtype=np.uint8)
    d=b"\x1c"
    ser.write(d)
    for row in matrix_A:
        print(row)
        ser.write(row)

def read_thread():
    while True:
        try:
            # Read bytes from the serial port
            data = ser.read(1)  # Read available bytes or at least 1 byte
            file.write(f"{int.from_bytes(data, 'little')}\n")
            # print(int.from_bytes(data, "little"))
            
        except Exception as e:
            pass

t1 = threading.Thread(target=read_thread)
t1.start()
write_thread()

ser.close()
file.close()
