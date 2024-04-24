# Memory Request Controller Module

## Overview

The Memory Request Controller module is designed to manage requests for data from a memory unit. It facilitates the initiation of data retrieval processes based on start and stop addresses, along with controlling the flow of data transfer. This README provides an in-depth explanation of the module's functionality, testing procedures, and its integration within a larger system.

## Functionality

The Memory Request Controller module operates as follows:

1. **Initialization**: The controller waits for a start signal from the configuration block to begin the data retrieval process.

2. **FIFO Status Check**: Upon receiving the start signal, the controller checks the status of the FIFO (First-In-First-Out) buffer. Two conditions must be met for the process to proceed:
   - The FIFO must be empty.
   - The occupancy (the amount of data stored) should be below a set threshold occupancy.

3. **Address Assignment**: Once the FIFO conditions are met, the controller assigns the start address to the `addr_out` output port in chunks of 8 bits.

4. **Address Calculation**: Using the start address, the controller calculates the next address in line for data retrieval.

5. **Stop Address Comparison**: The next address is compared with the stop address to determine the course of action:
   - If the next address matches the stop address, the data retrieval process halts. The controller then checks if the kernel iteration has reached its maximum value. If so, the process transitions to an idle state, awaiting the next valid start signal. If not, the process repeats until the maximum kernel iteration is reached.
   - If the next address exceeds the stop address, the burst length is adjusted to match the difference between the stop address and the next address.
   - If the next address is less than the stop address, the data retrieval process continues as normal.

## Testing

For testing purposes, the Memory Request Controller module is integrated within a larger system consisting of the following modules:

- **RX Module**: Receives input signals.
- **Controller Concatenate**: Concatenates 8-bit inputs to form 32-bit start and stop addresses along with a 12-bit kernel iteration and a start bit.
- **FIFO Modules (3)**: Stores and manages data flow.
- **Top Module**: Comprises the controller for FIFO status and request reception.
- **Controller TX**: Outputs 8 bits of `addr_out` upon receiving a `done` signal from TX.
- **TX Module**: Transfers data.

The testing procedure involves sending valid signals to the main design to trigger data request processes. The controller's functionality is verified by observing the correct handling of start and stop addresses, as well as the data retrieval process.

## Request Controllers:

- for FC
- for FC-bias
- for accumulator
- for bias
- for image
- for weights

![image](https://github.com/vicharak-in/Gati/assets/114066925/52254bb8-0e28-49dd-9a41-8051f4d14e0b)

![image](https://github.com/vicharak-in/Gati/assets/114066925/9f34a130-4412-4351-a35b-cf48affaff55)

