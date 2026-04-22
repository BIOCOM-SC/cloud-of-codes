#ifndef BM_PARAMS_H
#define BM_PARAMS_H

typedef struct t_params_bm {
  double v0;
  double fvimm;
  double r0;
  double fr0dev;
  double frimm;
  double frimmdev;
  double b;
  double nata;
  double f;
  double tmax;
  double dt;
  double n;
  double a;
  double rmin;
  double n0;
  double fndev;
  double tc;
  double ftcdev;
  double tmin;
  double cdf_initial_dist[8];
} t_params_bm;


int read_params_and_update_lung(void);
void write_params(t_params_bm params);
int read_samples(t_params_bm **samples);

#endif
