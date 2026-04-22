#ifndef BM_EXP_ERR_H
#define BM_EXP_ERR_H

#include "results.h"

typedef struct t_exp_results {
  double nc[3], nc_std[3];
  double nm[3], nm_std[3];
  double nmi[3], nmi_std[3];
  double nmd[3], nmd_std[3];
  double vfc[3], vfc_std[3];
  double mac[3], mac_std[3];
} t_exp_results;


int read_experimental_results(void);
void calculate_and_write_errors(t_results *results);
void write_null_errors(void); 


#endif
