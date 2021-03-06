c
C$Id: xc_tabcd.F 20247 2011-04-28 18:58:49Z d3y133 $
c
c     Modified to handle CPKS while reusing existing code
c
c     BGJ - 8/98
c
      Subroutine xc_tabcd(what,l3d,
     ,     tol_rho, Tmat, TTmat, Amat, Bmat, Cmat, Dmat, 
     N     Emat,Fmat,qxyz,xyz,
     &     chi, delchi, heschi, 
     N     curatoms,ncuratoms,nmat,
     I     ipol, nq, nbf, max_at_bf, max_at_bf2, 
     G     GRAD, basis, natoms, iniz, ifin, 
     &     g_vxc, ibf, rchi_atom, rdelchi_atom, 
     &     rdens_atom, cetobfr,kske,Mmat,scr)
c
c     We're using xc_tabcd for CPKS purposes
c
      implicit none
#include "mafdecls.fh"
#include "dftpara.fh"
#include "dft2drv.fh"
#include "dist.fh"
#include "dft_fdist.fh"
c
      Logical GRAD
      integer what ! [in]
cwhat=0
cwhat=1 CPKS_LHS
cwhat=2 CPKS_RHS
cwhat=2 NMR_RHS
      integer basis
      integer max_at_bf ! [input]
      integer max_at_bf2 ! [input]
      integer nmat ! Number of XC matrices (alpha + beta sets) to make [input]
c                  ! e.g. number of perturbations for CPSCF
      integer imat ! XC matrix loop index
      integer ipol  ! [input]
      integer nq    ! [input]
      integer nbf    ! [input]
      integer natoms ! [input]
      integer ncuratoms ! Number of current "active" atoms [input]
      integer curatoms(*) ! Mapping array for current atoms [input]
      integer jatcur,  nu, nu1,  indT
      double precision tol_rho
      integer g_vxc(*)   ! GA handle [input]
      double precision Tmat(*), TTmat(*)
      double precision rchi_atom(natoms)
      double precision rdelchi_atom(natoms)
      double precision rdens_atom(natoms,natoms,ipol)
      integer cetobfr(2,natoms)
c
c     Sampling Matrices for the XC Potential & Energy
c
      double precision Amat(nq,ipol,*), Cmat(nq,3,ipol,*)
      double precision Mmat(nq,ipol,*) 
c
c     nmr
      double precision Emat(nq,max_at_bf)
      double precision Fmat(nq,3,max_at_bf)
      double precision qxyz(3,*)                     ! [input] grid point coordinates
      double precision xyz(3,*)                  ! [input] nuclear coordinates
      logical kske
c#elif defined(TABCD_CPKS_LHS)
c
c     Note: Meaning of dimensioning of Amat and Cmat changes for
c           second derivatives, simulating "overloading" of
c           Amat and Cmat
c
c     Sampling Matrices for the XC part of integrand when making
c     multiple matrices, e.g. XC part of perturbations for CPSCF
c
c      double precision Amat(nq,ipol,nmat), Cmat(nq,3,ipol,nmat)
c#elif defined(TABCD_CPKS_RHS)
c
c     For explicit nuclear derivatives of XC matrix, the same functional
c     derivative values are combined with different basis fn derivatives
c
c      double precision Amat(nq,ipol), Cmat(nq,3,ipol)
 
c
c     Sampling Matrices for [Products of] Basis Functions & Gradients
c
      double precision Bmat(nq,max_at_bf)
      double precision Dmat(nq,3,max_at_bf)
      integer iniz(natoms), ifin(natoms)
c
c     Basis Functions & Gradients
c
      double precision chi(nq,nbf), delchi(nq,3,nbf)
      double precision heschi(nq,6,*)
      integer ibf(nbf)
      double precision A_MAX, C_MAX, AC_MAX, FUNC_MAXI,
     &                 B_MAX, D_MAX, BD_MAX, FUNC_MAXJ
      integer iat, inizia, ifinia, nbfia, nnia, ifirst, ilast
      integer jat, inizja, ifinja, nbfja, nnja, jfirst, jlast
      integer ii, mu, mu1
      integer n,lastjat
      double precision chi1
      double precision scr(nq)
      double precision dabsmax
      double precision tolrho15
      external dabsmax
      logical l3d
      integer jrsh,jrsh2,n3d,idir,jdir
      integer g_update(2)
