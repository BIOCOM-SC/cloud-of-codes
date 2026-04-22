
#include "lesions.h"
#include "lung.h"
#include "aux.h"
#include "params.h"
#include <math.h>


void write_lesion(t_single_lesion *lesion, double t, double r, t_point pos, \
                  double rmax, double v, int termid, int lobe, int fusioned)
{
    lesion->t = t;
    lesion->r = r;
    lesion->pos = pos;
    lesion->rmax = rmax;
    lesion->v = v;
    lesion->termid = termid;
    lesion->lobe = lobe;
    lesion->fusioned = fusioned;
    return;
}


int is_inside_lesions(t_lesions *lesions, t_point point)
{
    for (int ii=0; ii<lesions->N; ii++) {
         t_point del = subtract_points(lesions->arr[ii].pos, point);
         double dij = sqrt(del.x * del.x + del.y * del.y + del.z * del.z);
         if (dij < lesions->arr[ii].r) return 1;
    }
    return 0;
}


double limit_radius(double rmax, double frmax_dev, double dmax)
{
    double rtrial = normal_distribution(rmax, rmax * frmax_dev);
    if (rtrial < params.rmin) rtrial = params.rmin;
    if (rtrial > dmax) rtrial = dmax;
    return rtrial;
}


void initialize_lesions(t_lesions *lesions)
{
    int N_init = (int)round( normal_distribution(params.n0, params.n0 * params.fndev) );
    for (int ii=0; ii<N_init; ii++) {
        int trial_term_id;
        t_point trial_pos;
        do { // Make sure initial position is inside the lung
            // Choose initial terminal according to experimental lobe distribution
            trial_term_id = 0;
            double U = (1.0*rand())/RAND_MAX;
            double cdf_down = 0;
            double cdf_up = lung.terminals[trial_term_id].p_initial_infection;
            while ( trial_term_id < lung.N_terminals-1 && !( U >= cdf_down && U < cdf_up ) ) {
                trial_term_id ++;
                cdf_down += lung.terminals[trial_term_id].p_initial_infection;
                cdf_up += lung.terminals[trial_term_id].p_initial_infection;
            }

            double phi = 2 * M_PI * (1.0*rand())/RAND_MAX;
            double th = acos(1 - 2*(1.0*rand())/RAND_MAX);
            double dist = radius_volume_irrigated(lung.terminals[trial_term_id].diameter) * cbrt((1.0*rand())/RAND_MAX);
            trial_pos = sum_points(lung.terminals[trial_term_id].pos, spherical_to_cartesian(dist, th, phi));

        } while (!(is_inside_lobe(lung.terminals[trial_term_id].lobe, trial_pos) == 1 && \
                 is_inside_lesions(lesions, trial_pos) == 0));
        
        double rmax = limit_radius(params.r0, params.r0 * params.fr0dev, lung.terminals[trial_term_id].dmax);
        write_lesion(&lesions->arr[ii], 0, params.rmin, trial_pos, \
                     rmax, params.v0, trial_term_id, lung.terminals[trial_term_id].lobe, 0);
    }
    lesions->N = N_init;
    return;
}


void lesion_growth(t_lesions *lesions) 
{
    int ii;
    double delr;
    for (ii=0; ii<lesions->N; ii++) {
        lesions->arr[ii].t += params.dt;
        //lesions->arr[ii].fusioned = 0; this is not necessary. All non-0 get removed at synchronisation
        if ( (lesions->arr[ii].t > params.tmin) && (lesions->arr[ii].rmax > lesions->arr[ii].r) ) { //TODO CHECK THIS CONDITION!!!
            delr = ( lesions->arr[ii].v )*( lesions->arr[ii].r )*( 1 - pow(( lesions->arr[ii].r )/( lesions->arr[ii].rmax ), 2) )*params.dt;
            lesions->arr[ii].r += delr;
        }
    }
}


void activate_immune(t_lesions *lesions)
{
    for (int ii=0; ii<lesions->N; ii++) {
        lesions->arr[ii].v = params.v0 * params.fvimm;

        double trial_rmax = normal_distribution(params.r0 * params.frimm, params.r0 * params.frimm * params.frimmdev);
        while (trial_rmax < params.rmin) {
            trial_rmax = normal_distribution(params.r0 * params.frimm, params.r0 * params.frimm * params.frimmdev);
        }
        //limit radius:
        if ( trial_rmax < lung.terminals[ lesions->arr[ii].termid ].dmax ) {
            lesions->arr[ii].rmax = trial_rmax;
        } else {
            lesions->arr[ii].rmax = lung.terminals[ lesions->arr[ii].termid ].dmax;
        }
        
        if ( lesions->arr[ii].r > lesions->arr[ii].rmax ) {
            lesions->arr[ii].rmax = lesions->arr[ii].r;
        }
    }
}


void determine_rmax_v_immune(int immune_state, double dmax, double *rmax, double *v)
{
    if (immune_state == 0) {
        *rmax = limit_radius(params.r0, params.r0 * params.fr0dev, dmax);
        *v = params.v0;
    }
    else {
        *rmax = limit_radius(params.r0 * params.frimm, params.r0 * params.frimm * params.frimmdev, dmax);
        *v = params.v0 * params.fvimm;
    }
}


int synchronise_lesions(t_lesions *lesions, t_lesions *reinfected_lesions, t_lesions *fusioned_lesions)
{
    int jj = 0;
    //first remove fusioned lesions
    for (int ii=0; ii<lesions->N; ii++) {
        if ( lesions->arr[ii].fusioned == 0 ) {
            lesions->arr[jj] = lesions->arr[ii];
            jj++;
        }
    }
    //next add the fusions
    for (int ii=0; ii<fusioned_lesions->N; ii++) {
        lesions->arr[jj] = fusioned_lesions->arr[ii];
        jj++;
    }
    //finally add the reinfections
    if ( jj + reinfected_lesions->N >= MAX_LESIONS - 2 ) { //this is to avoid a segmentation fault
        return ERROR; 
    } else {
        for (int ii=0; ii<reinfected_lesions->N; ii++) {
            lesions->arr[jj] = reinfected_lesions->arr[ii];
            jj++;
        }
    }

    // OBSERVATION jj should be equal to lesion->N + reinfected_lesions->N - fusioned_lesions->N ; 
    lesions->N = lesions->N + reinfected_lesions->N - fusioned_lesions->N; //each fusion implies a lost lesion
    return jj ;
}

