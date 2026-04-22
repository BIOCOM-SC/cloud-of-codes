
#include <math.h>
#include "main.h"
#include "results.h"
#include "params.h"
#include "fusion.h"
#include "reinfection.h"
#include "aux.h"
#include "memory.h"
#include "exp_err.h"
#include "gnuplotc.h"


enum plot_variable {
    NC,
    NM,
    VFC,
    NMD,
    NMI,
    MAC
};


static void add_experimental(t_gnuplot *interface, enum plot_variable var)
{
    double exp_days[3] = {21, 53, 77};
    double exp[3][3];
    for (int ii=0; ii<3; ii++) {
        exp[0][ii] = exp_days[ii];
        switch (var) {
            case NC: 
                exp[1][ii] = exp_results.nc[ii];
                exp[2][ii] = exp_results.nc_std[ii];
                break;
            case NM:
                exp[1][ii] = exp_results.nm[ii];
                exp[2][ii] = exp_results.nm_std[ii];
                break;
            case VFC:
                exp[1][ii] = exp_results.vfc[ii];
                exp[2][ii] = exp_results.vfc_std[ii];
                break;
            case NMD:
                exp[1][ii] = exp_results.nmd[ii];
                exp[2][ii] = exp_results.nmd_std[ii];
                break;
            case NMI:
                exp[1][ii] = exp_results.nmi[ii];
                exp[2][ii] = exp_results.nmi_std[ii];
                break;
            case MAC:
                exp[1][ii] = exp_results.mac[ii];
                exp[2][ii] = exp_results.mac_std[ii];
                break;
        }
    }
    // Errorbars:
    draw_errorbars_2d(interface, exp[0], exp[1], exp[2], 3, "lc 8 lw 2 lt -1");
    // Points:
    draw_2d(interface, exp[0], exp[1], 3, POINTS, "pt 5 lc 8 lw 4");
}


static void add_array_errorbars(t_gnuplot *interface, double *mean, double *std, int N, int skip, char *config)
{
    for (int ii=0; ii<N; ii++) {
        if (ii % skip == 0) {
            double x = (double) ii;
            draw_errorbars_2d(interface, &x, &mean[ii], &std[ii], 1, config);
        }
    }
}