cnmr
      double precision Rij(3) ! vector R(jat) - R(iat)
      integer inia, iq, ix, ix1, ix2
c
c     Indexing array for basis function hessian columns as if
c     it were a 3x3 matrix
c
      integer indh(3,3)
      logical w01,w02,w013,dofull
      double precision ddot
      double precision raa,rbb
      integer nbhandl1,nbhandl2
      logical nbfirst1,nbfirst2,doitt
      integer sizeblk
#include "nwc_const.fh"
      integer nonzero(nw_max_atom),natleft,
     A     iat0,jat0
      external ddot
      data indh / 1, 2, 3,
     &            2, 4, 5,
     &            3, 5, 6 /
c
c         0: l3d=.f.    & n3d=1
ccc     rhs: l3d=.true. & n3d=3
ccc     lhs: l3d=.true. & n3d=1
c
      call starttimer(monitor_tabcd)
      call starttimer(monitor_screen0)
      natleft=0
      do  iat = 1, natoms
         if(iniz(iat).ne.0) then
            natleft=natleft+1
            nonzero(natleft)=iat
         endif
      enddo
      tolrho15=tol_rho**1.25d0
      if(what.eq.0) then
        n3d=1
      elseif(what.eq.1) then
         n3d=1
      elseif(what.eq.2) then
         n3d=3
      elseif(what.eq.3) then
         n3d=3
      else
         call errquit(' wrong what value for xctabcd ',0,0)
      endif
      w01=what.eq.0.or.what.eq.1
      w013=w01.or.what.eq.3
      w02=what.eq.0.or.what.eq.2
      dofull=what.ne.0.or.l3d
      nbfirst1=.true.
      nbfirst2=.true.
      call endtimer(monitor_screen0)
c
c
c     Beginning of loop over multiple XC matrices
c
      do 500 imat = 1,nmat
c
c     Compute the matrix product for the XC potential and energy:
c
c              T = transpose(A*B) + transpose(C*D)
c

         call starttimer(monitor_screen1)

         A_MAX = dabsmax(nq*ipol,Amat(1,1,imat))
         if (GRAD) then
            C_MAX = dabsmax(nq*3*ipol,Cmat(1,1,1,imat))
         else
            C_MAX = 0d0
         endif
         AC_MAX = max(A_MAX,C_MAX)

         call endtimer(monitor_screen1)

c
c     repl stuff
c
      if(xcreplicated.and.dorepxc) then
         g_update(1)=k_repxc(1)
         g_update(2)=k_repxc(2)
      else
         g_update(1)=g_vxc(1)
         g_update(2)=g_vxc(2)
      endif
      do 430 iat0=1,natleft
         call starttimer(monitor_screen2)
         iat=nonzero(iat0)
         inizia = iniz(iat)
         FUNC_MAXI = rchi_atom(iat)
         if(GRAD) FUNC_MAXI = max(FUNC_MAXI,rdelchi_atom(iat))
         doitt=(AC_MAX*FUNC_MAXI).ge.tol_rho
         call endtimer(monitor_screen2)
         if(what.eq.2.or.doitt) then
         ifinia = ifin(iat)
         ifirst = cetobfr(1,iat)
         ilast = cetobfr(2,iat)
         nnia = ifinia - inizia + 1
         nbfia = ilast - ifirst + 1
         do ii = 1, ipol
            do mu = 1, nnia

               call starttimer(monitor_mult1)

               mu1 = mu+inizia-1
               if (GRAD) then
                  do n = 1, nq
                     chi1 = chi(n,mu1)


                     Bmat(n,mu) = Amat(n,ii,imat)*chi1 +
     &                    delchi(n,1,mu1)*Cmat(n,1,ii,imat) +
     &                    delchi(n,2,mu1)*Cmat(n,2,ii,imat) +
     &                    delchi(n,3,mu1)*Cmat(n,3,ii,imat)
                     Dmat(n,1,mu) = Cmat(n,1,ii,imat)*chi1
                     Dmat(n,2,mu) = Cmat(n,2,ii,imat)*chi1
                     Dmat(n,3,mu) = Cmat(n,3,ii,imat)*chi1
                     
                     if(kske) then 
                        Dmat(n,1,mu) = Dmat(n,1,mu) +
     &                       Mmat(n,ii,imat)*delchi(n,1,mu1)
                        Dmat(n,2,mu) = Dmat(n,2,mu) +
     &                       Mmat(n,ii,imat)*delchi(n,2,mu1)
                        Dmat(n,3,mu) = Dmat(n,3,mu) +
     &                       Mmat(n,ii,imat)*delchi(n,3,mu1)
                     endif
                     
                  enddo
               else
                  do n = 1, nq
                     Bmat(n,mu) = chi(n,mu1)*Amat(n,ii,imat)
                  enddo
               endif
            enddo
