/*
 $Id: nw_inp_from_string.c 19695 2010-10-29 16:51:02Z d3y133 $
*/
#include "ga.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef CRAY_T3E
#define FATR
#include <fortran.h> /* Required for Fortran-C string interface on Crays */
#endif
#ifndef WIN32
#include <unistd.h>
#else
#include "typesf2c.h"
#endif

#if defined(CRAY_T3E)  || defined(WIN32)
#define nw_inp_from_file_ NW_INP_FROM_FILE
#define util_sgroup_mygroup_ UTIL_SGROUP_MYGROUP
#endif

#if defined(CRAY_T3E) || defined(USE_FCD) || defined(WIN32)
extern Integer FATR nw_inp_from_file_(Integer *rtdb, _fcd filename);
#else
extern Integer FATR nw_inp_from_file_(Integer *rtdb, char *filename, int flen);
#endif
extern Integer FATR util_sgroup_mygroup_(void);

int nw_inp_from_string(Integer rtdb, const char *input)
{
    char filename[30];
    FILE *file;
#if defined(USE_FCD) || defined(CRAY_T3E) || defined(WIN32)
    _fcd fstring;
#else
    char fstring[255];
#endif
    int status;
    const char base[] = "temp";
    const char ending[] = ".nw";
    int number ;

// This is bad, not 100% sure to be unique, since could be subgroup
    if (GA_Pgroup_get_world() != GA_Pgroup_get_default()) {
       number = (int) util_sgroup_mygroup_() ;
    } else {
       number = 0 ;
    }
    sprintf(filename, "%s%d%s", base,number,ending);
    if (GA_Nodeid() == 0) {
      if (!(file = fopen(filename,"w"))) {
        GA_Error("nw_inp_from_string: failed to open temp.nw\n",0);
      }
      if (fwrite(input, 1, strlen(input), file) != strlen(input)) {
        GA_Error("nw_inp_from_string: failed to write to temp.nw\n",0);
      }
      if (fwrite("\n", 1, 1, file) != 1) {
        GA_Error("nw_inp_from_string: failed to write to temp.nw\n",0);
      }
      (void) fclose(file);
    }

#if defined(CRAY_T3E)
      fstring = _cptofcd(filename, strlen(filename));
      status = nw_inp_from_file_(&rtdb, fstring);
#elif defined(WIN32)
    fstring.string = filename;
    fstring.len = strlen(filename);
    status = nw_inp_from_file_(&rtdb, fstring);
#elif defined(USE_FCD)
#error Do something about _fcd
#else
    status = nw_inp_from_file_(&rtdb, filename, strlen(filename));
#endif


    if (GA_Nodeid() == 0) (void) unlink(filename);

    return status;
}
