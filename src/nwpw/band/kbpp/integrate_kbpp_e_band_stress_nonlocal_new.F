*
* $Id: integrate_kbpp_e_band_stress_nonlocal_new.F 22503 2012-05-20 06:58:57Z d3y133 $
*

*     **********************************************
*     *                                            *
*     *   integrate_kbpp_e_band_stress_nonlocal_new  *
*     *                                            *
*     **********************************************

      subroutine integrate_kbpp_e_band_stress_nonlocal_new(version,kvec,
     >                            nrho,drho,lmax,locp,nmax,
     >                            n_extra,n_expansion,zv,
     >                            vp,wp,rho,f,cs,sn,
     >                            nfft1,nfft2,nfft3,nprj,
     >                            G,dvnl,
     >                            nray,G_ray,dvnl_ray,
     >                            ierr)
      implicit none
      integer          version
      double precision kvec(3)
      integer          nrho
      double precision drho
      integer          lmax
      integer          locp
      integer          nmax
      integer          n_extra,n_expansion(0:lmax)
      double precision zv
      double precision vp(nrho,0:lmax)
      double precision wp(nrho,0:(lmax+n_extra))
      double precision rho(nrho)
      double precision f(nrho)
      double precision cs(nrho)
      double precision sn(nrho)

      integer nfft1,nfft2,nfft3,nprj
      double precision G(nfft1,nfft2,nfft3,3)
      double precision dvnl(nfft1,nfft2,nfft3,3,nprj)

      integer nray
      double precision G_ray(nray)
      double precision dvnl_ray(nray,2,0:(lmax+n_extra),2)

      integer ierr

#include "errquit.fh"

*     *** local variables ****
      integer np,taskid,MASTER
      parameter (MASTER=0)

      integer lcount,task_count,nfft3d
      integer k1,k2,k3,i,l,nx,n,nb
      double precision p,pp
      double precision gx,gy,gz,q,d,dd
      double precision duxdGx,duxdGy,duxdGz
      double precision duydGx,duydGy,duydGz
      double precision duzdGx,duzdGy,duzdGz
      double precision sumx,sumy,sumz,dG
      double precision T,dTdux,dTduy,dTduz
      integer indx(5,0:3)

*     **** external functions ****
      double precision dsum,simp,nwpw_splint
      external         dsum,simp,nwpw_splint

*     **** set up indx(n,l) --> to wp ****
      nb = lmax+1
      do l=0,lmax
         indx(1,l) = l
         do n=2,n_expansion(l)
            indx(n,l) = nb
            nb = nb+1
         end do
      end do

      call Parallel_np(np)
      call Parallel_taskid(taskid)

      if(lmax.gt.3) then
         call errquit(
     >    'integrate_kbpp_band_stress_nonlocal_new - lmax > f',0,
     >       INPUT_ERR)
      end if
      if((nrho/2)*2.eq.nrho) then
        call errquit(
     >  'integrate_kbpp_band_stress_nonlocal_new - psp grid not odd',0,
     >       INPUT_ERR)
      end if

      nfft3d = (nfft1)*nfft2*nfft3

*======================  Fourier transformation  ======================
      dG = G_ray(3)-G_ray(2)
      call dcopy(3*nprj*nfft3d,0.0d0,0,dvnl,1)
      task_count = -1
      do 700 k3=1,nfft3
      do 700 k2=1,nfft2
      do 700 k1=1,nfft1
        task_count = task_count + 1
        if (mod(task_count,np).ne.taskid) go to 700
        gx=G(k1,k2,k3,1)+kvec(1)
        gy=G(k1,k2,k3,2)+kvec(2)
        gz=G(k1,k2,k3,3)+kvec(3)

        q=dsqrt(gx**2 + gy**2 + gz**2)
        nx = (q/dG) + 1.0d0

        if (dabs(q).gt.1.0d-9) then

           gx=gx/q
           gy=gy/q
           gz=gz/q
           do i=1,nrho
             cs(i)=dcos(q*rho(i))
             sn(i)=dsin(q*rho(i))
           end do

