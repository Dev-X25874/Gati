Analysis
########

Timeline and burst analysis
---------------------------

Number of buffer registers available at each compute engine decides the
dram bandwidth. With 16 buffers (128 registers) at each engine we have
16 cycles. With 32 buffers we have 32 cycles dram available. however,
these available cycles (16 or 32) has to be smartly distributed between
blocks that access the dram. Our current version considers a
**fixed-weighted** distribution on DRAM allotment to each of the above
blocks that accesses the DRAM. However, in future revisions this could
be extended to **on-demand-dynamic** allotment of DRAM access to these
blocks.

1. In the current version, with 16 buffer variant, for every 16 cycles:
   im2col block accesses 4 cycle burst, an equal number of cycles to
   dram read by opFIFO set2 - 4 cycle burst, 2 cycle burst write of
   opFIFO set3 to DRAM. Left 6 cycles can be allocated to weight block
   or other block that requires DRAM access.

2. In the current version, with 32 buffer variant, for every 32 cycles:
   im2col block accesses 8 cycle burst, an equal number of cycles to
   dram read by opFIFO set2 - 8 cycle burst, 4 cycle burst write of
   opFIFO set3 to DRAM. Left 12 cycles can be allocated to weight block
   or other block (mipi) that requires DRAM access.

for other queries: shreeyash

Performance
-----------

Our latest performance estimates of imagenet on VGG16 achieve approx
300ms/frame for 9x8 x8 considering 100 MHz. 260ms is spent on first 13
convolution layers and 30ms of rest 40ms is spent on first fully
connected layer with 100MB of weights. our baseline jetson nano 2GB
achieves 130ms operating at 900 MHz.

for other queries: shreeyash
