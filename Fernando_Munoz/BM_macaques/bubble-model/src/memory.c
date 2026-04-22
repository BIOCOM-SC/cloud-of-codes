#include "main.h"
#include "memory.h"
#include "lung.h"


int initialize_memory_pool(void) 
{
    int size_OMP = omp_get_max_threads();

    memory_pool.results = malloc(sizeof(t_results**) * size_OMP);
    memory_pool.lesions = malloc(sizeof(t_results**) * size_OMP);
    memory_pool.clusters = malloc(sizeof(t_cluster**) * size_OMP);
    memory_pool.cluster_summary = malloc(sizeof(t_cluster_summary*) * size_OMP);
    memory_pool.cluster_labels = malloc(sizeof(int*) * size_OMP);
    memory_pool.cumsum = malloc(sizeof(double*) * size_OMP);
    memory_pool.UF = malloc(sizeof(int**) * size_OMP);
    memory_pool.limit_simu = malloc(sizeof(t_limit_simu*) * size_OMP);

    if (!memory_pool.results || !memory_pool.results || \
        !memory_pool.clusters || !memory_pool.cluster_summary || \
        !memory_pool.cluster_labels || !memory_pool.cumsum || \
        !memory_pool.UF || !memory_pool.limit_simu) 
        return ERROR;

    for (int ii=0; ii<size_OMP; ii++) {
        memory_pool.results[ii] = malloc(sizeof(t_results *) * 2);
        if (!memory_pool.results[ii]) return ERROR;
        memory_pool.results[ii][0] = malloc(sizeof(t_results));
        memory_pool.results[ii][1] = malloc(sizeof(t_results));
        if (!memory_pool.results[ii][0] || !memory_pool.results[ii][1]) return ERROR;

        memory_pool.lesions[ii] = malloc(sizeof(t_results *) * 3);
        if (!memory_pool.lesions[ii]) return ERROR;
        memory_pool.lesions[ii][0] = malloc(sizeof(t_lesions));
        memory_pool.lesions[ii][1] = malloc(sizeof(t_lesions));
        memory_pool.lesions[ii][2] = malloc(sizeof(t_lesions));
        if (!memory_pool.lesions[ii][0] || !memory_pool.lesions[ii][1] || !memory_pool.lesions[ii][2]) return ERROR;

        memory_pool.clusters[ii] = malloc(sizeof(t_cluster *) * 2);
        if (!memory_pool.clusters[ii]) return ERROR;
        memory_pool.clusters[ii][0] = malloc(sizeof(t_cluster));
        memory_pool.clusters[ii][1] = malloc(sizeof(t_cluster));
        if (!memory_pool.clusters[ii][0] || !memory_pool.clusters[ii][1]) return ERROR;

        memory_pool.cluster_summary[ii] = malloc(sizeof(t_cluster_summary) * MAX_LESIONS);
        if (!memory_pool.cluster_summary[ii]) return ERROR;

        memory_pool.cluster_labels[ii] = malloc(sizeof(int) * MAX_LESIONS);
        if (!memory_pool.cluster_labels[ii]) return ERROR;

        memory_pool.cumsum[ii] = malloc(sizeof(double) * lung.N_terminals);
        if (!memory_pool.cumsum[ii]) return ERROR;

        memory_pool.UF[ii] = malloc(sizeof(int*) * 2); 
        if (!memory_pool.UF[ii]) return ERROR;
        memory_pool.UF[ii][0] = malloc(sizeof(int) * MAX_LESIONS);
        memory_pool.UF[ii][1] = malloc(sizeof(int) * MAX_LESIONS);
        if (!memory_pool.UF[ii][0] || !memory_pool.UF[ii][1]) return ERROR;

        if(!memory_pool.limit_simu) return ERROR;
        memory_pool.limit_simu[ii] = malloc(sizeof(t_limit_simu));
        if (!memory_pool.limit_simu[ii]) return ERROR;
    }
    return OK;
}


void free_memory_pool(void)
{
    int size_OMP = omp_get_max_threads();
    for (int ii=0; ii<size_OMP; ii++) {
        free(memory_pool.results[ii][0]);
        free(memory_pool.results[ii][1]);
        free(memory_pool.results[ii]);
        
        free(memory_pool.lesions[ii][0]);
        free(memory_pool.lesions[ii][1]);
        free(memory_pool.lesions[ii][2]);
        free(memory_pool.lesions[ii]);

        free(memory_pool.clusters[ii][0]);
        free(memory_pool.clusters[ii][1]);
        free(memory_pool.clusters[ii]);

        free(memory_pool.cluster_summary[ii]);

        free(memory_pool.cluster_labels[ii]);

        free(memory_pool.cumsum[ii]);

        free(memory_pool.UF[ii][0]);
        free(memory_pool.UF[ii][1]);
        free(memory_pool.UF[ii]);

        free(memory_pool.limit_simu[ii]);
    }

    free(memory_pool.results);
    free(memory_pool.lesions);
    free(memory_pool.clusters);
    free(memory_pool.cluster_summary);
    free(memory_pool.cluster_labels);
    free(memory_pool.cumsum);
    free(memory_pool.UF);
    free(memory_pool.limit_simu);
}





void free_lung(void)
{
    for (int ii=0; ii<lung.N_lobes; ii++) {
        free(lung.lobes[ii].faces);
    }
    free(lung.lobes);
    free(lung.terminals);
    free(lung.distance);
}





void request_memory_lesions(t_lesions **lesions_1, t_lesions **lesions_2, t_lesions **lesions_3)
{
    int OMP_id = omp_get_thread_num();
    if (lesions_1) *lesions_1 = memory_pool.lesions[OMP_id][0];
    if (lesions_2) *lesions_2 = memory_pool.lesions[OMP_id][1];
    if (lesions_3) *lesions_3 = memory_pool.lesions[OMP_id][2];
}


void request_memory_results(t_results **results_1, t_results **results_2)
{
    int OMP_id = omp_get_thread_num();
    if (results_1) *results_1 = memory_pool.results[OMP_id][0];
    if (results_2) *results_2 = memory_pool.results[OMP_id][1];
}


void request_memory_UF(int **arr_1, int **arr_2)
{
    int OMP_id = omp_get_thread_num();
    if (arr_1) *arr_1 = memory_pool.UF[OMP_id][0];
    if (arr_2) *arr_2 = memory_pool.UF[OMP_id][1];
}


void request_memory_clusters(t_cluster **cluster_1, t_cluster **cluster_2)
{
    int OMP_id = omp_get_thread_num();
    if (cluster_1) *cluster_1 = memory_pool.clusters[OMP_id][0];
    if (cluster_2) *cluster_2 = memory_pool.clusters[OMP_id][1];
}


void request_memory_cluster_summary(t_cluster_summary **cluster_summary)
{
    int OMP_id = omp_get_thread_num();
    if (cluster_summary) *cluster_summary = memory_pool.cluster_summary[OMP_id];
}


void request_memory_cluster_labels(int **cluster_labels)
{
    int OMP_id = omp_get_thread_num();
    if (cluster_labels) *cluster_labels = memory_pool.cluster_labels[OMP_id];
}


void request_memory_limit_simu(t_limit_simu **limit_simu)
{
    int OMP_id = omp_get_thread_num();
    if (limit_simu) *limit_simu = memory_pool.limit_simu[OMP_id];
}


void request_memory_cumsum(double **cumsum)
{ 
    int OMP_id = omp_get_thread_num();
    if (cumsum) *cumsum = memory_pool.cumsum[OMP_id];
}



