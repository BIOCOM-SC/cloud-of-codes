
#include "main.h"
#include "clusters.h"
#include "results.h"
#include "params.h"
#include "lung.h"
#include <math.h>

void initialize_results(t_results *results)
{
    memset(results, 0, sizeof(t_results));
}


void sum_results(const t_results *results_i, t_results *results_tot)
{
    for (int ii=0; ii<MAX_DAYS; ii++) {
        results_tot->nn.t1[ii] += results_i->nn.t1[ii];
        results_tot->nn.t2[ii] += results_i->nn.t2[ii];

        results_tot->nc.t1[ii] += results_i->nc.t1[ii];
        results_tot->nc.t2[ii] += results_i->nc.t2[ii];

        results_tot->nm.t1[ii] += results_i->nm.t1[ii];
        results_tot->nm.t2[ii] += results_i->nm.t2[ii];

        results_tot->nmd.t1[ii] += results_i->nmd.t1[ii];
        results_tot->nmd.t2[ii] += results_i->nmd.t2[ii];

        results_tot->nmi.t1[ii] += results_i->nmi.t1[ii];
        results_tot->nmi.t2[ii] += results_i->nmi.t2[ii];

        results_tot->vfc.t1[ii] += results_i->vfc.t1[ii];
        results_tot->vfc.t2[ii] += results_i->vfc.t2[ii];

        results_tot->ma.t1[ii] += results_i->ma.t1[ii];
        results_tot->ma.t2[ii] += results_i->ma.t2[ii];

        results_tot->mac.t1[ii] += results_i->mac.t1[ii];
        results_tot->mac.t2[ii] += results_i->mac.t2[ii];

        results_tot->fu.t1[ii] += results_i->fu.t1[ii];
        results_tot->fu.t2[ii] += results_i->fu.t2[ii];

        results_tot->nintra.t1[ii] += results_i->nintra.t1[ii];
        results_tot->nintra.t2[ii] += results_i->nintra.t2[ii];

        results_tot->nextra.t1[ii] += results_i->nextra.t1[ii];
        results_tot->nextra.t2[ii] += results_i->nextra.t2[ii];

        for (int jj=0; jj<7; jj++) {
            results_tot->nnf_lobe[jj].t1[ii] += results_i->nnf_lobe[jj].t1[ii];
            results_tot->nnf_lobe[jj].t2[ii] += results_i->nnf_lobe[jj].t2[ii];

            results_tot->ncf_lobe[jj].t1[ii] += results_i->ncf_lobe[jj].t1[ii];
            results_tot->ncf_lobe[jj].t2[ii] += results_i->ncf_lobe[jj].t2[ii];
        }
    }
    return;
}


void average_results(t_results *results, int N)
{
    // WE STORE IN T2 THE STD, AND IN T1 THE MEAN
    for (int ii=0; ii<MAX_DAYS; ii++) {
        results->nn.t2[ii] = sqrt( results->nn.t2[ii]/N - pow( results->nn.t1[ii]/N, 2 ) );
        results->nn.t1[ii] /= N;

        results->nc.t2[ii] = sqrt( results->nc.t2[ii]/N - pow( results->nc.t1[ii]/N, 2 ) );
        results->nc.t1[ii] /= N;

        results->nm.t2[ii] = sqrt( results->nm.t2[ii]/N - pow( results->nm.t1[ii]/N, 2 ) );
        results->nm.t1[ii] /= N;

        results->nmd.t2[ii] = sqrt( results->nmd.t2[ii]/N - pow( results->nmd.t1[ii]/N, 2 ) );
        results->nmd.t1[ii] /= N;

        results->nmi.t2[ii] = sqrt( results->nmi.t2[ii]/N - pow( results->nmi.t1[ii]/N, 2 ) );
        results->nmi.t1[ii] /= N;

        results->vfc.t2[ii] = sqrt( results->vfc.t2[ii]/N - pow( results->vfc.t1[ii]/N, 2 ) );
        results->vfc.t1[ii] /= N;

        results->fu.t2[ii] = sqrt( results->fu.t2[ii]/N - pow( results->fu.t1[ii]/N, 2 ) );
        results->fu.t1[ii] /= N;  

        results->nintra.t2[ii] = sqrt( results->nintra.t2[ii]/N - pow( results->nintra.t1[ii]/N, 2 ) );
        results->nintra.t1[ii] /= N;

        results->nextra.t2[ii] = sqrt( results->nextra.t2[ii]/N - pow( results->nextra.t1[ii]/N, 2 ) );
        results->nextra.t1[ii] /= N;
        
        results->mac.t2[ii] = sqrt( results->mac.t2[ii]/N - pow( results->mac.t1[ii]/N, 2 ) );
        results->mac.t1[ii] /= N;

        results->ma.t2[ii] = sqrt( results->ma.t2[ii]/N - pow( results->ma.t1[ii]/N, 2 ) );
        results->ma.t1[ii] /= N;
        
        for (int jj=0; jj<7; jj++) {
            results->nnf_lobe[jj].t2[ii] = sqrt( results->nnf_lobe[jj].t2[ii]/N - pow( results->nnf_lobe[jj].t1[ii]/N, 2 ) );
            results->nnf_lobe[jj].t1[ii] /= N;

            results->ncf_lobe[jj].t2[ii] = sqrt( results->ncf_lobe[jj].t2[ii]/N - pow( results->ncf_lobe[jj].t1[ii]/N, 2 ) );
            results->ncf_lobe[jj].t1[ii] /= N;
        }

    }
    return;
}


