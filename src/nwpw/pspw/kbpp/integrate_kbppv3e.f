*
* $Id: integrate_kbppv3e.f 22503 2012-05-20 06:58:57Z d3y133 $
*

      subroutine integrate_kbppv3e(version,rlocal,
     >                            nrho,drho,lmax,locp,nmax,
     >                            n_extra,n_expansion,zv,
     >                            vp,wp,rho,f,cs,sn,
     >                            nfft3d,nprj,
     >                            G,vl,vnl,
     >                            n_prj,l_prj,m_prj,b_prj,vnlnrm,
     >                            semicore,rho_sc_r,rho_sc_k,
     >                            ierr)
      implicit none
      integer          version
      double precision rlocal
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

      integer nfft3d,nprj
      double precision G(nfft3d,3)
      double precision vl(nfft3d)
      double precision vnl(nfft3d,nprj)
      integer          n_prj(nprj),l_prj(nprj),m_prj(nprj)
      integer          b_prj(nprj)
      double precision vnlnrm(nmax,nmax,0:lmax)

      logical semicore
      double precision rho_sc_r(nrho,2)
      double precision rho_sc_k(nfft3d,4)

      integer ierr

      integer np,taskid,MASTER
      integer np_i,np_j,taskid_i,taskid_j,countj
      parameter (MASTER=0)

*     *** local variables ****
      integer lcount,info
      integer k1,k2,k3,i,j,l,pzero,zero,n,nb,n1,n2
      double precision pi,twopi,forpi
      double precision p0,p1,p2,p3,p
      double precision gx,gy,gz,a,q,d
      integer indx(5,0:3)

*     **** Error function parameters ****
      real*8 yerf,xerf

*     **** external functions ****
      double precision dsum,simp,util_erf
      external         dsum,simp,util_erf

*     **** set up indx(n,l) --> to wp ****
      nb = lmax+1
      do l=0,lmax
         indx(1,l) = l
         do n=2,n_expansion(l)
            indx(n,l) = nb
            nb = nb+1
         end do
      end do

      call Parallel2d_np_i(np_i)
      call Parallel2d_np_j(np_j)
      call Parallel2d_taskid_i(taskid_i)
      call Parallel2d_taskid_j(taskid_j)

      pi=4.0d0*datan(1.0d0)
      twopi=2.0d0*pi
      forpi=4.0d0*pi

      if (lmax.gt.3) then
        ierr=1
        return
      end if
      if ((nrho/2)*2.eq.nrho) then
        ierr=2
        return
      end if

      P0=DSQRT(FORPI)
      P1=DSQRT(3.0d0*FORPI)
      P2=DSQRT(15.0d0*FORPI)
      P3=DSQRT(105.0d0*FORPI)

*::::::::::::::::::  Define non-local pseudopotential  ::::::::::::::::
      do l=0,lmax
        if (l.ne.locp) then
          do I=1,nrho
            vp(i,l)=vp(i,l)-vp(i,locp)
          end do
        end if
      end do

*:::::::::::::::::::::  Normarization constants  ::::::::::::::::::::::
      lcount = 0
      do l=0,lmax
        if (l.eq.locp) then
           do n2 = 1, n_expansion(l)
           do n1 = n2,n_expansion(l)
              vnlnrm(n1,n2,l) = 0.0d0
              vnlnrm(n2,n1,l) = 0.0d0
           end do
           end do
        else
           do n2 = 1, n_expansion(l)
              do i=1,nrho
                 f(i)=vp(i,l)*wp(i,indx(n2,l))**2
              end do   
              a=simp(nrho,f,drho)
              vnlnrm(n2,n2,l) = a
              do n1 = n2+1,n_expansion(l)
                 do i=1,nrho
                    f(i)=vp(i,l)*wp(i,indx(n1,l))*wp(i,indx(n2,l))
                 end do   
                 a=simp(nrho,f,drho)
                 vnlnrm(n1,n2,l) = a
                 vnlnrm(n2,n1,l) = a
              end do
           end do
           if (n_expansion(l).eq.1) then
              vnlnrm(1,1,l) = 1/a
           else if (n_expansion(l).eq.2) then
              d = vnlnrm(1,1,l)*vnlnrm(2,2,l) 
     >          - vnlnrm(1,2,l)*vnlnrm(2,1,l)
              q = vnlnrm(1,1,l)
              vnlnrm(1,1,l) = vnlnrm(2,2,l)/d
              vnlnrm(2,2,l) = q/d
              vnlnrm(1,2,l) = -vnlnrm(1,2,l)/d
              vnlnrm(2,1,l) = -vnlnrm(2,1,l)/d
           else 
              call nwpw_matrix_invert(n_expansion(l),vnlnrm(1,1,l),nmax)
           end if
        end if
      end do

*======================  Fourier transformation  ======================
      call dcopy(nfft3d,0.0d0,0,vl,1)
      call dcopy(nprj*nfft3d,0.0d0,0,vnl,1)
      call dcopy(4*nfft3d,0.0d0,0,rho_sc_k,1)