*          **** calculate du_r/dG_s ****
           duxdGx = 1.0d0/q -gx*gx/q
           duxdGy = -gx*gy/q
           duxdGz = -gx*gz/q

           duydGx = -gy*gx/q
           duydGy = 1.0d0/q - gy*gy/q
           duydGz = -gy*gz/q

           duzdGx = -gz*gx/q
           duzdGy = -gz*gy/q
           duzdGz = 1.0d0/q - gz*gz/q

           lcount = nprj+1
           GO TO (500,400,300,200), LMAX+1

*::::::::::::::::::::::::::::::  f-wave  ::::::::::::::::::::::::::::::
  200      CONTINUE
        if (locp.ne.3) then
           do n=1,n_expansion(3)
           D  = nwpw_splint(G_ray,dvnl_ray(1,1,indx(n,3),1),
     >                            dvnl_ray(1,1,indx(n,3),2),nray,nx,Q)
           DD = nwpw_splint(G_ray,dvnl_ray(1,2,indx(n,3),1),
     >                            dvnl_ray(1,2,indx(n,3),2),nray,nx,Q)
           lcount = lcount-1
           T = gx*(4.0d0*gx*gx - 3.0d0*(1.0d0-gz*gz))/dsqrt(24.0d0)
           dTdux = (12.0d0*gx*gx-3.0d0*(1.0d0-gz*gz))/dsqrt(24.0d0)
           dTduy = 0.0d0
           dTduz = 6.0d0*gx*gz/dsqrt(24.0d0)
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
           dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
           dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

           lcount = lcount-1
           T = gy*(3.0d0*(1.0d0-gz*gz)-4.0d0*gy*gy)/dsqrt(24.0d0)
           dTdux = 0.0d0
           dTduy = (3.0d0*(1.0d0-gz*gz)-12.0d0*gy*gy)/dsqrt(24.0d0)
           dTduz = -6.0d0*gy*gz/dsqrt(24.0d0)
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
           dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
           dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

           lcount = lcount-1
           T =gz*(gx*gx - gy*gy)/2.0d0
           dTdux =  gx*gz
           dTduy = -gy*gz
           dTduz = (gx*gx-gy*gy)/2.0d0
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
           dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
           dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

           lcount = lcount-1
           T =gx*gy*gz
           dTdux = gy*gz
           dTduy = gx*gz
           dTduz = gx*gy
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
           dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
           dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

           lcount = lcount-1
           T =  gx*(5.0d0*gz*gz-1.0d0)/dsqrt(40.0d0)
           dTdux = (5.0d0*gz*gz-1.0d0)/dsqrt(40.0d0)
           dTduy = 0.0d0
           dTduz = 10.0d0*gx*gz/dsqrt(40.0d0)
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
           dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
           dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

           lcount = lcount-1
           T = gy*(5.0d0*gz*gz-1.0d0)/dsqrt(40.0d0)
           dTdux = 0.0d0
           dTduy =(5.0d0*gz*gz-1.0d0)/dsqrt(40.0d0)
           dTduz =10.0d0*gy*gz/dsqrt(40.0d0)
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
           dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
           dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

           lcount = lcount-1
           T =gz*(5.0d0*gz*gz-3.0d0)/dsqrt(60.0d0)
           dTdux = 0.0d0
           dTduy = 0.0d0
           dTduz =(15.0d0*gz*gz -3.0d0)/dsqrt(60.0d0)
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
           dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
           dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz
           end do
        end if