int save_info(t_lesions *lesions, int N_fusions, int N_intra, int N_extra, int day, t_results *results) 
{
    int nc = 0, nm = 0, ntot = 0, nmd = 0, nmi = 0;
    double vfc = 0, ma = 0, mac = 0;
    extract_cluster_info(lesions, &nc, &nm, &nmd, &nmi, &vfc, &ma, &mac);


    results->nn.t1[day] = lesions->N;
    results->nn.t2[day] = pow(lesions->N, 2);

    results->nc.t1[day] = nc;
    results->nc.t2[day] = pow(nc, 2);

    results->nm.t1[day] = nm;
    results->nm.t2[day] = pow(nm, 2);

    results->nmi.t1[day] = nmi;
    results->nmi.t2[day] = pow(nmi, 2);

    results->nmd.t1[day] = nmd;
    results->nmd.t2[day] = pow(nmd, 2);

    results->fu.t1[day] = N_fusions;
    results->fu.t2[day] = pow(N_fusions, 2);

    results->vfc.t1[day] = vfc/lung.volume;
    results->vfc.t2[day] = pow(vfc/lung.volume, 2);

    results->mac.t1[day] = mac;
    results->mac.t2[day] = pow(mac, 2);

    results->ma.t1[day] = ma;
    results->ma.t2[day] = pow(ma, 2);

    results->nintra.t1[day] = N_intra;
    results->nintra.t2[day] = pow(N_intra, 2);

    results->nextra.t1[day] = N_extra;
    results->nextra.t2[day] = pow(N_extra, 2);
      
    for (int ii=0; ii<7; ii++) {  //TODO
      if (ntot != 0) {
        results->nnf_lobe[ii].t1[day] = 0; //(1.0*nn_lobe[ii])/ntot;
        results->nnf_lobe[ii].t2[day] = 0; //pow( (1.0*nn_lobe[ii])/ntot, 2);
      } else {
        results->nnf_lobe[ii].t1[day] = 0;
        results->nnf_lobe[ii].t2[day] = 0;
      }
      if (nc != 0) {
        results->ncf_lobe[ii].t1[day] = 0; //(1.0*nc_lobe[ii])/nc;
        results->ncf_lobe[ii].t2[day] = 0; //pow( (1.0*nc_lobe[ii])/nc, 2);
      } else {
        results->ncf_lobe[ii].t1[day] = 0;
        results->ncf_lobe[ii].t1[day] = 0;
      }
    }

    return OK ;
}


void write_results(t_results *results)
{
    FILE *file_results;
    file_results = fopen(FILE_RESULTS,"w");
    for (int ii=0; ii<params.tmax; ii++) {
        fprintf(file_results, "%d, ", ii);
        // 1->22
        fprintf(file_results, "%lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, ", \
            results->nn.t1[ii], results->nn.t2[ii], results->nc.t1[ii], results->nc.t2[ii], results->nm.t1[ii], results->nm.t2[ii], \
            results->vfc.t1[ii], results->vfc.t2[ii], results->nmd.t1[ii], results->nmd.t2[ii], results->nmi.t1[ii], results->nmd.t2[ii], \
            results->ma.t1[ii], results->ma.t2[ii], results->mac.t1[ii], results->mac.t2[ii], \
            results->fu.t1[ii], results->fu.t2[ii], results->nintra.t1[ii], results->nintra.t2[ii], results->nextra.t1[ii], results->nextra.t2[ii]);
        // 23->36
        fprintf(file_results, "%lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, ", \
            results->nnf_lobe[0].t1[ii], results->nnf_lobe[0].t2[ii], results->nnf_lobe[1].t1[ii], results->nnf_lobe[1].t2[ii], \
            results->nnf_lobe[2].t1[ii], results->nnf_lobe[2].t2[ii], results->nnf_lobe[3].t1[ii], results->nnf_lobe[3].t2[ii], \
            results->nnf_lobe[4].t1[ii], results->nnf_lobe[4].t2[ii], results->nnf_lobe[5].t1[ii], results->nnf_lobe[5].t2[ii], \
            results->nnf_lobe[6].t1[ii], results->nnf_lobe[6].t2[ii] );
        // 37->50
        fprintf(file_results, "%lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf\n", \
            results->ncf_lobe[0].t1[ii], results->ncf_lobe[0].t2[ii], results->ncf_lobe[1].t1[ii], results->ncf_lobe[1].t2[ii], \
            results->ncf_lobe[2].t1[ii], results->ncf_lobe[2].t2[ii], results->ncf_lobe[3].t1[ii], results->ncf_lobe[3].t2[ii], \
            results->ncf_lobe[4].t1[ii], results->ncf_lobe[4].t2[ii], results->ncf_lobe[5].t1[ii], results->ncf_lobe[5].t2[ii], \
            results->ncf_lobe[6].t1[ii], results->ncf_lobe[6].t2[ii] );
    }    
    fclose(file_results);
    return;
}
