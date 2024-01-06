.. _overview:

Overview
########

Convolutional neural networks are a class of Machine Learning algorithms that
excel at identifying/representing patterns in 2D structures such as images. CNN
inherit the computational complexity that ML algorithms are known for.

The compute required for CNN may not be "complex" with a lot of interacting
elements but it is **vast**. Accelerating CNNs is an interesting and challenging
problem as a result. It requires handling memory bandwidth diligently and
designing efficient architectures that fit on a small FPGA and do not occupy a 
lot of resources. 

Vaaman and the edge
===================

Vaaman is a single-board computer with an `FPGA
<https://en.wikipedia.org/wiki/Field-programmable_gate_array>`_ with it. The CPU
and the FPGA are connected through the `MIPI
<https://en.wikipedia.org/wiki/MIPI_Alliance>`_ interface. This connection
allows a special type of computation where the CPU may perform computations
that it is good at (`Data Marshalling
<https://en.wikipedia.org/wiki/Marshalling_(computer_science)>`_, running an
operating system, controlling other processors etc.) and a co-processor (in this
case FPGA, can perform massively parallel, high-throughput demanding
computations). This is the core essence of vaaman (and of `Heterogeneous
Computing <https://en.wikipedia.org/wiki/Heterogeneous_computing>`_).

Where Gati Fits
===============

Gati is the set of software-hardware libraries/programs that enable/accelerate
CNN (as of now) applications. The following document describes the internal
architecture of Gati.
