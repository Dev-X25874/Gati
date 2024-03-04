# Systolic Array Design and Implementation

## Overview

This document outlines the steps for implementing and verifying a systolic array design on an FPGA (Field Programmable Gate Array). The design utilizes scripts to transmit matrices to the FPGA via PySerial, facilitating convolution operations. The design's functionality is verified through comparison with expected outputs.

## Implementation Steps

The implementation process involves several steps to ensure the proper transmission and processing of weight and image matrices. Follow these steps:

1. Execute the script for sending the weight matrix using the following command:
    ```bash
    ./<FILE_NAME> <PORT> <BAUDRATE>
    ```
    Replace `<FILE_NAME>`, `<PORT>`, and `<BAUDRATE>` with appropriate values for your setup.

2. When prompted with "Enter to send weight matrix" in the terminal, connect the `sel_1` wire with ground on the board and press enter to send the weight matrix to the FIFO north array. Once the matrix is sent, disconnect the cable.

3. Before transmitting the image matrix (matrix_B), a trigger is necessary to load weights from the FIFO array into the processing element (PE) blocks. Connect the `trigger_1` cable with ground on the board and remove it as soon as it gets deasserted to ensure the trigger is sent only once. This step ensures the proper loading of weights into the PE blocks. Whenever a new set of weights needs loading into the systolic array, this trigger must be sent.

4. Send the image matrix to the systolic array's rows by connecting the `sel_2` signal to ground on the board and press enter to transmit the image matrix. Once done, disconnect the cable.

Note: These steps are designed for a single systolic array engine. For multiple systolic array engines (N), run the script in N different terminals simultaneously, following the steps for each engine.

## Verification of Design Functionality

To ensure the precision of the design output, additional Python logic in the script executes the same operation on the input weight and image matrices, saving the output in "out_data.txt." Verification entails examining the serial output (partial sums) using Saleae Logic Analyzer.

### Comparison Steps:

1. The illustration below depicts how the input matrix from the script integrates with the systolic array (SA) design:

    ![Matrix Data Flow](src/rtl/asa/test/images/matrix.png)
2. The "out_data.txt" file captures the output of convolutions performed on matrices sent through the script. Each row in the text file represents the convolution results of the corresponding weights column with each row of the input image matrix. Byte by byte, the text file records these convolution outputs.

    - The first byte in each row corresponds to the convolution output of the weights in the first column with the first row of the input image.
    - Subsequent bytes in the same row represent the convolution outputs of the weights in the first column with the successive rows of the input image.
   
    This pattern repeats for each row in the text file, offering a comprehensive record of the convolution results.

    In case of multiple systolic arrays, the output of each engine comes in a sequence where the output of the first systolic array engines comes first, followed by the second engine, and so forth, until the last engine.

## Output Analysis

Serial Output of Partial Sums from SA Design:

![Partial sums otuput](src/rtl/asa/test/images/psum_output.png)

Each engine has one fifo that stores partial sum output coming from that engine and sends it to the UART transmitter. The output of this fifo is shown in the above image. These outputs are compared with the outputs stored in "out_data.txt" file to ensure the accuracy of the design.

![Serial otuput](src/rtl/asa/test/images/serial_output.png)

A controller converts the 19 bits of output partial sums coming from the last fifo and sends them in 8 bits one by one to the UART transmitter. This is done because the UART transmitter works with 8 bits of data. In the image given above, we compare the corresponding hex values of outputs obtained serially with the hex values of output coming from the last fifo, which is connected with the UART transmitter.