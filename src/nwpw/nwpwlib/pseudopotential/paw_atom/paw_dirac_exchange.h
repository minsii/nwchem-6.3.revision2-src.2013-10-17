#ifndef _PAW_DIRAC_EXCHANGE_H_
#define _PAW_DIRAC_EXCHANGE_H_
/*
   $Id: paw_dirac_exchange.h 19707 2010-10-29 17:59:36Z d3y133 $
*/


extern void paw_init_dirac_exchange();
extern double paw_get_exchange_energy(double **rho);
extern void paw_generate_exchange_pot_LDA(double *rho);
extern double paw_get_exchange_energy_LDA(double *rho);
extern double* paw_get_exchange_potential();

#endif

