###############################################################################
####################### PRCC ON LAST DAY OF SIMU ##############################
###############################################################################
# Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 6,4
set output "./out/prcc_final.eps"

# Define file and constants
set datafile separator " "  # Change to "," if the file uses commas
prcc = "./data/prcc_final.txt"
y_p = 0.0622
y_m = -0.0622

# Define custom line styles with recommended colors
set style line 1 lw 3 lc rgb "#999999"  # Grey
set style line 2 lw 2 lc rgb  "#0072bd"  # Blue

# Define xtics with labels
set xtics ("v_0" 0, "f_{imm}" 1, "R_{m_0}" 2, "{/Symbol b}" 3, \
           "{/Symbol r}" 4, "r_{min}" 5, "N_0" 6, "t_{imm}" 7)

# Configure plot style
set title font "Helvetica Bold,13"
set grid lw 1
set style histogram errorbars gap 2 lw 1
set style data histograms 
set style fill solid 1.0 border -1
set boxwidth 2.2  # Increase box width for thicker bars
set yrange [-1:1]  # Set y-range for better bar scaling
set ylabel "PRCC" offset 1,0  # Label y-axis

# Plot the data
set multiplot layout 2, 3 title "PRCC sensitivity analysis of output variables in day 80 at optimal parameters" font "Helvetica Bold,13"

set title "Consolidations (NC)"
set arrow from graph 0, first y_p to graph 1, first y_p nohead ls 1 front
set arrow from graph 0, first y_m to graph 1, first y_m nohead ls 1 front
plot prcc i 0 using 2:3 notitle ls 2

set title "Micronodules (NM)"
plot prcc i 1 using 2:3 notitle ls 2

set title "Volume occupied by consol. (VFC)"
plot prcc i 2 using 2:3 notitle ls 2

set title "Daughter micronodules (NMD)"
plot prcc i 3 using 2:3 notitle ls 2

set title "Isolated micronodules (NMI)"
plot prcc i 4 using 2:3 notitle ls 2

set title "Main axis of consolidations (MAC)"
plot prcc i 5 using 2:3 notitle ls 2

unset multiplot


###############################################################################
############################ PRCC EVOLUTION  ##################################
###############################################################################
reset
#Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 6,4
set output "./out/prcc.eps"

set datafile separator ","  # Change to "," if the file uses commas
prcc = "./data/prcc_daily.txt"
y_p = 0.0622
y_m = -0.0622

# Define custom line styles with recommended colors
set style line 1 lw 3 lc rgb "#999999"  # Grey
# set style line 2 lw 2 lc rgb "#000080"  # Navy Blue # "#0072B2"  # Blue
set style line 2 lw 2 lc rgb "#8B4513" # Saddle Brown
# set style line 3 lw 2 lc rgb "#000000"  # "#D55E00"  # Red
set style line 3 lw 2 lc rgb "#DC143C" # Red
set style line 4 lw 2 lc rgb "#E69F00"  # Orange
set style line 5 lw 2 lc rgb "#66C266"  # Green
set style line 6 lw 2 lc rgb "#CC79A7"  # Purple
set style line 7 lw 2 lc rgb "#56B4E9"  # Light Blue
set style line 8 lw 2 lc rgb "#000080" #"#F0E442"  # Yellow
set style line 9 lw 2 lc rgb "#007F7F"  # Teal


set multiplot

# Create title and legend
set title "PRCC sensitivity analysis of output variables over time at optimal parameters" font "Helvetica Bold,13"
set origin 0, 0.9
set size 1, 0.1
set xrange [0:1]       # Dummy range for the legend
set yrange [0:1]
unset xtics
unset ytics
set border 0           # No border for the legend area
set key at screen 0.5, 0.93 center
set key box spacing 1.75 font ",13"
plot NaN ls 2 lw 4 title "v_0", \
     NaN ls 3 lw 4 title "f_{imm}", \
     NaN ls 4 lw 4 title "R_{max 0}", \
     NaN ls 5 lw 4 title "{/Symbol b}", \
     NaN ls 6 lw 4 title "{/Symbol r}", \
     NaN ls 7 lw 4 title "r_{min}", \
     NaN ls 8 lw 4 title "N_0", \
     NaN ls 9 lw 4 title "t_{imm}"
     #NaN ls 7 lw 4 title "n", \
     #NaN ls 8 lw 4 title "a", \
unset title

set title font "Helvetica Bold,13"
unset key
set grid lw 1
set border
set xtics
set ytics

# Set up the multiplot layout
set origin 0, 0.45
set size 0.33, 0.45
set title "Consolidations (NC)"
set xlabel "time (days)"
set ylabel "PRCC" offset 1,0
set xrange [1:80]
set yrange [-1:1]
set arrow from 1,y_p to 80,y_p nohead ls 1 front
set arrow from 1,y_m to 80,y_m nohead ls 1 front
plot prcc i 0 using (column(0)+1):1 w l ls 2 notitle, \
     prcc i 0 using (column(0)+1):2 w l ls 3 notitle, \
     prcc i 0 using (column(0)+1):3 w l ls 4 notitle, \
     prcc i 0 using (column(0)+1):4 w l ls 5 notitle, \
     prcc i 0 using (column(0)+1):5 w l ls 6 notitle, \
     prcc i 0 using (column(0)+1):6 w l ls 7 notitle, \
     prcc i 0 using (column(0)+1):7 w l ls 8 notitle, \
     prcc i 0 using (column(0)+1):8 w l ls 9 notitle

