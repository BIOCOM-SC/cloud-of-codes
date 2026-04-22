
#include "simulation.h"
#include "main.h"
#include "lesions.h"
#include "memory.h"
#include "results.h"
#include "params.h"
#include "fusion.h"
#include "reinfection.h"
#include "aux.h"
#include "time.h"
#include "lung.h"


// SIMULATION ORCHESTRATION:
int simulations_parallel(t_results *results_tot, t_limit_simu *limit_simu_tot) 
{
    initialize_results(results_tot);
    initialize_limit_simu(limit_simu_tot);
    int cancel = 0;
    #pragma omp parallel 
    {
        t_results *results_i = NULL, *results_tot_priv = NULL;
        request_memory_results(&results_i, &results_tot_priv);
        initialize_results(results_tot_priv);

        t_limit_simu *limit_simu_i = NULL;
        request_memory_limit_simu(&limit_simu_i);
        initialize_limit_simu(limit_simu_i);

        int cancel_priv = 0;
        #pragma omp for 
        for (int ii=0; ii<simu.N_MPI; ii++) {
            if (cancel_priv == 0) {
                int out = simulation(results_i, limit_simu_i);
                if (out == ERROR) {
                    cancel_priv++;
                    #pragma omp cancel for
                }
                #pragma omp cancellation point for
                sum_results(results_i, results_tot_priv);
            }
        }

        #pragma omp critical 
        {
            sum_results(results_tot_priv, results_tot);
            merge_limit_simu(limit_simu_i, limit_simu_tot);
            cancel += cancel_priv;
        }
    }

    if (cancel != 0) return ERROR;
    return OK;
}

// DEBUG:
int DEBUG_simulations_sequential(t_results *results_tot, t_limit_simu *limit_simu_tot) 
{ 
    FILE *f_debug_aux = fopen("results/debug.txt", "w");
    fclose(f_debug_aux);

    t_results *results_i = NULL;
    request_memory_results(&results_i, NULL);

    initialize_limit_simu(limit_simu_tot);
  
    int num_reinfections = 0;
    double *array_debug = malloc(sizeof(double)*(params.tmax/params.dt+1));
    double *counter_normalisation = malloc(sizeof(double)*(params.tmax/params.dt+1));
    if ( array_debug==NULL || counter_normalisation==NULL ) display_and_exit("\nERROR\nError allocating pointers for debugging arrays!!!\n");
    memset(array_debug, 0, sizeof(double)*(params.tmax/params.dt+1));
    memset(counter_normalisation, 0, sizeof(double)*(params.tmax/params.dt+1));

    struct timespec begin_timer, end_timer;
    double timer_simu = 0, timer_inside = 0, timer_fusion = 0, timer_reinf = 0, timer_saving = 0;
    for(int ii=0; ii<simu.N_tot; ii++ ) {
        clock_gettime(CLOCK_MONOTONIC, &begin_timer);
        int out = DEBUG_simulation(results_i, limit_simu_tot, &num_reinfections, array_debug, counter_normalisation, \
                                   &timer_inside, &timer_reinf, &timer_fusion, &timer_saving);
        clock_gettime(CLOCK_MONOTONIC, &end_timer);
        timer_simu += time_difference_seconds(end_timer, begin_timer);

        if (out == ERROR) {
            printf("\nERROR!!! Inside simulations \n");
            free(array_debug); free(counter_normalisation);
            return ERROR;
        }

        int nlesions = results_i->nn.t1[(int)params.tmax-2];
        printf("N_simu=%d, exit_code=%d, N_lesions_end=%d\n", ii, out, nlesions);
        sum_results(results_i, results_tot);
    }

    printf("\nMean num reinfections=%lf\n", (1.0*num_reinfections)/simu.N_tot);
    printf("Mean time for a simulation [s] = %lf\n", timer_simu/(1.0*simu.N_tot));
    printf("Mean time for growth+reinfection+fusion+synchronization+saving [s * N_simu] (!!DIVIDE BY N_SIMU"")  = %lf\n", \
           timer_inside/(1.0*simu.N_tot));
    printf("Mean time inside reinfection per simulation = %lf\n", timer_reinf/(1.0*simu.N_tot));
    printf("Mean time inside fusion per simulation = %lf\n", timer_fusion/(1.0*simu.N_tot));
    printf("Mean time inside saving per simulation = %lf\n", timer_saving/(1.0*simu.N_tot));

    //save debugging info in file
    FILE *f_debug = fopen(FILE_DEBUGGING,"w");
    for(int ii=0; ii<(params.tmax/params.dt+1); ii++) {
      if ( counter_normalisation[ii] != 0 ) {
        fprintf(f_debug, "%lf,", array_debug[ii]/(counter_normalisation[ii]));
      }
      else {
        fprintf(f_debug, "%d,", 0);
      }
    }
    fclose(f_debug);

    free(array_debug);
    free(counter_normalisation);
    return OK;
}


