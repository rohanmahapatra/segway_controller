# don't compile tb_tasks.v
vlog -work work tb/*.sv Segway.vg
vsim -t ns +notimingchecks -L /userspace/a/aczech2/ece551/TSMC_lib -novopt work.Segway_tb
run -all
