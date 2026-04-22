// Implementation of the Bubble Model on the Macaque's virtual lung.
// Started on 11/23, Fernando Muñoz
#include "main.h"
#include "memory.h"
#include "simulation.h"
#include "exp_err.h"
#include "lung.h"
#include "params.h"
#include "aux.h"
#include "plot.h"
#include <mpi.h>


time_t start_time;
t_exec_config simu;
t_config_lung lung;
t_params_bm params;
t_exp_results exp_results;


t_memory_pool memory_pool;


void initialize_MPI(int argc, char **argv, int *rank_MPI, int *size_MPI) 
{
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, rank_MPI);
    MPI_Comm_size(MPI_COMM_WORLD, size_MPI);
}


void read_args(int argc, char **argv)
{   
    simu.N_tot = 100;
    simu.is_human = 0; 
    simu.dseg = 1;
    simu.plot = 1;
    if (argc > 1) {
        for (int ii=1; ii<argc; ii++) {
            if (strcmp(argv[ii],"-N") == 0 ) {
              simu.N_tot = atoi(argv[ii+1]);
            //} else if ( strcmp(argv[ii], "-dseg") == 0 ) {
            //  dseg = 1;
            } else if ( strcmp(argv[ii], "-dlobe") == 0 ) {
                simu.dseg = 0;
                simu.dlobe = 1;
            } else if ( strcmp(argv[ii],"-debug_seq") == 0 ) {
                simu.debug_seq = 1;
            } else if ( strcmp(argv[ii], "-debug_par") == 0 ) {
                simu.debug_par = 1;
            } else if ( strcmp(argv[ii], "-pin") == 0 ) {
                simu.inner_parallel = 1;
            } else if ( strcmp(argv[ii], "-video") == 0 ) {
                simu.video = 1;
            } else if ( strcmp(argv[ii], "-write_sample") == 0 ) {
                simu.write_sample = atoi(argv[ii+1]);
            } else if ( strcmp(argv[ii], "-append") == 0 ) {
                simu.append = 1;
            } else if ( strcmp(argv[ii], "-human") == 0 ) {
                simu.is_human = 1;
            } else if (strcmp(argv[ii], "-noplot") == 0 ) {
                simu.plot = 0;
            }
        }
    }
}


void write_sample_and_exit(int rank_MPI)
{
    t_params_bm *samples;
    int N_samples;
    if (rank_MPI == 0) {
      N_samples = read_samples(&samples);
      if (simu.write_sample > N_samples) {
        printf("ERROR!! Only read %d samples, trying to write number %d...\n",  N_samples, simu.write_sample);
      } else {
        write_params(samples[simu.write_sample - 1]);
        printf("-> Succesfully wrote sample %d into %s\n", simu.write_sample, FILE_PARAMS);
      }
    }
    MPI_Finalize();
    exit(0);
}


void display_headers(int rank_MPI)
{
    if (rank_MPI == 0) {
        if (simu.is_human == 1) {
            printf("-> Chosen HUMAN lung, ");
        } else {
            printf("-> Chosen MACAQUE lung, ");
        }

        if (simu.dseg == 1) {
            if (simu.is_human == 1) {
                printf("limiting lesions to SECONDARY LUNG LOBULES\n");
            } else {
                printf("limiting lesions to SEGMENTS\n");
            }
        } else if (simu.dlobe == 1 ) {
            printf("limiting lesions to LOBES\n");
        }

        printf("      PARAMS: v0:%.3f, fvimm:%.3f, r0:%.3f, frimm:%.3f, beta:%.3f, nata:%.3f, n:%.3f, a:%.3f N0:%.3f, tc:%.3f, rmin:%.3f  \n", \
            params.v0, params.fvimm, params.r0, params.frimm, params.b, params.nata, params.n, params.a, params.n0, params.tc, params.rmin);
    }
}


