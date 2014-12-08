/*$Id: rjhtest.c 19708 2010-10-29 18:04:21Z d3y133 $*/
#include <stdio.h>
#include <sys/types.h>
#include <limits.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <db.h>
#include "rjhmisc.h"
#include <stdlib.h>
#include <string.h>

extern long my_random(void);
extern void my_srandom(unsigned);


DBT wrap_DBT(void *data, size_t size)
/*
  Make a DBT that refers to the region pointed to
  by the arguments .. NO MEMORY IS ALLOCATED
*/
{
  DBT tmp;

  tmp.data = data; tmp.size = size;

  return tmp;
}

DBT make_DBT(void *data, size_t size) 
/*
  Make a DBT by duplicating the data described
  by the arguments.
*/
{
  DBT tmp;

  tmp.size = 0; tmp.data = 0;
  
  if (size && data) {
    ALLOCATE(tmp.data, size, char, "make_DBT: tmp.data");
    memcpy(tmp.data, (void *) data, (int) size);
    tmp.size = size;
  }

  return tmp;
}

void print_hex_DBT(DBT d)
/*
  Print summary of DBT to stdout in hex
*/
{
  long len = (long) MIN(8, d.size);
  long i;
  unsigned char *ptr = (unsigned char *) d.data;

  printf("(%d, 0x%x, 0x",d.size, d.data);
  if (d.data) {
    for (i=0; i<len; i++) 
      printf("%2.2x", (unsigned) ptr[i]);
    if (len < d.size)
      printf(" ...");
  }
  printf(")");
  fflush(stdout);
}

void print_string_DBT(DBT d)
/*
  Prints DBT to stdout assuming a null terminated string.
*/
{
  long len = (long) MIN(8, d.size-1);

  (void) printf("(%ld, 0x%lx, \"",d.size, (unsigned long) d.data);
  if (d.data) {
    (void) printf("%.*s", len, (char *) d.data);
    if (len < (d.size-1))
      (void) printf("...");
  }
  (void) printf("\")");
  fflush(stdout);
}

DBT duplicate_DBT(DBT d)
/*
  Duplicate the DBT d, ALLOCATing space as required.
*/
{
  void *data = d.data;
  size_t size = d.size;
  DBT tmp;

  tmp.data = 0; tmp.size = 0;
  
  if (size && data) {
    ALLOCATE(tmp.data, size, char, "duplicate_DBT: data");
    memcpy(tmp.data, data, size);
    tmp.size = size;
  }

  return tmp;
}

void free_DBT(DBT d)
/*
  Free the memory pointed to by d.data, assumed to have
  got from ALLOCATE.
*/
{
  if (d.data)
    FREE(d.data);
}

int main(int argc, char *argv[])

