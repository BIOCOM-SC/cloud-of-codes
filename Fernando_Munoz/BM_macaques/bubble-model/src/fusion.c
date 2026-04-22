
#include <math.h>
#include "main.h"
#include "lesions.h"
#include "lung.h"


int will_merge(t_lesions *lesions, int id_lesion1, int id_lesion2)
{
// returns an indicator determining whether lesion1 will fusion with lesion2
// 0: not fusion,   1: will fusion
    if ( (lesions->arr[id_lesion1].fusioned == 0) && (lesions->arr[id_lesion2].fusioned == 0) \
         && ( id_lesion1 != id_lesion2 ) && ( lesions->arr[id_lesion1].lobe == lesions->arr[id_lesion2].lobe ) \
         && ( lesions->arr[id_lesion1].t > 0 ) && ( lesions->arr[id_lesion2].t > 0 ) ) {
      
        t_point del = subtract_points(lesions->arr[id_lesion1].pos, lesions->arr[id_lesion2].pos);
        double dij = sqrt( del.x*del.x + del.y*del.y + del.z*del.z );
      
        if ( (dij < lesions->arr[id_lesion1].r) || (dij < lesions->arr[id_lesion2].r) ) {
            return 1;
        }
    }
    return 0;
}


int fusion(t_lesions *lesions, t_lesions *fusioned_lesions)
{
    fusioned_lesions->N = 0;
    for (int ii=0; ii < lesions->N-1 ; ii++) { 
        for (int jj=ii+1; jj < lesions->N ; jj++) {
            int indicator_fusion = will_merge(lesions, ii, jj);   
            if ( indicator_fusion == 1 ) {
                double r_new = sqrt( pow(lesions->arr[ii].r, 2) + pow(lesions->arr[jj].r, 2) );
                
                int id_big;
                double wi = pow( lesions->arr[ii].r/r_new, 2 );
                double wj = pow( lesions->arr[jj].r/r_new, 2 );
                if (wi > wj) {
                    id_big = ii;
                } else {
                    id_big = jj;
                }
                
                int termid_new = lesions->arr[id_big].termid;
                double rmax_new = sqrt( pow(lesions->arr[ii].rmax, 2) + pow(lesions->arr[jj].rmax, 2) ); 

                if ( rmax_new > lung.terminals[ termid_new ].dmax ) rmax_new = lung.terminals[termid_new ].dmax;
                if (r_new > rmax_new) rmax_new = r_new;
                
                double t_new = (lesions->arr[ii].t)*wi + (lesions->arr[jj].t)*wj ;
                t_point pos_new;
                pos_new.x = (lesions->arr[ii].pos.x)*wi + (lesions->arr[jj].pos.x)*wj ;
                pos_new.y = (lesions->arr[ii].pos.y)*wi + (lesions->arr[jj].pos.y)*wj ;
                pos_new.z = (lesions->arr[ii].pos.z)*wi + (lesions->arr[jj].pos.z)*wj ;

                write_lesion( &fusioned_lesions->arr[ fusioned_lesions->N ], t_new, r_new, pos_new, \
                  rmax_new, lesions->arr[id_big].v, termid_new, lesions->arr[id_big].lobe, 0 );

                fusioned_lesions->N += 1;
                //indicate that they have fusioned:
                lesions->arr[ii].fusioned = 1;
                lesions->arr[jj].fusioned = 1;
            }
        }
    }

    return fusioned_lesions->N;
}