int DEBUG_simulations_parallel(t_results *results_tot, t_limit_simu *limit_simu_tot)
{
    initialize_results(results_tot);
    int cancel = 0;
    struct timespec begin_timer, end_timer;
    clock_gettime(CLOCK_MONOTONIC, &begin_timer);
    #pragma omp parallel 
    {
        t_results *results_i = NULL, *results_tot_priv = NULL;
        request_memory_results(&results_i, &results_tot_priv);
        initialize_results(results_tot_priv);

        t_limit_simu *limit_simu_priv = NULL;
        request_memory_limit_simu(&limit_simu_priv);
        initialize_limit_simu(limit_simu_priv);

        int cancel_priv = 0;
        #pragma omp for 
        for (int ii=0; ii<simu.N_MPI; ii++) {
            if (cancel_priv == 0) {
                int out = simulation(results_i, limit_simu_priv);
                if (out == ERROR) {
                    cancel_priv++;
                    #pragma omp cancel for
                }
                #pragma omp cancellation point for
                sum_results(results_i, results_tot_priv);
                printf("Thread=%d, N_simu=%d, exit_code=%d\n", omp_get_thread_num(), ii, out);
            }
        }
        
        #pragma omp critical 
        {
            sum_results(results_tot_priv, results_tot);
            merge_limit_simu(limit_simu_priv, limit_simu_tot);
            cancel += cancel_priv;
        }
    }
    clock_gettime(CLOCK_MONOTONIC, &end_timer);
    double timer_simu = time_difference_seconds(end_timer, begin_timer);
    printf("\n Total simulation (parallel region) time = %lf\n\n", timer_simu);

    if (cancel != 0) {
        printf("Error inside parallel region...\n");
        return ERROR;
    }

    return OK;
}



// SINGLE SIMULATION :
void initialize_limit_simu(t_limit_simu *limit_simu)
{
    memset(limit_simu, 0, sizeof(t_limit_simu));
}


void merge_limit_simu(t_limit_simu *limit_simu_priv, t_limit_simu *limit_simu_tot)
{
    limit_simu_tot->max_ntot += limit_simu_tot->max_ntot;
    limit_simu_tot->max_nc += limit_simu_priv->max_nc;
    limit_simu_tot->max_nm += limit_simu_priv->max_nm;
    limit_simu_tot->max_vfc += limit_simu_priv->max_vfc;
    limit_simu_tot->max_time += limit_simu_priv->max_time;
}


int reached_maximum(t_results *results, double t, t_limit_simu *limit_simu)
{   // Checks if any limit has been reached!
    int out = 0;
    if (results->nn.t1[(int)t] >= MAX_LESIONS) {
        out++;
        limit_simu->max_ntot = 1;
    }
    if ( results->nc.t1[(int)t] >= MAX_CONSOLIDATIONS ) {
        out++;
        limit_simu->max_nc = 1;
    }
    if ( results->nm.t1[(int)t] >= MAX_MICRONODULES ) {
        out++;
        limit_simu->max_nm = 1;
    }
    if ( results->vfc.t1[(int)t] >= MAX_VFC ) {
        out++;
        limit_simu->max_vfc = 1;
    }
    if ((gettime_seconds() - start_time) >= MAX_SIMU_TIME) {
        out++;
        limit_simu->max_time = 1;
    }
    return out;
}


