#ifndef _PAW_ION_H_
#define _PAW_ION_H_
/*
   $Id: paw_ion.h 19707 2010-10-29 17:59:36Z d3y133 $
*/


extern void   paw_init_ion(double Z);
extern double paw_get_ion_energy(double *dn);
extern double* paw_get_ion_pot();
extern double paw_get_ion_charge();

#endif


