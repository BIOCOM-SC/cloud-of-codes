#!/bin/bash

mkdir ./out
rm -rf ./out/*

gnuplot terminals_dwall.plt
gnuplot fits.plt
gnuplot experiments.plt
gnuplot prcc.plt
./plot_sweeps.sh