{
  const char filename[] = "test.db";
  int nelem, ielem, loop;
  DB *db;
  HASHINFO openinfo;

  switch (argc) {
  case 1:
    nelem = 10000; break;
  case 2:
    nelem = atoi(argv[1]); break;
  default:
    (void) fprintf(stderr, "usage: rjhtest [nelem]\n");
    exit(1);
  }

  openinfo.bsize = 4096;
  openinfo.cachesize = 256*1024;
  openinfo.ffactor = 8;
  openinfo.hash = 0;
  openinfo.lorder = 0;
  openinfo.nelem = nelem;

  if (!(db = dbopen(filename, O_CREAT|O_TRUNC|O_RDWR, 0660, DB_HASH,
          &openinfo)))
    error("rjhtest: failed to open the data base\n", 0);

  /* Fill the data base with nelem arrays of random length */

  (void) printf("Inserting elements ..."); (void) fflush(stdout);
  my_srandom((unsigned) 98761);
  for (ielem=0; ielem<nelem; ielem++) {
    DBT key, value;
#define RECLEN (0xff)
/* 0x03ff */
    size_t len = RECLEN & (size_t) my_random();
    unsigned char data[RECLEN];
    int i, status;

    if ((ielem % (nelem/10)) == 0) {
      printf(" %d ", ielem);
      fflush(stdout);
    }

    for (i=0; i<len; i++) 
      data[i] = (unsigned char) (ielem + i);

    key   = wrap_DBT((void *) &ielem, sizeof(ielem));
    value = wrap_DBT((void *) data, (size_t) len);

    if (status = db->put(db, &key, &value, (u_int) 0)) {
      if (status == -1)
	{error("rjhtest: put failed for element %d\n", ielem);}
      else
	{error("rjhtest: put status=1 for element %d\n", ielem);}
    }
	
  }
  printf(" done\n");

  /* Retreive the elements at random and check the contents */

  (void) printf("Random access ..."); fflush(stdout);
  for (loop=0; loop < 3*nelem; loop++) {
    int ielem = (int) (my_random() % nelem);
    unsigned char *data;
    DBT key, value;
    int i, len;

    if ((loop % ((3*nelem)/10)) == 0) {
      printf(" %d ", loop);
      fflush(stdout);
    }

    key   = wrap_DBT((void *) &ielem, sizeof(ielem));
    if (db->get(db, &key, &value, (u_int) 0))
      error("rjhtest: get failed for element %d\n", ielem);

    data = (unsigned char *) value.data;
    len = (int) value.size;

    for (i=0; i<len; i++) 
      if (data[i] != (unsigned char) (ielem + i))
	error("rjhtest: get returned invalid element no. %d\n", ielem);
  }
  printf(" done\n");

  /* Retreive the elements sequentially and check the contents */

  (void) printf("Sequential access ..."); fflush(stdout);
  {
    DBT key, value;
    int icount=0, flags = R_FIRST, status;

    while ((status = db->seq(db, &key, &value, flags)) == 0) {
      unsigned char *data;
      int i, len, ielem;
      
      flags = R_NEXT;

      if ((icount % (nelem/10)) == 0) {
	printf(" %d ", icount);
	fflush(stdout);
      }

      data = (unsigned char *) value.data;
      len = (int) value.size;
      if (key.size != sizeof(ielem))
	error("rjhtest: key is wrong size=%d\n", (int) key.size);
      (void) memcpy(&ielem, key.data, key.size);

      for (i=0; i<len; i++) 
	if (data[i] != (unsigned char) (ielem + i))
	  error("rjhtest: get returned invalid element no. %d\n", ielem);

      icount++;
    }

    if (icount != nelem || status != 1) {
      fprintf(stderr, "rjhtest: icount=%d, nelem=%d\n", icount, nelem);
      error("rjhtest: seq failed, status=%d\n", status);
    }
  }

  printf(" done\n");

  /* Delete all the elements */

  (void) printf("Deleting elements ..."); fflush(stdout);
  for (ielem=0; ielem<nelem; ielem++) {
    DBT key = wrap_DBT((void *) &ielem, sizeof(ielem));
    
    if ((ielem % (nelem/10)) == 0) {
      printf(" %d ", ielem);
      fflush(stdout);
    }
    
    if (db->del(db, &key, (u_int) 0))
      error("rjhtest: del failed for element %d\n", ielem);
  }
  printf(" done\n");

  if (db->close(db))
    error("rjhtest: close failed\n", 0);

  return 0;
}


/* This just to keep things self contained */

/* $Header: /tmp/mss/nwchem/src/rtdb/db/rjhtest.c,v 1.1 1995-03-31 01:55:40 d3g681 Exp $ */

/*
 * Copyright (c) 1983 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)random.c	5.5 (Berkeley) 7/6/88";
#endif /* LIBC_SCCS and not lint */


