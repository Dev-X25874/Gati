Document for CNN Accelerator on Vaaman

(For any typos reach to yash / shreeyash for modifications)

What is Gati?

  Gati is name of CNN accelerator that runs on the FPGA side of the Vaaman. Gati is a deep learning inference accelerator is a specialized hardware component or system designed to accelerate the inference phase of deep neural networks (DNNs) in deep learning applications. Inference is the process of using a trained neural network model to make predictions or classifications based on new, unseen data. Deep learning inference accelerators are optimized to efficiently execute the inference tasks, providing faster and more energy-efficient results compared to running these tasks on general-purpose processors like CPUs.

What is task that is being accelerated?

  Gati focusses on accelerating image classfication. In our intial version we target VGG16. VGG16 is a deep convolutional neural network architecture used for image classification. It consists of 16 weight layers, including multiple convolutional and fully connected layers. VGG16 is known for its simplicity and effectiveness, with small 3x3 convolutional filters and max-pooling layers that capture intricate image features. Despite its depth, VGG16 has been widely used as a benchmark in computer vision tasks. Its straightforward design and pre-trained models make it a popular choice for various image recognition applications.


List of various blocks and their general definitions. 

Memory controller: The memory controller is responsible for ensuring efficient and accurate data transfer between the master/request initiator and the memory modules. (e.g. CPU is one such an example of a master).

Buffer: A buffer, in the context of computing and information technology, refers to a temporary storage area that holds data while it is being transferred from one location to another. Buffers are commonly used to smooth out differences in data flow rates between two devices or components that might operate at different speeds or with varying data transfer rates. Buffers help to ensure that data can be efficiently processed without interruption, even if there are temporary mismatches in data flow.

Systolic array: 
A systolic array is a parallel computing structure with interconnected processing units that collaboratively perform computations in a synchronized, pipelined manner, often used for matrix multiplication and other iterative algorithms.


The im2col operation is a transformation applied to image data in deep learning. It reshapes image patches into columns, simplifying convolutions and enabling matrix operations. This enhances efficiency in neural networks by utilizing optimized matrix multiplication for convolutional layers.

Integer quantization in deep neural networks is a process of reducing model memory and computation requirements by converting floating-point weights and activations to integer values. This minimizes storage and accelerates computations on hardware with limited precision, maintaining network performance with quantized values for faster inference.

ReLU (Rectified Linear Unit) is a popular activation function used in neural networks. It replaces negative values with zero while keeping positive values unchanged. It helps alleviate the vanishing gradient problem, promoting faster convergence during training.
ReLU6: ReLU6 is a variant of the ReLU activation function that clips the output at 6. In other words, if the output is greater than 6, it is set to 6. This can help constrain the output range and prevent large activations that might cause numerical instability.
ReLU8: ReLU8 is a further variant that clips the output at 8 instead of 6. It operates similarly to ReLU6 but with a different clipping threshold.
Both ReLU6 and ReLU8 are often used in scenarios where constrained output values are desired, such as in quantized neural networks where integer arithmetic is used, limiting the dynamic range of activations to improve efficiency and performance on hardware with limited bit precision.


Max pooling is a downsampling technique in neural networks used to reduce spatial dimensions of feature maps. It partitions input data into non-overlapping regions and selects the maximum value from each region, effectively preserving essential features while reducing computational complexity and preventing overfitting.

Multiplexer (MUX): A multiplexer is a digital circuit that selects one of multiple inputs and forwards it to a single output based on a selection signal. In Verilog, a multiplexer is typically described using the always block or other modeling constructs.

Demultiplexer (DEMUX): A demultiplexer is the reverse of a multiplexer. It takes a single input and routes it to one of multiple outputs based on a selection signal. Verilog is used to define demultiplexers using similar modeling techniques as multiplexers.

Counter: A counter is a digital circuit that generates a sequence of binary numbers. It can be used for tasks like counting events or creating clock divisions. Verilog allows you to design various types of counters, such as binary counters or decade counters, by defining the logic for counting and state transitions.

Shift Register: A shift register is a sequential digital circuit that stores and shifts data in a linear manner. It can be used for tasks like data serialization, parallel-to-serial conversion, or delay generation. In Verilog, you can describe shift registers using shift operations within an always block or other constructs.

MIPI (Mobile Industry Processor Interface) is a standardized communication protocol used in mobile devices and other electronics to transmit data between components like cameras, displays, and sensors. It offers high-speed, low-power, and reliable connections, enabling efficient data transfer and control within compact devices, improving performance and power efficiency.

