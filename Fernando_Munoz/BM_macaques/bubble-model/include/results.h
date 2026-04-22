#ifndef BM_RESULTS_H
#define BM_RESULTS_H

#include "main.h"
#include "lesions.h"

typedef struct t_totals {
  double t1[MAX_DAYS];
  double t2[MAX_DAYS];
} t_totals;  // Totals of a variable, t0=sum(xi^0), t1=sum(xi^1), t2=sum(xi^2)

typedef struct t_results {
  t_totals nn;
  t_totals nc;
  t_totals nm;
  t_totals nmi;
  t_totals nmd;
  t_totals vfc;
  t_totals ma;
  t_totals mac;
  t_totals fu;
  t_totals nintra;
  t_totals nextra;
  t_totals nnf_lobe[7];
  t_totals ncf_lobe[7];
} t_results;


void initialize_results(t_results *results);

void sum_results(const t_results *results_i, t_results *results_tot);
void average_results(t_results *results, int N);
int save_info(t_lesions *lesions, int N_fusions, int N_intra, int N_extra, int day, t_results *results);

void write_results(t_results *results);

#endif