void display_error_message(t_limit_simu *limit_simu)
{
    puts("ERROR!! There has been an error in the simulations:");
    if (limit_simu->max_nc != 0) puts("        Reached maximum NC");
    if (limit_simu->max_nm != 0) puts("        Reached maximum NM");
    if (limit_simu->max_vfc != 0) puts("        Reached maximum VFC");
    if (limit_simu->max_time != 0) puts("        Reached maximum simulation time");
}


void blank_file_errors_if_needed(int rank_MPI) 
{
    if (rank_MPI == 0) {
      if (simu.append == 0) {
        printf("WARNING!! Blanked file %s\n", FILE_ERROR);
        FILE *f_error = fopen(FILE_ERROR, "w");
        fclose(f_error);
      }
    }
}


void schedule_work_MPI(int rank_MPI, int size_MPI)
{
    int workload_MPI = simu.N_tot / size_MPI;
    int remainder_MPI = simu.N_tot % size_MPI;
    int start_MPI = rank_MPI * workload_MPI;
    int end_MPI = start_MPI + workload_MPI;
    if (rank_MPI == size_MPI - 1) {
        end_MPI += remainder_MPI; // Adjust for remainder
    }
    simu.N_MPI = end_MPI - start_MPI;
}


void check_omp_cancel(int rank_MPI)
{
    if(rank_MPI == 0 && omp_get_cancellation()) {
      puts("OMP cancellations are enabled! Unsure if this is better or worse performance.");
      puts("Untested.");
      // puts("Enable by launching with OMP_CANCELLATION=true");
      // puts("Enabling cancellation and rerunning program...\n\n");
      // putenv("OMP_CANCELLATION=true");
      // execv(argv[0], argv);
    }
}


int initialize_main_pointers(int size_MPI, t_results **results_tot, t_results **syncMPI_results, 
                             t_results **arrayMPI_results, t_limit_simu **limit_simu_tot,
                             t_limit_simu **syncMPI_limit_simu, t_limit_simu **arrayMPI_limit_simu)
{
    *results_tot = malloc(sizeof(t_results));
    if (!results_tot) return ERROR;
    initialize_results(*results_tot);

    *syncMPI_results = malloc(sizeof(t_results));
    if (!syncMPI_results) return ERROR;
    initialize_results(*syncMPI_results);

    *arrayMPI_results = malloc(sizeof(t_results) * size_MPI);
    if (!arrayMPI_results) return ERROR;
    for (int ii=0; ii<size_MPI; ii++) {
        initialize_results(&(*arrayMPI_results)[ii]);
    }

    *limit_simu_tot = malloc(sizeof(t_limit_simu));
    if (!limit_simu_tot) return ERROR;
    initialize_limit_simu(*limit_simu_tot);

    *syncMPI_limit_simu= malloc(sizeof(t_limit_simu));
    if (!syncMPI_limit_simu) return ERROR;
    initialize_limit_simu(*syncMPI_limit_simu);

    *arrayMPI_limit_simu = malloc(sizeof(t_limit_simu) * size_MPI);
    for (int ii=0; ii<size_MPI; ii++) {
        initialize_limit_simu(&(*arrayMPI_limit_simu)[ii]);
    }
    return OK;
}


