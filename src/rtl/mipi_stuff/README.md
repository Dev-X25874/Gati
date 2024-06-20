# FPGA to CPU Dispatcher Block

This block handles the data transfer between FPGA and CPU. After the completion of all the layers in the model, this bock is responsible
for taking the results stored in DDR to the CPU. It handles the request generation and the data conversion from AXI data width ,i.e., 
256 bits to CPU data width ,i.e., 32 bits.

## How the FPGA to CPU Dispatcher works

First, we'll receive a dispatch_cpu siganl from the instructions after which we'll wait for the layer_done signal from the config block, indicating
that all layers have been completed and results are ready to be dispatched. After which we'll generate a request to DDR to send the data along with 
start address, burst length and read signal.

Once, the request is sent DDR will start sending the 256 bit data from the address given with the request and we'll that data into 32 bit chunks 
and store it in a FIFO to be read by CPU and wait for the config_done signal from the config block indicating the last request, upon which we'll 
send the SOF, data_size and id indicating the end of the operation.

## Sub-Blocks of FPGA to CPU Dispatcher Block

### Dispatch_flag_checker

This is the initial block in the design which will receive the start address and size of the data that needs to be send to the CPU. After
the dispatch_cpu is received, it waits for layer_done and then latches the data and concatenate them and sends to the FIFO which stores all the request.

### Request_Generator

This block generates the request to be sent to DDR. It waits for both mipi_formatter and memory_request_controller to send the ready signals, upon which
it'll take the data from the FIFO and pass it on to the mipi_formatter and memory_request_controller along with a valid request signal.

### Memory_Request_Controller

After, getting a valid_req it latches the address and data size and then sends this 32-bit address to DDR in the chunks of 8-bit along with the burst length, which 
keeps on updating according to the data size which keeps on updating itself and then waits for the data_last siganl from the data_rd_ctrl to send the next request.

### MIPI_Formatter

This block is responsible for slicing the incoming 256-bit data from DDR into 32-bit chunks. As soon as it receives the valid_rq from it latches the data size and
ID and then starts sending data to FIFO and checks for the config_done signal to send the SOF  and indicate the end of the operation.

Below given is the block diagram of fpga2cpu architecture

<img src="test\images\fpga2cpu.drawio.png" alt="fpga2cpu block">


## Steps to test the design

1. We'll have two '.mem' files for testing the design, one for sending the address, data size and id and the other for 256-bit DDR data.

2. Make the 'top_test' module as the top module and run the flow to generate the bitstream.

3. After uploding the bitstream onto the Vaaman board, open the debugger create the reset signal as a trigger and check the waveform for functional verification.