/*
 * random.c:
 * An improved random number generation package.  In addition to the standard
 * rand()/srand() like interface, this package also has a special state info
 * interface.  The initstate() routine is called with a seed, an array of
 * bytes, and a count of how many bytes are being passed in; this array is then
 * initialized to contain information for random number generation with that
 * much state information.  Good sizes for the amount of state information are
 * 32, 64, 128, and 256 bytes.  The state can be switched by calling the
 * setstate() routine with the same array as was initiallized with initstate().
 * By default, the package runs with 128 bytes of state information and
 * generates far better random numbers than a linear congruential generator.
 * If the amount of state information is less than 32 bytes, a simple linear
 * congruential R.N.G. is used.
 * Internally, the state information is treated as an array of longs; the
 * zeroeth element of the array is the type of R.N.G. being used (small
 * integer); the remainder of the array is the state information for the
 * R.N.G.  Thus, 32 bytes of state information will give 7 longs worth of
 * state information, which will allow a degree seven polynomial.  (Note: the
 * zeroeth word of state information also has some other information stored
 * in it -- see setstate() for details).
 * The random number generation technique is a linear feedback shift register
 * approach, employing trinomials (since there are fewer terms to sum up that
 * way).  In this approach, the least significant bit of all the numbers in
 * the state table will act as a linear feedback shift register, and will have
 * period 2^deg - 1 (where deg is the degree of the polynomial being used,
 * assuming that the polynomial is irreducible and primitive).  The higher
 * order bits will have longer periods, since their values are also influenced
 * by pseudo-random carries out of the lower bits.  The total period of the
 * generator is approximately deg*(2**deg - 1); thus doubling the amount of
 * state information has a vast influence on the period of the generator.
 * Note: the deg*(2**deg - 1) is an approximation only good for large deg,
 * when the period of the shift register is the dominant factor.  With deg
 * equal to seven, the period is actually much longer than the 7*(2**7 - 1)
 * predicted by this formula.
 */



/*
 * For each of the currently supported random number generators, we have a
 * break value on the amount of state information (you need at least this
 * many bytes of state info to support this random number generator), a degree
 * for the polynomial (actually a trinomial) that the R.N.G. is based on, and
 * the separation between the two lower order coefficients of the trinomial.
 */

#define		TYPE_0		0		/* linear congruential */
#define		BREAK_0		8
#define		DEG_0		0
#define		SEP_0		0

#define		TYPE_1		1		/* x**7 + x**3 + 1 */
#define		BREAK_1		32
#define		DEG_1		7
#define		SEP_1		3

#define		TYPE_2		2		/* x**15 + x + 1 */
#define		BREAK_2		64
#define		DEG_2		15
#define		SEP_2		1

#define		TYPE_3		3		/* x**31 + x**3 + 1 */
#define		BREAK_3		128
#define		DEG_3		31
#define		SEP_3		3

#define		TYPE_4		4		/* x**63 + x + 1 */
#define		BREAK_4		256
#define		DEG_4		63
#define		SEP_4		1


/*
 * Array versions of the above information to make code run faster -- relies
 * on fact that TYPE_i == i.
 */

#define		MAX_TYPES	5		/* max number of types above */

static  int		degrees[ MAX_TYPES ]	= { DEG_0, DEG_1, DEG_2,
								DEG_3, DEG_4 };

static  int		seps[ MAX_TYPES ]	= { SEP_0, SEP_1, SEP_2,
								SEP_3, SEP_4 };



/*
 * Initially, everything is set up as if from :
 *		initstate( 1, &randtbl, 128 );
 * Note that this initialization takes advantage of the fact that my_srandom()
 * advances the front and rear pointers 10*rand_deg times, and hence the
 * rear pointer which starts at 0 will also end up at zero; thus the zeroeth
 * element of the state information, which contains info about the current
 * position of the rear pointer is just
 *	MAX_TYPES*(rptr - state) + TYPE_3 == TYPE_3.
 */

static  long		randtbl[ DEG_3 + 1 ]	= { TYPE_3,
			    0x9a319039, 0x32d9c024, 0x9b663182, 0x5da1f342,
			    0xde3b81e0, 0xdf0a6fb5, 0xf103bc02, 0x48f340fb,
			    0x7449e56b, 0xbeb1dbb0, 0xab5c5918, 0x946554fd,
			    0x8c2e680f, 0xeb3d799f, 0xb11ee0b7, 0x2d436b86,
			    0xda672e2a, 0x1588ca88, 0xe369735d, 0x904f35f7,
			    0xd7158fd6, 0x6fa6f051, 0x616e6b96, 0xac94efdc,
			    0x36413f93, 0xc622c298, 0xf5a42ab8, 0x8a88d77b,
					0xf5ad9d0e, 0x8999220b, 0x27fb47b9 };

