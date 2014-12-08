*
* $Id: integrate_kbppv3_ray.f 19707 2010-10-29 17:59:36Z d3y133 $
*

      subroutine integrate_kbppv3_ray(version,rlocal,
     >                            nrho,drho,lmax,locp,zv,
     >                            vp,wp,rho,f,cs,sn,
     >                            nray,G_ray,vl_ray,vnl_ray,
     >                            semicore,rho_sc_r,rho_sc_k_ray,
     >                            ierr)
      implicit none
      integer          version
      double precision rlocal
      integer          nrho
      double precision drho
      integer          lmax
      integer          locp
      double precision zv
      double precision vp(nrho,0:lmax)
      double precision wp(nrho,0:lmax)
      double precision rho(nrho)
      double precision f(nrho)
      double precision cs(nrho)
      double precision sn(nrho)

      integer nray
      double precision G_ray(nray)
      double precision vl_ray(nray)
      double precision vnl_ray(nray,0:lmax)

      logical semicore
      double precision rho_sc_r(nrho,2)
      double precision rho_sc_k_ray(nray,2)
      integer ierr

      integer np,taskid,MASTER
      parameter (MASTER=0)

*     *** local variables ****
      integer task_count
      integer k1,i,l
      double precision pi,twopi,forpi
      double precision p0,p1,p2,p3,p
      double precision a,q,d

*     **** Error function parameters ****
      real*8 yerf,xerf

*     **** external functions ****
      double precision dsum,simp,util_erf
      external         dsum,simp,util_erf

      call Parallel_np(np)
      call Parallel_taskid(taskid)

      pi=4.0d0*datan(1.0d0)
      twopi=2.0d0*pi
      forpi=4.0d0*pi

      IF((NRHO/2)*2.EQ.NRHO) THEN
        IERR=2
        RETURN
      ENDIF

      P0=DSQRT(FORPI)
      P1=DSQRT(3.0d0*FORPI)
      P2=DSQRT(15.0d0*FORPI)
      P3=DSQRT(105.0d0*FORPI)

*======================  Fourier transformation  ======================
      call dcopy(nray,0.0d0,0,vl_ray,1)
      call dcopy((lmax+1)*nray,0.0d0,0,vnl_ray,1)
      call dcopy(2*nray,0.0d0,0,rho_sc_k_ray,1)
      task_count = -1
      DO 700 k1=2,nray
        task_count = task_count + 1
        if (mod(task_count,np).ne.taskid) go to 700

        Q=G_ray(k1)

        DO I=1,NRHO
          CS(I)=DCOS(Q*RHO(I))
          SN(I)=DSIN(Q*RHO(I))
        END DO

        GO TO (500,400,300,200), lmax+1


*::::::::::::::::::::::::::::::  f-wave  ::::::::::::::::::::::::::::::
  200   CONTINUE
        if (locp.ne.3) then
           F(1)=0.0d0
           do I=2,NRHO
             A=SN(I)/(Q*RHO(I))
             A=15.0d0*(A-CS(I))/(Q*RHO(I))**2 - 6*A + CS(I)
             F(I)=A*WP(I,3)*VP(I,3)
           end do
           D=P3*SIMP(NRHO,F,DRHO)/Q
           vnl_ray(k1,3)=D
        end if
*::::::::::::::::::::::::::::::  d-wave  ::::::::::::::::::::::::::::::
  300   CONTINUE
        if (locp.ne.2) then
          F(1)=0.0d0
          DO I=2,NRHO
            A=3.0d0*(SN(I)/(Q*RHO(I))-CS(I))/(Q*RHO(I))-SN(I)
            F(I)=A*WP(I,2)*VP(I,2)
          END DO
          D=P2*SIMP(NRHO,F,DRHO)/Q
          vnl_ray(k1,2)=D
        end if