void plot_results(t_results *results)
{
    double days[(int)params.tmax];
    for (int ii=1; ii<=params.tmax; ii++) days[ii] = ii;

    char buff[1024];
    snprintf(buff, 1024, "set multiplot layout 2,3 columns rowsfirst title 'v0:%.3f, fvimm:%.3f, r0:%.3f, frimm:%.3f, ß:%.3f, ρ:%.3f, n:%.3f, a:%.3f, N0:%.3f, tc:%.3f, rmin:%.3f' font ',24'", \
          params.v0, params.fvimm, params.r0, params.frimm, params.b, params.nata, params.n, params.a, params.n0, params.tc, params.rmin);

    t_gnuplot *interface = gnuplot_start(PNG_2D, "./results/main_results.png", (int[2]){1920, 1080}, 18);
    gnuplot_config(interface, buff, "set grid", "set style line 1 lc rgb '#c8c8c8' lt 1 lw 1");
    
    // NC
    gnuplot_config(interface, "set xlabel 'time (days)'", "set ylabel 'Number'", 
                   "set title '# of consolidations (NC)'", "set yrange [0:25]");
    draw_2d(interface, days, results->nc.t1, params.tmax, LINES, "lc 6 lw 3");
    add_array_errorbars(interface, results->nc.t1, results->nc.t2, params.tmax, 5, "lc 3 lt -1");
    add_experimental(interface, NC);

    // NM
    next_subplot(interface, "set xlabel 'time (days)'", "set ylabel 'Number'", 
                   "set title '# of consolidations (NM)'", "set yrange [0:150]");
    draw_2d(interface, days, results->nm.t1, params.tmax, LINES, "lc 6 lw 3");
    add_array_errorbars(interface, results->nm.t1, results->nm.t2, params.tmax, 5, "lc 3 lt -1");
    add_experimental(interface, NM);

    // VFC
    next_subplot(interface, "set xlabel 'time (days)'", "set ylabel 'Lung volume fraction'",
                    "set title 'Vol. fract. occupied by consol.'", "set yrange [0:0.14]");
    draw_2d(interface, days, results->vfc.t1, params.tmax, LINES, "lc 6 lw 3");
    add_array_errorbars(interface, results->vfc.t1, results->vfc.t2, params.tmax, 5, "lc 3 lt -1");
    add_experimental(interface, VFC);

    // NMD
    next_subplot(interface, "set xlabel 'time (days)'", "set ylabel 'Number'",
                "set title '# of daughter micronodules (NMD)'", "set yrange [0:100]");
    draw_2d(interface, days, results->nmd.t1, params.tmax, LINES, "lc 6 lw 3");
    add_array_errorbars(interface, results->nmd.t1, results->nmd.t2, params.tmax, 5, "lc 3 lt -1");
    add_experimental(interface, NMD);

    // NMI
    next_subplot(interface, "set xlabel 'time (days)'", "set ylabel 'Number'",
                    "set title '# of isolated micronodules (NMI)'", "set yrange [0:100]");
    draw_2d(interface, days, results->nmi.t1, params.tmax, LINES, "lc 6 lw 3");
    add_array_errorbars(interface, results->nmi.t1, results->nmi.t2, params.tmax, 5, "lc 3 lt -1");
    add_experimental(interface, NMI);

    // MAC
    next_subplot(interface, "set xlabel 'time (days)'", "set ylabel 'Main axis (mm)'",
                    "set title 'Main axis'", "set yrange [0:22]");
    draw_2d(interface, days, results->mac.t1, params.tmax, LINES, "lc 6 lw 3 title 'MAC'");
    draw_2d(interface, days, results->ma.t1, params.tmax, LINES, "lc 4 lw 3 title 'MA(C+M)'");
    add_array_errorbars(interface, results->mac.t1, results->mac.t2, params.tmax, 5, "lc 3 lt -1");
    add_experimental(interface, MAC);

    gnuplot_end(interface);


    /* Reinfections */
    interface = gnuplot_start(PNG_2D, "./results/reinfections.png", (int[2]){1920, 1080}, 18);
    gnuplot_config(interface, "set yrange [0:180]", "set grid", "set style line 1 lc rgb '#c8c8c8' lt 1 lw 1");
    draw_2d(interface, days, results->nintra.t1, params.tmax, LINES, "lc 4 lw 3 title 'intra'");
    draw_2d(interface, days, results->nextra.t1, params.tmax, LINES, "lc 6 lw 3 title 'extra'");
    gnuplot_end(interface);
}


static void add_lung(t_gnuplot *interface)
{
    char dir_name[300];
    if (simu.is_human == 1) {
        snprintf(dir_name, 100, "%s/lobes", DIR_CONFIG_HUMAN);
    } else {
        if (simu.dseg == 1) {
            snprintf(dir_name, 100, "%s/segments", DIR_CONFIG_MACAQUE);
        } else {
            snprintf(dir_name, 100, "%s/lobes", DIR_CONFIG_MACAQUE);
        }
    }
  
    DIR *dir;
    dir = opendir(dir_name);
    if (!dir) display_and_exit("ERROR!! Unable to open directory (add_lung_as_data_blocks)");

    struct dirent *entry;
    entry = readdir(dir);
    int num_segments = 0;
    while (entry) {
        if (entry->d_type == DT_REG) {
            if (ends_with_txt(entry->d_name)) {
                char buff[256];
                snprintf(buff, 256, "DATA_%d", num_segments);
                char fname[256];
                snprintf(fname, 256, "%s/%s", dir_name, entry->d_name);
                draw_file(interface, fname, 1, POLYGONS,  "fs transparent solid 0.1 fc 'salmon'");
                // add_datablock_from_file(interface, fname, 1, buff);
                num_segments++;
            }
        }
        entry = readdir(dir);
    }
    closedir(dir);
}