/*
 * fptr and rptr are two pointers into the state info, a front and a rear
 * pointer.  These two pointers are always rand_sep places aparts, as they cycle
 * cyclically through the state information.  (Yes, this does mean we could get
 * away with just one pointer, but the code for random() is more efficient this
 * way).  The pointers are left positioned as they would be from the call
 *			initstate( 1, randtbl, 128 )
 * (The position of the rear pointer, rptr, is really 0 (as explained above
 * in the initialization of randtbl) because the state table pointer is set
 * to point to randtbl[1] (as explained below).
 */

static  long		*fptr			= &randtbl[ SEP_3 + 1 ];
static  long		*rptr			= &randtbl[ 1 ];



/*
 * The following things are the pointer to the state information table,
 * the type of the current generator, the degree of the current polynomial
 * being used, and the separation between the two pointers.
 * Note that for efficiency of random(), we remember the first location of
 * the state information, not the zeroeth.  Hence it is valid to access
 * state[-1], which is used to store the type of the R.N.G.
 * Also, we remember the last location, since this is more efficient than
 * indexing every time to find the address of the last element to see if
 * the front and rear pointers have wrapped.
 */

static  long		*state			= &randtbl[ 1 ];

static  int		rand_type		= TYPE_3;
static  int		rand_deg		= DEG_3;
static  int		rand_sep		= SEP_3;

static  long		*end_ptr		= &randtbl[ DEG_3 + 1 ];



/*
 * my_srandom:
 * Initialize the random number generator based on the given seed.  If the
 * type is the trivial no-state-information type, just remember the seed.
 * Otherwise, initializes state[] based on the given "seed" via a linear
 * congruential generator.  Then, the pointers are set to known locations
 * that are exactly rand_sep places apart.  Lastly, it cycles the state
 * information a given number of times to get rid of any initial dependencies
 * introduced by the L.C.R.N.G.
 * Note that the initialization of randtbl[] for default usage relies on
 * values produced by this routine.
 */

void my_srandom( x )

    unsigned		x;
{
    	register  int		i;
	long my_random();

	if(  rand_type  ==  TYPE_0  )  {
	    state[ 0 ] = x;
	}
	else  {
	    state[ 0 ] = x;
	    for( i = 1; i < rand_deg; i++ )  {
		state[i] = 1103515245*state[i - 1] + 12345;
	    }
	    fptr = &state[ rand_sep ];
	    rptr = &state[ 0 ];
	    for( i = 0; i < 10*rand_deg; i++ )  my_random();
	}
}



/*
 * initstate:
 * Initialize the state information in the given array of n bytes for
 * future random number generation.  Based on the number of bytes we
 * are given, and the break values for the different R.N.G.'s, we choose
 * the best (largest) one we can and set things up for it.  my_srandom() is
 * then called to initialize the state information.
 * Note that on return from my_srandom(), we set state[-1] to be the type
 * multiplexed with the current value of the rear pointer; this is so
 * successive calls to initstate() won't lose this information and will
 * be able to restart with setstate().
 * Note: the first thing we do is save the current state, if any, just like
 * setstate() so that it doesn't matter when initstate is called.
 * Returns a pointer to the old state.
 */

