
#include <math.h>
#include "lesions.h"
#include "memory.h"
#include "clusters.h"
#include "aux.h"


void initialize_cluster_labels(int *cluster_labels, int N)
{
    if (N > MAX_LESIONS) display_and_exit("ERROR! N > max_lesions in initialize_cluster_lables");
    for (int ii=0; ii<N; ii++) {
        cluster_labels[ii] = -1;
    }
    //memset(cluster_labels, -1, sizeof(int) * N);  // unasigned to -1
}


void initialize_cluster_summary(t_cluster_summary *cluster_summary, int N_clusters)
{
    memset(cluster_summary, 0, sizeof(t_cluster_summary) * N_clusters);
}


void initialize_UF(int *UF_rank, int *UF_parent, int N)
{
    if (N > MAX_LESIONS) display_and_exit("ERROR! N > max_lesions in initialize_UF");
    memset(UF_rank, 0, sizeof(int) * N);
    for (int ii=0; ii<N; ii++) {
        // Each sphere is its own cluster
        UF_parent[ii] = ii;  
    }
}


int are_in_contact(t_single_lesion lesion_1, t_single_lesion lesion_2)
{
    double d = distance_points(lesion_1.pos, lesion_2.pos);
    if (d <= lesion_1.r + lesion_2.r) return 1;
    return 0;
}


int find(int x, int *parent)
{
    if (parent[x] != x) {
        // Path compression makes the tree as flat as possible
        // by pointing directly to the root
        parent[x] = find(parent[x], parent); 
    }
    return parent[x];
}


void union_sets(int x, int y, int *parent, int *rank)  // Union operation with rank
{
    int rootX = find(x, parent);
    int rootY = find(y, parent);

    if (rootX != rootY) {
        if (rank[rootX] > rank[rootY]) {
            parent[rootY] = rootX;
        } else if (rank[rootX] < rank[rootY]) {
            parent[rootX] = rootY;
        } else {
            parent[rootY] = rootX;
            rank[rootX]++;
        }
    }
}


int find_clusters(t_lesions *lesions, int *cluster_labels)
{
    int *UF_parent, *UF_rank;  // UF, "Union Find"
    request_memory_UF(&UF_parent, &UF_rank);
    initialize_UF(UF_rank, UF_parent, lesions->N);

   // Check all pairs of spheres
    for (int ii=0; ii<lesions->N - 1; ii++) {
        for (int jj=ii+1; jj<lesions->N; jj++) {
            if (are_in_contact(lesions->arr[ii], lesions->arr[jj])) {
                union_sets(ii, jj, UF_parent, UF_rank); // Merge clusters
            }
        }
    }

    // Count unique clusters and assign labels to all elements
    initialize_cluster_labels(cluster_labels, lesions->N);
    int cluster_count = 0;
    for (int ii = 0; ii < lesions->N; ii++) {
        int root = find(ii, UF_parent);
        if (cluster_labels[root] == -1) {
            cluster_labels[root] = cluster_count; // Assign new cluster ID
            cluster_count++;
        }
        // Ensure every element gets the correct cluster label
        cluster_labels[ii] = cluster_labels[root];
    }

    return cluster_count;
}


void add_lesion_to_cluster(t_cluster *cluster, int lesion_id)
{
    cluster->lesion_id[cluster->N] = lesion_id;
    cluster->N++;
}


void select_cluster(t_lesions *lesions, int *cluster_labels, int num_cluster, t_cluster *cluster) {
    cluster->N = 0;
    for (int ii = 0; ii<lesions->N; ii++) {
        if (cluster_labels[ii] == num_cluster) {
            add_lesion_to_cluster(cluster, ii);
        }
    }
}


void analyze_cluster(t_cluster *cluster, t_lesions *lesions, double *rmin, double *vol, double *MA)
{
    double dmax = 0, rmax = 0, vol_local = 0, rmin_local = DBL_MAX;

    for (int ii=0; ii<cluster->N; ii++) {
        int ii_lesion = cluster->lesion_id[ii];
        double r_ii = lesions->arr[ii_lesion].r;

        vol_local += radius_to_volume(r_ii);
        if (r_ii < rmin_local) rmin_local = r_ii;
        if (r_ii > rmax) rmax = r_ii;

        for (int jj=ii+1; jj<cluster->N; jj++) {
            int jj_lesion = cluster->lesion_id[jj];
            double r_jj = lesions->arr[jj_lesion].r;
            
            double d = distance_points(lesions->arr[ii_lesion].pos, lesions->arr[jj_lesion].pos);
            d += r_ii + r_jj;  // Accounts for radii
            if (d > dmax) dmax = d;
        }   
   }    
    
    *rmin = rmin_local;
    *vol = vol_local;
    *MA = fmax(dmax, 2 * rmax);  // Handles the case N = 1
}


