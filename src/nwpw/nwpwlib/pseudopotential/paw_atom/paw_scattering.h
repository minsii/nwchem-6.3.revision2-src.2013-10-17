#ifndef	_PAW_SCATTERING_H_
#define _PAW_SCATTERING_H_
/*
   $Id: paw_scattering.h 19707 2010-10-29 17:59:36Z d3y133 $
*/


extern void paw_init_paw_scattering_set();
extern void paw_init_paw_scattering();
extern void paw_end_paw_scattering();

extern void paw_solve_paw_scattering(int l, double r, double e, double* psi,double* psi_prime);

#endif
