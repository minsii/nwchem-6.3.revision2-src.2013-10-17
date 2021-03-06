      subroutine esp_esp(ene,occ,dns,x,q,grid,val)
c
c $Id: esp_esp.F 21090 2011-09-09 17:49:07Z d3y133 $
c
      implicit none
c
#include "esp_params.fh"
#include "esp_common.fh"
#include "global.fh"
#include "bas.fh"
#include "rtdb.fh"
#include "geom.fh"
#include "mafdecls.fh"
#include "msgids.fh"
#include "util.fh"
#include "schwarz.fh"
c
      integer ga_create_atom_blocked
      external ga_create_atom_blocked
c
      real*8 ene(2*nbf),occ(2*nbf),dns(mbf,mbf)
      real*8 x(3,natoms),q(natoms)
      real*8 grid(3,mxgrid),val(mxgrid)
c
      integer i,j,ish,jsh,ix
      integer ilo,ihi,jlo,jhi
      real*8 dist,vt
      integer imin,nval,jshi
      real*8 dmin,fact
      character*10 today,now
      logical ldummy(1)
c
c     calculate density matrix, occupation and energies
c
      call esp_denmat(occ,ene)
c
      if(lscrn.ne.0) call schwarz_init(igeom,ibasis)
c
c     get electrostatic potential on the grid points
c
      do 2 i=1,ngrid
      val(i)=0.0d0
    2 continue
c
      call hnd_elfcon(ibasis,igeom,lg_d,grid(1,1),ngrid,val(1),0)
      if(me.eq.0) then
      do 8 i=1,ngrid
         imin=0
         val(i)=-val(i)
         vt=val(i)
         do 9 ix=1,natoms
            dist=sqrt((grid(1,i)-x(1,ix))*(grid(1,i)-x(1,ix))+
     +          (grid(2,i)-x(2,ix))*(grid(2,i)-x(2,ix))+
     +          (grid(3,i)-x(3,ix))*(grid(3,i)-x(3,ix)))
            if(imin.eq.0) then
               dmin=dist
               imin=ix
            endif
            if(dmin.gt.dist) then
               dmin=dist
               imin=ix
            endif
            val(i)=val(i)+q(ix)/dist
    9    continue
    8 continue
      endif
c
      if(lscrn.ne.0) call schwarz_tidy()
      if(np.gt.1) then
      call ga_brdcst(mre_002,val,ngrid*ma_sizeof(mt_dbl,1,mt_byte),0)
      endif
c
c     deallocate memory for the integrals
c
      if(.not.ga_destroy(lg_d))
     + call md_abort('esp_denmat: ga_destroy lg_d failed',me)
c
c     integral termination
c
      call int_terminate()
c
      if(me.eq.0) then
      call util_file_name('grid',.false.,.false.,grdfil)
      open(unit=lfngrd,file=grdfil,form='formatted',status='unknown')
      rewind(lfngrd)
      write(lfngrd,'(i10,f20.10)') ngrid,charge
      do 10 i=1,ngrid
      write(lfngrd,'(4f20.10)') (grid(j,i),j=1,3),val(i)
   10 continue
      close(unit=lfngrd)
      endif
c
      return
      end