int DEBUG_is_cluster(t_lesions *lesions, t_cluster *cluster)
{
    if (cluster->N == 1) return 1;

    int **visited = calloc(cluster->N, sizeof(int*));
    for (int ii=0; ii<cluster->N; ii++){
        visited[ii] = calloc(cluster->N, sizeof(int));
    }

    for (int ii=0; ii<cluster->N - 1; ii++) {
        int ii_lesion = cluster->lesion_id[ii];
        for (int jj=1; jj<cluster->N; jj++) {
            int jj_lesion = cluster->lesion_id[jj];
            
            int contact = are_in_contact(lesions->arr[ii_lesion], lesions->arr[jj_lesion]);
            if (contact) {
                visited[ii][jj]++;
                visited[jj][ii]++;
            }
        }
    }
    
    // Sum column-wise
    int *sum = calloc(cluster->N, sizeof(int));
    for (int ii=0; ii<cluster->N; ii++) {
        for (int jj=0; jj<cluster->N; jj++) {
            sum[ii] += visited[jj][ii];
        }
    }

    // Check if all sums are > 1
    int out = 1;
    for (int ii=0; ii<cluster->N; ii++) {
        if (sum[ii] < 1) out = 0;
        // printf("%d ", sum[ii]);
    }
    // puts("");
    
    for (int ii=0; ii<cluster->N; ii++){
        free(visited[ii]);
    }
    free(visited);
    free(sum);
    return out;
}


double distance_clusters(t_lesions *lesions, int *cluster_labels, int cluster_id_1, int cluster_id_2) 
{
    t_cluster *cluster_1, *cluster_2;  
    request_memory_clusters(&cluster_1, &cluster_2);

    select_cluster(lesions, cluster_labels, cluster_id_1, cluster_1);
    select_cluster(lesions, cluster_labels, cluster_id_2, cluster_2);

    double dmin = DBL_MAX;
    for (int ii=0; ii<cluster_1->N; ii++) {
        int id_ii = cluster_1->lesion_id[ii];
        for (int jj=0; jj<cluster_2->N; jj++) {
            int id_jj = cluster_2->lesion_id[jj];
            if (id_ii == id_jj) display_and_exit("ERROR! Same lesion?\n"); 

            double d = distance_points(lesions->arr[id_ii].pos, lesions->arr[id_jj].pos);
            d -= lesions->arr[id_ii].r + lesions->arr[id_jj].r;  // distance from surface to surface
            if (d < dmin) dmin = d;
        }
    }
    return dmin;
}



void find_d_closest_consolidation(int cluster_id, t_lesions *lesions, int *cluster_labels, t_cluster_summary *cluster_summary, int N_clusters, double *dmin_out, double *SA_cons_out)
{
    double dmin = DBL_MAX, SA_cons = 0;
    for (int ii=0; ii<N_clusters; ii++) {
        if ((ii != cluster_id) && (cluster_summary[ii].consolidation == 1)) {
            double d = distance_clusters(lesions, cluster_labels, cluster_id, ii);
            if (d < dmin) {
                dmin = d;
                SA_cons = cluster_summary[ii].short_axis;
            }
        }
    }
    *dmin_out = dmin;
    *SA_cons_out = SA_cons;
}


void extract_cluster_info(t_lesions *lesions, int *nc, int *nm, int *nmd, int *nmi, double *vfc, double *ma, double *mac)
{   // Outputs average results considering clustering: NC, NM, ...
    int *cluster_labels;  // Each lesion has a label with the cluster_id it belongs to
    request_memory_cluster_labels(&cluster_labels);
    int N_clusters = find_clusters(lesions, cluster_labels); 
 
    t_cluster_summary *cluster_summary;
    request_memory_cluster_summary(&cluster_summary);
    initialize_cluster_summary(cluster_summary, N_clusters);
    t_cluster *cluster;
    request_memory_clusters(&cluster, NULL);
    for (int id_cluster=0; id_cluster<N_clusters; id_cluster++) {
        select_cluster(lesions, cluster_labels, id_cluster, cluster);
        // if (cluster->N == 0) display_and_exit("Attention! Cluster has N = 0.\n");
        // if (!DEBUG_is_cluster(lesions, cluster)) display_and_exit("Attention! Not a cluster.\n");
        
        double MA, rmin, vol;  //rmin is not currently used
        analyze_cluster(cluster, lesions, &rmin, &vol, &MA);
        double SA = MA * FACTOR_MAINAXIS_TO_SHORTAXIS;

        cluster_summary[id_cluster].main_axis = MA;
        cluster_summary[id_cluster].short_axis = SA;

        *vfc += vol;
        if (MA > CONS_MIN_MAINAXIS) {
            *ma += MA;
            *nc += 1;
            *mac += MA;
            cluster_summary[id_cluster].consolidation = 1;
        } else if (MA < CONS_MIN_MAINAXIS && MA > MICRONOD_MIN_MAINAXIS) {
            *ma += MA;
            *nm += 1;
            cluster_summary[id_cluster].micronodule = 1;
        }
    }

    // Select NMD and NMI
    for (int id_cluster=0; id_cluster<N_clusters; id_cluster++) {
        if (cluster_summary[id_cluster].micronodule == 1) {
            double dmin, SA_cons;
            find_d_closest_consolidation(id_cluster, lesions, cluster_labels, cluster_summary, N_clusters, &dmin, &SA_cons);
            if (dmin < SA_cons) {
                *nmd += 1;
            } else { 
                *nmi += 1;
            }
        }
    }
    
    // Average quantities
    if (*nc != 0) {
        *mac /= *nc;
    } else {
        if (*mac != 0) display_and_exit("Not possible...\n");
    }
    if (*nm + *nc != 0) {
      *ma /= *nm + *nc;
    } else {
        if (*ma != 0) display_and_exit("Not possible...\n");
    }
}
