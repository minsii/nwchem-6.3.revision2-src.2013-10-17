#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sndrcv.h"

#define MAX_PROCESS 100000
#define TYPE_NXTVAL 33333

extern MPI_Comm TCGMSG_Comm;
extern int      SR_parallel;
extern int      SR_single_cluster;
extern long  DEBUG_;
extern int       _tcg_initialized;

#ifdef  EXT_INT
#  define TCG_INT MPI_LONG
#else
#  define TCG_INT MPI_INT
#endif

#ifdef  EXT_DBL
#  define TCG_DBL MPI_LONG_DOUBLE
#else
#  define TCG_DBL MPI_DOUBLE
#endif


#define TCG_MAX(a,b) (((a) >= (b)) ? (a) : (b))
#define TCG_MIN(a,b) (((a) <= (b)) ? (a) : (b))
#define TCG_ABS(a)   (((a) >= 0)   ? (a) : (-(a)))

#define TCG_ERR_LEN 80
#define ERR_STR_LEN TCG_ERR_LEN + MPI_MAX_ERROR_STRING
extern  char  tcgmsg_err_string[ERR_STR_LEN];

#define tcgmsg_test_statusM(_str, _status)\
{\
  if( _status != MPI_SUCCESS){\
      int _tot_len, _len = TCG_MIN(ERR_STR_LEN, strlen(_str));\
      strncpy(tcgmsg_err_string, _str, _len);\
      MPI_Error_string( _status, tcgmsg_err_string + _len, &_tot_len);\
      Error(tcgmsg_err_string, (int)_status);\
  }\
}

extern void finalize_nxtval();
extern void install_nxtval(int *argc, char **argv[]);

#ifdef __crayx1
#undef CRAY
#endif
