# Physical/Address specification for Almaif device

## Rationale

[Almaif](almaif.rst) is a Hardware Interface Specification that abstracts an
FPGA accelerator as a linear memory device segmented into 3 distinct regions:
Control, Command Queue, Data. Details of these regions are mentioned in that
document. 

As the FPGA on our board does not have direct access to memory, there is nothing
to be segmented. This specification aims to achieve this deception of the FPGA
being a storage device to the CPU. This spec in brief defines an addressing
protocol and how the aforementioned segmentation is achieved via the FPGA.

## Specification

### Packet Format

This packet shall be referred to as a **"STORE"** packet.

![STORE packet](./store.png)

|Bit fields|Meaning                                                                                                |
|----------|-------------------------------------------------------------------------------------------------------|
|W         |1 if the packet is a Write                                                                             |
|Reserved  |Reserved for future extensions                                                                         |
|Address   |A number that falls in the range of 0-N where N is the size of memory we've advertised the FPGA to have|
|Data      |How this field is interpreted is upto the region (among the three) that the Address field falls in.    |
|          |See below for more information

### Architecture

When a STORE packet is received, there are three ways in which it can be
interpreted. This is decided by the 32bit address field. The address can fall
into three regions of memory: Control, Command Queue, and Data. Each of these
cases are handled separately.

![Block Diagram](./block.png)

The **Address Translator** is like an arbiter. If the address lies in:

1. *Control Region*: One of the 13 registers in the register file need to be
   written to a register mapped to the address in address field. The data to
   be written will be the next 64bits.

2. *Command Queue*: Upcoming 8 packets (each 64 bit) should be sent to a FIFO.
   On the other end of the FIFO is a packet processor that dispatches the
kernels. The 512bits (64\*8) are defined by the Kernel Dispatch Packet format
defined [here](./almaif.rst).

3. *Data*: The Data field in the STORE packet specifies how many 64bits packets
that come after should be stored at address starting from 'Address'. This is 
the only region that is actually memory that can store data. Furthermore, this
is the only region that uses the 'data' field of the STORE packet.

#### Reading/Writing

Above section define for most part how Writing works. Reading is similar. To
read data from any part of the memory, STORE packet should mark the 'Write'
bit as Zero and the 'Data' field should specify how many 64bit packets need
to be read starting from 'Address'

