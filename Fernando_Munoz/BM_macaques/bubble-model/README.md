# Bubble Model
Implementation of the Bubble Model, written in C and parallelized with OMP-MPI.


## Configuration files
Found in *config/*. 
- **params_bm.txt**. Parameters of the BM used for the simulations.
- **samples.txt**. OPTIONAL, each row contains a different set of parameters. 
    Useful for parameter sweeps.
- **experimental_results.txt**. Experimental values of NC, NM, VFC, NMD, NMI, MAC
    and their standard deviations. Used in the plots and when computing the 
    fitting error.
- **macaque/terminals.txt** Virtual lung's terminals (position, distance to 
    closest segment wall, ...).
- **macaque/D.bin** Distance matrix between every given terminal. Binary for
    faster management. 
- **macaque/segments/**. Contains the segments of the lung **Si.txt** (stored
    as a triangulation).
- **macaque/lobes/**. Contains the lobes of the lung **Li.txt** (stored 
    as a triangulation).


## Output files
### Main
Found in *results/*:
- **results.txt**. Averaged info of the simulations. All modes produce this file.
- **error.txt**. Experimental error for the set of parameters.
- **main_results.png**. Plot of main results (NC, NM, VFC, NMD, NMI, MAC).
- **reinfections.png**. Plot of number of reinfections.

### Other
Found in *results/*:
- **video.mp4**. Video of a single run of the model.
- **video.txt**. Data necessary to compile the video. Right now is useless.


## Compilation
Adapt the Makefile to your setup. 


## Running
- Specify the number of Simulations: **-N number**. Default is 100.
- Specify if you want to limit lesions with lobe or segment: 
    **-dlobe** or **-dseg**. Default is segment.
- If you want to append into *errors.txt* instead of rewriting the file at each
    run, use the flag **-append**.
- In my macbook, if I want multiple MPI modes, I need to execute with **mpirun**.
    I indicate the number of threads with **OMP_NUM_THREADS=N**. On a cluster
    this may be different.

An example: **OMP_NUM_THREADS=2 mpirun -np 2 ./bubble -dseg -N 1000**


## Parameter weep 
In order to perform a sweep, I need to change the **params_bm.txt** file between 
each run. This is implemented with the mode **-write_sample N**, which writes
into **params_bm.txt** the set of parameters in row N of **samples.txt**. I then
run a normal simulation, making sure to add the **-append** flag to append the 
errors to **errors.txt**. 

An example of a bash script to run a sweep on a cluster (see *other/job.sh*):
```
for ii in {1..1000}
do
  srun ./bubble -write_sample $ii
  srun ./bubble -dlobe -N 10000 -append -noplot
  echo
  echo
done
```


## Special modes

- **-write_sample N**: Write the set of parameters of row N of file *samples.txt*
    to *params.txt* 
- **-debug_seq**: Produces *debugging.txt*. Most detailed information. 
- **-debug_par**: Only provides additional info of the threads and timing.
- **-video**: Makes a video of the output of a *single* simulation, saved in 
    results/video.
- **-pin**: Parallelize simultaneously the inner level of the model. ATTENTION:
    This mode has not beed tested properly and I do not guarantee that it works
    as intended. In my computer it freezes.

