#ifndef BM_LUNG_H
#define BM_LUNG_H


#include "geometry.h"

typedef struct t_terminal {
  t_point pos;
  int seg;
  double dseg;
  int lobe;
  double dlobe;
  double dmax;  // dmax is either dseg or dlobe depending on the configuration
  double diameter;
  double p_initial_infection;
  double p_close_reinf;
} t_terminal;


typedef struct t_lobe {
  int N_faces;
  t_face *faces;
} t_lobe;


typedef struct t_config_lung {
  int N_terminals;
  t_terminal *terminals;
  double *distance;  //[MAX_NUM_TERMINALS * (MAX_NUM_TERMINALS + 1) / 2];  // It's symmetric...  IN REALITY, I COULD USE N*(N-1)/2 BECAUSE DIAGONAL IS 0
  int N_lobes;
  t_lobe *lobes;
  double volume;
  double diam_trachea;
} t_config_lung;



int malloc_and_read_lung(void);



#endif
