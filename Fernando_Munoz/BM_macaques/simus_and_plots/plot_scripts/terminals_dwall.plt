#Set up the terminal and output
set terminal postscript eps color font "Helvetica,12" enhanced size 3,3
set output "./out/terminals_dwall.eps"

set title font "Helvetica Bold, 13"

set datafile separator ","  # Change to "," if the file uses commas
data = "./data/terminals.txt"

set title "Distribution of terminal's distance to closest wall"
set xlabel 'Distance to closest wall (mm)'
set ylabel 'Count'
set xtics 1
set grid

binwidth = 1.0
gap = binwidth * 1.0/10
bin1(x) = binwidth * floor(x / (binwidth )) + binwidth / 5  # Left bin of pair
bin2(x) = binwidth * floor(x / (binwidth )) + binwidth * 3.0 / 5  # Right bin of pair

set boxwidth binwidth * 2.0/5  # Ensure the bars fit side by side without overlap
set style fill solid border -1  # Style for bars

plot data using (bin1(column(5))) smooth frequency with boxes title 'Segment walls' lc rgb "#0072bd", \
      data using (bin2(column(7))) smooth frequency with boxes title 'Lobe walls' lc rgb "#d95319"

