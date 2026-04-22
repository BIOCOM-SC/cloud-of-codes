#ifndef BM_MEMORY_H
#define BM_MEMORY_H

#include "lesions.h"
#include "clusters.h"
#include "lesions.h"
#include "results.h"
#include "simulation.h"


typedef struct memory_pool {
    t_results ***results;                   // x2 per thread
    t_lesions ***lesions;                   // x3 per thread
    t_cluster ***clusters;                  // x2 per thread
    t_cluster_summary **cluster_summary;    // x1 per thread
    int **cluster_labels;                   // x1 per thread
    double **cumsum;                        // x1 per thread
    int ***UF;                              // x2 per thread
    t_limit_simu **limit_simu;              // x1 per thread
} t_memory_pool;


extern t_memory_pool memory_pool;

int initialize_memory_pool(void);
void free_memory_pool(void);


void free_lung(void);  // TODO put this in corresponding module?

void request_memory_lesions(t_lesions **lesions_1, t_lesions **lesions_2, t_lesions **lesions_3);
void request_memory_results(t_results **results_1, t_results **results_2);
void request_memory_UF(int **arr_1, int **arr_2);
void request_memory_clusters(t_cluster **cluster_1, t_cluster **cluster_2);
void request_memory_cluster_summary(t_cluster_summary **cluster_summary);
void request_memory_cluster_labels(int **cluster_labels);
void request_memory_limit_simu(t_limit_simu **limit_simu);
void request_memory_cumsum(double **cumsum);

#endif
