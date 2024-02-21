# Adder Tree Block

This Verilog block implements an adder tree structure with 7 adder blocks to compute the sum of 20-bit inputs. The adder tree consists of multiple layers where each layer performs addition operations on inputs from the previous layer until a final output is obtained.

## Functionality

The adder tree block receives inputs from 8 engines and produces a single 20-bit output. The inputs are fed into the adder blocks in a tree-like fashion:

1. The first layer consists of 4 adder blocks, each receiving 2 inputs from respective engines and producing 1 output, each.
2. The second layer has 2 adder blocks, each receiving inputs from 2 adder blocks in the previous layer and producing 1 output, each.
3. The third layer contains a single adder block, which takes inputs from the 2 adder blocks in the second layer and produces the final output.

## Testing Design

The testing design includes several modules to verify the functionality of the adder tree block:

1. **Receiver**: Receives input data from a Python script, providing 8-bit outputs to the next module.
2. **Controller_gen**: Controls the write and read enable signals for an array of FIFOs, ensuring sequential data processing.
3. **FIFO Array**: An array of 8 FIFOs to store intermediate data.
4. **Main Design (Generate Block)**: Generates 8 instances of the main design, each consisting of a controller, FIFO array, adder blocks, and a final FIFO.
5. **Controller_after_main_design**: Manages the data flow between FIFOs and controls the read and write operations.
6. **Final FIFO**: Stores the final results from each instance of the main design.
7. **Controller_fifo_tx**: Controls the transmission of data from the final FIFO to a UART transmitter.
8. **Transmitter**: Transmits data via UART for verification.

## Testing Procedure

1. **Receiver Initialization**: The testing procedure begins with the Receiver module initialized and ready to receive input data from a Python script.

2. **Input Data Transmission**: The Python script transmits input data, byte by byte, which are received by the Receiver module.

3. **Controller_gen Activation**: Upon receiving input data, the Receiver module outputs 8-bit segments sequentially to the Controller_gen module. The Controller_gen module controls the write and read enable signals for an array of FIFOs(writes into the FIFOs sequentially while read from them when they have three or more elements each).

4. **FIFO Array Operations**: The FIFO array, consisting of 8 FIFOs, receives data segments from the Controller_gen module. The data segments are stored in the FIFOs in sequential order, with each FIFO storing one segment.

5. **Main Design Generation**: The Main Design (Generate Block) creates 8 instances of the main design, each containing a controller, FIFO array, adder blocks, and a final FIFO. These instances operate concurrently to process data segments from the FIFO array. The controller concatenate 3 bytes together to make 24 bits and stores it into FIFOs sequentially and the data is read from them once all the fifos have 24 bit element, each. After that the adder blocks operates as stated above, producing a final output(max of 20 bits) which further get stored into a FIFO.

8. **Data Transmission for Verification**: The Controller_after_main_design module manages the transmission of data from the final array of FIFOs of generate block of main design to a singular FIFO to the UART transmitter. It ensures that all final results of 8 instances are transmitted for verification.

9. **UART Transmission**: The UART transmitter sends the transmitted data for verification via another controller. This controller reads from the final singular FIFO at every done bit of the transmitter, breaks the 20 bits of output into 3 packets of 1 byte, each. The data can be monitored and analyzed to ensure that the adder tree block operates correctly and produces the expected results.

## Conclusion

The described testing design verifies the functionality of the adder tree block by processing input data through 8 instances of the main design and transmitting the final results for verification.
