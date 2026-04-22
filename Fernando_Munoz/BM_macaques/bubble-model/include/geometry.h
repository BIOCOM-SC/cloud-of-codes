#ifndef BM_GEOMETRY_H
#define BM_GEOMETRY_H

typedef struct t_point {
  double x, y, z;
} t_point;

typedef struct t_face {
  t_point p[3];  // Set of 3 points (rows)
} t_face;



t_point spherical_to_cartesian(double r, double theta, double phi);
int is_inside_lobe(int lobe, t_point pos);
t_point sum_points(t_point p1, t_point p2);
t_point subtract_points(t_point p1, t_point p2);
double distance_points(t_point p1, t_point p2);


#endif
