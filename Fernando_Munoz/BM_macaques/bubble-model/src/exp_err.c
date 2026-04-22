
#include "main.h"
#include <math.h>
#include "results.h"
#include "exp_err.h"
#include "aux.h"
#include "params.h"


int read_experimental_results(void)
{
    FILE *f_exp = fopen(FILE_EXPERIMENTAL_RESULTS, "r");
    if (!f_exp) display_and_exit("ERROR! Could not open file with experimental results\n");
    fscanf(f_exp, "%lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf\n %lf,%lf,%lf",  \
            &exp_results.nc[0],      &exp_results.nc[1],      &exp_results.nc[2], \
            &exp_results.nc_std[0],  &exp_results.nc_std[1],  &exp_results.nc_std[2], \
            &exp_results.nm[0],      &exp_results.nm[1],      &exp_results.nm[2], \
            &exp_results.nm_std[0],  &exp_results.nm_std[1],  &exp_results.nm_std[2], \
            &exp_results.nmd[0],      &exp_results.nmd[1],      &exp_results.nmd[2], \
            &exp_results.nmd_std[0],  &exp_results.nmd_std[1],  &exp_results.nmd_std[2], \
            &exp_results.nmi[0],      &exp_results.nmi[1],      &exp_results.nmi[2], \
            &exp_results.nmi_std[0],  &exp_results.nmi_std[1],  &exp_results.nmi_std[2], \
            &exp_results.vfc[0],     &exp_results.vfc[1],     &exp_results.vfc[2], \
            &exp_results.vfc_std[0], &exp_results.vfc_std[1], &exp_results.vfc_std[2], \
            &exp_results.mac[0],      &exp_results.mac[1],      &exp_results.mac[2], \
            &exp_results.mac_std[0],  &exp_results.mac_std[1],  &exp_results.mac_std[2]);
    fclose(f_exp);
    return 0;
}


