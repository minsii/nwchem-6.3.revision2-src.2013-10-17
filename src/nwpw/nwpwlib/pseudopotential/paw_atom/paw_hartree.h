#ifndef _PAW_HARTREE_H_
#define _PAW_HARTREE_H_
/*
   $Id: paw_hartree.h 19707 2010-10-29 17:59:36Z d3y133 $
*/


extern void paw_init_hartree();
extern void paw_generate_hartree_pot(double *n);
extern double paw_get_hartree_energy(double *n);
extern double* paw_get_hartree_pot();
#endif


