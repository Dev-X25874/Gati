.. _transpose:

Transpose Architecture
**********************

This document presents the architecture for performing transpose operation on a
tensor MxNxK, specifically, CHW to HWC transpose.

.. image:: _static/Transpose.jpg
    :width: 70%
    :align: center

The basic idea of this architecture is to read the data from DRAM randomly and
write the data into DRAM sequentially in the required order to achieve desired
tensor transposition.

It comprises of a DRAM read memory requestor that requests the data from random
addresses, a set of FIFOs to store the data and a DRAM write memory requestor
that reads the data from FIFO and continuously write into DRAM. For a tensor of
size `MxNxK` and systolic array architecture with `N_SA` number of engines,
random reads are performed as follows, 

1. Read first packet of data from DRAM whose start address is denoted as
   'Start_Add'. The subsequent bytes are accessed by adding offset to this start
   address that points to the next channel data in the DRAM. (i.e., offset =
   :math:`\lceil{\frac{MxN}{L}}\rceil<<AXI_BYTES`, where 'L' is number of bytes
   produced in one column of SA).

2. In each access burst-length is set to '1' and increment the address with the
   above offset till all the channels were read. Number of read accesses
   required for reading atleast one packet of all the channels is
   :math:`\lceil{\frac{K}{N_SA}}\rceil`.

3. After that, increment the base AXI address ('Start_Add') to next address and
   repeat the above two steps.

4. In similar manner, increment the AXI addresses in each iteration. The number
   of iterations required is :math:`\lceil{\frac{MxN}{L}}\rceil`

The data read from DRAM is written into a set of 'L' independent FIFOs. After
reading all channels data then DRAM write requestor initiates the write access
request to DRAM controller to write the FIFO data into DRAM. The write operation
to DRAM is carried out such that, one of the FIFO data is read completely and
then next FIFO data is read out. Depending on the data size, the DRAM write
requestor adjust the burst-length and updates the write DRAM address in each
iteration.

Note that, DRAM read requestor initially reads the first 'L' bytes of all
channels and then next subsequent bytes were requested after successful transfer
of the data present in the 'L' FIFOs.
