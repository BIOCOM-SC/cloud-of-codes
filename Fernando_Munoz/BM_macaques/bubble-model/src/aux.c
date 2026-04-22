// Auxiliary functions, mainly mathematical

#include "main.h"
#include "lung.h"


time_t gettime_seconds(void)
{
    struct timespec current_time;
    clock_gettime(CLOCK_MONOTONIC, &current_time);
    return current_time.tv_sec;
}


double time_difference_seconds(struct timespec t1, struct timespec t2) 
{   
    time_t dt_s = t1.tv_sec - t2.tv_sec;
    long dt_n = t1.tv_nsec - t2.tv_nsec;

    if (dt_n < 0) {
        dt_s -= 1;          // Borrow 1 second
        dt_n += 1e9; // Add 1 second worth of nanoseconds
    }

    return dt_s + dt_n / 1.0e9;
}


void display_and_exit(char *message)
{
    printf("%s", message);
    exit(1);
}


int sign(double x) 
{
    return (x > 0) - (x < 0);
}


int factorial(int N) 
{
    if (N == 1) {
       return 1;
    } else {  
        return N*factorial(N-1);
    }
}


double normal_distribution(double mean, double std) 
{
    //Box-Muller method
    double U, V, X;
    U = (1.0*rand())/RAND_MAX ;
    V = (1.0*rand())/RAND_MAX ;
    
    X = sqrt(-2*log(U))*cos(2*M_PI*V);
    return (mean + std*X);
}


int poisson_distribution(double lambda) 
{
    double U = (1.0*rand())/RAND_MAX;
    int kk = 0;
    double aux = 1;
    while (U > aux * exp(-lambda)) {
        kk++;
        aux += pow(lambda, (double)kk) / factorial(kk);
    }
    return kk;
}


int index_rand_terminal(void)
{
    double U = (1.0*rand())/(RAND_MAX+1.0);
    return floor(U*lung.N_terminals); //USE FLOOR TO NEVER GET TERMINAL 8233
}


double radius_volume_irrigated(double terminal_diameter) 
{
    return ( cbrt(3 * lung.volume / (4 * M_PI)) * terminal_diameter / lung.diam_trachea );
}


double radius_to_volume(double radius) 
{
    return ( 4.0/3.0*M_PI*pow(radius,3) );
}


int matrix_to_vector(int i, int j)
{
    if (i <= j) {
        return i*lung.N_terminals - (i-1)*i/2 + j - i;
      } else {
        return j*lung.N_terminals - (j-1)*j/2 + i - j;
      }
}


int ends_with_txt(const char *string)
{
    size_t length = strlen(string);
    if (length <= 4) return 0;
    // We move the pointer to compare only the last 4 characters of the string:
    return (strcmp(string + length - 4, ".txt") == 0);
}


int count_txt_files(const char *directory_path)
{
    DIR *dir;
    struct dirent *entry;
    int txt_count = 0;

    dir = opendir(directory_path);
    if (!dir) display_and_exit("ERROR!! Unable to open path to count txt files.\n");

    entry = readdir(dir);
    while (entry != NULL) {
        if (entry->d_type == DT_REG) {
            if (ends_with_txt(entry->d_name)) {
                txt_count += 1;
          }
        }
        entry = readdir(dir);
    }

    closedir(dir);
    return txt_count;
}


// void update_dmax(int dmax_is_dlobe)
// {
//     for (int ii=0; ii<lung.N_terminals; ii++) {
//         if (1 == dmax_is_dlobe) {
//             lung.terminals[ii].dmax = lung.terminals[ii].dlobe;
//         } else {
//             lung.terminals[ii].dmax = lung.terminals[ii].dseg;
//         }
//         lung.terminals[ii].dmax *= params.f; //MULTIPLY FACTOR
//     }
// }


