// TODO OR IMPROVEMENTS
// -- Improve reading and writing, by automating as much as possible. Create a function to return automatically 
//    the number of txt files in a directory as well as a list of names sorted alphabetically (for reading lobes and segments!).
//    This will help in virtual populations with multiple lungs. Select the name of the folder with lung info for example as a flag.
// -- Add selection to choose if I don't want plot (default being plot to avoid redundant runs where I forgot to indicate plot)
// 

#ifndef BM_BUBBLE_H
#define BM_BUBBLE_H

//Names of files
#define DIR_CONFIG_MACAQUE "./config/macaque"
#define DIR_CONFIG_HUMAN "./config/human"
#define FILE_TERMINALS "terminals.txt"
#define FILE_DIST_INTRABRONQ "D.bin"

#define FILE_PARAMS "./config/params_bm.txt"
#define FILE_SAMPLES "./config/samples.txt"

#define FILE_RESULTS "./results/results.txt"
#define FILE_RESULTS_IMAGE "./results/main_results.png"
#define FILE_DEBUGGING "./results/debugging.txt"
#define FILE_EXPERIMENTAL_RESULTS "./config/experimental_results.txt"
#define FILE_ERROR "./results/error.txt"
#define FILE_PRCC "./results/prcc.txt"
#define FILE_VIDEOS "./results/video.txt"

#define MAX_NUM_TERMINALS 12000
#define MAX_DAYS 100
#define MAX_SIMU_TIME 600  // Seconds

#define MAX_LESIONS 10000
#define MAX_CONSOLIDATIONS 1000 //80
#define MAX_MICRONODULES 5000 //400
#define MAX_VFC 2 //0.4

#define MAX_SAMPLES 2000
#define MAX_NUM_LOBES 20
#define MAX_LOBE_FACES 8000

// Magic values
#define MACAQUE_LUNG_VOLUME 319000  //mm3
#define HUMAN_LUNG_VOLUME 2780000  //mm3
#define DIAM_TRACHEA_MACAQUE 8.1  //mm
#define DIAM_TRACHEA_HUMAN 12 //mm
#define FACTOR_MAINAXIS_TO_SHORTAXIS 0.7102
#define MICRONOD_MIN_MAINAXIS 1  // Resolution of CT scans
#define CONS_MIN_MAINAXIS 4.5

#define ERROR -1
#define OK 0
// #define PI 3.14159265

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <dirent.h>
#include <unistd.h>
#include <limits.h>
#include <float.h>
#include <math.h>
// #include <omp.h>
// #include <mpi.h>
#include "omp.h"


typedef struct t_exec_config{
    int N_tot;
    int N_MPI;
    int debug_seq;
    int debug_par;
    int inner_parallel;
    int video;
    int dseg;
    int dlobe;
    int write_sample;
    int append;
    int is_human;
    int plot;
} t_exec_config;



// GLOBAL VARIABLES
extern time_t start_time;
extern struct t_exec_config simu;
extern struct t_params_bm params;
extern struct t_exp_results exp_results;
extern struct t_config_lung lung;


#endif