set origin 0.33, 0.45
set size 0.33, 0.45
set title "Micronodules (NM)"
set xlabel "time (days)"
set ylabel "PRCC" offset 1,0
set xrange [1:80]
set yrange [-1:1]
set arrow from 1,y_p to 80,y_p nohead ls 1 front
set arrow from 1,y_m to 80,y_m nohead ls 1 front
plot prcc i 1 using (column(0)+1):1 w l ls 2 notitle, \
     prcc i 1 using (column(0)+1):2 w l ls 3 notitle, \
     prcc i 1 using (column(0)+1):3 w l ls 4 notitle, \
     prcc i 1 using (column(0)+1):4 w l ls 5 notitle, \
     prcc i 1 using (column(0)+1):5 w l ls 6 notitle, \
     prcc i 1 using (column(0)+1):6 w l ls 7 notitle, \
     prcc i 1 using (column(0)+1):7 w l ls 8 notitle, \
     prcc i 1 using (column(0)+1):8 w l ls 9 notitle

set origin 0.66, 0.45
set size 0.33, 0.45
set title "Volume occupied by consol. (VFC)"
set xlabel "time (days)"
set ylabel "PRCC" offset 1,0
set xrange [1:80]
set yrange [-1:1]
set arrow from 1,y_p to 80,y_p nohead ls 1 front
set arrow from 1,y_m to 80,y_m nohead ls 1 front
plot prcc i 4 using (column(0)+1):1 w l ls 2 notitle, \
     prcc i 4 using (column(0)+1):2 w l ls 3 notitle, \
     prcc i 4 using (column(0)+1):3 w l ls 4 notitle, \
     prcc i 4 using (column(0)+1):4 w l ls 5 notitle, \
     prcc i 4 using (column(0)+1):5 w l ls 6 notitle, \
     prcc i 4 using (column(0)+1):6 w l ls 7 notitle, \
     prcc i 4 using (column(0)+1):7 w l ls 8 notitle, \
     prcc i 4 using (column(0)+1):8 w l ls 9 notitle

set origin 0, 0
set size 0.33, 0.45
set title "Daughter micronodules (NMD)"
set xlabel "time (days)"
set ylabel "PRCC" offset 1,0
set xrange [1:80]
set yrange [-1:1]
set arrow from 1,y_p to 80,y_p nohead ls 1 front
set arrow from 1,y_m to 80,y_m nohead ls 1 front
plot prcc i 2 using (column(0)+1):1 w l ls 2 notitle, \
     prcc i 2 using (column(0)+1):2 w l ls 3 notitle, \
     prcc i 2 using (column(0)+1):3 w l ls 4 notitle, \
     prcc i 2 using (column(0)+1):4 w l ls 5 notitle, \
     prcc i 2 using (column(0)+1):5 w l ls 6 notitle, \
     prcc i 2 using (column(0)+1):6 w l ls 7 notitle, \
     prcc i 2 using (column(0)+1):7 w l ls 8 notitle, \
     prcc i 2 using (column(0)+1):8 w l ls 9 notitle

set origin 0.33, 0
set size 0.33, 0.45
set title "Isolated micronodules (NMI)"
set xlabel "time (days)"
set ylabel "PRCC" offset 1,0
set xrange [1:80]
set yrange [-1:1]
set arrow from 1,y_p to 80,y_p nohead ls 1 front
set arrow from 1,y_m to 80,y_m nohead ls 1 front
plot prcc i 3 using (column(0)+1):1 w l ls 2 notitle, \
     prcc i 3 using (column(0)+1):2 w l ls 3 notitle, \
     prcc i 3 using (column(0)+1):3 w l ls 4 notitle, \
     prcc i 3 using (column(0)+1):4 w l ls 5 notitle, \
     prcc i 3 using (column(0)+1):5 w l ls 6 notitle, \
     prcc i 3 using (column(0)+1):6 w l ls 7 notitle, \
     prcc i 3 using (column(0)+1):7 w l ls 8 notitle, \
     prcc i 3 using (column(0)+1):8 w l ls 9 notitle


set origin 0.66, 0
set size 0.33, 0.45
set title "Main axis of consolidations (MAC)"
set xlabel "time (days)"
set ylabel "PRCC" offset 1,0
set xrange [1:80]
set yrange [-1:1]
set arrow from 1,y_p to 80,y_p nohead ls 1 front
set arrow from 1,y_m to 80,y_m nohead ls 1 front
plot prcc i 5 using (column(0)+1):1 w l ls 2 notitle, \
     prcc i 5 using (column(0)+1):2 w l ls 3 notitle, \
     prcc i 5 using (column(0)+1):3 w l ls 4 notitle, \
     prcc i 5 using (column(0)+1):4 w l ls 5 notitle, \
     prcc i 5 using (column(0)+1):5 w l ls 6 notitle, \
     prcc i 5 using (column(0)+1):6 w l ls 7 notitle, \
     prcc i 5 using (column(0)+1):7 w l ls 8 notitle, \
     prcc i 5 using (column(0)+1):8 w l ls 9 notitle

unset multiplot