c     Monitoring 

            call endtimer(monitor_mult1)

c
            call starttimer(monitor_screen3)
            B_MAX = dabsmax(nnia*nq,Bmat)
            if (GRAD) then
               D_MAX = dabsmax(nnia*nq*3,Dmat)
            else
               D_MAX = 0d0
            endif
            BD_MAX = max(B_MAX,D_MAX)
c
            lastjat=iat0
            if(what.eq.2) lastjat=natleft
            if(what.eq.3) lastjat=iat0-1
            call endtimer(monitor_screen3)
            do 168 jat0=1,lastjat
               jat=nonzero(jat0)
               if(what.eq.2) then
c
c     To fit better into existing structure, loop over full square
c     of atom pairs and only compute nuclear derivative contribution
c     from jat.  Also, this way we only need check jatcur once and
c     for all, and don't have to check iatcur at all.
c
                  jatcur = curatoms(jat)
                  if (jatcur.eq.0) goto 168
               endif
               call starttimer(monitor_screen4)
               inizja = iniz(jat)
               FUNC_MAXJ = rchi_atom(jat)
               if(grad) FUNC_MAXJ = max(rchi_atom(jat),FUNC_MAXJ)
               doitt=(BD_MAX*FUNC_MAXJ).ge.tol_rho
               call endtimer(monitor_screen4)
               if(what.eq.2.or.doitt) then
 
c     Monitoring 

            call starttimer(monitor_mult2)

               if(what.eq.3) then
                     Rij(1) = 0.5d0*(xyz(1,jat)-xyz(1,iat))
                     Rij(2) = 0.5d0*(xyz(2,jat)-xyz(2,iat))
                     Rij(3) = 0.5d0*(xyz(3,jat)-xyz(3,iat))
               endif
               ifinja = ifin(jat)
               jfirst = cetobfr(1,jat)
               jlast = cetobfr(2,jat)
               nbfja = jlast - jfirst + 1
               nnja = ifinja - inizja + 1
               sizeblk=n3d*nbfia*nbfja
               if(what.eq.2.or.what.eq.3) 
     Y              call dcopy(sizeblk, 0d0,0, TTmat,1) 
c
c              Loop over x, y, z directions for derivative XC mats
c
               do jdir = 1,n3d
c
                  if(what.eq.3) then
                     ix1 = mod(jdir,3)+1
                     ix2 = mod(jdir+1,3)+1
                     raa=rij(ix1)
                     rbb=rij(ix2)
                     do iq = 1, nq
                        scr(iq) = raa*qxyz(ix2,iq) - rbb*qxyz(ix1,iq)
                     enddo
                     do inia = 1, nnia
                        do iq = 1, nq
                           Emat(iq,inia) = scr(iq)*Bmat(iq,inia)
                        enddo
                        if (GRAD) then
                           do iq = 1, nq
                              Emat(iq,inia) = Emat(iq,inia)+
     &                             (raa*Dmat(iq,ix2,inia)
     &                             -  rbb*Dmat(iq,ix1,inia))
                           enddo
                        endif
                     enddo
                     if (GRAD) then
                        do inia = 1, nnia
                              do iq = 1, nq
                                 Fmat(iq,1,inia) = scr(iq)
     &                                * Dmat(iq,1,inia)
                                 Fmat(iq,2,inia) = scr(iq)
     &                                * Dmat(iq,2,inia)
                                 Fmat(iq,3,inia) = scr(iq)
     &                                * Dmat(iq,3,inia)
                           enddo
                        enddo
                     endif
                  endif
