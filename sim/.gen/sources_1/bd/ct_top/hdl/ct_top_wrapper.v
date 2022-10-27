//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
//Date        : Tue Mar  1 16:49:29 2022
//Host        : luberon running 64-bit Ubuntu 20.04.4 LTS
//Command     : generate_target ct_top_wrapper.bd
//Design      : ct_top_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ct_top_wrapper
   (led,
    switch0,
    wire_in,
    wire_out);
  output [3:0]led;
  input switch0;
  input wire_in;
  output wire_out;

  wire [3:0]led;
  wire switch0;
  wire wire_in;
  wire wire_out;

  ct_top ct_top_i
       (.led(led),
        .switch0(switch0),
        .wire_in(wire_in),
        .wire_out(wire_out));
endmodule
