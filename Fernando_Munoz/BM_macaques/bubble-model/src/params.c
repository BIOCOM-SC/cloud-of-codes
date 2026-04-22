
#include "main.h"
#include "params.h"
#include "stdlib.h"
#include "stdio.h"
#include "lung.h"
#include "aux.h"
#include "reinfection.h"


int read_params_and_update_lung(void)
{
    FILE *file_params;
    file_params = fopen(FILE_PARAMS, "r");
    if (!file_params) {
        printf("ERR: file_params pointer is null");
        return ERROR;
    }
    fscanf(file_params, "v0 = %lf\n", &params.v0);
    fscanf(file_params, "fvimm = %lf\n", &params.fvimm);
    fscanf(file_params, "r0 = %lf\n", &params.r0);
    fscanf(file_params, "fr0dev = %lf\n", &params.fr0dev);
    fscanf(file_params, "frimm = %lf\n", &params.frimm);
    fscanf(file_params, "frimmdev = %lf\n", &params.frimmdev);
    fscanf(file_params, "b = %lf\n", &params.b);
    fscanf(file_params, "nata = %lf\n", &params.nata);
    fscanf(file_params, "f = %lf\n", &params.f);
    fscanf(file_params, "tmax = %lf\n", &params.tmax);
    fscanf(file_params, "dt = %lf\n", &params.dt);
    fscanf(file_params, "n = %lf\n", &params.n);
    fscanf(file_params, "a = %lf\n", &params.a);
    fscanf(file_params, "rmin = %lf\n", &params.rmin);
    fscanf(file_params, "n0 = %lf\n", &params.n0);
    fscanf(file_params, "fndev = %lf\n", &params.fndev);
    fscanf(file_params, "tc = %lf\n", &params.tc);
    fscanf(file_params, "ftcdev = %lf\n", &params.ftcdev);
    fscanf(file_params, "tmin = %lf%*c", &params.tmin);
    fclose(file_params);

    // Update dmax
    for (int ii=0; ii<lung.N_terminals; ii++) {
        if (simu.dlobe == 1) {
            lung.terminals[ii].dmax = lung.terminals[ii].dlobe;
        } else {
            lung.terminals[ii].dmax = lung.terminals[ii].dseg;
        }
        lung.terminals[ii].dmax *= params.f; //MULTIPLY FACTOR
    }
    // Initialise p_close_reinf
    for (int ii=0; ii<lung.N_terminals; ii++) {
        lung.terminals[ii].p_close_reinf = probability_close_reinfection(ii, lung.terminals[ii].diameter, params.b);
    }

    return OK;
}


void write_params(t_params_bm params)
{
    FILE *file_params = fopen(FILE_PARAMS, "w");
    fprintf(file_params, "v0 = %lf\n", params.v0);
    fprintf(file_params, "fvimm = %lf\n", params.fvimm);
    fprintf(file_params, "r0 = %lf\n", params.r0);
    fprintf(file_params, "fr0dev = %lf\n", params.fr0dev);
    fprintf(file_params, "frimm = %lf\n", params.frimm);
    fprintf(file_params, "frimmdev = %lf\n", params.frimmdev);
    fprintf(file_params, "b = %lf\n", params.b);
    fprintf(file_params, "nata = %lf\n", params.nata);
    fprintf(file_params, "f = %lf\n", params.f);
    fprintf(file_params, "tmax = %lf\n", params.tmax);
    fprintf(file_params, "dt = %lf\n", params.dt);
    fprintf(file_params, "n = %lf\n", params.n);
    fprintf(file_params, "a = %lf\n", params.a);
    fprintf(file_params, "rmin = %lf\n", params.rmin);
    fprintf(file_params, "n0 = %lf\n", params.n0);
    fprintf(file_params, "fndev = %lf\n", params.fndev);
    fprintf(file_params, "tc = %lf\n", params.tc);
    fprintf(file_params, "ftcdev = %lf\n", params.ftcdev);
    fprintf(file_params, "tmin = %lf", params.tmin);
    fclose(file_params);
    return;
}


int read_samples(t_params_bm **samples)
{
    FILE *f_samples = fopen(FILE_SAMPLES, "r");
    if (!f_samples) display_and_exit("ERROR opening file with samples.\n");

    t_params_bm *params = (t_params_bm*)calloc(MAX_SAMPLES, sizeof(t_params_bm));
    if (!params) display_and_exit("ERROR allocating pointer inside read_samples()\n");

    int ii = 0;
    int out = 19;
    while (out == 19) {
        out = fscanf(f_samples, "%lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf\n", 
            &params[ii].v0, &params[ii].fvimm, &params[ii].r0, &params[ii].fr0dev, &params[ii].frimm, \
            &params[ii].frimmdev, &params[ii].b, &params[ii].nata, &params[ii].f, &params[ii].tmax, \
            &params[ii].dt, &params[ii].n, &params[ii].a, &params[ii].rmin, &params[ii].n0, &params[ii].fndev, \
            &params[ii].tc, &params[ii].ftcdev, &params[ii].tmin);
        ii++;
    }

    *samples = params;
    fclose(f_samples);
    return ii-1;
}







