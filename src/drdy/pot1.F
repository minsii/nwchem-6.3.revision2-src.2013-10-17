C $Id: pot1.F 19708 2010-10-29 18:04:21Z d3y133 $
      Subroutine drdy_pot1 (x,v,dx,xs,amass,natom,ndim)
C
      Implicit none
C
#include "nwc_drdyP.fh"
C
      Integer natom,ndim
      Double Precision x(ndim),v,dx(ndim),xs(ndim),amass(ndim)
      Double Precision dummy
C
C Transform to cartesian coordinates
      Call drdy_trans (2,ndim,amass,x,dx)
C potential routine specific for NWChem
      Call nwc_gen (x,v,dx,dummy,dummy,xs,natom,ndim,1,1,
     &   DRDY_CODE_GRADIENT)
C  Transform coordinates and gradient to mass-weight cartesians
      Call drdy_trans (1,ndim,amass,x,dx)
C
      return
      end
