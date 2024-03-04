# Systolic Array Design 

## Overview

This repository contains the design and implementation details of a systolic array, a specialized grid of processors that collaboratively execute repetitive computations efficiently. Such arrays are notably advantageous in tasks involving matrix multiplication or signal processing.

### Purpose and Advantages

The key motivation behind constructing a systolic array lies in its application for performing convolutions within Convolutional Neural Networks (CNNs). Systolic arrays are chosen for their specific advantages:

- **Efficient Handling of Repetitive Computations:** Systolic arrays excel in efficiently managing repetitive computations, a critical aspect in convolution tasks.
- **Parallel Processing Capability:** Utilizing parallel processors arranged in a grid allows simultaneous processing of multiple data components, enhancing computational speed.
- **Alignment with Convolution's Nature:** The array's structure and operation are well-suited for convolution tasks, thereby boosting overall performance in CNNs.
- **Performance Enhancement in CNN Convolutional Layers:** Particularly adept at accelerating computationally intensive tasks within CNN convolutional layers.

## Abstract Data Flow

The flow of data within this systolic array design follows a specific sequence:

1. **Input Storage in FIFO:**
    - Data is transmitted serially from UART.
    - PySerial facilitates the transmission of two matrices (weights and image) via UART.
    - The received data is stored in FIFOs, and the controller manages the transfer of data into the systolic array.

2. **Loading and Processing in Systolic Array:**
    - The systolic array consists of a grid of processors (PEs) and interconnected pathways to perform convolution operations in a pipelined manner.
    - Weight matrices are loaded in a top-to-bottom direction, while the image matrix is loaded from left to right simultaneously.
    - Sub-modules within the systolic array:
        - Grid of PE Blocks: Different configurations exist for PE blocks in various rows.
        - Delay Registers: Introduce clock cycle delays for effective data handling within the array.
    - Utilization of booth multipliers for computation within the array.

3. **Output Storage in FIFO:**
    - The resultant output is stored in a FIFO array (referred to as the south array), managed by dedicated controllers for write and read enable signals.
    - Image data outputted from rows is stored in another FIFO array (east array) for subsequent serial reading through UART.

## Detailed Sections Breakdown

### Input FIFO Storage
The storage of input data in FIFOs is a crucial initial step in the systolic array operation:

- **Byte-by-Byte Sequential Storage:** The data transmission occurs serially, with each byte stored sequentially within a single FIFO. This ensures a structured data flow.
- **Dual FIFO Management via UART:** The system employs two FIFOs, each managed by UART—one dedicated to weights and the other to image data.
- **Array Configuration Correspondence:** To align with the systolic array's columns and rows, two arrays of FIFOs—namely, north_array (for weights) and west_array (for image data)—facilitate organized data storage.

### Systolic Array Processing
The processing phase within the systolic array involves intricate operations and functional units:

- **Grid of Processing Elements (PEs):** The heart of the systolic array consists of a grid of PEs and interconnects designed to execute convolution operations in a pipelined manner.
- **Distinct PE Block Configurations:** Rows within the systolic array host PE blocks with unique configurations—top, middle, bottom—each exhibiting varying input/output characteristics.
- **Clock Cycle Synchronization:** Delay registers are strategically employed to synchronize the data flow, introducing clock cycle delays for seamless data propagation within the array.
- **Enhancing Computational Performance with Booth Multipliers:** Booth multipliers are strategically integrated into the design to optimize computational performance. Their inclusion aims to improve the array's overall efficiency by leveraging advanced multiplication techniques.

### Output FIFO Storage
The management of processed output data through FIFOs constitutes the final phase of the systolic array operation:

- **Dedicated FIFO Arrays (South and East Arrays):** The processed output is stored in the south array, managed by controllers with specific functionalities for efficient write and read operations. Simultaneously, image data from array rows is stored in the east array for subsequent serial transmission through UART.

For a visual representation of the connection setup of controllers and FIFOs within the systolic array, refer to the following diagram:

  <img src="https://github.com/vicharak-in/uart_SA/blob/master/img/systolic_array.jpg" alt="output matrix" width="700" height="400">

*Note: The description and diagram depicts a single systolic array engine. In the design, four systolic array engines run in parallel with identical connections.*