Synchronous FIFO and Asynchronous FIFO are both types of First-In-First-Out (FIFO) memory buffers used in digital electronic systems, but they differ in how they handle data synchronization and timing. Here are the key differences:

    Synchronization:

        Synchronous FIFO: In a synchronous FIFO, both the write and read operations are synchronized to a common clock signal. This means that data is written into and read from the FIFO on specific clock edges, ensuring precise timing control. Synchronous FIFOs are typically used in systems where data transfer timing is critical.

        Asynchronous FIFO: An asynchronous FIFO, on the other hand, does not rely on a common clock signal for its operation. Write and read operations can occur independently of each other and may be driven by separate clock domains. Asynchronous FIFOs are more flexible in handling data transfers between asynchronous or differently clocked parts of a system.

    Clocking:

        Synchronous FIFO: Synchronous FIFOs require careful clock domain management, as both the writing and reading sides must be synchronized to the same clock. This can be more complex but ensures precise timing control.

        Asynchronous FIFO: Asynchronous FIFOs are more forgiving when it comes to clock domain mismatches because they don't rely on a common clock. They use techniques like handshaking signals to manage data flow between asynchronous domains.

    Complexity:

        Synchronous FIFO: Implementing synchronous FIFOs can be more complex due to the need for careful clock synchronization, but they are often preferred in applications where precise timing is essential.

        Asynchronous FIFO: Asynchronous FIFOs are generally simpler to implement because they don't require strict clock synchronization. They are suitable for applications where flexibility in connecting components with different clock domains is more important than precise timing.

In summary, the choice between synchronous and asynchronous FIFOs depends on the specific requirements of your digital system. Synchronous FIFOs offer precise timing control but require careful clock management, while asynchronous FIFOs are more flexible and can handle data transfers between different clock domains with less stringent timing constraints.


Some faqs 

why is for loop not allowed in verilog design?


In Verilog, for loops are not used for behavioral modeling or describing logic operations directly because Verilog is primarily a hardware description language (HDL), and it is designed to describe the structure and behavior of digital hardware.

Here are a few reasons why for loops are not typically used in Verilog for hardware design:

    Hardware Parallelism: Hardware operates in parallel, whereas for loops imply sequential execution. In hardware design, you want to describe parallelism wherever possible to optimize the performance of the resulting circuit. Using for loops might lead to sequential or serial behavior, which is often undesirable in hardware.


what is difference between matrix multiplication and 2-d convolution?

Matrix multiplication and 2D convolution are two distinct mathematical operations used in various fields, including signal processing and image processing. Here are the key differences between them:

    Operation Purpose:

        Matrix Multiplication: Matrix multiplication is a fundamental mathematical operation used for various purposes, such as solving linear equations, transforming data, or performing operations in linear algebra. It involves multiplying elements of two matrices to produce a new matrix.

        2D Convolution: 2D convolution is specifically used in signal processing and image processing for operations like filtering, blurring, edge detection, and feature extraction. It involves sliding a small matrix (kernel) over a larger matrix (input image) to perform local operations.

    Input Data:

        Matrix Multiplication: Matrix multiplication typically involves two matrices of arbitrary size, and it produces a third matrix as the result. The dimensions of the input matrices must adhere to specific rules to be compatible for multiplication (e.g., the number of columns in the first matrix must match the number of rows in the second matrix).

        2D Convolution: 2D convolution operates on a 2D input matrix (e.g., an image) and a 2D kernel (also known as a filter) matrix. The kernel matrix is usually smaller than the input matrix and is slid over the input in a pixel-wise manner.

    Operation Type:

        Matrix Multiplication: Matrix multiplication is a global operation that considers all elements of both matrices to compute the result. It is used for operations like linear transformations and solving systems of linear equations.

        2D Convolution: 2D convolution is a local operation that computes the output for each pixel in the input image based on a neighborhood defined by the kernel. It is used for various local image processing tasks, including smoothing and feature extraction.

    Output Size:
    
        Matrix Multiplication: The output matrix's size in matrix multiplication depends on the dimensions of the input matrices and follows specific rules (e.g., the resulting matrix's dimensions are determined by the row count of the first matrix and the column count of the second matrix).

        2D Convolution: The output size in 2D convolution can be controlled by the choice of padding and stride parameters. Convolution can produce an output of the same size, smaller size (with valid padding), or larger size (with zero or other padding).

In summary, matrix multiplication is a general mathematical operation for multiplying matrices, while 2D convolution is a specific operation used in image and signal processing for local operations like filtering and feature extraction. They have different input data requirements, operation types, and purposes.


what is mipi interface?


MIPI (Mobile Industry Processor Interface) is a standardized communication protocol used in mobile devices and other electronics to transmit data between components like cameras, displays, and sensors. It offers high-speed, low-power, and reliable connections, enabling efficient data transfer and control within compact devices, improving performance and power efficiency.


difference between synchronous fifo and asynchronous fifo?

