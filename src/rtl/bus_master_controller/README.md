# Bus Master Controller

The Bus Master Controller is a Verilog module designed to facilitate communication between a master device and multiple slave devices within a system. This README serves as a comprehensive guide to understanding its functionality and implementation details, particularly for testing purposes.

## Modules Overview

1. **Master**: This module acts as the central controller, responsible for fetching 256 bits of data from the FIFO (First-In-First-Out) buffer and managing its distribution to the selected slave device.

2. **Master's Controller**: Operating under the direction of the Master module, this component orchestrates the process of dividing the 256-bit data into manageable 8-bit chunks and dispatching them to the designated slave device.

3. **Slaves**:
   - **OP_CONV**: One of the slave modules, designed to handle convolution operations.
   - **OP_FC**: Another slave module designed to handle Fully connected operations.
   - **OP_OUTPUTBLOCK**: A slave module tasked with processing output data block.
   - **OP_TAILBLOCK**: A slave module specialized in handling tailblocks(quantization, relu & maxpool).

## Functionality

- The Master module initiates the data transfer process upon receiving a start signal from the Instruction Read Controller, coupled with a readiness signal from the chosen slave device.

- With guidance from the Master module, the Master's Controller meticulously dissects the incoming 256 bits of data into smaller, 8-bit segments, and dispatches them to the appropriate slave device based on the opcode information obtained from the configuration block.

- Upon receipt of the segmented data, the selected slave device collates the bytes into an internal register and proceeds to execute the necessary operations dictated by its predefined functionality.

- To simplify testing and streamline data monitoring, each slave module emits output signals. To consolidate these signals, a unified "dout" signal is introduced for each slave, encompassing the combined output bits from all the respective slave outputs.

- The collective output data, represented by `dout_final` (comprising 240 bits), is aggregated and stored within a FIFO buffer (`fifo_tx`) for subsequent processing.

- The Controller_TX module then manages the transmission of data by segmenting the 240-bit data stream into 8-bit packets, and forwarding them to the TX module for outbound transmission.

- Data transmission continues through TX until all 8 bits are transferred at the done bit received from tx.

## Testing On-Board

For comprehensive on-board testing, additional modules are integrated into the system:

1. **RX Controller**: Facilitates the reception and coordination of incoming data from external sources.

2. **Controller_RX & FIFO_RX**: Responsible for receiving and buffering the incoming 256 bits of data from the RX Controller, facilitating seamless integration with the main processing pipeline.

3. **Main Design**: The central processing unit, is responsible for orchestrating data flow and executing the functionalities as mentioned earlier.

4. **FIFO_TX & Controller_TX**: Facilitate the transmission of processed data to the TX module, managing data buffering and packetization.

5. **TX**: The transmission module responsible for outbound data transmission to external devices or systems.


   ![image](https://github.com/vicharak-in/Gati/assets/114066925/bc1578ab-b00a-46d8-8d81-f793d53c8017)

