/*
 $Id: grids.h 22539 2012-06-01 15:40:16Z bylaska $
*/
#ifndef _GRID_H_
#define _GRID_H_
/* grid.h
   author - Eric Bylaska
*/

extern	void	init_Grids();
extern	void	end_Grids();
extern	double	*alloc_Grid();
extern	void	dealloc_Grid(double*);

#endif