c
                  if(w01) then
                     call dgemm('T', 'N', nnia, nnja, nq, 1.d0, Bmat,
     &                    nq, chi(1,inizja), nq, 0.d0, Tmat, nnia)
                  elseif(what.eq.3) then
                     call dgemm('T', 'N', nnia, nnja, nq, 1.0d0, Emat,
     &                    nq, chi(1,inizja), nq, 0.0d0, Tmat, nnia)
                  else
c     Note the sign change for a nuclear derivative, and also that the
c     leading dimension of delchi must be set correctly
                     call dgemm('T', 'N', nnia, nnja, nq, -1.d0, Bmat,
     &                    nq, delchi(1,jdir,inizja), nq*3, 0.d0, Tmat,
     &                    nnia)
                  endif
                  if (GRAD) then
                     if(w01) then
                        call dgemm('T', 'N', nnia, nnja, 3*nq,
     &                       1.d0, Dmat, 3*nq, delchi(1,1,inizja), 
     &                       3*nq, 1.d0, Tmat, nnia)
                     elseif(what.eq.3) then
                        call dgemm('T', 'N', nnia, nnja, 3*nq,
     &                       1.0d0, Fmat, 3*nq, delchi(1,1,inizja), 
     &                       3*nq, 1.0d0, Tmat, nnia)
                     else
                        indT = 0
                        do nu = 1, nnja
                           nu1 = nu+inizja-1
                           do mu = 1, nnia
                              indT = indT + 1
                              Tmat(indT) = Tmat(indT)-
     *                             ddot(nq,Dmat(1,1,mu),1,
     &                             heschi(1,indh(1,jdir),nu1),1) -
     *                             ddot(nq,Dmat(1,2,mu),1,
     &                             heschi(1,indh(2,jdir),nu1),1) -
     *                             ddot(nq,Dmat(1,3,mu),1,
     &                             heschi(1,indh(3,jdir),nu1),1)
                           enddo
                        enddo
                     endif
                  endif
                  if(n3d.eq.1) then
                     call dfill(max_at_bf2, 0.d0, TTmat, 1)
                     if(dofull) then
                        call scat_mat(TTmat, Tmat, nbfia, nbfja, nnia,
     &                       nnja,ifirst,jfirst,ibf(inizia),ibf(inizja))
                     else
                        call scat_matup(TTmat, Tmat, nbfia, nbfja, nnia,
     &                       nnja,ifirst,jfirst,ibf(inizia),ibf(inizja))
                     endif
                  else
                     call scat_mat3(n3d,jdir,
     &                    TTmat, Tmat, nbfia, nbfja, nnia,
     &                    nnja,ifirst,jfirst,ibf(inizia),ibf(inizja))
                  endif
                     
               enddo            ! jdir (loop over x, y, z directions for nmr)
c     Monitoring 

            call endtimer(monitor_mult2)
            
                  doitt=.true.
            call starttimer(monitor_screen5)
               if(what.eq.0) then
                  doitt=dabsmax(sizeblk,ttmat).ge.tolrho15
                  jrsh=ii
               elseif(what.eq.1) then
                  doitt=.true.
                  jrsh=imat+(ii-1)*nmat
               elseif(what.eq.3) then
                  jrsh=(ii-1)*n3d+1
               else
                  doitt=dabsmax(sizeblk,ttmat).ge.tol_rho
                  jrsh=1+(jat-1)*3+(ii-1)*3*natoms
               endif
               call endtimer(monitor_screen5)
               if(doitt) then

                  jrsh2=jrsh+n3d-1