void add_lesions(t_gnuplot *interface, t_lesions *lesions)
{
    for (int ii=0; ii<lesions->N; ii++) {
        if (lesions->arr[ii].r > params.rmin) {
            draw_sphere_3d(interface, lesions->arr[ii].pos.x, lesions->arr[ii].pos.y, 
                           lesions->arr[ii].pos.z, lesions->arr[ii].r, POLYGONS, "fc 'black'");
        }
    }
}


void save_photogram(t_gnuplot *interface, t_lesions *lesions, int day)
{   
    char buffer[1024];
    static double rotation_z = 80;
    double scale = 1.4;

    rotation_z = fmod((rotation_z + 0.3), 360);
    snprintf(buffer, 1024, "set view 70, %f, %f, 1", rotation_z, scale);
    gnuplot_config(interface, buffer);
    snprintf(buffer, 1024, "set title 'Day %d' font ',48' offset 0,-7", day);
    gnuplot_config(interface, buffer);
    
    add_lung(interface);
    add_lesions(interface, lesions);
  
    for (int ii=0; ii<2; ii++) {
        rotation_z = fmod(rotation_z + 0.3, 360);
    }
}


static void set_config_lung(t_gnuplot *interface)
{
    if (simu.is_human == 1) {
        gnuplot_config(interface, "set xrange [-200:200]", "set yrange [0:350]", "set zrange [-275:25]");
    } else {
        gnuplot_config(interface, "set xrange [-85:85]", "set yrange [-105:65]", "set zrange [-110:60]");
    }
}


int make_video(void)
{
    activate_parallel_video_processing(omp_get_max_threads());

    t_gnuplot *interface = gnuplot_start(VIDEO_3D, "./results/video.mp4", (int[2]){1920, 1080}, 18); 
    gnuplot_config(interface, "unset tics", "unset border", "set xyplane relative 0");
    gnuplot_config(interface, "set parametric", "set urange [-pi/2:pi/2]", "set vrange [0:2*pi]",
                   "set samples 50", "set pm3d depthorder");
    set_config_lung(interface);

    t_lesions *lesions, *reinfected_lesions, *fusioned_lesions;
    request_memory_lesions(&lesions, &reinfected_lesions, &fusioned_lesions);
    initialize_lesions(lesions); 
    initialize_lesions(reinfected_lesions);
    initialize_lesions(fusioned_lesions);

    // Simulation
    int immune_state = 0;
    double t = 0;
    double timm = normal_distribution(params.tc, params.tc * params.ftcdev);
    while (t <= params.tmax) {
        if ( (t >= timm) && (immune_state == 0) ) {
            activate_immune(lesions);
            immune_state = 1;
        }
        lesion_growth(lesions);
        int N_intra_it, N_extra_it;
        int N_reinf = endogenous_reinfection(lesions, reinfected_lesions, immune_state, &N_intra_it, &N_extra_it);
        if ( N_reinf == ERROR ) return ERROR;
        fusion(lesions, fusioned_lesions);
        synchronise_lesions(lesions, reinfected_lesions, fusioned_lesions);

        if ( (int)t < (int)(t+params.dt) || (int)(t+0.33) < (int)(t+params.dt+0.33) || (int)(t+0.66) < (int)(t+params.dt+0.66)) {
            save_photogram(interface, lesions, (int)t);
            next_frame(interface, "unset tics", "unset border", "set xyplane relative 0", 
                        "set parametric", "set urange [-pi/2:pi/2]", "set vrange [0:2*pi]",
                        "set samples 50", "set pm3d depthorder");
            set_config_lung(interface);
        }
        t += params.dt;
    }
    puts("-> Rendering video frames...");
    gnuplot_end(interface);
    return OK;
}

