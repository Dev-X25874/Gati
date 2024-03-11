# Module Overview

This block contains modules for Shift Register inplementation and testing.

## Shift Register Design

The main shift register design is composed of a multiplexer (mux) and a register, instantiated four times to form a complete shift register module. The mux features a select line determining whether the output is an intermediate result (32 bits) or a quantized result (8 bits). In the case of a quantized result, where the input is 8 bits, data is transferred from one mux and register block to the next while new 8-bit data enters the initial block. The final 32-bit result is received from the shift register block. For intermediate results, the 32-bit input is divided into 8-bit segments, distributed among the four mux and register blocks, with a 32-bit output provided from the shift register block.

## For testing

Modules for testing:
UART receiver, controllers, first set of fifos, shift register designs, second set of fifos, controller after main design, singular fifo, controller for divinding data into 8 bits and a UART transmitter. These modules are designed to facilitate data transmission and processing within a UART system.

### Receiver

The receiver module retrieves 8-bit data and forwards it to the controller.

### Controller

The controller concatenates received 8-bit data to form 32-bit chunks, storing them into a FIFO array in case of intermediate result and 8-bit data from the receiver, storing it into the first FIFO array in the case of quantized result input. It also transfer select signal for the shift register's main design usage.

### Controller for first FIFO Arrays

This controller manages read and write enable operations for the first FIFO array. Write enable for the four FIFOs is enabled sequentially, while read enable is triggered once a specific occupancy threshold is reached in each FIFO.

### Data Flow

Data processed by the controller is passed on to the main shift register design for further computation. The resulting 32-bit data from each instantiation of the main design(4 instances) is stored in the second FIFO array.

### Post-Processing Controller

Following the main design, this controller sequentially reads data from the second FIFO array and writes it into a singular FIFO.

### UART Transmitter Interface and controller fifo tx

The controller FIFO TX module receives 32-bit data from the singular FIFO, dividing it into 8-bit chunks. These chunks are then transferred sequentially to the UART transmitter upon receiving done bit from uart transmitter, the uart transmitter tramits the 8 bits of data serially.
