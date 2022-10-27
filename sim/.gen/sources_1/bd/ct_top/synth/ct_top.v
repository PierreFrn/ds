//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
//Date        : Tue Mar  1 16:49:29 2022
//Host        : luberon running 64-bit Ubuntu 20.04.4 LTS
//Command     : generate_target ct_top.bd
//Design      : ct_top
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "ct_top,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ct_top,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "ct_top.hwdef" *) 
module ct_top
   (led,
    switch0,
    wire_in,
    wire_out);
  output [3:0]led;
  input switch0;
  input wire_in;
  output wire_out;

  wire [3:0]ct_led;
  wire ct_wire_out;
  wire switch0_1;
  wire wire_in_1;

  assign led[3:0] = ct_led;
  assign switch0_1 = switch0;
  assign wire_in_1 = wire_in;
  assign wire_out = ct_wire_out;
  ct_top_ct_0 ct
       (.led(ct_led),
        .switch0(switch0_1),
        .wire_in(wire_in_1),
        .wire_out(ct_wire_out));
endmodule