*     ***** find the G==0 point in the lattice *****
      call D3dB_ijktoindexp(1,1,1,1,zero,pzero)
      
      countj = -1
      DO 700 k1=1,nfft3d

        countj = mod(countj+1,np_j)

        if (countj.ne.taskid_j) go to 700
        if ((pzero.eq.taskid_i).and.(k1.eq.zero)) go to 700

        Q=DSQRT(G(k1,1)**2
     >         +G(k1,2)**2
     >         +G(k1,3)**2)

        
        GX=G(k1,1)/Q
        GY=G(k1,2)/Q
        GZ=G(k1,3)/Q
        DO I=1,NRHO
          CS(I)=DCOS(Q*RHO(I))
          SN(I)=DSIN(Q*RHO(I))
        END DO

        lcount = nprj+1
        GO TO (500,400,300,200), LMAX+1


*::::::::::::::::::::::::::::::  f-wave  ::::::::::::::::::::::::::::::
  200   CONTINUE
        if (locp.ne.3) then
           do n=1,n_expansion(3)
              F(1)=0.0d0
              do I=2,NRHO
                A=SN(I)/(Q*RHO(I))
                A=15.0d0*(A-CS(I))/(Q*RHO(I))**2 - 6*A + CS(I)
                F(I)=A*WP(I,indx(n,3))*VP(I,3)
              end do
              D=P3*SIMP(NRHO,F,DRHO)/Q

              lcount = lcount-1
              vnl(k1,lcount)=D*GY*(3.0d0*(1.0d0-GZ*GZ)-4.0d0*GY*GY)
     >                             /dsqrt(24.0d0)
              lcount = lcount-1
              vnl(k1,lcount)=D*GX*GY*GZ
              lcount = lcount-1
              vnl(k1,lcount)=D*GY*(5.0d0*GZ*GZ-1.0d0)
     >                             /dsqrt(40.0d0)
              lcount = lcount-1
              vnl(k1,lcount)=D*GZ*(5.0d0*GZ*GZ-3.0d0)
     >                             /dsqrt(60.0d0)
              lcount = lcount-1
              vnl(k1,lcount)=D*GX*(5.0d0*GZ*GZ-1.0d0)
     >                             /dsqrt(40.0d0)
              lcount = lcount-1
              vnl(k1,lcount)=D*GZ*(GX*GX - GY*GY)
     >                             /2.0d0
              lcount = lcount-1
              vnl(k1,lcount)=D*GX*(4.0d0*GX*GX-3.0d0*(1.0d0-GZ*GZ))
     >                             /dsqrt(24.0d0)
           end do
        end if



*::::::::::::::::::::::::::::::  d-wave  ::::::::::::::::::::::::::::::
  300   CONTINUE
        if (locp.ne.2) then
          do n=1,n_expansion(2)
             F(1)=0.0d0
             DO I=2,NRHO
               A=3.0d0*(SN(I)/(Q*RHO(I))-CS(I))/(Q*RHO(I))-SN(I)
               F(I)=A*WP(I,indx(n,2))*VP(I,2)
             END DO
             D=P2*SIMP(NRHO,F,DRHO)/Q

             lcount = lcount-1
             vnl(k1,lcount)=D*GX*GY
             lcount = lcount-1
             vnl(k1,lcount)=D*GY*GZ
             lcount = lcount-1
             vnl(k1,lcount)=D*(3.0d0*GZ*GZ-1.0d0)
     >                             /(2.0d0*dsqrt(3.0d0))
             lcount = lcount-1
             vnl(k1,lcount)=D*GZ*GX
             lcount = lcount-1
             vnl(k1,lcount)=D*(GX*GX-GY*GY)/(2.0d0)
          end do
        end if

*::::::::::::::::::::::::::::::  p-wave  ::::::::::::::::::::::::::::::
  400   CONTINUE
        if (locp.ne.1) then
           do n=1,n_expansion(1)
              F(1)=0.0d0
              DO I=2,NRHO
                F(I)=(SN(I)/(Q*RHO(I))-CS(I))*WP(I,indx(n,1))*VP(I,1)
              END DO
              P=P1*SIMP(NRHO,F,DRHO)/Q
              lcount = lcount-1
              vnl(k1,lcount)=P*GY
              lcount = lcount-1
              vnl(k1,lcount)=P*GZ
              lcount = lcount-1
              vnl(k1,lcount)=P*GX
           end do
        end if

*::::::::::::::::::::::::::::::  s-wave  :::::::::::::::::::::::::::::::
  500   CONTINUE
        if (locp.ne.0) then
          do n=1,n_expansion(0)
             DO I=1,NRHO
               F(I)=SN(I)*WP(I,indx(n,0))*VP(I,0)
             END DO
             lcount = lcount-1
             vnl(k1,lcount)=P0*SIMP(NRHO,F,DRHO)/Q
          end do
        end if