*::::::::::::::::::::::::::::::  p-wave  ::::::::::::::::::::::::::::::
  400   CONTINUE
        if (locp.ne.1) then
           F(1)=0.0d0
           DO I=2,NRHO
             F(I)=(SN(I)/(Q*RHO(I))-CS(I))*WP(I,1)*VP(I,1)
           END DO
           P=P1*SIMP(NRHO,F,DRHO)/Q
           vnl_ray(k1,1)=P
        end if
*::::::::::::::::::::::::::::::  s-wave  :::::::::::::::::::::::::::::::
  500   CONTINUE
        if (locp.ne.0) then
          DO I=1,NRHO
            F(I)=SN(I)*WP(I,0)*VP(I,0)
          END DO
          vnl_ray(k1,0)=P0*SIMP(NRHO,F,DRHO)/Q
        end if

*::::::::::::::::::::::::::::::  local  :::::::::::::::::::::::::::::::
  600   CONTINUE


        if (version.eq.3) then
        DO  I=1,NRHO
          F(I)=RHO(I)*VP(I,locp)*SN(I)
        END DO
        vl_ray(k1)=SIMP(NRHO,F,DRHO)*FORPI/Q-ZV*FORPI*CS(NRHO)/(Q*Q)
        end if
 
        if (version.eq.4) then
        DO I=1,NRHO

          xerf=RHO(I)/rlocal
          yerf = util_erf(xerf)
          F(I)=(RHO(I)*VP(I,locp)+ZV*yerf)*SN(I)
        END DO
        vl_ray(k1)=SIMP(NRHO,F,DRHO)*FORPI/Q
        end if


*::::::::::::::::::::: semicore density :::::::::::::::::::::::::::::::
        if (semicore) then
           do i=1,nrho
              f(i) = rho(i)*dsqrt(rho_sc_r(i,1))*sn(i)
           end do
           rho_sc_k_ray(k1,1) = SIMP(nrho,f,drho)*forpi/Q

           do i=1,nrho
             f(i)=(sn(i)/(Q*rho(i))-cs(i))*rho_sc_r(i,2)*rho(i)
           end do
           P = SIMP(nrho,f,drho)*forpi/Q
           rho_sc_k_ray(k1,2)=P
        end if
    
  700 CONTINUE
      call Parallel_Vector_SumAll(2*nray,rho_sc_k_ray)
      call Parallel_Vector_SumAll(nray,vl_ray)
      call Parallel_Vector_Sumall((lmax+1)*nray,vnl_ray)

*:::::::::::::::::::::::::::::::  G=0  ::::::::::::::::::::::::::::::::      
      if (version.eq.3) then
      DO I=1,NRHO
        F(I)=VP(I,locp)*RHO(I)**2
      END DO
      vl_ray(1)=FORPI*SIMP(NRHO,F,DRHO)+TWOPI*ZV*RHO(NRHO)**2
      end if

      if (version.eq.4) then
      DO I=1,NRHO
        xerf=RHO(I)/rlocal
        yerf = util_erf(xerf)
        F(I)=(VP(I,locp)*RHO(I)+ZV*yerf)*RHO(I)
      END DO
      vl_ray(1)=FORPI*SIMP(NRHO,F,DRHO)
      end if

*     **** semicore density ****
      if (semicore) then
         do i=1,nrho
            f(i) = dsqrt(rho_sc_r(i,1))*rho(i)**2
         end do
         rho_sc_k_ray(1,1) = forpi*SIMP(nrho,f,drho)
         rho_sc_k_ray(1,2) = 0.0d0
      end if

      do l=0,lmax
        vnl_ray(1,l)=0.0d0
      end do
*     *** only j0 is non-zero at zero ****
      if (locp.ne.0) then
         DO  I=1,NRHO
           F(I)=RHO(I)*WP(I,0)*VP(I,0)
         END DO
         vnl_ray(1,0)=P0*SIMP(NRHO,F,DRHO)
      end if

      IERR=0
      RETURN
      END



