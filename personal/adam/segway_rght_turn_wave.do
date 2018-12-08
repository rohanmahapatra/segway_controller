onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Segway_tb/clk
add wave -noupdate /Segway_tb/RST_n
add wave -noupdate -radix hexadecimal /Segway_tb/iPHYS/torque_lft
add wave -noupdate -radix hexadecimal /Segway_tb/iPHYS/torque_rght
add wave -noupdate -radix hexadecimal /Segway_tb/iPHYS/net_torque
add wave -noupdate -format Analog-Step -height 84 -max 27429.0 -radix decimal /Segway_tb/iPHYS/omega_lft
add wave -noupdate -format Analog-Step -height 84 -max 27429.0 -radix decimal /Segway_tb/iPHYS/omega_rght
add wave -noupdate -format Analog-Step -height 84 -max 149789.0 -radix decimal /Segway_tb/iPHYS/theta_lft
add wave -noupdate -format Analog-Step -height 84 -max 149789.0 -radix decimal /Segway_tb/iPHYS/theta_rght
add wave -noupdate -format Analog-Step -height 84 -max 18319.0 -min -18651.0 -radix decimal /Segway_tb/iPHYS/omega_platform
add wave -noupdate -format Analog-Step -height 84 -max 11841.0 -min -9215.0 -radix decimal /Segway_tb/iPHYS/theta_platform
add wave -noupdate -radix hexadecimal /Segway_tb/rider_lean
add wave -noupdate -radix hexadecimal /Segway_tb/iDUT/i_Digital_core/lft_ld
add wave -noupdate -radix hexadecimal /Segway_tb/iDUT/i_Digital_core/rght_ld
add wave -noupdate -radix hexadecimal /Segway_tb/iDUT/batt_w
add wave -noupdate /Segway_tb/iDUT/i_Digital_core/moving
add wave -noupdate /Segway_tb/iDUT/i_Digital_core/rider_off_w
add wave -noupdate /Segway_tb/iDUT/A2D_SS_n
add wave -noupdate /Segway_tb/iDUT/A2D_MOSI
add wave -noupdate /Segway_tb/iDUT/A2D_SCLK
add wave -noupdate /Segway_tb/iDUT/A2D_MISO
add wave -noupdate -format Analog-Step -height 84 -max 930.0 -min -995.0 -radix decimal /Segway_tb/iDUT/i_Digital_core/lft_spd
add wave -noupdate -format Analog-Step -height 84 -max 1005.0 -min -1013.0 -radix decimal /Segway_tb/iDUT/i_Digital_core/rght_spd
add wave -noupdate /Segway_tb/iDUT/i_Digital_core/lft_rev
add wave -noupdate /Segway_tb/iDUT/i_Digital_core/rght_rev
add wave -noupdate /Segway_tb/iDUT/i_peizo_drv/ovr_spd
add wave -noupdate /Segway_tb/iDUT/i_peizo_drv/batt_low
add wave -noupdate /Segway_tb/iDUT/i_peizo_drv/moving
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5762914 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 318
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {74699032 ps}
