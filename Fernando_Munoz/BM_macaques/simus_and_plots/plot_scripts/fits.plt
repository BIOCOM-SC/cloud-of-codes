###############################################################################
####################### EVOLUTION MINIMUM ERROR ###############################
###############################################################################
# Set terminal for high-quality output (PDF)
set terminal postscript eps color font "Helvetica,12" enhanced size 3,3

# Set output file
set output "out/evolution_min_error.eps"

# Set grid
set grid lw 1

# Set labels
set xlabel "Function evaluations"
set ylabel "Minimum error (unitless)"

# Set axis ranges
set xrange [0:1000]
set yrange [0:10]

# Set title
set title "Evolution of minimum error in parameter fitting"

# Set font size for ticks and labels
set title font "Helvetica Bold,13"

# Define custom line styles with recommended colors
set style line 1 lw 4 lc rgb "#0072B2" # Blue
set style line 2 lw 4 lc rgb "#D55E00" # Red
set style line 3 lw 4 lc rgb "#E69F00" # Orange
set style line 4 lw 4 lc rgb "#009E73" # Green
set style line 5 lw 4 lc rgb "#CC79A7" # Purple

# Plot the data
plot "data/minerr_fitA.txt" using 1 w l ls 1 title "Fit A", \
     "data/minerr_fitB.txt" using 1 w l ls 2 title "Fit B"



###############################################################################
####################### SIMULATIONS WITH BOTH FITS ############################
###############################################################################
reset
#Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 6,4
set output "./out/fits.eps"

set datafile separator ","  # Change to "," if the file uses commas
exp = "./data/experimental_results.txt"
res1 = "./data/results_fitA.txt"
res2 = "./data/results_fitB.txt"

# Set font size for ticks and labels
set title font "Helvetica Bold, 13"
set key top left Left reverse

# Define custom line styles with recommended colors
set style line 1 lw 3 lc 7 pt 0 # Black
set style line 2 lw 4 lc rgb "#0072bd" # Blue
set style line 3 lw 2 lt -1 lc rgb "#0072bd" # Blue
set style line 4 lw 4 lc rgb "#d95319" # Orange
set style line 5 lw 2 lt -1 lc rgb "#d95319" # Orange

# Set up the multiplot layout
set multiplot layout 2,3 columns rowsfirst 
set grid lc rgb "gray" lw 1

# Variables
skip_errorbars = 12

col_nc_1 = 4
col_nc_2 = 5
col_nm_1 = 6
col_nm_2 = 7
col_vfc_1 = 8
col_vfc_2 = 9
col_nmd_1 = 10
col_nmd_2 = 11
col_nmi_1 = 12
col_nmi_2 = 13
col_mac_1 = 16
col_mac_2 = 17


set title "Consolidations (NC)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set yrange [0:25]
plot res1 using 1:col_nc_1 w l ls 2 title 'fit A', \
     res1 using 1:col_nc_1:col_nc_2 every skip_errorbars w errorbars ls 3 notitle, \
     res2 using 1:col_nc_1 w l ls 4 title 'fit B', \
     res2 using 1:col_nc_1:col_nc_2 every skip_errorbars w errorbars ls 5 notitle, \
     exp using 1:2:3 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:2:3 w errorbars ls 1 notitle

set title "Micronodules (NM)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set yrange [0:140]
plot res1 using 1:col_nm_1 w l ls 2 title 'fit A', \
     res1 using 1:col_nm_1:col_nm_2 every skip_errorbars w errorbars ls 3 notitle, \
     res2 using 1:col_nm_1 w l ls 4 title 'fit B', \
     res2 using 1:col_nm_1:col_nm_2 every skip_errorbars w errorbars ls 5 notitle, \
     exp using 1:4:5 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:4:5 w errorbars ls 1 notitle

set title "Vol. occupied by consol. (VFC)"
set xlabel "time (days)"
set ylabel "Lung volume fraction" offset 1,0
set yrange [0:0.15]
plot res1 using 1:col_vfc_1 w l ls 2 title 'fit A', \
     res1 using 1:col_vfc_1:col_vfc_2 every skip_errorbars w errorbars ls 3 notitle, \
     res2 using 1:col_vfc_1 w l ls 4 title 'fit B', \
     res2 using 1:col_vfc_1:col_vfc_2 every skip_errorbars w errorbars ls 5 notitle, \
     exp using 1:10:11 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:10:11 w errorbars ls 1 notitle


set title "Daughter micronodules (NMD)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set yrange [0:70]
plot res1 using 1:col_nmd_1 w l ls 2 title 'fit A', \
     res1 using 1:col_nmd_1:col_nmd_2 every skip_errorbars w errorbars ls 3 notitle, \
     res2 using 1:col_nmd_1 w l ls 4 title 'fit B', \
     res2 using 1:col_nmd_1:col_nmd_2 every skip_errorbars w errorbars ls 5 notitle, \
     exp using 1:6:7 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:6:7 w errorbars ls 1 notitle

set title "Isolated micronodules (NMI)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set yrange [0:70]
plot res1 using 1:col_nmi_1 w l ls 2 title 'fit A', \
     res1 using 1:col_nmi_1:col_nmi_2 every skip_errorbars w errorbars ls 3 notitle, \
     res2 using 1:col_nmi_1 w l ls 4 title 'fit B', \
     res2 using 1:col_nmi_1:col_nmi_2 every skip_errorbars w errorbars ls 5 notitle, \
     exp using 1:8:9 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:8:9 w errorbars ls 1 notitle

set title "Main axis of consolidations (MAC)"
set xlabel "time (days)"
set ylabel "Main axis (mm)" offset 1,0
set yrange [0:25]
plot res1 using 1:col_mac_1 w l ls 2 title 'fit A', \
     res1 using 1:col_mac_1:col_mac_2 every skip_errorbars w errorbars ls 3 notitle, \
     res2 using 1:col_mac_1 w l ls 4 title 'fit B', \
     res2 using 1:col_mac_1:col_mac_2 every skip_errorbars w errorbars ls 5 notitle, \
     exp using 1:12:13 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:12:13 w errorbars ls 1 notitle

unset multiplot
