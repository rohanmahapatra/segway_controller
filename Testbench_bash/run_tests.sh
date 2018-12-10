#!/bin/bash
ls -l ./


vlog -work work ../RTL_for_synthesis/*.sv ../RTL_for_synthesis/Segway.v
vlog -work work ../submodules/*.sv

for i in ./tb/*.sv; do
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Starting: " + $i
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	vlog -work work $i
	vsim -c -do tb.do
done