*::::::::::::::::::::::::::::::  d-wave  ::::::::::::::::::::::::::::::
  300      CONTINUE
        if (locp.ne.2) then
          do n=1,n_expansion(2) 
          D  = nwpw_splint(G_ray,dvnl_ray(1,1,indx(n,2),1),
     >                           dvnl_ray(1,1,indx(n,2),2),nray,nx,Q)
          DD = nwpw_splint(G_ray,dvnl_ray(1,2,indx(n,2),1),
     >                           dvnl_ray(1,2,indx(n,2),2),nray,nx,Q)
          lcount = lcount-1
          T = (3.0d0*gz*gz-1.0d0)/(2.0d0*dsqrt(3.0d0))
          dTdux = 0.0d0
          dTduy = 0.0d0
          dTduz = 6.0d0*gz/(2.0d0*dsqrt(3.0d0))
          sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
          sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
          sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
          dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
          dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
          dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

          lcount = lcount-1
          T = gx*gy
          dTdux = gy
          dTduy = gx
          dTduz = 0.0d0
          sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
          sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
          sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
          dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
          dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
          dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

          lcount = lcount-1
          T = gy*gz
          dTdux = 0.0d0
          dTduy = gz
          dTduz = gy
          sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
          sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
          sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
          dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
          dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
          dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

          lcount = lcount-1
          T = gz*gx
          dTdux = gz
          dTduy = 0.0d0
          dTduz = gx
          sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
          sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
          sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
          dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
          dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
          dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz

          lcount = lcount-1
          T = (gx*gx-gy*gy)/2.0d0
          dTdux = gx
          dTduy = -gy
          dTduz = 0.0d0
          sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
          sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
          sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
          dvnl(k1,k2,k3,1,lcount)=DD*T*gx + D*sumx
          dvnl(k1,k2,k3,2,lcount)=DD*T*gy + D*sumy
          dvnl(k1,k2,k3,3,lcount)=DD*T*gz + D*sumz
          end do
        end if
*::::::::::::::::::::::::::::::  p-wave  ::::::::::::::::::::::::::::::
  400      CONTINUE
        if (locp.ne.1) then
           do n=1,n_expansion(1)
           P  = nwpw_splint(G_ray,dvnl_ray(1,1,indx(n,1),1),
     >                            dvnl_ray(1,1,indx(n,1),2),nray,nx,Q)
           PP = nwpw_splint(G_ray,dvnl_ray(1,2,indx(n,1),1),
     >                            dvnl_ray(1,2,indx(n,1),2),nray,nx,Q)
           lcount = lcount-1
           T = gx
           dTdux = 1.0d0
           dTduy = 0.0d0
           dTduz = 0.0d0
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)= PP*T*gx + P*sumx
           dvnl(k1,k2,k3,2,lcount)= PP*T*gy + P*sumy
           dvnl(k1,k2,k3,3,lcount)= PP*T*gz + P*sumz

           lcount = lcount-1
           T = gy
           dTdux = 0.0d0
           dTduy = 1.0d0
           dTduz = 0.0d0
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)= PP*T*gx + P*sumx
           dvnl(k1,k2,k3,2,lcount)= PP*T*gy + P*sumy
           dvnl(k1,k2,k3,3,lcount)= PP*T*gz + P*sumz

           lcount = lcount-1
           T = gz
           dTdux = 0.0d0
           dTduy = 0.0d0
           dTduz = 1.0d0
           sumx = dTdux*duxdGx + dTduy*duydGx + dTduz*duzdGx
           sumy = dTdux*duxdGy + dTduy*duydGy + dTduz*duzdGy
           sumz = dTdux*duxdGz + dTduy*duydGz + dTduz*duzdGz
           dvnl(k1,k2,k3,1,lcount)= PP*T*gx + P*sumx
           dvnl(k1,k2,k3,2,lcount)= PP*T*gy + P*sumy
           dvnl(k1,k2,k3,3,lcount)= PP*T*gz + P*sumz
           end do
        end if
*::::::::::::::::::::::::::::::  s-wave  :::::::::::::::::::::::::::::::
  500      CONTINUE
        if (locp.ne.0) then
          do n=1,n_expansion(0)
          P  = nwpw_splint(G_ray,dvnl_ray(1,1,indx(n,0),1),
     >                           dvnl_ray(1,1,indx(n,0),2),nray,nx,Q)
          lcount = lcount-1
          dvnl(k1,k2,k3,1,lcount) = P *gx
          dvnl(k1,k2,k3,2,lcount) = P *gy
          dvnl(k1,k2,k3,3,lcount) = P *gz
          end do
        end if


  600      CONTINUE
*:::::::::::::::::::::::::::::::  G+k=0  ::::::::::::::::::::::::::::::::      
      else

        do l=1,nprj
          dvnl(1,1,1,1,l)=0.0d0
          dvnl(1,1,1,2,l)=0.0d0
          dvnl(1,1,1,3,l)=0.0d0
        end do

       end if
    
  700 CONTINUE
      call Parallel_Vector_Sumall(3*nprj*nfft3d,dvnl)

      ierr=0
      return
      end



