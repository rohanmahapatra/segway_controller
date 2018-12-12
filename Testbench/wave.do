onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 84 -max 15815.000000000002 -min -19446.0 -radix decimal /Segway_tb_h/iPHYS/omega_platform
add wave -noupdate -divider {Slave SPI - Inter Sensor}
add wave -noupdate /Segway_tb_h/iPHYS/clk
add wave -noupdate /Segway_tb_h/iPHYS/SS_n
add wave -noupdate /Segway_tb_h/iPHYS/SCLK
add wave -noupdate /Segway_tb_h/iPHYS/MOSI
add wave -noupdate /Segway_tb_h/iPHYS/MISO
add wave -noupdate /Segway_tb_h/iPHYS/INT
add wave -noupdate /Segway_tb_h/iPHYS/ld_tx_reg
add wave -noupdate /Segway_tb_h/iPHYS/shft_reg_tx
add wave -noupdate -divider {DUT - SPI Interface}
add wave -noupdate /Segway_tb_h/iDUT/INT
add wave -noupdate /Segway_tb_h/iDUT/INERT_MISO
add wave -noupdate /Segway_tb_h/iDUT/INERT_SS_n
add wave -noupdate /Segway_tb_h/iDUT/INERT_MOSI
add wave -noupdate /Segway_tb_h/iDUT/INERT_SCLK
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/inst_SPI/done
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/inst_SPI/rd_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5887850 ns} 1} {{Cursor 3} {1454510 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 286
configure wave -valuecolwidth 87
configure wave -justifyvalue left
configure wave -signalnamewidth 3
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1438486 ns} {1473222 ns}
