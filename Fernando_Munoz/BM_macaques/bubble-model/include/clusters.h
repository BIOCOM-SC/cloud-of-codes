#ifndef BM_CLUSTERS_H
#define BM_CLUSTERS_H

#include "lesions.h"

typedef struct {
    int N;
    int lesion_id[MAX_LESIONS];
} t_cluster;

typedef struct {
  int id;
  double main_axis;
  double short_axis;
  int consolidation, micronodule;
} t_cluster_summary;


void initialize_cluster_labels(int *cluster_labels, int N);
void initialize_cluster_summary(t_cluster_summary *cluster_summary, int N_clusters);
void initialize_UF(int *UF_rank, int *UF_parent, int N);

// Outputs average results considering clustering: NC, NM, ... 
void extract_cluster_info(t_lesions *lesions, int *nc, int *nm, int *nmd, int *nmi, double *vfc, double *ma, double *mac);

#endif
