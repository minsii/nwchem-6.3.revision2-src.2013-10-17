#ifndef _PAW_VOSKO_H_
#define _PAW_VOSKO_H_
/*
   $Id: paw_vosko.h 19707 2010-10-29 17:59:36Z d3y133 $
*/


extern void paw_init_vosko();
extern void paw_generate_corr_pot(double **rho, double **Vc);
extern double paw_get_correlation_energy(double **rho);
extern void paw_generate_corr_pot_LDA(double *rho);
extern double* paw_get_corr_pot_LDA();
extern double paw_get_correlation_energy_LDA(double *rho);

#endif


