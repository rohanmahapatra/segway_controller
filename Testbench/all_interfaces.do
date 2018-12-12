onerror {resume}
quietly virtual function -install /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr -env /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr { &{/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[7], /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[6], /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[5], /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[4], /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[3], /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[2], /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[1], /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[0] }} rd_data_7_downto_0
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
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[7]}
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[6]}
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[5]}
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[4]}
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[3]}
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[2]}
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[1]}
add wave -noupdate {/Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data[0]}
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/inst_SPI/rd_data
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/rd_data_7_downto_0
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/ptchlw
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/ptchl
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/ptchhw
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/ptchh
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/azlw
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/azl
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/azhw
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/azh
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/ptch_rt
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/az
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/ready
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/pwr_up
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/integrator_reg
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/vld
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/rider_off
add wave -noupdate -divider iPHY
add wave -noupdate /Segway_tb_h/iPHYS/PWM_frwrd_rght
add wave -noupdate /Segway_tb_h/iPHYS/PWM_rev_rght
add wave -noupdate /Segway_tb_h/iPHYS/PWM_frwrd_lft
add wave -noupdate /Segway_tb_h/iPHYS/PWM_rev_lft
add wave -noupdate -divider DUT
add wave -noupdate /Segway_tb_h/iDUT/PWM_frwrd_rght
add wave -noupdate /Segway_tb_h/iDUT/PWM_rev_rght
add wave -noupdate /Segway_tb_h/iDUT/PWM_frwrd_lft
add wave -noupdate /Segway_tb_h/iDUT/PWM_rev_lft
add wave -noupdate -divider {PWM Output}
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/PWM_frwrd_rght
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/PWM_rev_rght
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/PWM_frwrd_lft
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/PWM_rev_lft
add wave -noupdate -divider PWM_input
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/rght_spd
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/rght_rev
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/lft_spd
add wave -noupdate /Segway_tb_h/iDUT/i_mtr_drv/lft_rev
add wave -noupdate -divider Digital_core
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/rght_spd
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/lft_spd
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/rght_rev
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/lft_rev
add wave -noupdate -divider {Balance Coontroller}
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/ptch
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/lft_spd
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/lft_rev
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/rght_spd
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_balance_cntr/rght_rev
add wave -noupdate -divider {Inertial Integrator}
add wave -noupdate /Segway_tb_h/iDUT/i_Digital_core/i_inert_intr/inst_inert_integrator/ptch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5887850 ns} 1} {{Cursor 3} {3391593 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 356
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
WaveRestoreZoom {2351391 ns} {4590815 ns}
