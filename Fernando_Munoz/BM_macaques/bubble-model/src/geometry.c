
#include "main.h"
#include "geometry.h"
#include "lung.h"
#include <math.h>


t_point spherical_to_cartesian(double r, double theta, double phi) 
{
    t_point cart;
    cart.x = r * sin(theta) * cos(phi);
    cart.y = r * sin(theta) * sin(phi);
    cart.z = r * cos(theta);
    return cart;
}


t_point cross_product(t_point v1, t_point v2)
{
    t_point out;
    out.x = v1.y * v2.z - v1.z * v2.y;
    out.y = v1.z * v2.x - v1.x * v2.z;
    out.z = v1.x * v2.y - v1.y * v2.x;
    return out;
}


double dot_product(t_point v1, t_point v2)
{
    return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}


t_point sum_points(t_point p1, t_point p2)
{
    t_point out;
    out.x = p1.x + p2.x;
    out.y = p1.y + p2.y;
    out.z = p1.z + p2.z;
    return out;
}


t_point subtract_points(t_point p1, t_point p2)
{
    t_point out;
    out.x = p1.x - p2.x;
    out.y = p1.y - p2.y;
    out.z = p1.z - p2.z;
    return out;
}


double distance_points(t_point p1, t_point p2)
{
    t_point diff = subtract_points(p1, p2);
    return pow(dot_product(diff, diff), 0.5);
}


int ray_triangle_intersection(t_point ray_origin, t_point ray_vector, t_face triangle)
{
    // Möller-Trumbore algorithm
    double epsilon = 1e-5;

    t_point edge1, edge2;
    edge1.x = triangle.p[1].x - triangle.p[0].x;
    edge1.y = triangle.p[1].y - triangle.p[0].y;
    edge1.z = triangle.p[1].z - triangle.p[0].z;

    edge2.x = triangle.p[2].x - triangle.p[0].x;
    edge2.y = triangle.p[2].y - triangle.p[0].y;
    edge2.z = triangle.p[2].z - triangle.p[0].z;

    t_point ray_cross_e2 = cross_product(ray_vector, edge2);
    double det = dot_product(edge1, ray_cross_e2);
    
    if (det > -epsilon && det < epsilon) return 0;  // This ray is parallel to this triangle.

    double inv_det = 1.0 / det;
    t_point s;
    s.x = ray_origin.x - triangle.p[0].x;
    s.y = ray_origin.y - triangle.p[0].y;
    s.z = ray_origin.z - triangle.p[0].z;
    double u = inv_det * dot_product(s, ray_cross_e2);

    if (u < 0 || u > 1) return 0;

    t_point s_cross_e1 = cross_product(s, edge1);
    double v = inv_det * dot_product(ray_vector, s_cross_e1);

    if (v < 0 || u + v > 1) return 0;

    // At this stage we can compute t to find out where the intersection point is on the line.
    double t = inv_det * dot_product(edge2, s_cross_e1);
    
    if (t > epsilon) { // ray intersection
        //out_intersection_point = ray_origin + ray_vector * t;
        return 1;
    } else { // This means that there is a line intersection but not a ray intersection.
        return 0;
    }
}


int is_inside_lobe(int lobe, t_point pos)
{
    t_point ray_origin = pos; 
    t_point ray_vector;  // TODO Make this random?
    ray_vector.x = 1;
    ray_vector.y = 0;
    ray_vector.z = 0;

    int intersections = 0;
    for (int ii=0; ii<lung.lobes[lobe-1].N_faces; ii++) {
        if (ray_triangle_intersection(ray_origin, ray_vector, lung.lobes[lobe-1].faces[ii]) == 1) {
            intersections += 1;
          }
    }
    return (intersections % 2 == 1);  // Odd num. of inters. means point is inside
}



/*
#define MAX_PLANES_CONVHULL 1000


typedef struct {
  int N;
  double planes[MAX_PLANES_CONVHULL][4];
} t_convhull_planes;


int is_inside_convhull(int lobe, t_point pos) {
  int ii, count;
  t_convhull_planes *convhull;

  int leftright = lobe2leftright(lobe);
  if (leftright == 1) {
    convhull = &lung.hull_planes_right;
  } else {
    convhull = &lung.hull_planes_left;
  }

  count = 0;
  for (ii=0; ii<convhull->N; ii++) {
    count += sign( pos.x * convhull->planes[ii][0] + pos.y * convhull->planes[ii][1] + \
                   pos.z * convhull->planes[ii][2] + convhull->planes[ii][3]);
  }

  return abs(count) == convhull->N;
}


int lobe2leftright(int lobe) {
  // right = 1,   left = 2
  if (lobe <= 4) {
    return 1;
  } else {
    return 2;
  }
} */


