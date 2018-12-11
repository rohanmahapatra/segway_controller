#!/bin/bash
ls -l ./


vlog -work work ../RTL_for_synthesis/*.sv
vlog -work work ../submodules/*.sv

for i in ./tb/*.sv; do
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "Starting: " + $i
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	vlog -work work $i
	vsim -c -do tb.do
done


