# MASTER-ONLY: DO NOT MODIFY THIS FILE
#
# Copyright (C) Telecom Paris
# Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

set board [get_board_parts digilentinc.com:zybo*]
set part xc7z010clg400-1

proc usage {} {
	puts "
usage: vivado -mode batch -source <script>
	<script>: TCL script"
	exit -1
}

set script [file normalize [info script]]
set lab [file dirname $script]
set vhdl [file dirname $lab]
regsub {\..*} [file tail $script] "" design
set params $lab/$design.params.tcl

if [file exists $params] {
	source $params
} else {
	puts "
Error: parameter file $params not found. Aborting."
	exit -1
}

if { $argc != 0 } {
	usage
}

puts "*********************************************"
puts "Summary of build parameters"
puts "*********************************************"
puts "Board: $board"
puts "Part: $part"
puts "Root directory: $vhdl"
puts "Design name: $design"
puts "Frequency: $f_mhz MHz"
puts "Delay: $delay_us µs"
puts "*********************************************"

#############
# Create IP #
#############
set_part $part
set_property board_part $board [current_project]
read_vhdl -vhdl2008 $vhdl/lab02/sr.vhd
read_vhdl -vhdl2008 $vhdl/lab03/timer.vhd
read_vhdl -vhdl2008 $vhdl/lab04/lb.vhd
ipx::package_project -force_update_compile_order -import_files -root_dir $design -vendor www.telecom-paris.fr -library DS -force $design
close_project

############################
## Create top level design #
############################
set top ${design}_top
set_part $part
set_property board_part $board [current_project]
set_property ip_repo_paths [list ./$design] [current_fileset]
update_ip_catalog
create_bd_design $top
set ip [create_bd_cell -type ip -vlnv [get_ipdefs *www.telecom-paris.fr:DS:$design:*] $design]
set_property -dict [list CONFIG.f_mhz $f_mhz CONFIG.delay_us $delay_us] $ip

# Interconnections
# Primary IOs
create_bd_port -dir I -type clk clk
connect_bd_net [get_bd_pins $ip/clk] [get_bd_ports clk]
create_bd_port -dir I areset
connect_bd_net [get_bd_pins $ip/areset] [get_bd_ports areset]
create_bd_port -dir O -type data -from 3 -to 0 led
connect_bd_net [get_bd_pins $ip/led] [get_bd_ports led]

# Synthesis flow
validate_bd_design
save_bd_design
generate_target all [get_files $top.bd]
synth_design -top $top

# IOs
foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}

# Clocks and timing
create_clock -name clk -period [expr 1000.0 / $f_mhz] [get_ports clk]
set_false_path -from clk -to [get_ports led[*]]
set_false_path -from [get_ports areset] -to clk

# Implementation
opt_design
place_design
route_design

# Reports
report_utilization -hierarchical -force -file $design.utilization.rpt
report_timing_summary -file $design.timing.rpt

# Bitstream
write_bitstream -force $design

# Messages
puts ""
puts "*********************************************"
puts "\[VIVADO\]: done"
puts "*********************************************"
puts "Summary of build parameters"
puts "*********************************************"
puts "Board: $board"
puts "Part: $part"
puts "Root directory: $vhdl"
puts "Design name: $design"
puts "Frequency: $f_mhz MHz"
puts "Delay: $delay_us µs"
puts "*********************************************"
puts "  bitstream in $design.bit"
puts "  resource utilization report in $design.utilization.rpt"
puts "  timing report in $design.timing.rpt"
puts "*********************************************"

# Quit
quit

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0:
