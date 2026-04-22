#ifndef BM_SIMULATION_H
#define BM_SIMULATION_H

#include "results.h"

// Stores indicators whether some relevant values have reached its maximum, 
// to check if simulation is diverging.
typedef struct t_limit_simu {
    int max_ntot;
    int max_nc;
    int max_nm;
    int max_vfc;
    int max_time;
} t_limit_simu;


void initialize_limit_simu(t_limit_simu *limit_simu);

// Simulations orchestration:
int simulations_parallel(t_results *results_tot, t_limit_simu *limit_simu_tot);
int DEBUG_simulations_sequential(t_results *results_tot, t_limit_simu *limit_simu_tot);
int DEBUG_simulations_parallel(t_results *results_tot, t_limit_simu *limit_simu_tot);

// Single simulation:
void initialize_limit_simu(t_limit_simu *limit_simu);
void merge_limit_simu(t_limit_simu *limit_simu_priv, t_limit_simu *limit_simu_tot);
int reached_maximum(t_results *results, double t, t_limit_simu *limit_simu);

int simulation(t_results *results, t_limit_simu *limit_simu);
int DEBUG_simulation(t_results *results, t_limit_simu *limit_simu, int *num_reinfections, \
                     double *array_debug, double *counter_normalisation, double *timer, \
                     double *timer_reinf, double *timer_fusion, double *timer_saving);


#endif
