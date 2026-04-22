#ifndef BM_REINFECTION_H
#define BM_REINFECTION_H

#include "lesions.h"

double probability_close_reinfection(int id_term, double diameter, double beta);
int endogenous_reinfection(t_lesions *lesions, t_lesions *reinf_lesions, int immune_state, int *N_intra, int *N_extra);


#endif
