###############################################################################
##################### SHARED PLOT WITH EXPERIMENTS ############################
###############################################################################
#Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 6,4
set output "./out/experiments.eps"

set datafile separator ","  # Change to "," if the file uses commas
exp = "./data/experimental_results.txt"
res1 = "./data/results_fitA.txt"
res2 = "./data/results_dseg.txt"
res3 = "./data/results_immunosuppressed.txt"

# Set font size for ticks and labels
set title font "Helvetica Bold,13"
set key top left Left reverse

# Define custom line styles with recommended colors
set style line 1 lw 3 lc 7 pt 0 # Black
set style line 2 lw 4 lc rgb "#0072bd" dashtype '-'  # Grey
set style line 3 lw 2 pt 0 lc rgb "#999999"  # Grey
set style line 4 lw 4 lc rgb "#77ac30" # Blue
set style line 5 lw 2 lt -1 lc rgb "#77ac30" # Blue
set style line 6 lw 4 lc rgb "#a2142f" # Orange
set style line 7 lw 2 lt -1 lc rgb "#a2142f" # Orange

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
set yrange [0:30]
plot res1 using 1:col_nc_1 w l ls 2 title 'Control scenario', \
     res2 using 1:col_nc_1 w l ls 4 title 'Segment limited', \
     res2 using 1:col_nc_1:col_nc_2 every skip_errorbars w errorbars ls 5 notitle, \
     res3 using 1:col_nc_1 w l ls 6 title 'Immunosuppressed', \
     res3 using 1:col_nc_1:col_nc_2 every skip_errorbars w errorbars ls 7 notitle, \
     exp using 1:2:3 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:2:3 w errorbars ls 1 notitle

set title "Micronodules (NM)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set yrange [0:140]
plot res1 using 1:col_nm_1 w l ls 2 title 'Control scenario', \
     res2 using 1:col_nm_1 w l ls 4 title 'Segment limited', \
     res2 using 1:col_nm_1:col_nm_2 every skip_errorbars w errorbars ls 5 notitle, \
     res3 using 1:col_nm_1 w l ls 6 title 'Immunosuppressed', \
     res3 using 1:col_nm_1:col_nm_2 every skip_errorbars w errorbars ls 7 notitle, \
     exp using 1:4:5 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:4:5 w errorbars ls 1 notitle

set title "Vol. occupied by consol. (VFC)"
set xlabel "time (days)"
set ylabel "Lung volume fraction" offset 1,0
set yrange [0:0.25]
plot res1 using 1:col_vfc_1 w l ls 2 title 'Control scenario', \
     res2 using 1:col_vfc_1 w l ls 4 title 'Segment limited', \
     res2 using 1:col_vfc_1:col_vfc_2 every skip_errorbars w errorbars ls 5 notitle, \
     res3 using 1:col_vfc_1 w l ls 6 title 'Immunosuppressed', \
     res3 using 1:col_vfc_1:col_vfc_2 every skip_errorbars w errorbars ls 7 notitle, \
     exp using 1:10:11 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:10:11 w errorbars ls 1 notitle


set title "Daughter micronodules (NMD)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set yrange [0:70]
plot res1 using 1:col_nmd_1 w l ls 2 title 'Control scenario', \
     res2 using 1:col_nmd_1 w l ls 4 title 'Segment limited', \
     res2 using 1:col_nmd_1:col_nmd_2 every skip_errorbars w errorbars ls 5 notitle, \
     res3 using 1:col_nmd_1 w l ls 6 title 'Immunosuppressed', \
     res3 using 1:col_nmd_1:col_nmd_2 every skip_errorbars w errorbars ls 7 notitle, \
     exp using 1:6:7 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:6:7 w errorbars ls 1 notitle

set title "Isolated micronodules (NMI)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set yrange [0:70]
plot res1 using 1:col_nmi_1 w l ls 2 title 'Control scenario', \
     res2 using 1:col_nmi_1 w l ls 4 title 'Segment limited', \
     res2 using 1:col_nmi_1:col_nmi_2 every skip_errorbars w errorbars ls 5 notitle, \
     res3 using 1:col_nmi_1 w l ls 6 title 'Immunosuppressed', \
     res3 using 1:col_nmi_1:col_nmd_2 every skip_errorbars w errorbars ls 7 notitle, \
     exp using 1:8:9 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:8:9 w errorbars ls 1 notitle

set title "Main axis of consolidations (MAC)"
set xlabel "time (days)"
set ylabel "Main axis (mm)" offset 1,0
set yrange [0:30]
plot res1 using 1:col_mac_1 w l ls 2 title 'Control scenario', \
     res2 using 1:col_mac_1 w l ls 4 title 'Segment limited', \
     res2 using 1:col_mac_1:col_mac_2 every skip_errorbars w errorbars ls 5 notitle, \
     res3 using 1:col_mac_1 w l ls 6 title 'Immunosuppressed', \
     res3 using 1:col_mac_1:col_mac_2 every skip_errorbars w errorbars ls 7 notitle, \
     exp using 1:12:13 w p pt 5 lc -1 title 'Experimental', \
     exp using 1:12:13 w errorbars ls 1 notitle

unset multiplot




###############################################################################
####################### VACCINATED SWEEP (ALL) ################################
###############################################################################
reset
#Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 6,4
set output "./out/exp_vaccine_all.eps"