Synchronous FIFO and Asynchronous FIFO are both types of First-In-First-Out (FIFO) memory buffers used in digital electronic systems, but they differ in how they handle data synchronization and timing. Here are the key differences:

    Synchronization:

        Synchronous FIFO: In a synchronous FIFO, both the write and read operations are synchronized to a common clock signal. This means that data is written into and read from the FIFO on specific clock edges, ensuring precise timing control. Synchronous FIFOs are typically used in systems where data transfer timing is critical.

        Asynchronous FIFO: An asynchronous FIFO, on the other hand, does not rely on a common clock signal for its operation. Write and read operations can occur independently of each other and may be driven by separate clock domains. Asynchronous FIFOs are more flexible in handling data transfers between asynchronous or differently clocked parts of a system.

    Clocking:

        Synchronous FIFO: Synchronous FIFOs require careful clock domain management, as both the writing and reading sides must be synchronized to the same clock. This can be more complex but ensures precise timing control.

        Asynchronous FIFO: Asynchronous FIFOs are more forgiving when it comes to clock domain mismatches because they don't rely on a common clock. They use techniques like handshaking signals to manage data flow between asynchronous domains.

    Complexity:

        Synchronous FIFO: Implementing synchronous FIFOs can be more complex due to the need for careful clock synchronization, but they are often preferred in applications where precise timing is essential.

        Asynchronous FIFO: Asynchronous FIFOs are generally simpler to implement because they don't require strict clock synchronization. They are suitable for applications where flexibility in connecting components with different clock domains is more important than precise timing.

In summary, the choice between synchronous and asynchronous FIFOs depends on the specific requirements of your digital system. Synchronous FIFOs offer precise timing control but require careful clock management, while asynchronous FIFOs are more flexible and can handle data transfers between different clock domains with less stringent timing constraints.

why is systolic array better than vector processors?


Systolic arrays and vector processors are both parallel computing architectures used to accelerate computations, but they have different strengths and weaknesses. Whether one is "better" than the other depends on the specific application and requirements. Here are some reasons why systolic arrays might be considered advantageous in certain scenarios:

    Regular Data Flow: Systolic arrays are particularly well-suited for algorithms with regular and predictable data flow patterns, such as matrix operations (e.g., matrix multiplication). The data flows through a structured grid of processing elements in a synchronized manner, which can lead to efficient utilization of hardware resources.

    Parallelism: Systolic arrays can achieve a high degree of parallelism by performing the same operation on multiple data elements simultaneously. This makes them efficient for tasks that involve large-scale data parallelism.

    Low Latency: Systolic arrays are designed to minimize data movement and maximize computation within the array. This can lead to low latency, making them suitable for applications where minimizing processing time is critical.

    Energy Efficiency: Due to their regular structure and optimized data flow, systolic arrays can be energy-efficient for specific workloads. By reducing data movement and leveraging parallelism, they can perform computations with lower energy consumption compared to some other architectures.

    Customizability: Systolic arrays are often designed for specific tasks or algorithms. This customization can result in highly efficient hardware for those tasks but might not be as versatile as general-purpose processors. For specialized applications, this can be an advantage.

    Throughput: Systolic arrays can achieve high throughput for specific operations. For example, in a matrix multiplication systolic array, a continuous stream of data can be processed efficiently, which is crucial in applications like scientific computing and deep learning.

However, it's important to note that vector processors also have their strengths, such as flexibility for a wide range of tasks and adaptability to different algorithms. The choice between systolic arrays and vector processors depends on the specific computational requirements and trade-offs for a given application. In practice, hybrid architectures that combine elements of both systolic arrays and vector processors are sometimes used to leverage the advantages of each in different parts of a computation.
User
 
 
 
what is uart protocol?

UART (Universal Asynchronous Receiver/Transmitter) is a widely used hardware communication protocol for serial communication between devices. It is a simple and versatile protocol that has been used for decades in various applications, including computer peripherals, microcontroller-based systems, and communication between devices in embedded systems. Here are some key features of the UART protocol:

    Asynchronous Communication: UART is asynchronous, which means that data is transmitted without a shared clock signal between the sender (transmitter) and receiver. Instead, both devices must agree on a common baud rate (data rate) to ensure proper synchronization.

    Serial Data Transmission: UART sends data sequentially, one bit at a time, over a single wire (transmit or TX) from the transmitter to the receiver. Similarly, data is received one bit at a time on a separate wire (receive or RX) at the receiver.

    Start and Stop Bits: To establish synchronization between devices, UART uses start and stop bits around each data byte. A typical UART frame consists of a start bit, 8 data bits (though it can be configured for different data lengths), an optional parity bit for error-checking, and one or more stop bits.

    Configurable Baud Rate: The baud rate (bits per second) is configurable and must be the same on both the transmitter and receiver. Common baud rates include 9600, 19200, 115200, etc.

    No Master-Slave Relationship: UART communication does not inherently involve a master-slave relationship like some other protocols (e.g., SPI or I2C). Any device with UART capability can transmit data to or receive data from another UART device.

    Half-Duplex: UART is typically half-duplex, meaning that data can be sent or received, but not both simultaneously on the same UART channel. Full-duplex communication often requires two UART channels, one for transmitting and one for receiving.

    Error Handling: UART can include optional error-checking mechanisms, such as parity bits, to detect and correct transmission errors. However, error handling in UART is relatively simple compared to more advanced communication protocols.

    Versatility: UART is a versatile and widely supported protocol used in a variety of applications, including serial communication between microcontrollers, interfacing with sensors and peripherals, and even communication between a computer and external devices through serial ports.

UART is known for its simplicity, which makes it suitable for basic communication needs. However, it may not be as efficient or feature-rich as other protocols like SPI or I2C, which are designed for more complex data transfer requirements.