*::::::::::::::::::::::::::::::  local  :::::::::::::::::::::::::::::::
  600   CONTINUE


        if (version.eq.3) then
        DO  I=1,NRHO
          F(I)=RHO(I)*VP(I,locp)*SN(I)
        END DO
        vl(k1)=SIMP(NRHO,F,DRHO)*FORPI/Q-ZV*FORPI*CS(NRHO)/(Q*Q)
        end if

        if (version.eq.4) then
        DO I=1,NRHO

          xerf=RHO(I)/rlocal
          yerf = util_erf(xerf)
          F(I)=(RHO(I)*VP(I,locp)+ZV*yerf)*SN(I)
        END DO
        vl(k1)=SIMP(NRHO,F,DRHO)*FORPI/Q
        end if


*::::::::::::::::::::: semicore density :::::::::::::::::::::::::::::::
        if (semicore) then
           do i=1,nrho
              f(i) = rho(i)*dsqrt(rho_sc_r(i,1))*sn(i)
           end do
           rho_sc_k(k1,1) = SIMP(nrho,f,drho)*forpi/Q

           do i=1,nrho
             f(i)=(sn(i)/(Q*rho(i))-cs(i))*rho_sc_r(i,2)*rho(i)
           end do
           P = SIMP(nrho,f,drho)*forpi/Q
           rho_sc_k(k1,2)=P*GX
           rho_sc_k(k1,3)=P*GY
           rho_sc_k(k1,4)=P*GZ

        end if
    
  700 CONTINUE
      call D1dB_Vector_SumAll(4*nfft3d,rho_sc_k)
      call D1dB_Vector_SumAll(nfft3d,vl)
      call D1dB_Vector_Sumall(nprj*nfft3d,vnl)


*:::::::::::::::::::::::::::::::  G=0  ::::::::::::::::::::::::::::::::      
      if (pzero.eq.taskid_i) then

         if (version.eq.3) then
         DO I=1,NRHO
           F(I)=VP(I,locp)*RHO(I)**2
         END DO
         vl(zero)=FORPI*SIMP(NRHO,F,DRHO)+TWOPI*ZV*RHO(NRHO)**2
         end if

         if (version.eq.4) then
         DO I=1,NRHO
           xerf=RHO(I)/rlocal
           yerf = util_erf(xerf)
           F(I)=(VP(I,locp)*RHO(I)+ZV*yerf)*RHO(I)
         END DO
         vl(zero)=FORPI*SIMP(NRHO,F,DRHO)
         end if

*        **** semicore density ****
         if (semicore) then
            do i=1,nrho
               f(i) = dsqrt(rho_sc_r(i,1))*rho(i)**2
            end do
            rho_sc_k(zero,1) = forpi*SIMP(nrho,f,drho)
            rho_sc_k(zero,2) = 0.0d0
            rho_sc_k(zero,3) = 0.0d0
            rho_sc_k(zero,4) = 0.0d0
         end if

         do l=1,nprj
           vnl(zero,l)=0.0d0
         end do
*        *** only j0 is non-zero at zero ****
         if (locp.ne.0) then
            do n=1,n_expansion(0)
               do i=1,nrho
                 f(i)=rho(i)*wp(i,indx(n,0))*vp(i,0)
               end do
               vnl(zero,n_expansion(0)-n+1)=P0*SIMP(nrho,f,drho)
            end do
         end if

      end if


*     ********************************    
*     **** define n_prj and l_prj ****
*     ********************************
      lcount = nprj+1
      GO TO (950,940,930,920), lmax+1

        !::::::  f-wave  :::::::
  920   CONTINUE
        if (locp.ne.3) then
          do n=1,n_expansion(3)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = -3
             b_prj(lcount) = indx(n,3)+1
    
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = -2
             b_prj(lcount) = indx(n,3)+1
           
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = -1
             b_prj(lcount) = indx(n,3)+1
     
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 0
             b_prj(lcount) = indx(n,3)+1
           
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 1
             b_prj(lcount) = indx(n,3)+1
           
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 2
             b_prj(lcount) = indx(n,3)+1
     
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 3
             b_prj(lcount) = indx(n,3)+1
          end do
        end if


        !::::  d-wave  ::::
  930   CONTINUE
        if (locp.ne.2) then
          do n=1,n_expansion(2)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = -2
             b_prj(lcount) = indx(n,2)+1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = -1
             b_prj(lcount) = indx(n,2)+1
          
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = 0
             b_prj(lcount) = indx(n,2)+1
          
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = 1
             b_prj(lcount) = indx(n,2)+1
          
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = 2
             b_prj(lcount) = indx(n,2)+1
          end do
        end if


        !::::  p-wave  ::::
  940   CONTINUE
        if (locp.ne.1) then
          do n=1,n_expansion(1)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 1
             m_prj(lcount) = -1
             b_prj(lcount) = indx(n,1)+1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 1
             m_prj(lcount) = 0
             b_prj(lcount) = indx(n,1)+1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 1
             m_prj(lcount) = 1
             b_prj(lcount) = indx(n,1)+1
          end do
        end if


        !::::  s-wave  ::::
  950   CONTINUE
        if (locp.ne.0) then
          do n=1,n_expansion(0)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 0
             m_prj(lcount) = 0
             b_prj(lcount) = indx(n,0)+1
          end do
        end if

      IERR=0
      RETURN
      END



