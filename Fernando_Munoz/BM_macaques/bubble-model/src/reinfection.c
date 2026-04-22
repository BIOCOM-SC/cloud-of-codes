
#include "main.h"
#include "reinfection.h"
#include "lung.h"
#include "params.h"
#include "aux.h"
#include "memory.h"
#include <math.h>

double probability_close_reinfection(int id_term, double diameter, double beta)
{
    double dij, num, aux1, aux2, aux3, den;
    double factor = 1 + cbrt(2) + cbrt(4);

    // diameter = 0.3814;
    if (beta != 0) {
    num = 0;
    for (int ii=0; ii<lung.N_terminals; ii++) {
       dij = lung.distance[ matrix_to_vector(id_term, ii) ];
       num += exp( -beta * (dij + 1.5 * factor * (diameter + lung.terminals[ii].diameter)) );
    }
    
    aux1 = exp(-3 * beta * diameter);
    aux2 = 2 * exp(-3 * beta * diameter * (1 + cbrt(2)));
    aux3 = 4 * exp(-3 * beta * diameter * factor);
    den = aux1 + aux2 + aux3 + 8 * num;

    return 1 - 8 * num / den;
    } else {
        return 0;
    }
}


int number_of_reinfections(t_single_lesion *lesion)
{
    if (lesion->t > params.tmin) {
        double lambda = params.nata * lesion->r * exp(-params.a * pow(lesion->t - params.tmin, params.n)) * params.dt;
        return poisson_distribution(lambda);
    } else {
        return 0;
    }
}


int type_of_reinfection(int termid)
{
    //1: intrabronquial reinfection,   2: extrabronquial reinfection
    double U = 1.0*rand()/RAND_MAX;
    if (U <= lung.terminals[termid].p_close_reinf) return 1;
    return 2;
}


int intrabronquial_reinfection(t_lesions *lesions, t_single_lesion *mother, t_lesions *reinf_lesions, int immune_state, int *N_intra)
{
    // Returns 1 if success, 0 if not
    t_point trial_pos;
    int tries = 0;
    do {
        double phi = 2 * M_PI * (1.0*rand())/RAND_MAX;
        double th = acos(1 - 2*(1.0*rand())/RAND_MAX);
        double dist = mother->r - radius_volume_irrigated(lung.terminals[mother->termid].diameter) / 2 * log(1 - (1.0*rand())/RAND_MAX); 

        trial_pos = sum_points(mother->pos, spherical_to_cartesian(dist, th, phi));
        tries ++;
        if (tries >= 10) return 0;
    } while(!(is_inside_lobe(mother->lobe, trial_pos) && !is_inside_lesions(lesions, trial_pos)));

    //rmax and v will depend on immune_state
    //assume dmax is the same as mother
    double rmax, v;
    determine_rmax_v_immune(immune_state, lung.terminals[mother->termid].dmax, &rmax, &v);
    write_lesion( &reinf_lesions->arr[ reinf_lesions->N ], 0, params.rmin, trial_pos, \
                  rmax, v, mother->termid, mother->lobe, 0 );
    reinf_lesions->N += 1;
    *N_intra += 1;
    return 1;
}


void cumsum_extrabronq_reinf(int termid_mother, double *cumsum)
{
    //returns the cdf of a given terminal infecting any of the others;
    double Q = 0;
    for (int ii=0; ii<lung.N_terminals; ii++) {
        if (termid_mother == ii) { //make prob of infecting one-self 0 !!
            cumsum[ii] = 0; 
        } 
        else {
            if (params.b != 0) {
                cumsum[ii] = exp( -params.b * ( lung.distance[matrix_to_vector(termid_mother, ii)] + \
                  1.5 * (1 + cbrt(2) + cbrt(4)) * lung.terminals[ii].diameter));
                Q += cumsum[ii];
            } else {
                cumsum[ii] = 1.0/(lung.N_terminals - 1);
                Q += cumsum[ii];
            }
        }
    }

    //accumulate and normalize 
    cumsum[0] = cumsum[0] / Q;
    for (int ii=1; ii<lung.N_terminals; ii++) {
        cumsum[ii] = cumsum[ii-1] + cumsum[ii] / Q ;  //sum normalised with previous entry
    }
}


int extrabronquial_reinfection(t_lesions *lesions, int mother_id, t_lesions *reinf_lesions, int immune_state, int *N_extra)
{
    // returns 1 if succes, 0 if not
    double *cumsum;
    request_memory_cumsum(&cumsum);
    int daughter_term_id;
    t_point trial_pos;
    int tries = 0;
    do {
        cumsum_extrabronq_reinf( lesions->arr[ mother_id ].termid , cumsum );
        double U = 1.0*rand()/(RAND_MAX + 1.0);  //random between (0,1)
        daughter_term_id = 0;
        while ( (U >= cumsum[daughter_term_id] ) && (daughter_term_id != (lung.N_terminals - 1)) ) {
            daughter_term_id++;
        }
        
        double phi = 2 * M_PI * (1.0*rand())/RAND_MAX;
        double th = acos(1 - 2*(1.0*rand())/RAND_MAX);
        double dist = radius_volume_irrigated(lung.terminals[daughter_term_id].diameter) * cbrt((1.0*rand())/RAND_MAX);
        trial_pos = sum_points(lung.terminals[daughter_term_id].pos, spherical_to_cartesian(dist, th, phi));
        
        tries++;
        if (tries == 10) return 0;
    } while(!(is_inside_lobe(lung.terminals[daughter_term_id].lobe, trial_pos) && !is_inside_lesions(lesions, trial_pos)));

    // int lesion_already_exists = 0;
    double rmax, v;
    determine_rmax_v_immune(immune_state, lung.terminals[daughter_term_id].dmax, &rmax, &v);
    write_lesion( &reinf_lesions->arr[ reinf_lesions->N ], 0, params.rmin, trial_pos, \
                  rmax,v,daughter_term_id,lung.terminals[daughter_term_id].lobe,0);
    *N_extra += 1;
    reinf_lesions->N += 1;
    return 1;
}


int endogenous_reinfection(t_lesions *lesions, t_lesions *reinf_lesions, int immune_state, int *N_intra, int *N_extra) {
    //returns N_reinfections if OK, returns ERROR if N_lesions>=MAX_LESIONS
    int type, new_lesion_counter;
    int num_reinf, success;
    new_lesion_counter = 0;
    reinf_lesions->N = 0;
    *N_intra = 0;
    *N_extra = 0;
    for (int ii=0; ii<lesions->N; ii++) {
        num_reinf = number_of_reinfections(&lesions->arr[ii]);
        for (int jj=0; jj<num_reinf; jj++) {
            //determine if this lesion will cause reinfection, and what type
            type = type_of_reinfection(lesions->arr[ii].termid);
            if (type == 1) {
                //INTRABRONQUIAL REINFECTION
                success = intrabronquial_reinfection(lesions, &lesions->arr[ii], reinf_lesions, immune_state, N_intra);
                // if (!success) printf("Not success!\n");
            }
            else if (type == 2) {
                //EXTRABRONQUIAL REINFECTION ----- ATTENTION: Not all result in a valid reinfection!
                success = extrabronquial_reinfection(lesions, ii, reinf_lesions, immune_state, N_extra);
            }
            new_lesion_counter += success;
            if (lesions->N + new_lesion_counter >= MAX_LESIONS - 1) {
                printf("ERROR INSIDE REINFECTION!! -> too many lesions...\n");
                return ERROR;
            }

        }
    }
    return reinf_lesions->N;
}
