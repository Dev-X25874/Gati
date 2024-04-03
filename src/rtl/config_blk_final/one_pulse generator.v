module one_pulse_generator(
    input clkin,
    input signal,
    output reg pulse_signal
);
reg reg_1;
always@(posedge clkin)begin
    reg_1<=signal;
    pulse_signal<=(~reg_1)*(signal);
end
endmodule