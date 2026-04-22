#ifndef BM_LESIONS_H
#define BM_LESIONS_H

#include "main.h"  // Remove this if possible
#include "geometry.h"

typedef struct t_single_lesion {
  int termid, lobe, fusioned;
  double t, r, rmax, v;
  t_point pos;
} t_single_lesion;


typedef struct t_lesions {
  int N;  // Indicates the number of active lesions
  t_single_lesion arr[MAX_LESIONS];  // This is an array containing such lesions
} t_lesions;



void write_lesion(t_single_lesion *lesion, double t, double r, t_point pos, \
    double rmax, double v, int termid, int lobe, int fusioned);  // TODO Return directly t_single_lesion instead of input pointer...
int is_inside_lesions(t_lesions *lesions, t_point point);
void determine_rmax_v_immune(int immune_state, double dmax, double *rmax, double *v);
void initialize_lesions(t_lesions *lesions);
void lesion_growth(t_lesions *lesions);
void activate_immune(t_lesions *lesions);
int synchronise_lesions(t_lesions *lesions, t_lesions *reinfected_lesions, t_lesions *fusioned_lesions);



#endif
