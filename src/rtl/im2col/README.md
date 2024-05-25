# vaaman-im2col

## IM2COL

### IM2COL in a nutshell

* `Systolic arrays` arranged in a regular square (or rectangular) grid are matmul
(or gemm) machines. I.e. they can perform `matrix multiplications`. `Convolution` on
the other hand is a dot-product based operation. Ergo, it is not possible to
take a 3x3 kernel, for example, and a 3x3 section of a input (as one would in
convolution), feed it to the systolic array and expect the correct result.

* The im2col algorithm works by sliding a window over the input image and extracting patches of data, which are then rearranged into columns.
* IM2COL also takes care of zero padding which is a technique that allows us to preserve the original input size. The type of padding that we're employing in our design is called same padding. This means that we want to pad the original input before we convolve it so that the output size is the same size as the input size. 

***There is a need for a transformation that would allow us to carry out a
convolution operation on a matmul engine. This transformation is `im2col`***

Refer [this](https://github.com/vicharak-in/Gati/edit/rst_docs/docs/source/input_blocks.rst) for a detailed explanation.

### Implementation Details of IM2COL on Vaaman
* Image data is initially received from the DRAM (Dynamic Random Access Memory) through register buffers as input to the im2col block.
* The design incorporates zero padding to ensure consistent patch extraction, especially at the borders of the input image. So im2col requests for the data from the buffer everytime when it is done sending zeroes for zero padding. 
* The output of im2col is the input data including zeroes for zero padding with a valid and valid squares, is sent to systolic array through FIFOs. By expanding image patches into columns and routing them to the systolic array through FIFOs, the design ensures that every patch of the input image is converted into a column format suitable for convolution operations.

### Branching strategy employed

This strategy involves three main branches: `main`, `test`, and `develop`. 

1. Main branch - The `main` branch serves as the primary branch that contains the finalized and latest design of our hardware project. Code is merged into main only after thorough testing and validation.

2. Test branch - The `test` branch is dedicated to hosting all the files required for testing on hardware boards.

3. Develop branch - The `develop` branch is the workspace for ongoing development. It contains the latest code changes, including features that are still in progress or undergoing testing. This branch allows for collaboration among team members without impacting the stability of the main branch.

### Sub blocks of IM2COL
> Index to co-ordinate block
1. When the im2col design receives the start im2col signal, indicated by a pulse, it initiates its operation and maintains the signal high until both the row and column coordinates reach the values of matrix size + 2.
2. This block calculates the coordinates for each data point starting from (1,1) to (matrix size + 2, matrix size + 2). The additional 2 is due to the zero padding.
3. It initiates a request for data from the buffer after sending zeros for zero padding, signaled by o valid buff.
4. Additionally, it ensures that zeros are sent for the first row, last row, first column, and last column.

> Valid Squares block
1. The design incorporates 9 conditions (kernel size - 3x3) to determine which FIFOs the data should be sent to.
2. Based on the row and column coordinates, this block identifies the valid squares and outputs the corresponding data.

> Total Rows
1. This block simply outputs 9 rows with constant values ranging from 1 to 9.


### Steps for testing the design 

1. The input data, organized as a matrix, is transmitted from a Python script. To initiate the transmission, the script is invoked with the command:

   `sudo ./<input_file.py> /dev/tty<usb_port> <baud_rate>`

2. Upon executing the script, pressing the Enter key triggers the transmission of the matrix data through the specified UART terminal.

3. This transmission includes both the size of the matrix and the actual input data, facilitating testing of the system.

4. However, to activate the im2col operation once the data is transmitted, a pulse signal is required. This signal is sent through another UART terminal using serial interface emulators like GTK Term. The pulse signal acts as a trigger, initiating the im2col operation upon receipt.

### Input Generation and Functionality Verification
The below image depicts the input image matrix, generated via a Python script, serves as the initial input for the system. This matrix is essential for testing and validating the functionality of the design.

![image](https://github.com/vicharak-in/vaaman-im2col/assets/102940423/475693fa-d332-4d35-af13-56ab87c4cb50)


The below image shows the output of the design for the functionality verification 

![image](https://github.com/vicharak-in/vaaman-im2col/assets/102940423/da9a2cbf-5024-452f-8f44-b225662500ab)





### Final Output via UART Communication

The depicted image illustrates the expected final output of the system. Notably, there's a distinction between the design output and the final output sent via UART. This discrepancy arises due to a limitation: while the design output comprises 9 bits, UART communication can only handle 8 bits at a time.

To address this limitation, a controller is introduced after a FIFO to manage the transmission. The first 8 bits are sent initially, followed by the last bit appended with 7 additional bits set to 0.

Throughout the im2col transformation, the system generates 9 bits of valid squares, 8 bits of data, and a corresponding valid signal for each data. To streamline transmission, the data and its validity status are concatenated and sent as input to the FIFO. However, to align with UART constraints, the last bit is transmitted with 7 additional 0 bits appended to ensure compatibility with the 8-bit transmission format.

![image](https://github.com/vicharak-in/vaaman-im2col/assets/102940423/45095bcd-79d5-48e1-a8ad-c4cc66929776)


The correctness and integrity of the system's output have undergone thorough verification using a logic analyzer, specifically the "LOGIC" tool by SALEAE. This verification process involved connecting the two UART channels responsible for transmitting data to the logic analyzer. One uart for valid squares and another to capture data and valid. The below image is a captured segment from the logic analyzer.

![image](https://github.com/vicharak-in/vaaman-im2col/assets/102940423/1dc44ad2-64c5-4ea2-957b-c40110038e90)
