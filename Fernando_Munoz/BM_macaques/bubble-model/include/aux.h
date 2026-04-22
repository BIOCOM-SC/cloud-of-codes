#ifndef BM_AUX_H
#define BM_AUX_H

#include "time.h"

time_t gettime_seconds(void);
double time_difference_seconds(struct timespec t1, struct timespec t2);
void display_and_exit(char *message);
int sign(double x);
int factorial(int N);
double normal_distribution(double mean, double std);
int poisson_distribution(double lambda);
int index_rand_terminal(void);
double radius_volume_irrigated(double terminal_diameter);
double radius_to_volume(double radius);
int matrix_to_vector(int i, int j);
int ends_with_txt(const char *string);
int count_txt_files(const char *directory_path);

#endif
