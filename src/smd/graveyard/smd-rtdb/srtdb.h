/*$Id: srtdb.h 19707 2010-10-29 17:59:36Z d3y133 $*/
#ifndef RTDB_H
#define RTDB_H

#include "macdecls.h"

/*
  All routines return TRUE (1) on success, FALSE (0) on failure.

  int srtdb_parallel(const int mode)
  
    Set the parallel access mode of all databases to mode and
    return the previous setting


  int srtdb_open(const char *filename, const char *mode, int *handle)

    Filename = path to file associated with the data base
    mode     = 'new'     Open only if it does not exist already
               'old',    Open only if it does exist already
               'unknown' Create new or open existing (preserving contents)
               'empty'   Create new or open existing (deleting contents)
               'scratch' Create new or open existing (deleting contents)
                         and automatically delete upon closing.  Also, items
                         cached in memory are not written to disk.

    handle   = returns handle by which all future references to the
               data base are made



  int srtdb_clone(const int handle, const char *suffix)

    Copy the data base file

    handle   = handle to RTDB
    suffix   


  int srtdb_close(const int handle, const char *mode)

    Close the data base

    handle   = handle to RTDB
    mode     = 'keep'    Preserve the data base file to enable restart
               'delete'  Delete the data base file freeing all resources

               mode is overridden by opening the data base with 
               mode='scratch' in which instance it is always deleted 
               upon closing


  int srtdb_get_info(const int handle, const char *name, int *ma_type, 
                    int *nelem, char date[26])

    Get info about an entry from the data base

    handle   = handle to RTDB
    name     = entry name (null terminated character string)
    ma_type  = returns MA type of the entry
    nelem    = returns no. of elements of the given type
    date     = returns date of insertion (null terminated character string)


  int srtdb_put(const int handle, const char *name, const int ma_type,
               const int nelem, const void *array)

    Insert an entry into the data base replacing previous entry

    handle   = handle to RTDB
    name     = entry name (null terminated character string)
    ma_type  = MA type of the entry
    nelem    = no. of elements of the given type
    array    = data to be inserted


  int srtdb_get(const int handle, const char *name, const int ma_type,
               const int nelem, void *array)

    Get an entry from the data base

    handle   = handle to RTDB
    name     = entry name (null terminated character string)
    ma_type  = MA type of the entry which must match entry type
    nelem    = size of array in units of ma_type
    array    = user provided buffer that returns data


  int srtdb_ma_get(const int handle, const char *name, int *ma_type,
                  int *nelem, int *ma_handle)

    Get an entry from the data base returning an MA handle
  
    handle   = handle to RTDB
    name     = entry name (null terminated character string)
    ma_type  = returns MA type of the entry
    nelem    = returns no. of elements of type ma_type in data
    ma_handle= returns MA handle to data


  int srtdb_first(const int handle, const int namelen, char *name)

    Return the name of the first (user inserted) entry in the data base.
    The order is effectively random.

    handle  = handle to RTDB
    namelen = size of user provided buffer name
    name    = name of entry is returned in this buffer


  int srtdb_next(const int handle, const int namelen, char *name)

    Return the name of the next (user inserted) entry in the data base.
    The order is effectively random.

    handle  = handle to RTDB
    namelen = size of user provided buffer name
    name    = name of entry is returned in this buffer


  int srtdb_print(const int handle, const int print_values)

    Print the contents of the data base to stdout

    handle  = handle to RTDB
    print_values = boolean flag ... if true values as well as
                   keys are printed out.


  int srtdb_delete(const int handle, const char *name)

    Delete the entry from the database.
    Return
          1 if key was present and successfully deleted

         0 if key was not present, or if an error occured

    handle  = handle to RTDB
    name    = name of entry to delete
		   
*/

extern int srtdb_open(const char *, const char *, int *);
extern int srtdb_clone(const int, const char *);
extern int srtdb_getfname(const int,  char [36]);
extern int srtdb_close(const int, const char *);
extern int srtdb_put(const int, const char *, const int, const int, 
		    const void *);
extern int srtdb_get(const int, const char *, const int, const int,
		    void *);
extern int srtdb_get_info(const int, const char *, int *, int *, char [26]);
extern int srtdb_ma_get(const int, const char *, int *, int *, int *);
extern int srtdb_first(const int, const int, char *);
extern int srtdb_next(const int, const int, char *);
extern int srtdb_print(const int, const int);
extern int srtdb_delete(const int, const char *);
extern int srtdb_parallel(const int);

/*
  Following are 'sequential' versions of the above
  for internal use only
*/

extern int srtdb_seq_open(const char *, const char *, int *);
extern int srtdb_seq_copy(const int, const char *);
extern int srtdb_seq_getfname(const int,  char [36]);
extern int srtdb_seq_close(const int, const char *);
extern int srtdb_seq_put(const int, const char *, const int, const int, 
		    const void *);
extern int srtdb_seq_get(const int, const char *, const int, const int,
		    void *);
extern int srtdb_seq_get_info(const int, const char *, int *, int *, char [26]);
extern int srtdb_seq_ma_get(const int, const char *, int *, int *, int *);
extern int srtdb_seq_first(const int, const int, char *);
extern int srtdb_seq_next(const int, const int, char *);
extern int srtdb_seq_print(const int, const int);
extern int srtdb_seq_delete(const int, const char *);
#include "srtdb.cray.h"
#endif