set datafile separator ","  # Change to "," if the file uses commas
data = "./data/experiment_vaccinated.txt"

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
# set cbrange [0:19]
# set cbtics 1

set multiplot
set grid lc rgb "gray" lw 1

# Set up the colorbox
set cbrange [10:40]
set cbtics 2
set colorbox vertical user
set colorbox origin 0.92, 0.05 
set colorbox size 0.02, 0.9
set cblabel "t_{imm} (days)" font "Helvetica Bold, 13" offset 1.5, 0 
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

set origin 0, 0.5
set size 0.30, 0.5
set title "Consolidations (NC)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:25]
plot for [j=1:20] data index 0 using (column(0)+1):j w l ls j notitle

set origin 0.30, 0.5
set size 0.30, 0.5
set title "Micronodules (NM)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:80]
plot for [j=1:20] data index 1 using (column(0)+1):j w l ls j notitle

set origin 0.60, 0.5
set size 0.30, 0.5
set title "Vol. occupied by consol. (VFC)"
set xlabel "time (days)"
set ylabel "Lung volume fraction" offset 1,0
set xrange [1:80]
set yrange [0:0.15]
plot for [j=1:20] data index 4 using (column(0)+1):j w l ls j notitle

set origin 0, 0
set size 0.30, 0.5
set title "Daughter micronodules (NMD)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:50]
plot for [j=1:20] data index 2 using (column(0)+1):j w l ls j notitle

set origin 0.30, 0
set size 0.30, 0.5
set title "Isolated micronodules (NMI)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:50]
plot for [j=1:20] data index 3 using (column(0)+1):j w l ls j notitle

set origin 0.60, 0
set size 0.30, 0.5
set title "Main axis of consolidations (MAC)"
set xlabel "time (days)"
set ylabel "Main Axis (mm)" offset 1,0
set xrange [1:80]
set yrange [0:20]
plot for [j=1:20] data index 5 using (column(0)+1):j w l ls j notitle

unset multiplot



###############################################################################
###################### VACCINATED SWEEP (VOLUME) ##############################
###############################################################################
reset
#Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 3,3
set output "./out/exp_vaccine_vol.eps"

set datafile separator ","  # Change to "," if the file uses commas
data = "./data/experiment_vaccinated.txt"

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
set cbrange [10:40]
# set cbtics 4
set cblabel "t_{imm} (days)" font "Helvetica Bold, 13" offset 0.5, 0
set colorbox user origin 0.83, 0.2 size 0.03, 0.6
# set cbrange [10:40]
# set colorbox horizontal
# set colorbox user origin 0.2, 0.92 size 0.6, 0.03
# set cblabel "t_{imm} (days)" font "Helvetica Bold, 13" offset 0, 0.5
# set cbtics scale 0.5

set title font "Helvetica Bold,13" 
set title "Volume occupied by consol. (VFC) when varying t_{imm}"
set xlabel "time (days)"
set ylabel "Lung volume fraction"
set grid
set rmargin 12
set xrange [1:80]
set yrange [0:0.06]
plot for [j=1:20] data index 4 using (column(0)+1):j w l ls j notitle, \
     NaN w l palette frac 0 notitle

unset multiplot



###############################################################################
######################### FIMM SWEEP (VOLUME) #################################
###############################################################################
reset
#Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 6,4
set output "./out/exp_fimm_all.eps"

set datafile separator ","  # Change to "," if the file uses commas
data = "./data/experiment_fimm.txt"

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
# set cbrange [0:19]
# set cbtics 1

set multiplot
set grid lc rgb "gray" lw 1

# Set up the colorbox
set cbrange [0.15:1]
set colorbox vertical user
set colorbox origin 0.92, 0.05 
set colorbox size 0.02, 0.9
set cblabel "f_{imm}" font "Helvetica Bold, 13" offset 0.5, 0 
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

set origin 0, 0.5
set size 0.30, 0.5
set title "Consolidations (NC)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:25]
plot for [j=1:20] data index 0 using (column(0)+1):j w l ls j notitle

set origin 0.30, 0.5
set size 0.30, 0.5
set title "Micronodules (NM)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:80]
plot for [j=1:20] data index 1 using (column(0)+1):j w l ls j notitle

set origin 0.60, 0.5
set size 0.30, 0.5
set title "Vol. occupied by consol. (VFC)"
set xlabel "time (days)"
set ylabel "Lung volume fraction" offset 1,0
set xrange [1:80]
set yrange [0:0.2]
plot for [j=1:20] data index 4 using (column(0)+1):j w l ls j notitle

set origin 0, 0
set size 0.30, 0.5
set title "Daughter micronodules (NMD)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:50]
plot for [j=1:20] data index 2 using (column(0)+1):j w l ls j notitle

set origin 0.30, 0
set size 0.30, 0.5
set title "Isolated micronodules (NMI)"
set xlabel "time (days)"
set ylabel "Number" offset 1,0
set xrange [1:80]
set yrange [0:50]
plot for [j=1:20] data index 3 using (column(0)+1):j w l ls j notitle

set origin 0.60, 0
set size 0.30, 0.5
set title "Main axis of consolidations (MAC)"
set xlabel "time (days)"
set ylabel "Main Axis (mm)" offset 1,0
set xrange [1:80]
set yrange [0:20]
plot for [j=1:20] data index 5 using (column(0)+1):j w l ls j notitle

unset multiplot