int main(int argc, char **argv) 
{
    int out;   

    int rank_MPI, size_MPI;
    initialize_MPI(argc, argv, &rank_MPI, &size_MPI);

    srand(time(NULL) + rank_MPI);
    check_omp_cancel(rank_MPI);

    read_args(argc, argv);
    if (simu.write_sample != 0) write_sample_and_exit(rank_MPI);  // Special case
    blank_file_errors_if_needed(rank_MPI);

    out = malloc_and_read_lung();
    if (out == ERROR) return ERROR;
    out = read_params_and_update_lung();
    if (out == ERROR) return ERROR;
    out = read_experimental_results();
    if (out == ERROR) return ERROR;

    display_headers(rank_MPI);

    schedule_work_MPI(rank_MPI, size_MPI);

    out = initialize_memory_pool();
    if (out == ERROR) return ERROR;

    t_results *results_tot = NULL, *syncMPI_results = NULL, *arrayMPI_results = NULL;
    t_limit_simu *limit_simu_tot = NULL, *syncMPI_limit_simu = NULL, *arrayMPI_limit_simu = NULL;
    out = initialize_main_pointers(size_MPI, &results_tot, &syncMPI_results, &arrayMPI_results, \
                        &limit_simu_tot, &syncMPI_limit_simu, &arrayMPI_limit_simu);
    if (out == ERROR) return ERROR;

    int global_out = 0;

    // Timer
    struct timespec t_start, t_end;
    clock_gettime(CLOCK_MONOTONIC, &t_start);
    start_time = t_start.tv_sec;

    // Run simulations depending on the choices
    MPI_Barrier(MPI_COMM_WORLD);
    if ( simu.debug_par == 1 && size_MPI == 1) {  
        printf("-> Now running %d simulations... ", simu.N_tot);
        printf("      MODE: debug parallel\n");
        global_out = DEBUG_simulations_parallel(results_tot, limit_simu_tot);
    } 
    else if ( simu.debug_seq == 1 && size_MPI == 1) {  
        printf("-> Now running %d simulations... ", simu.N_tot);
        printf("      MODE: debug sequential\n");
        global_out = DEBUG_simulations_sequential(results_tot, limit_simu_tot);
    }
    else if ( simu.video == 1 && size_MPI == 1) {
        printf("      MODE: video (tmax is changed to 250)\n");
        //params.tmax = 250;
        global_out = make_video();
    }
    else {  
        if (rank_MPI == 0) {
            printf("-> Now running %d simulations... ", simu.N_tot);
            printf("  MODE: Parallel on %d processes, each with %d threads\n", size_MPI, omp_get_max_threads());
        }
        out = simulations_parallel(results_tot, limit_simu_tot);

        MPI_Gather(results_tot, sizeof(t_results), MPI_BYTE, arrayMPI_results, sizeof(t_results), MPI_BYTE, 0, MPI_COMM_WORLD);
        MPI_Gather(limit_simu_tot, sizeof(t_limit_simu), MPI_BYTE, arrayMPI_limit_simu, sizeof(t_limit_simu), MPI_BYTE, 0, MPI_COMM_WORLD);
        MPI_Reduce(&out, &global_out, 1, MPI_INT, MPI_MIN, 0, MPI_COMM_WORLD);
    }

    if (rank_MPI == 0) {
        if ( 0 == global_out ) {
            for (int jj = 0; jj < size_MPI; jj++) {
                sum_results(&arrayMPI_results[jj], syncMPI_results);
            }
            //average and write results
            average_results(syncMPI_results, simu.N_tot);
            write_results(syncMPI_results);
            calculate_and_write_errors(syncMPI_results);
            if (simu.plot) plot_results(syncMPI_results);
        } else {
            for (int jj = 0; jj < size_MPI; jj++) {
                merge_limit_simu(&arrayMPI_limit_simu[jj], syncMPI_limit_simu);
            }
            display_error_message(syncMPI_limit_simu);
            write_null_errors();
        }
    }

    if (rank_MPI == 0) {
        clock_gettime(CLOCK_MONOTONIC, &t_end);
        double elapsed_time = time_difference_seconds(t_end, t_start);
        printf("-> TIMING: %f s\n", elapsed_time);
    }

    free_memory_pool();
    free_lung();
    if (rank_MPI == 0) {
        printf("-> FINISHED THE PROGRAM!!!\n");
    }
    free(results_tot); free(syncMPI_results); free(arrayMPI_results);
    free(limit_simu_tot); free(syncMPI_limit_simu); free(arrayMPI_limit_simu);

    MPI_Finalize();
    return OK;
}