void calculate_and_write_errors(t_results *results)
{
    int d1 = 20, d2 = 52, d3 = 76;
    // Compute differences
    double d_nc1 = results->nc.t1[d1] - exp_results.nc[0];
    double d_nc2 = results->nc.t1[d2] - exp_results.nc[1];
    double d_nc3 = results->nc.t1[d3] - exp_results.nc[2];

    double d_nm1 = results->nm.t1[d1] - exp_results.nm[0];
    double d_nm2 = results->nm.t1[d2] - exp_results.nm[1];
    double d_nm3 = results->nm.t1[d3] - exp_results.nm[2];

    double d_nmd1 = results->nmd.t1[d1] - exp_results.nmd[0];
    double d_nmd2 = results->nmd.t1[d2] - exp_results.nmd[1];
    double d_nmd3 = results->nmd.t1[d3] - exp_results.nmd[2];
    
    double d_nmi1 = results->nmi.t1[d1] - exp_results.nmi[0];
    double d_nmi2 = results->nmi.t1[d2] - exp_results.nmi[1];
    double d_nmi3 = results->nmi.t1[d3] - exp_results.nmi[2];
    
    double d_vfc1 = results->vfc.t1[d1] - exp_results.vfc[0];
    double d_vfc2 = results->vfc.t1[d2] - exp_results.vfc[1];
    double d_vfc3 = results->vfc.t1[d3] - exp_results.vfc[2];
    
    double d_mac1 = results->mac.t1[d1] - exp_results.mac[0];
    double d_mac2 = results->mac.t1[d2] - exp_results.mac[1];
    double d_mac3 = results->mac.t1[d3] - exp_results.mac[2];

    // Compute errors
    double e_nc =  pow(d_nc1/exp_results.nc_std[0], 2)   +  pow(d_nc2/exp_results.nc_std[1], 2)   +  5 * pow(d_nc3/exp_results.nc_std[2], 2);
    double e_nm =  pow(d_nm1/exp_results.nm_std[0], 2)   +  pow(d_nm2/exp_results.nm_std[1], 2)   +  5 * pow(d_nm3/exp_results.nm_std[2], 2);
    double e_nmd = pow(d_nmd1/exp_results.nmd_std[0], 2) +  pow(d_nmd2/exp_results.nmd_std[1], 2) +  5 * pow(d_nmd3/exp_results.nmd_std[2], 2);
    double e_nmi = pow(d_nmi1/exp_results.nmi_std[0], 2) +  pow(d_nmi2/exp_results.nmi_std[1], 2) +  5 * pow(d_nmi3/exp_results.nmi_std[2], 2);
    double e_vfc = pow(d_vfc1/exp_results.vfc_std[0], 2) +  pow(d_vfc2/exp_results.vfc_std[1], 2) +  5 * pow(d_vfc3/exp_results.vfc_std[2], 2);
    double e_mac __attribute__ ((unused)) = pow(d_mac1/exp_results.mac_std[0], 2) + pow(d_mac2/exp_results.mac_std[1],2) +  \
                                            5 * pow(d_mac3/exp_results.mac_std[2], 2);

    double e1_tot =  e_nc + e_nm + e_vfc;
    double e2_tot = e_nc + e_nmi + e_nmd + e_vfc;

    printf("      RESULTING ERR: e1=%.3f, e2=%.3f\n", e1_tot, e2_tot);
    printf("nc %f, nm %f, nmi %f, nmd %f, vfc %f\n", e_nc, e_nm, e_nmd, e_nmi, e_vfc);

    // Save in file
    FILE *f_error = fopen(FILE_ERROR,"a");
    fprintf(f_error, "%lf, %lf, %lf, %lf, %lf, %lf, %lf\n", \
                   e_nc, e_nm, e_nmi, e_nmd, e_vfc, e1_tot, e2_tot);
    fclose(f_error);
    
    //PRCC DATA
    FILE *f_results = fopen(FILE_PRCC, "a");
    fprintf(f_results, "%lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, ", 
        params.v0, params.fvimm, params.r0, params.fr0dev, params.frimm, params.frimmdev, params.b, params.nata, params.f, params.tmax, \
        params.dt, params.n, params.a, params.rmin, params.n0, params.fndev, params.tc, params.ftcdev, params.tmin);
    for (int ii=0; ii<params.tmax; ii++) {
        fprintf(f_results, "%lf, ", results->nc.t1[ii]);
    }
    for (int ii=0; ii<params.tmax; ii++) {
        fprintf(f_results, "%lf, ", results->nm.t1[ii]);
    }
    for (int ii=0; ii<params.tmax; ii++) {
        fprintf(f_results, "%lf, ", results->nmd.t1[ii]);
    }
    for (int ii=0; ii<params.tmax; ii++) {
        fprintf(f_results, "%lf, ", results->nmi.t1[ii]);
    }
    for (int ii=0; ii<params.tmax; ii++) {
        fprintf(f_results, "%lf, ", results->vfc.t1[ii]);
    }
    for (int ii=0; ii<params.tmax; ii++) {
        fprintf(f_results, "%lf, ", results->mac.t1[ii]);
    }
    fprintf(f_results, "%lf, %lf, %lf, %lf, %lf, %lf, %lf\n", e_nc, e_nm, e_nmd, e_nmi, e_vfc, e1_tot, e2_tot);
    fclose(f_results);
}


void write_null_errors(void)
{
    FILE *f_error = fopen(FILE_ERROR,"a");
    fprintf(f_error, "%d, %d, %d, %d, %d, %d, %d\n", \
                      100, 100, 100, 100, 100, 100, 100);
    fclose(f_error);
      
    //PRCC
    FILE *f_results = fopen(FILE_PRCC, "a");
    for (int ii=0; ii<6*params.tmax; ii++) {
        fprintf(f_results, "%d, ", -1);
    }
    fprintf(f_results, "%d, %d, %d, %d, %d, %d, %d\n", 100, 100, 100, 100, 100, 100, 100);
    fclose(f_results);
}
