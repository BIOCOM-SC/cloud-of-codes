
#include "main.h" 
#include "lung.h"
#include "stdlib.h"
#include "stdio.h"
#include "aux.h"



void malloc_and_read_single_lobe(char *fname, t_lobe *lobe)
{
    FILE *file = fopen(fname, "r");

    int N_faces;
    fscanf(file, "%d\n\n", &N_faces);
    if (N_faces < 10) display_and_exit("Check format of lobe file?\n"); 
    if (N_faces >= MAX_LOBE_FACES - 2) display_and_exit("Error in reading lobes! Maximum lobe faces...\n");

    t_face *faces = malloc(sizeof(t_face) * N_faces);
    for (int ii=0; ii<N_faces; ii++) {
        int result = fscanf(file, "%lf %lf %lf\n %lf %lf %lf\n %lf %lf %lf\n %*lf %*lf %*lf\n\n\n", \
            &faces[ii].p[0].x, &faces[ii].p[0].y, &faces[ii].p[0].z, \
            &faces[ii].p[1].x, &faces[ii].p[1].y, &faces[ii].p[1].z, \
            &faces[ii].p[2].x, &faces[ii].p[2].y, &faces[ii].p[2].z);
        if (result == EOF) display_and_exit("Error reading lobe! reached EOF...\n");
    }
    lobe->N_faces = N_faces;
    lobe->faces = faces;

    fclose(file);
}


void malloc_and_read_lobes(void)
{
    char dir_name[256];
    if (simu.is_human == 1) {
        snprintf(dir_name, 100, "%s/lobes", DIR_CONFIG_HUMAN);
    } else {
        snprintf(dir_name, 100, "%s/lobes", DIR_CONFIG_MACAQUE);
    }

    int N_lobes = count_txt_files(dir_name);
    lung.N_lobes = N_lobes;
    lung.lobes = malloc(sizeof(t_lobe) * N_lobes);

    struct dirent **sorted_entries;
    int n_files = scandir(dir_name, &sorted_entries, NULL, alphasort);
    if (n_files == -1) display_and_exit("ERROR!! Unable to open directory, or unable to allocate memory for name array\n");
    
    int ii = 0, lobe_id = 0;
    char fname[256];
    while (ii < n_files) {
        if (sorted_entries[ii]->d_type == DT_REG) {
            if (ends_with_txt(sorted_entries[ii]->d_name)) {
                snprintf(fname, 100, "%s/%s", dir_name, sorted_entries[ii]->d_name);
                malloc_and_read_single_lobe(fname, &lung.lobes[lobe_id]);
                lobe_id++;
            }
        }
        ii++;
    }

    // free dirent
    for (int ii=0; ii<n_files; ii++) free(sorted_entries[ii]);
    free(sorted_entries);
}


int malloc_and_read_terminals(void)
{
    char fname[100];
    if (simu.is_human == 1) {
        snprintf(fname, 100, "%s/%s", DIR_CONFIG_HUMAN, FILE_TERMINALS);
    } else {
        snprintf(fname, 100, "%s/%s", DIR_CONFIG_MACAQUE, FILE_TERMINALS);
    }

    FILE *file_term = fopen(fname,"r");
    if (!file_term) display_and_exit("ERR: file_term pointer is null\n");

    int N_terminals;
    fscanf(file_term, "%d\n\n", &N_terminals);
    if (N_terminals < 10) display_and_exit("N_terminals is too low?\n");

    lung.N_terminals = N_terminals;
    lung.terminals = malloc(sizeof(t_terminal) * N_terminals);
    for (int ii=0; ii<N_terminals; ii++) {
        int result = fscanf(file_term, "%lf,%lf,%lf,%d,%lf,%d,%lf,%lf,%lf",  &lung.terminals[ii].pos.x, 
                          &lung.terminals[ii].pos.y, &lung.terminals[ii].pos.z, &lung.terminals[ii].seg, 
                          &lung.terminals[ii].dseg, &lung.terminals[ii].lobe, &lung.terminals[ii].dlobe,
                          &lung.terminals[ii].diameter, &lung.terminals[ii].p_initial_infection);
        if (result == EOF) display_and_exit("Error reading terminals: reached EOF\n");
    }
    fclose(file_term);
    return N_terminals;
}


void malloc_and_read_D(int N_terminals)
{
    lung.distance = (double*)malloc(sizeof(double) * N_terminals*(N_terminals+1)/2);
    if (!lung.terminals) display_and_exit("ERR: Could not locate memory for lung.terminals or lung.distance.\n");
        
    char fname[100];
    if (simu.is_human == 1) {
        snprintf(fname, 100, "%s/%s", DIR_CONFIG_HUMAN, FILE_DIST_INTRABRONQ);
    } else {
        snprintf(fname, 100, "%s/%s", DIR_CONFIG_MACAQUE, FILE_DIST_INTRABRONQ);
    }
    FILE *file_D = fopen(fname, "r");
    if (!file_D) display_and_exit("ERR: file_D pointer is null\n");
    int out = fread(lung.distance, sizeof(double), N_terminals * (N_terminals + 1) / 2, file_D);
    if (out < N_terminals*(N_terminals+1)/2) display_and_exit("Error in fread for distance matrix");
    fclose(file_D);
}


int malloc_and_read_lung(void)
{
    if (simu.is_human == 1) {
        lung.volume = HUMAN_LUNG_VOLUME;
        lung.diam_trachea = DIAM_TRACHEA_HUMAN;
    } else {
        lung.volume = MACAQUE_LUNG_VOLUME;
        lung.diam_trachea = DIAM_TRACHEA_MACAQUE;
    }

    int N_terminals = malloc_and_read_terminals();
    malloc_and_read_D(N_terminals);
    malloc_and_read_lobes();
    
    return OK;
}
