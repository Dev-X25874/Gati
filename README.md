# Gati

**Gati** is a hardware-accelerated Deep Neural Network (DNN) inference engine designed specifically for FPGA platforms.

Built entirely in Verilog, Gati provides a flexible and efficient framework for accelerating machine learning workloads on reconfigurable hardware. The project focuses on enabling high-performance inference while maintaining portability across FPGA vendors and device families.

## Features

* Fully written in Verilog HDL
* FPGA-native DNN inference acceleration
* Support for Convolutional Neural Networks (CNNs)
* Quantized inference support (INT8)
* Configurable hardware architecture
* Vendor-agnostic design philosophy
* Optimized for resource-constrained FPGA devices
* Scalable architecture for larger FPGA platforms

## Supported Operators

Current accelerator support includes:

* Convolution (Conv2D)
* Fully Connected (Dense) Layers
* Pooling Layers
* ReLU Activation
* Flatten
* Quantization
* Element-wise Operations
* Qlinear Concat 

## Architecture Overview

The accelerator is designed around:

* Dedicated compute engines for DNN operators
* External DRAM-based storage for feature maps and weights
* Streaming dataflow architecture
* Configurable execution pipeline
* ONNX model deployment workflow

## Design Goals

* Support a wide range of neural network architectures
* Minimize FPGA resource utilization
* Maximize throughput per watt
* Remain portable across FPGA vendors
* Enable dynamic mapping of machine learning models to hardware

## Supported Models

Gati currently supports CNN-style architectures including:

* VGG-like Networks
* Image Classification Models
* Custom Quantized CNN Architectures

Support for additional network topologies is continuously expanding.

## Challenges

Large neural network workloads often exceed available on-chip memory resources. Gati addresses this through:

* Efficient DRAM utilization
* Tiling strategies
* Buffered data movement
* Optimized memory access patterns

## Project Status

Active Development

## Future Roadmap

* Broader ONNX compatibility
* Additional quantization formats
* Advanced scheduling and optimization
* Multi-accelerator support
* FPGA SoC integration
* Automated model compilation flow

## License

License information will be added upon public release.

## Contributing

Contributions, bug reports, feature requests, and discussions are welcome.
