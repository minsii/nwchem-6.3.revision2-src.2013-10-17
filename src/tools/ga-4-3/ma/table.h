#ifndef _table_h
#define _table_h

/* 
 * $Id: table.h,v 1.3 1994-10-07 19:41:33 d3g681 Exp $
 */

/* 
 * Private header file containing symbolic constants and type declarations
 * for the table module.
 *
 * This file should only be included by internal C files.
 */

#include "matypes.h"

/**
 ** constants
 **/

/* invalid handle */
#define TABLE_HANDLE_NONE (Integer)(-1)

/**
 ** types
 **/

/* type of data in each table entry */
typedef char * TableData;

/**
 ** function types
 **/

extern Integer ma_table_allocate();
extern void ma_table_deallocate();
extern TableData ma_table_lookup();
extern Integer ma_table_lookup_assoc();
extern Boolean ma_table_verify();

#endif /* _table_h */