char  *
initstate( seed, arg_state, n )

    unsigned		seed;			/* seed for R. N. G. */
    char		*arg_state;		/* pointer to state array */
    int			n;			/* # bytes of state info */
{
	register  char		*ostate		= (char *)( &state[ -1 ] );

	if(  rand_type  ==  TYPE_0  )  state[ -1 ] = rand_type;
	else  state[ -1 ] = MAX_TYPES*(rptr - state) + rand_type;
	if(  n  <  BREAK_1  )  {
	    if(  n  <  BREAK_0  )  {
		fprintf( stderr, "initstate: not enough state (%d bytes) with which to do jack; ignored.\n", n );
		return 0;
	    }
	    rand_type = TYPE_0;
	    rand_deg = DEG_0;
	    rand_sep = SEP_0;
	}
	else  {
	    if(  n  <  BREAK_2  )  {
		rand_type = TYPE_1;
		rand_deg = DEG_1;
		rand_sep = SEP_1;
	    }
	    else  {
		if(  n  <  BREAK_3  )  {
		    rand_type = TYPE_2;
		    rand_deg = DEG_2;
		    rand_sep = SEP_2;
		}
		else  {
		    if(  n  <  BREAK_4  )  {
			rand_type = TYPE_3;
			rand_deg = DEG_3;
			rand_sep = SEP_3;
		    }
		    else  {
			rand_type = TYPE_4;
			rand_deg = DEG_4;
			rand_sep = SEP_4;
		    }
		}
	    }
	}
	state = &(  ( (long *)arg_state )[1]  );	/* first location */
	end_ptr = &state[ rand_deg ];	/* must set end_ptr before my_srandom */
	my_srandom( seed );
	if(  rand_type  ==  TYPE_0  )  state[ -1 ] = rand_type;
	else  state[ -1 ] = MAX_TYPES*(rptr - state) + rand_type;
	return( ostate );
}



/*
 * setstate:
 * Restore the state from the given state array.
 * Note: it is important that we also remember the locations of the pointers
 * in the current state information, and restore the locations of the pointers
 * from the old state information.  This is done by multiplexing the pointer
 * location into the zeroeth word of the state information.
 * Note that due to the order in which things are done, it is OK to call
 * setstate() with the same state as the current state.
 * Returns a pointer to the old state information.
 */

char  *
setstate( arg_state )

    char		*arg_state;
{
	register  long		*new_state	= (long *)arg_state;
	register  int		type		= new_state[0]%MAX_TYPES;
	register  int		rear		= new_state[0]/MAX_TYPES;
	char			*ostate		= (char *)( &state[ -1 ] );

	if(  rand_type  ==  TYPE_0  )  state[ -1 ] = rand_type;
	else  state[ -1 ] = MAX_TYPES*(rptr - state) + rand_type;
	switch(  type  )  {
	    case  TYPE_0:
	    case  TYPE_1:
	    case  TYPE_2:
	    case  TYPE_3:
	    case  TYPE_4:
		rand_type = type;
		rand_deg = degrees[ type ];
		rand_sep = seps[ type ];
		break;

	    default:
		fprintf( stderr, "setstate: state info has been munged; not changed.\n" );
	}
	state = &new_state[ 1 ];
	if(  rand_type  !=  TYPE_0  )  {
	    rptr = &state[ rear ];
	    fptr = &state[ (rear + rand_sep)%rand_deg ];
	}
	end_ptr = &state[ rand_deg ];		/* set end_ptr too */
	return( ostate );
}



/*
 * random:
 * If we are using the trivial TYPE_0 R.N.G., just do the old linear
 * congruential bit.  Otherwise, we do our fancy trinomial stuff, which is the
 * same in all ther other cases due to all the global variables that have been
 * set up.  The basic operation is to add the number at the rear pointer into
 * the one at the front pointer.  Then both pointers are advanced to the next
 * location cyclically in the table.  The value returned is the sum generated,
 * reduced to 31 bits by throwing away the "least random" low bit.
 * Note: the code takes advantage of the fact that both the front and
 * rear pointers can't wrap on the same call by not testing the rear
 * pointer if the front one has wrapped.
 * Returns a 31-bit random number.
 */

long
my_random()
{
	long		i;

	if(  rand_type  ==  TYPE_0  )  {
	    i = state[0] = ( state[0]*1103515245 + 12345 )&0x7fffffff;
	}
	else  {
	    *fptr += *rptr;
	    i = (*fptr >> 1)&0x7fffffff;	/* chucking least random bit */
	    if(  ++fptr  >=  end_ptr  )  {
		fptr = state;
		++rptr;
	    }
	    else  {
		if(  ++rptr  >=  end_ptr  )  rptr = state;
	    }
	}
	return( i );
}
/*  Added by RJH ... usual FORTRAN drand interface */

double drand_(flag)
    unsigned long *flag;
{
  if (*flag)
    my_srandom((unsigned) *flag);

  return ((double) my_random()) * 4.6566128752458e-10;
}
