#!/bin/bash

mkdir -p ./out

# ----------------------------------------------------------------------
# sweep_plot MIN MAX ID OUTPUT CBLABEL
# ----------------------------------------------------------------------
sweep_plot() {
    local MIN=$1
    local MAX=$2
    local id=$3
    local OUTPUT=$4
    local CB_LABEL=$5

    local D
    D=$(echo "($MAX - $MIN) / 11" | bc -l)

gnuplot << EOF
# Set output file
set output "$OUTPUT"
# Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 6,4

set datafile separator ","  # Change to "," if the file uses commas
data = "./data/sweep.txt"

# Define custom line styles with recommended colors
set style line 1 lw 3 lc rgb "#0033AA"  # Deep Blue
set style line 2 lw 3 lc rgb "#0044CC"
set style line 3 lw 3 lc rgb "#0055DD"
set style line 4 lw 3 lc rgb "#1166EE"
set style line 5 lw 3 lc rgb "#3377FF"
set style line 6 lw 3 lc rgb "#5588FF"
set style line 7 lw 3 lc rgb "#7799FF"
set style line 8 lw 3 lc rgb "#99AAFF"  # Light Blue
set style line 9 lw 3 lc rgb "#B3BBFF"  # Very Light Blue
set style line 10 lw 3 lc rgb "#C4C4C4" # Neutral Gray
set style line 11 lw 3 lc rgb "#D6BBA0" # Warm Gray
set style line 12 lw 3 lc rgb "#E8AA7F" # Dimmed Orange
set style line 13 lw 3 lc rgb "#F09A5C" # Light Orange
set style line 14 lw 3 lc rgb "#F87B3C" # Dimmed Red-Orange
set style line 15 lw 3 lc rgb "#FF5C1F" # Brighter Red-Orange
set style line 16 lw 3 lc rgb "#FF4415" # Dimmed Bright Red
set style line 17 lw 3 lc rgb "#FF2A10" # Deep Bright Red
set style line 18 lw 3 lc rgb "#EE120C" # Bold Red
set style line 19 lw 3 lc rgb "#DD0008" # Dimmed Vivid Red
set style line 20 lw 3 lc rgb "#BB0007" # Deep Pure Red

set palette defined ( \
    0 "#0033AA", \
    1 "#0044CC", \
    2 "#0055DD", \
    3 "#1166EE", \
    4 "#3377FF", \
    5 "#5588FF", \
    6 "#7799FF", \
    7 "#99AAFF", \
    8 "#B3BBFF", \
    9 "#C4C4C4", \
    10 "#D6BBA0", \
    11 "#E8AA7F", \
    12 "#F09A5C", \
    13 "#F87B3C", \
    14 "#FF5C1F", \
    15 "#FF4415", \
    16 "#FF2A10", \
    17 "#EE120C", \
    18 "#DD0008", \
    19 "#BB0007" \
)

# ------------------------------------------
set multiplot
# Set up the colorbox
set cbrange [$MIN:$MAX]
set cbtics $D format "%.2f"
set colorbox vertical user
set colorbox origin 0.91, 0.05 
set colorbox size 0.02, 0.9
set cblabel "$CB_LABEL" font "Helvetica Bold,13" offset 1, 0
set border 0
set origin 0.9, 0
set size 0.1, 1
set xrange [0:1]       # Dummy range for the legend
set yrange [0:1]
unset xtics
unset ytics
plot for [j=1:20] NaN w l lc palette frac (j-1)/20 notitle
# Set up the multiplot
set title font "Helvetica Bold,13" offset 0, 0
set border
set xtics
set ytics
set grid lw 1

# Plot sections
# Consolidations (NC)
set origin 0, 0.5
set size 0.30, 0.5
set title "Consolidations (NC)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:25]
do for [j=1:20] {
    ii = j + $id
    id_style = j
    plot data index 0 using (column(0)+1):ii w l ls id_style notitle
}

# Micronodules (NM)
set origin 0.30, 0.5
set size 0.30, 0.5
set title "Micronodules (NM)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:150]
do for [j=1:20] {
    ii = j + $id
    id_style = j
    plot data index 1 using (column(0)+1):ii w l ls id_style notitle
}

# Vol. fraction occupied by consol. (VFC)
set origin 0.60, 0.5
set size 0.30, 0.5
set title "Vol. occupied by consol. (VFC)"
set xlabel "time (days)"
set ylabel "Lung volume fraction" offset 1,0
set xrange [1:80]
set yrange [0:0.15]
do for [j=1:20] {
    ii = j + $id
    id_style = j
    plot data index 4 using (column(0)+1):ii w l ls id_style notitle
}

# Daughter micronodules (NMD)
set origin 0, 0
set size 0.30, 0.5
set title "Daughter micronodules (NMD)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:100]
do for [j=1:20] {
    ii = j + $id
    id_style = j
    plot data index 2 using (column(0)+1):ii w l ls id_style notitle
}

# Isolated micronodules (NMI)
set origin 0.30, 0
set size 0.30, 0.5
set title "Isolated micronodules (NMI)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:100]
do for [j=1:20] {
    ii = j + $id
    id_style = j
    plot data index 3 using (column(0)+1):ii w l ls id_style notitle
}

# Main axis of consolidations (MAC)
set origin 0.60, 0
set size 0.30, 0.5
set title "Main axis of consolidations (MAC)"
set xlabel "time (days)"
set ylabel "Main Axis (mm)" offset 1,0
set xrange [1:80]
set yrange [0:25]
do for [j=1:20] {
    ii = j + $id
    id_style = j
    plot data index 5 using (column(0)+1):ii w l ls id_style notitle
}

unset multiplot
EOF

    echo "Plot saved to $OUTPUT"
}

# ----------------------------------------------------------------------
# Generate all sweep plots
#   sweep_plot  MIN      MAX      ID   OUTPUT                   CBLABEL
# ----------------------------------------------------------------------
sweep_plot  0.8434   1.406    0   "./out/sweep_v0.eps"     "v_0 (mm day^{-1})"
sweep_plot  0.113    0.188    20  "./out/sweep_fimm.eps"   "f_{imm}"
sweep_plot  4.773    7.955    40  "./out/sweep_rmax.eps"   "R_{max 0} (mm)"
sweep_plot  0.083    0.168    60  "./out/sweep_b.eps"      "{/Symbol b} (mm^{-1})"
sweep_plot  0.145    0.242    80  "./out/sweep_nata.eps"   "{/Symbol r} (day^{-1} mm^{-1})"
sweep_plot  0.053    0.088    100 "./out/sweep_rmin.eps"   "r_{min} (mm)"
sweep_plot  14.5     24.167   120 "./out/sweep_n0.eps"     "N_0"
sweep_plot  29.014   48.357   140 "./out/sweep_timm.eps"   "t_{imm} (days)"

