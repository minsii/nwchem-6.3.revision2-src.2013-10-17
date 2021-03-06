      subroutine smd_ewald_init()
      implicit none
#include "errquit.fh"
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "util.fh"
#include "global.fh"
#include "smd_const_data.fh"
c
      character*32 sp_lat
      character*32 pname
      integer i_rl
      integer kmax(3)
      double precision alpha
      double precision ralphsq
      double precision rksqmax
      character*(smd_tag_size) namespace,tag

      logical result
c
      pname = "smd_ewald_init"
c
c      write(*,*) "in "//pname

c
      call smd_system_get_component(sp_lat,"lattice",result)
      if(.not.result) return
c
      call smd_ewald_rtdb_read(alpha,kmax)
c
      tag = "lat:rcell"
      call smd_get_ind(tag,i_rl,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)

      call smd_ewald_compute(ralphsq,rksqmax,alpha,kmax,dbl_mb(i_rl))
c      call smd_ewald_set_kmax(kmax)
c      call smd_ewald_set_alpha(alpha)
c      call smd_ewald_set_rksqmax(rksqmax)
c      call smd_ewald_set_ralphsq(ralphsq)

c      call smd_ewald_print(6)

      tag = "ewald"
      call smd_system_get_component(namespace,tag,result)
      if(.not.result)
     >  call errquit(
     >       pname//'no component '//tag,0,0)

      call smd_namespace_create(namespace)
     
      tag = "ewald:kmax"
      call smd_data_put_int(namespace,tag,3,kmax)
      tag = "ewald:alpha"
      call smd_data_put_dbl(namespace,tag,1,alpha)
      tag = "ewald:rksqmax"
      call smd_data_put_dbl(namespace,tag,1,rksqmax)
      tag = "ewald:ralphsq"
      call smd_data_put_dbl(namespace,tag,1,ralphsq)

      return
      end

      subroutine smd_ewald_rtdb_read(alpha,kmax)
      implicit none
#include "errquit.fh"
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "util.fh"
#include "global.fh"
c     
      double precision alpha
      integer kmax(3)
c
      character*32 pname
      character*80 tag
      logical result
c
      pname = "smd_ewald_rtdb_read"
c
c      write(*,*) "in "//pname
c
      tag = "smd:ewald"
      call smd_rtdb_get_dbl(tag,1,alpha,result)
      if (.not.result)
     >      call errquit(pname//'failed to get'//tag,0,
     >       RTDB_ERR)

      tag = "smd:kvec"
      call smd_rtdb_get_int(tag,3,kmax,result)
      if (.not.result)
     >      call errquit(pname//'failed to get'//tag,0,
     >       RTDB_ERR)


      return
      end

      subroutine smd_ewald_compute(ralphsq,rksqmax,alpha,kmax,rlatt)

      implicit none
#include "smd_const_data.fh"

      double precision ralphsq,rksqmax,alpha
      integer kmax(3)
      double precision rlatt(3,3)
c
      double precision axb1,axb2,axb3
      double precision bxc1,bxc2,bxc3
      double precision cxa1,cxa2,cxa3
      double precision xvector,yvector,zvector
      double precision rvol
      

      ralphsq=-0.25/alpha**2


      axb1=rlatt(2,1)*rlatt(3,2)-rlatt(3,1)*rlatt(2,2)
      axb2=rlatt(3,1)*rlatt(1,2)-rlatt(1,1)*rlatt(3,2)
      axb3=rlatt(1,1)*rlatt(2,2)-rlatt(2,1)*rlatt(1,2)
      bxc1=rlatt(2,2)*rlatt(3,3)-rlatt(3,2)*rlatt(2,3)
      bxc2=rlatt(3,2)*rlatt(1,3)-rlatt(1,2)*rlatt(3,3)
      bxc3=rlatt(1,2)*rlatt(2,3)-rlatt(2,2)*rlatt(1,3)
      cxa1=rlatt(2,3)*rlatt(3,1)-rlatt(2,1)*rlatt(3,3)
      cxa2=rlatt(1,1)*rlatt(3,3)-rlatt(3,1)*rlatt(1,3)
      cxa3=rlatt(2,1)*rlatt(1,3)-rlatt(1,1)*rlatt(2,3)

      rvol=abs(rlatt(1,1)*bxc1+rlatt(2,1)*bxc2+rlatt(3,1)*bxc3)

      xvector=rvol/sqrt(bxc1*bxc1+bxc2*bxc2+bxc3*bxc3)*kmax(1)
      yvector=rvol/sqrt(cxa1*cxa1+cxa2*cxa2+cxa3*cxa3)*kmax(2)
      zvector=rvol/sqrt(axb1*axb1+axb2*axb2+axb3*axb3)*kmax(3)

      rksqmax=min(xvector,yvector,zvector)
      rksqmax=rksqmax*1.05*twopi
      rksqmax=rksqmax**2

      return

      END

      subroutine smd_ewald_self()

      implicit none
#include "mafdecls.fh"
#include "errquit.fh"
#include "stdio.fh"
#include "smd_const_data.fh"
      double precision  ewald1
      integer i
      character*30 pname
      character*32 sp_charge
      character*32 tag
      integer i_q,nq
      double precision alpha
      logical result

      pname = "smd_ewald_self"

      tag = "charge"
      call smd_get_ind_dim(tag,i_q,nq,result)
      if(.not.result) then
       call smd_message_flush(luout)
       call errquit(
     >       pname//'no charge ',0,0)
      end if

      call smd_ewald_get_alpha(alpha)

      ewald1=0.0

      do i=1,nq

       ewald1=ewald1+dbl_mb(i_q+i-1)*dbl_mb(i_q+i-1)

      enddo

      ewald1=-convfct1*alpha*ewald1/sqrpi

      
      call smd_energy_set_component("ewald self",ewald1)

      return

      END

      subroutine smd_ewald_recip()

      implicit none
#include "mafdecls.fh"
#include "errquit.fh"
#include "smd_const_data.fh"
      double precision  ewald2
      character*30 pname
      character*32 tag
      integer i_q,nq
      integer h_eikx,i_eikx
      integer h_eiky,i_eiky
      integer h_eikz,i_eikz
      integer h_eikr,i_eikr
      integer i_f,i_c,i_rc
      double precision vol
      double precision rksqmax,ralphsq
      integer kmax(3)
      integer ntmp,nk
      logical result

      pname = "smd_ewald_recip"


c
c     get coord data
c     --------------
      tag = "coords"
      call smd_get_ind(tag,i_c,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get charge data
c     --------------
      tag = "charge"
      call smd_get_ind_dim(tag,i_q,nq,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get force data
c     --------------
      tag = "force"
      call smd_get_ind(tag,i_f,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get lattice data
c     ----------------
      tag = "lat:rcell"
      call smd_get_ind(tag,i_rc,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)

      call smd_latt_get_vol(vol)
c
c     get ewald data
c     --------------
      call smd_ewald_get_ralphsq(ralphsq)
      call smd_ewald_get_rksqmax(rksqmax)
      call smd_ewald_get_kmax(kmax)
 
      nk = max(kmax(1),kmax(2),kmax(3))
c
c    create temporary scratch array 
c    ---------------------------------------------
      ntmp = 2*(nk+1)*nq
      if(.not.ma_push_get(mt_dbl,ntmp,'tmp eikx',h_eikx,i_eikx))
     + call errquit(pname//'Failed to allocate memory ',
     + ntmp, MA_ERR)
      ntmp = 2*nq*(2*nk+1)
      if(.not.ma_push_get(mt_dbl,ntmp,'tmp eiky',h_eiky,i_eiky))
     + call errquit(pname//'Failed to allocate memory ',
     + ntmp, MA_ERR)
      ntmp = 2*nq*(2*nk+1)
      if(.not.ma_push_get(mt_dbl,ntmp,'tmp eikz',h_eikz,i_eikz))
     + call errquit(pname//'Failed to allocate memory ',
     + ntmp, MA_ERR)
      ntmp = 2*nq
      if(.not.ma_push_get(mt_dbl,ntmp,'tmp eikr',h_eikr,i_eikr))
     + call errquit(pname//'Failed to allocate memory ',
     + ntmp, MA_ERR)


      call  smd_ewald_recip_generic(
     >                          nq,
     >                          nk,
     >                          dbl_mb(i_eikr),
     >                          dbl_mb(i_eikx),
     >                          dbl_mb(i_eiky),
     >                          dbl_mb(i_eikz),
     >                          ralphsq,
     >                          rksqmax,
     >                          vol,
     >                          dbl_mb(i_rc),
     >                          kmax,
     >                          dbl_mb(i_c),
     >                          dbl_mb(i_q),
     >                          dbl_mb(i_f),
     >                          ewald2)


      if(.not.ma_pop_stack(h_eikr))
     & call errquit(pname//'Failed to deallocate stack',0,
     &       MA_ERR)

      if(.not.ma_pop_stack(h_eikz))
     & call errquit(pname//'Failed to deallocate stack',0,
     &       MA_ERR)


      if(.not.ma_pop_stack(h_eiky))
     & call errquit(pname//'Failed to deallocate stack',0,
     &       MA_ERR)

      if(.not.ma_pop_stack(h_eikx))
     & call errquit(pname//'Failed to deallocate stack',0,
     &       MA_ERR)

      call smd_energy_set_component("ewald reciprocal",ewald2)

      return

      END

      subroutine smd_ewald_excl()

      implicit none
#include "mafdecls.fh"
#include "errquit.fh"
#include "smd_const_data.fh"
      double precision  ewald2
      character*30 pname
      character*32 tag
      integer i_q,nq
      integer i_f,i_c,i_rlat
      integer i_lat
      integer i_l,i_p
      integer nl
      double precision vol
      double precision alpha
      double precision rcutsq
      integer kmax(3)
      integer ntmp,nk
      logical result

      pname = "smd_ewald_excl"


      ewald2 = 0.0d0
c
c     get components
c     --------------
c
c     get exluded list data
c     ---------------------
      tag = "exlist:pointer"
      call smd_get_ind(tag,i_p,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)

      tag = "exlist:list"
      call smd_get_ind_dim(tag,i_l,nl,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for'//tag,0, RTDB_ERR)
       if(nl.eq.0) return

c
c     get coord data
c     --------------
      tag = "coords"
      call smd_get_ind(tag,i_c,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get charge data
c     --------------
      tag = "charge"
      call smd_get_ind_dim(tag,i_q,nq,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get force data
c     --------------
      tag = "force"
      call smd_get_ind(tag,i_f,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get lattice data
c     ----------------
      tag = "lat:rcell"
      call smd_get_ind(tag,i_rlat,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)

      tag = "lat:cell"
      call smd_get_ind(tag,i_lat,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)


      call smd_latt_get_vol(vol)

c
c     get ewald data
c     --------------
      call smd_ewald_get_alpha(alpha)
c
c     get cutoff data
c     ---------------
      call smd_cutoff_get_rcut(rcutsq)
      rcutsq = rcutsq*rcutsq

      call       smd_ewald_excl_generic(nq,
     >                                  nl,
     >                                  alpha,
     >                                  rcutsq,
     >                                  dbl_mb(i_lat),
     >                                  dbl_mb(i_rlat),
     >                                  dbl_mb(i_q),
     >                                  dbl_mb(i_c),
     >                                  dbl_mb(i_f),
     >                                  int_mb(i_p),
     >                                  int_mb(i_l),
     >                                  ewald2)

      call smd_energy_set_component("ewald excluded",ewald2)
      return

      END

      subroutine smd_ewald_real()

      implicit none
#include "mafdecls.fh"
#include "errquit.fh"
#include "smd_const_data.fh"
      double precision  ewald2
      character*30 pname
      character*32 sp_charge
      character*32 sp_lattice
      character*32 sp_force
      character*32 sp_vlist
      character*32 sp
      character*32 tag
      integer i_q,nq
      integer i_f,i_c,i_rlat
      integer i_lat
      integer i_l,i_p
      integer nl
      double precision vol
      double precision alpha
      double precision rcutsq
      integer kmax(3)
      integer ntmp,nk
      logical result

      pname = "smd_ewald_real"


      ewald2 = 0.0d0
c
c     get components
c     --------------
      call smd_system_get_component(sp_charge,"charge",result)
      if(.not.result)
     >  call errquit(
     >       pname//'no charge ',0,0)

      call smd_system_get_component(sp_force,"force",result)
      if(.not.result)
     >  call errquit(
     >       pname//'no force ',0,0)

      call smd_system_get_component(sp_vlist,"verlet_list",result)
      if(.not.result)
     >  call errquit(
     >       pname//'no verlet_list ',0,0)

c
c     get verlet list data
c     --------------------
      tag = "vlist:pointer"
      call smd_get_ind(tag,i_p,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)

      tag = "vlist:list"
      call smd_get_ind_dim(tag,i_l,nl,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for'//tag,0, RTDB_ERR)
       if(nl.eq.0) return

      tag = "vlist:distances"
      call smd_get_ind(tag,i_c,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for'//tag,0, RTDB_ERR)


c
c     get charge data
c     --------------
      tag = "charge"
      call smd_get_ind_dim(tag,i_q,nq,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get force data
c     --------------
      tag = "force"
      call smd_get_ind(tag,i_f,result)
      if(.not. result) 
     >  call errquit(
     >       pname//'error getting index for '//tag,0, RTDB_ERR)
c
c     get ewald data
c     --------------
      call smd_ewald_get_alpha(alpha)
c
c     get cutoff data
c     ---------------
      call smd_cutoff_get_rcut(rcutsq)
      rcutsq = rcutsq*rcutsq

      call       smd_ewald_real_generic(nq,
     >                                  nl,
     >                                  alpha,
     >                                  rcutsq,
     >                                  dbl_mb(i_q),
     >                                  dbl_mb(i_c),
     >                                  dbl_mb(i_f),
     >                                  int_mb(i_p),
     >                                  int_mb(i_l),
     >                                  ewald2)

      
      call smd_energy_set_component("ewald real",ewald2)
      return

      END

      subroutine smd_ewald_get_alpha(alpha)
      implicit none
#include "errquit.fh"
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "util.fh"
#include "global.fh"
#include "smd_const_data.fh"
      double precision  alpha
c
      character*32 pname
      character*(smd_tag_size) namespace,tag
      logical result
c
      tag = "ewald"
      call smd_system_get_component(namespace,tag,result)
      if(.not.result)
     >  call errquit(
     >       pname//'no component '//tag,0,0)

      tag = "ewald:alpha"
      call smd_data_get_dbl(namespace,tag,1,alpha,result)
      if(.not.result)
     >  call errquit('no data '//tag,0,0)

      return
      end

      subroutine smd_ewald_get_ralphsq(ralphsq)
      implicit none
#include "errquit.fh"
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "util.fh"
#include "global.fh"
#include "smd_const_data.fh"
      double precision ralphsq
c
      character*32 pname
      character*(smd_tag_size) namespace,tag
      logical result
c
      tag = "ewald"
      call smd_system_get_component(namespace,tag,result)
      if(.not.result)
     >  call errquit(
     >       pname//'no component '//tag,0,0)

      tag = "ewald:ralphsq"
      call smd_data_get_dbl(namespace,tag,1,ralphsq,result)
      if(.not.result)
     >  call errquit('no data '//tag,0,0)

      return
      end

      subroutine smd_ewald_get_rksqmax(rksqmax)
      implicit none
#include "errquit.fh"
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "util.fh"
#include "global.fh"
#include "smd_const_data.fh"
      double precision rksqmax
c
      character*32 pname
      character*(smd_tag_size) namespace,tag
      logical result
c
      tag = "ewald"
      call smd_system_get_component(namespace,tag,result)
      if(.not.result)
     >  call errquit(
     >       pname//'no component '//tag,0,0)

      tag = "ewald:rksqmax"
      call smd_data_get_dbl(namespace,tag,1,rksqmax,result)
      if(.not.result)
     >  call errquit('no data '//tag,0,0)

      return
      end

      subroutine smd_ewald_get_kmax(kmax)
      implicit none
#include "errquit.fh"
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "util.fh"
#include "global.fh"
#include "smd_const_data.fh"
      integer kmax(3)
c
      character*32 pname
      character*(smd_tag_size) namespace,tag
      logical result
c
      tag = "ewald"
      call smd_system_get_component(namespace,tag,result)
      if(.not.result)
     >  call errquit(
     >       pname//'no component '//tag,0,0)

      tag = "ewald:kmax"
      call smd_data_get_int(namespace,tag,3,kmax,result)
      if(.not.result)
     >  call errquit('no data '//tag,0,0)

      return
      end

c $Id: smd_ewald.F 22502 2012-05-20 06:11:57Z d3y133 $