int simulation(t_results *results, t_limit_simu *limit_simu)
{
    initialize_results(results);
    initialize_limit_simu(limit_simu);

    t_lesions *lesions, *reinfected_lesions, *fusioned_lesions;
    request_memory_lesions(&lesions, &reinfected_lesions, &fusioned_lesions);
    initialize_lesions(lesions); 
    initialize_lesions(reinfected_lesions);
    initialize_lesions(fusioned_lesions);

    int sync_out = 0;
    int immune_state = 0;
    int N_fusions = 0, N_intra = 0, N_extra = 0;
    double timm = normal_distribution(params.tc, params.tc * params.ftcdev);
    double t=0;
    while (t <= params.tmax) {
        if ( (t >= timm) && (immune_state == 0) ) {
            activate_immune(lesions);
            immune_state = 1;
        }

        lesion_growth(lesions);

        int N_intra_it = 0, N_extra_it = 0;
        int N_reinfections = endogenous_reinfection(lesions, reinfected_lesions, immune_state, &N_intra_it, &N_extra_it);
        N_intra += N_intra_it;
        N_extra += N_extra_it;
        if ( N_reinfections == ERROR ) return ERROR;
        
        int N_fusions_it = fusion(lesions, fusioned_lesions);
        N_fusions += N_fusions_it;

        sync_out = synchronise_lesions(lesions, reinfected_lesions, fusioned_lesions);  //THIS RETURN N_LESIONS
        if (sync_out == ERROR) return ERROR;

        if ( (int)t < (int)(t+params.dt) ) {
          save_info(lesions, N_fusions, N_intra, N_extra, (int)t, results );
          if (reached_maximum(results, t, limit_simu)) return ERROR;
        }

        t += params.dt;

        
    }

    return OK ;
}


// ---------------------------------------------------------------------------------------------
// ----------------------------------------- DEBUG ---------------------------------------------
// ---------------------------------------------------------------------------------------------
int DEBUG_simulation(t_results *results, t_limit_simu *limit_simu, int *num_reinfections, \
                     double *array_debug, double *counter_normalisation, double *timer, \
                     double *timer_reinf, double *timer_fusion, double *timer_saving) {
    FILE *f_debug = fopen("results/debug.txt", "a");


    initialize_results(results);
    initialize_limit_simu(limit_simu);

    t_lesions *lesions, *reinfected_lesions, *fusioned_lesions;
    request_memory_lesions(&lesions, &reinfected_lesions, &fusioned_lesions);
    initialize_lesions(lesions);
    initialize_lesions(reinfected_lesions);
    initialize_lesions(fusioned_lesions);

    int N_lesions = 0, N_reinfections = 0, N_fusions = 0, immune_state = 0, N_intra = 0, N_extra = 0;
    struct timespec begin_timer, end_timer, timer_aux_1, timer_aux_2;

 
    double timm = normal_distribution(params.tc, params.tc * params.ftcdev);
    double t = 0;
    int tsteps = 0;
    while ( t < params.tmax ) {
        clock_gettime(CLOCK_MONOTONIC, &begin_timer);

        if ( (t >= timm) && (immune_state == 0) ) {
            activate_immune(lesions);
            immune_state = 1;
        } 

        lesion_growth(lesions);

        int N_intra_it = 0, N_extra_it = 0;
        clock_gettime(CLOCK_MONOTONIC, &timer_aux_1);
        N_reinfections = endogenous_reinfection(lesions, reinfected_lesions, immune_state, &N_intra_it, &N_extra_it);
        clock_gettime(CLOCK_MONOTONIC, &timer_aux_2);
        *timer_reinf += time_difference_seconds(timer_aux_2, timer_aux_1);

        *num_reinfections += N_reinfections;

        for (int jj=0; jj<lesions->N; jj++) {
            if (lesions->arr[jj].rmax == 0) {
                printf("RMAX IS 0??? (ISNAN r   )");
            }
        }

        if (  N_intra_it+N_extra_it != reinfected_lesions->N ) {
            printf("\n ERROR in reinfections!! Number of reinfections not consistent...\n");
            printf("N_reinf=%d, N_intra+N_extra=%d, reinfected_lesions->N=%d", N_reinfections, N_intra_it+N_extra_it, reinfected_lesions->N);
        }

        N_intra += N_intra_it;
        N_extra += N_extra_it;
          if ( N_reinfections == ERROR ) {
            printf("\nMAX_LESIONS!! (t=%lf) \n", t);
            free(lesions);
            free(reinfected_lesions);
            free(fusioned_lesions);
            return ERROR ;
          }
          
        clock_gettime(CLOCK_MONOTONIC, &timer_aux_1);
        int N_fusions_it = fusion(lesions, fusioned_lesions);
        clock_gettime(CLOCK_MONOTONIC, &timer_aux_2);
        *timer_fusion += time_difference_seconds(timer_aux_2, timer_aux_1);

        N_fusions += N_fusions_it;
        if (N_fusions_it != fusioned_lesions->N) printf("\n ERROR in fusions!! Number of fusions not consistent...\n");

        if ( (int)t < (int)(t+params.dt) ) {
            clock_gettime(CLOCK_MONOTONIC, &timer_aux_1);
            save_info(lesions, N_fusions, N_intra, N_extra, (int)t, results);
            clock_gettime(CLOCK_MONOTONIC, &timer_aux_2);
            *timer_saving += time_difference_seconds(timer_aux_2, timer_aux_1);
            if (reached_maximum(results, t, limit_simu)) return ERROR;
        }

        //synchronisation
        N_lesions = synchronise_lesions(lesions, reinfected_lesions, fusioned_lesions); //this returns N_lesions
        if (N_lesions != lesions->N) printf("\n ERROR in synchronisation!!! Number of lesions not consistent...\n");

        clock_gettime(CLOCK_MONOTONIC, &end_timer);
        *timer += time_difference_seconds(end_timer, begin_timer);
          
        for (int jj=0; jj<lesions->N; jj++) {
            //array_debug[ii] += (params.nata)* lesions->arr[jj].r *exp( -params.a*pow( ( lesions->arr[jj].t - params.tmin), params.n ) );
            array_debug[tsteps] += lesions->arr[jj].rmax ;
            counter_normalisation[tsteps] += 1;
      }
                 
        for (int ii=0; ii<lesions->N; ii++) {
            // fprintf(f_debug, "%g\n", lung.terminals[lesions->arr[ii].termid].dmax);
            fprintf(f_debug, "%g\n", lesions->arr[ii].rmax);
        }

        t += params.dt;
        tsteps ++;
    }

    fclose(f_debug);
    printf("  time-steps:%d ",tsteps);
    return OK ;
}


