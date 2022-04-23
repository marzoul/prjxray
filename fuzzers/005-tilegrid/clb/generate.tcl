# Copyright (C) 2017-2020  The Project X-Ray Authors
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
source "$::env(XRAY_DIR)/utils/utils.tcl"

proc run {} {
    create_project -force -part $::env(XRAY_PART) design design
    read_verilog top.v
    synth_design -top top

    set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_00) IOSTANDARD LVCMOS18" [get_ports clk]
    set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_01) IOSTANDARD LVCMOS18" [get_ports stb]
    set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_02) IOSTANDARD LVCMOS18" [get_ports di]
    set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_03) IOSTANDARD LVCMOS18" [get_ports do]

    set_property CFGBVS GND [current_design]
    set_property CONFIG_VOLTAGE 1.8 [current_design]
    set_property BITSTREAM.GENERAL.PERFRAMECRC YES [current_design]

    set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

    place_design
    route_design

    create_cell -reference VCC vcc_cell
    set vcc_pin [get_pins vcc_cell/P]

    create_net vcc_net
    set vcc_net [get_nets vcc_net]
    connect_net -net $vcc_net -objects $vcc_pin

    create_cell -reference GND gnd_cell
    set gnd_pin [get_pins gnd_cell/G]

    create_net gnd_net
    set gnd_net [get_nets gnd_net]
    connect_net -net $gnd_net -objects $gnd_pin

    set fp [open params.csv r]

    # Skip header line
    gets $fp line

    # This is done post-placement to remove PROHIBIT on some sites.
    puts "Creating CARRY4's"
    while {[gets $fp line] >= 0} {
        set parts [split [string trim $line] ","]
        set val [lindex $parts 1]
        set site [lindex $parts 2]

        set cell [create_cell -reference CARRY4 carry4_$site]
        set_property PROHIBIT 0 [get_sites $site]
        set_property KEEP true $cell
        set_property DONT_TOUCH 1 $cell
        set_property LOC $site $cell

        if { $val == 1 } {
            connect_net -net $vcc_net -objects [get_pins carry4_$site/CI]
        } else {
            connect_net -net $gnd_net -objects [get_pins carry4_$site/CI]
        }
    }
    puts "Done creating CARRY4's"

    write_checkpoint -force design.dcp
    write_bitstream -force design.bit
}

run
