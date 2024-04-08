# Configuration Block
The configuration block consists of the following modules:
1. DRAM Controller
2. Instruction Queue Controller
3. Instruction Queue
4. Instruction Read Controller
5. Bus Master COntroller
6. Acknowledgement Controller

### DRAM COntroller:
The DRAM controller is initially idle. After receiving a user start it loads start and stop addresses from global registers.
It then transmits the 32 bit addresses in chunks of 8 bits along with a read request signal to the DRAM Memory.

### Instruction Queue Controller:
The INstruction Queue Controller receives the instructions from the DRAM and writes it into the instruction queue.

### Instruction Queue
The Instruction Queue contains an instantiated submodule sync_fifo_config. It stores all instructions sent by the DRAM.
It also provide status signals to the DRAM controller and Instruction Read Controller. 
When it receives a Read Enable signal from Instruction Read COntroller it sends the instruction containing required data to the Bus Master Controller and Instruction Read Controller.

### Instruction Read Controller
The Instruction Read COntroller sends a read enable signal to the Instruction Queue based on the Done Status of the Bus Master and not_empty status of the Instruction Queue.
It also contains status registers to show the status of the various slave blocks of the bus master.
These status registers are:
1. Previous Registers
2. Next Registers
3. Acknowledgement Registers
These registers decide wheter to send a start signal to the Bus Master Controller.
It also sends a start command when it receives a start instruction i.e opcode =1111.

### Bus Master Controller
It is responsible for controlling various blocks what perform operations based on the instruction data.
It sends a done signal to the Instruction Read Controller.

### Acknowledgement Controller
It receives an acknowledgement signal from the blocks controlled by the bus master and sends a instruction acknowledgement received signal to the instruction read controller.



