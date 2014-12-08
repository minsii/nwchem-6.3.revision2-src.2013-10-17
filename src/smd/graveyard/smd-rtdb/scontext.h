/*$Id: scontext.h 19707 2010-10-29 17:59:36Z d3y133 $*/
extern int context_set(const char *);
extern char *context_get(void);
extern int context_srtdb_store(int);
extern int context_srtdb_load(int);
extern int context_push(const char *);
extern int context_pop(const char *);
extern int context_srtdb_match(int, const char *, int, char *);
extern int context_prefix(const char *, char *, int);

 
#if defined(CRAY) || defined(WIN32)
#include "srtdb.cray.h"
#endif

