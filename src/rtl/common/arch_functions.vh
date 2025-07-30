`ifndef ARCH_FUNCTIONS_VH
`define ARCH_FUNCTIONS_VH

function integer get_img_req_blen(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_img_req_blen = 31;
  else if (nsa == 8 && col == 8 && row == 9)   get_img_req_blen = 31;
  else if (nsa == 16 && col == 1 && row == 16) get_img_req_blen = 15;
  else get_img_req_blen = 0;
endfunction

function integer get_pointer_count(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_pointer_count = 10;
  else if (nsa == 8 && col == 8 && row == 9)   get_pointer_count = 8;
  else if (nsa == 16 && col == 1 && row == 16) get_pointer_count = 8;
  else get_pointer_count = 0;
endfunction

function integer get_inst_queue_depth(input integer nsa, input integer col, input integer row);
    if (nsa == 4 && col == 4 && row == 9)      get_inst_queue_depth = 512;
  else if (nsa == 8 && col == 8 && row == 9)   get_inst_queue_depth = 256;
  else if (nsa == 16 && col == 1 && row == 16) get_inst_queue_depth = 256;
  else get_inst_queue_depth = 0;
endfunction

function integer get_im2col_fifo_depth(input integer nsa, input integer col, input integer row);
   if (nsa == 4 && col == 4 && row == 9)      get_im2col_fifo_depth = 1024;
  else if (nsa == 8 && col == 8 && row == 9)   get_im2col_fifo_depth = 1024;
  else if (nsa == 16 && col == 1 && row == 16) get_im2col_fifo_depth = 512;
  else get_im2col_fifo_depth = 0;
endfunction

function integer get_psum_fifo_depth(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_psum_fifo_depth = 1024;
  else if (nsa == 8 && col == 8 && row == 9)   get_psum_fifo_depth = 512;
  else if (nsa == 16 && col == 1 && row == 16) get_psum_fifo_depth = 512;
  else get_psum_fifo_depth = 0;
endfunction

function integer get_acc_fifo_depth(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_acc_fifo_depth = 512;
  else if (nsa == 8 && col == 8 && row == 9)   get_acc_fifo_depth = 1024;
  else if (nsa == 16 && col == 1 && row == 16) get_acc_fifo_depth = 1024;
  else get_acc_fifo_depth = 0;
endfunction

function integer get_bias_fifo_depth(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_bias_fifo_depth = 512;
  else if (nsa == 8 && col == 8 && row == 9)   get_bias_fifo_depth = 256;
  else if (nsa == 16 && col == 1 && row == 16) get_bias_fifo_depth = 256;
  else get_bias_fifo_depth = 0;
endfunction

function integer get_eltwise_fifo_depth(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_eltwise_fifo_depth = 512;
  else if (nsa == 8 && col == 8 && row == 9)   get_eltwise_fifo_depth = 256;
  else if (nsa == 16 && col == 1 && row == 16) get_eltwise_fifo_depth = 256;
  else get_eltwise_fifo_depth = 0;
endfunction

function integer get_nsa_lut(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_nsa_lut = 0;
  else if (nsa == 8 && col == 8 && row == 9)   get_nsa_lut = 5;
  else if (nsa == 16 && col == 1 && row == 16) get_nsa_lut = 3;
  else get_nsa_lut = 0;
endfunction

function integer get_nsa_dsp(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_nsa_dsp = 4;
  else if (nsa == 8 && col == 8 && row == 9)   get_nsa_dsp = 3;
  else if (nsa == 16 && col == 1 && row == 16) get_nsa_dsp = 13;
  else get_nsa_dsp = 0;
endfunction

function integer get_fc_bram_depth(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_fc_bram_depth = 1024;
  else if (nsa == 8 && col == 8 && row == 9)   get_fc_bram_depth = 1024;
  else if (nsa == 16 && col == 1 && row == 16) get_fc_bram_depth = 512;
  else get_fc_bram_depth = 0;
endfunction

function integer get_mod1(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_mod1 = 2;
  else if (nsa == 8 && col == 8 && row == 9)   get_mod1 = 1;
  else if (nsa == 16 && col == 1 && row == 16) get_mod1 = 1;
  else get_mod1 = 0;
endfunction

function integer get_n_dmux_ports(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_n_dmux_ports = 2;
  else if (nsa == 8 && col == 8 && row == 9)   get_n_dmux_ports = 1;
  else if (nsa == 16 && col == 1 && row == 16) get_n_dmux_ports = 1;
  else get_n_dmux_ports = 0;
endfunction

function integer get_bias_fifo(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_bias_fifo = 8;
  else if (nsa == 8 && col == 8 && row == 9)   get_bias_fifo = 8;
  else if (nsa == 16 && col == 1 && row == 16) get_bias_fifo = 16;
  else get_bias_fifo = 0;
endfunction

function integer get_acc_fifo(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_acc_fifo = 8;
  else if (nsa == 8 && col == 8 && row == 9)   get_acc_fifo = 8;
  else if (nsa == 16 && col == 1 && row == 16) get_acc_fifo = 16;
  else get_acc_fifo = 0;
endfunction

function integer get_acc_op_fifo(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_acc_op_fifo = 2;
  else if (nsa == 8 && col == 8 && row == 9)   get_acc_op_fifo = 1;
  else if (nsa == 16 && col == 1 && row == 16) get_acc_op_fifo = 2;
  else get_acc_op_fifo = 0;
endfunction

function integer get_no_port_va(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_no_port_va = 2;
  else if (nsa == 8 && col == 8 && row == 9)   get_no_port_va = 1;
  else if (nsa == 16 && col == 1 && row == 16) get_no_port_va = 1;
  else get_no_port_va = 0;
endfunction

function integer get_no_port_bac(input integer nsa, input integer col, input integer row);
   if (nsa == 4 && col == 4 && row == 9)        get_no_port_bac = 2;
  else if (nsa == 8 && col == 8 && row == 9)   get_no_port_bac = 1;
  else if (nsa == 16 && col == 1 && row == 16) get_no_port_bac = 1;
  else get_no_port_bac = 0;
endfunction

function integer get_acc_toggle(input integer nsa, input integer col, input integer row);
  if (nsa == 4 && col == 4 && row == 9)        get_acc_toggle = 1;
  else if (nsa == 8 && col == 8 && row == 9)   get_acc_toggle = 0;
  else if (nsa == 16 && col == 1 && row == 16) get_acc_toggle = 0;
  else get_acc_toggle = 0;
endfunction

`endif