c     Monitoring

               call updist(monitor_size_ga_acc1, sizeblk)
               call starttimer( monitor_comm_ga_acc1)

                  if(l3d) then
                     call dft_3dacc(g_vxc, ttmat,
     &                    jrsh,jrsh2,
     %                 ifirst, ilast, jfirst, jlast, nbfia)
                  else
                     if(dftnbacc) then
                        if(.not.nbfirst1) then
                           call starttimer( monitor_wait1)
                           call ga_nbwait(nbhandl1)
                           call endtimer( monitor_wait1)
                        endif
                        nbfirst1=.false.
                        call upd_atombl_nb(g_update(ii),
     .                       basis,iat,jat,ttmat,nbhandl1)
                     else
                        if(truerepxc) then
                           call xc_atom_blockd(dbl_mb(k_repxc(ii)),
     N                          nbf_ld,basis,iat,jat,ttmat)
                        else
                        if(truerepxc) then
                           call xc_atom_block(dbl_mb(k_repxc(ii)),
     N                          nbf_ld,basis,jat,iat,tmat)
                        else
                        call upd_atom_block(g_update(ii),
     .                       basis,iat,jat,ttmat)
                        endif
                        endif
                     endif
                  endif
c     Monitoring

               call endtimer( monitor_comm_ga_acc1)

               if(what.ne.0.or.l3d) then
c
c                 check to see if can skip and use ga_symmetrize
c
                  if ((w013.and.iat.ne.jat).or.what.eq.2) then
c     For CPKS RHS, we update with transpose even for iat = jat,
c     since that is necessary to get both contributions
c     mu * del(nu) and del(mu) * nu
                     

                     call starttimer(monitor_comp_transp)

                     if(n3d.eq.1) then
                        call transp_mat(TTmat, Tmat,
     ,                       nbfia, nbfja)
                     else
                        if(what.eq.3) then
                           call dscal(n3d*nbfia*nbfja,-1.0d0,TTmat,1)
                        endif
                        call transp_mat3(n3d,TTmat, Tmat,
     ,                       nbfia, nbfja)
                     endif

                     call endtimer(monitor_comp_transp)

                     
c     Monitoring 

                     call starttimer(monitor_comm_ga_acc2)

                     
                     if(l3d) then
                        call dft_3dacc(g_vxc, tmat,
     &                       jrsh,jrsh2,
     %                       jfirst, jlast, ifirst, ilast, nbfja)
                     else
                        if(dftnbacc) then
                           if(.not.nbfirst2) then
                              call ga_nbwait(nbhandl2)
                           endif
                           nbfirst2=.false.
                           call upd_atombl_nb(g_update(ii),
     .                          basis,jat,iat,tmat,nbhandl2)
                        else
                           call upd_atom_block(g_update(ii),basis,
     J                          jat,iat,tmat)
                        endif
                     endif
c     Monitoring 

                     call endtimer(monitor_comm_ga_acc2)

                     
                  endif
               endif
            endif
            endif
  168       continue
         enddo ! ipol loop
      endif
  430 continue
  500 continue
c      write(6,*)' g_vxc(1) from xc_tabcd '
c      call ga_print(g_vxc(1))
c      write(6,*)' g_vxc(2) from xc_tabcd '
c      call ga_print(g_vxc(2))
      call endtimer(monitor_tabcd)
      return
      end
      subroutine upd_atombl_nb(g_array, basis, iat, jat, buf,
     $     nbhandle)
      implicit none
#include "errquit.fh"
#include "global.fh"
#include "bas.fh"
c
      integer g_array, basis, iat, jat
      integer nbhandle
      double precision buf(*)
      logical status
c
      integer ilo, ihi, jlo, jhi, idim, jdim
c
c     add atom block buf info of the matrix g_array (over basis functions)
c
      status= bas_ce2bfr(basis, iat, ilo, ihi)
      status=status.and. bas_ce2bfr(basis, jat, jlo, jhi)
      if (.not. status)
     $     call errquit('upd_atom_block: ce2bfr failed', 0, BASIS_ERR)
c
      idim = ihi - ilo + 1
      jdim = jhi - jlo + 1
c     
      if (idim.gt.0 .and. jdim.gt.0) 
     $     call ga_nbacc(g_array, ilo, ihi, jlo, jhi, buf, idim,
     $        1.0d0,nbhandle)
c
      end