int DEBUG_simulation_parallel(t_results *results, double *timer) {
  int N_fusions, N_fusions_it, immune_state, N_intra, N_intra_it, N_extra, N_extra_it;
  double t, timm, begin_timer, end_timer;
  
    t_lesions *lesions, *reinfected_lesions, *fusioned_lesions;
    request_memory_lesions(&lesions, &reinfected_lesions, &fusioned_lesions);

  
  timm = normal_distribution(params.tc, params.tc * params.ftcdev);
  initialize_lesions(lesions);
  immune_state = 0;
  // ii=0;
  N_fusions = 0;  
  N_intra = 0;
  N_extra = 0;
  t = 0;

  #pragma omp parallel num_threads(3) 
  #pragma omp single
  {
    while ( t < params.tmax ) {

      //check immunity
      if ( (t >= timm) && (immune_state == 0) ) {
        activate_immune(lesions);
        immune_state = 1;
      } 
      
      begin_timer = clock();
          //growth
      lesion_growth(lesions);
      #pragma omp task shared(N_intra, N_extra)
      {
        //reinfection
        endogenous_reinfection(lesions, reinfected_lesions, immune_state, &N_intra_it, &N_extra_it);
    
        N_intra += N_intra_it;
        N_extra += N_extra_it;
      }

      #pragma omp task shared(N_fusions)
      {
        //fusion
        N_fusions_it = fusion(lesions, fusioned_lesions);
        N_fusions += N_fusions_it;
      }

      #pragma omp task firstprivate(N_intra, N_extra, N_fusions)
      {
        //saving
        if ( (int)t < (int)(t+params.dt) ) {
          save_info(lesions, N_fusions, N_intra, N_extra, (int)t, results);
        }
      }

      #pragma omp taskwait

      //syncrhonisation
      synchronise_lesions(lesions, reinfected_lesions, fusioned_lesions); //this returns N_lesions                                                         
      
      end_timer = clock();
      *timer +=  (double)( end_timer-begin_timer ) / CLOCKS_PER_SEC ;
          
                 
      t += params.dt;
      // ii ++;
    }
  }

  return OK ;
}

