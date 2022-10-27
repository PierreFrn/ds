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
puts "*********************************************"

#############
# Create IP #
#############
set_part $part
set_property board_part $board [current_project]
read_vhdl -vhdl2008 $vhdl/lab01/ct.vhd
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

# Interconnections
# Primary IOs
create_bd_port -dir I switch0
connect_bd_net [get_bd_pins $ip/switch0] [get_bd_ports switch0]
create_bd_port -dir I wire_in
connect_bd_net [get_bd_pins $ip/wire_in] [get_bd_ports wire_in]
create_bd_port -dir O wire_out
connect_bd_net [get_bd_pins $ip/wire_out] [get_bd_ports wire_out]
create_bd_port -dir O -from 3 -to 0 led
connect_bd_net [get_bd_pins $ip/led] [get_bd_ports led]

# Synthesis flow
validate_bd_design
save_bd_design
generate_target all [get_files $top.bd]
synth_design -top $top

# Configuring ios
array set ios {
	switch0 	{ G15 LVCMOS33 }
	wire_in		{ V12 LVCMOS33 }
	wire_out	{ W16 LVCMOS33 }
	led[0]		{ M14 LVCMOS33 }
	led[1]		{ M15 LVCMOS33 }
	led[2]		{ G14 LVCMOS33 }
	led[3]		{ D18 LVCMOS33 }
}

# IOs
foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}

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
puts "*********************************************"
puts "  bitstream in $design.bit"
puts "  resource utilization report in $design.utilization.rpt"
puts "  timing report in $design.timing.rpt"
puts "*********************************************"

# Quit
quit

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0:
