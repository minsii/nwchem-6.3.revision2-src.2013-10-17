      logical function dft_uks_nr_solve(rtdb, energy, eone, etwo, exc,
     +                                  enrep, edisp, nexc)
C     $Id: dft_uks_nr_solve.F 23981 2013-04-07 09:22:57Z d3y133 $
      implicit none
#include "errquit.fh"
#include "mafdecls.fh"
#include "global.fh"
#include "rtdb.fh"
#include "geom.fh"
#include "cuhf.fh"
#include "pstat.fh"
#include "cscfps.fh"
#include "util.fh"
#include "cscf.fh"
c     
c     Solve the UKS equations using a hybrid NR/PCG method
c     
c     Arguments
c     
      integer rtdb
      double precision energy   ! Return UKS energy
      double precision eone, etwo, enrep ! Return UKS energy contribs
      double precision edisp
      double precision exc(2) ! Return exchange-correlation contribs
      integer nexc
c     
c     Local GA handles 
c     
      integer g_grad            ! gradient vector  ... cuhf_vlen
      integer g_search          ! search direction ... cuhf_vlen
      integer g_work            ! scratch vector   ... cuhf_vlen
c     
c     Local variables
c     
      integer ls_max            ! Max. no. of points for line search
      parameter (ls_max=20)
      integer iwork(10)         ! PCG routine internal info
      double precision dwork(3*ls_max+5) ! PCG routine internal info
      character*16 mode         ! For communication with PCG routine 
c
      double precision tlastwrite,ttest ! time last wrote the MO vectors
      double precision step     ! Step to take in search direction
      double precision time_iter_start
      integer time_prev_iter
c
      double precision gnorm    ! measures for convergence
      logical converged
      logical oprint_parm, oprint_conv, oprint_eval, oprint_vecs
      logical oprint_ls
c     
c     Functions
c     
      integer ga_create_atom_blocked
      external ga_create_atom_blocked
c     
      if (ga_nodeid().eq.0) call util_flush(6)
c     
c     Allocate global arrays.  Gradient, search direction
c     and work space for the PCG routine.
c     
*ga:1:0
      if (.not.ga_create(MT_DBL,cuhf_vlen, 1, 'dft_uks_nr_solve: grad',
     $                   0, 1, g_grad))
     $         call errquit('dft_uks_nr_solve: ga_cre grad', 0, GA_ERR)
*ga:1:0
      if (.not.ga_create(MT_DBL,cuhf_vlen, 1, 'dft_uks_nr_solve: serch',
     $                   0, 0, g_search))
     $         call errquit('dft_uks_nr_solve: ga_cre grad',0, GA_ERR)
*ga:1:0
      if (.not.ga_create(MT_DBL,cuhf_vlen, 1, 'dft_uks_nr_solve: work',
     $                   0, 0, g_work))
     $         call errquit('dft_uks_nr_solve: ga_cre work', 0, GA_ERR)
c     
      oprint_parm = util_print('parameters', print_default)
      oprint_conv = util_print('convergence', print_default)
      oprint_ls   = util_print('line search', print_high)
      oprint_vecs = util_print('intermediate vectors', print_debug)
      oprint_eval = util_print('intermediate evals', print_debug)
c
      tlastwrite = util_wallsec()
c     
      if (ga_nodeid().eq.0.and. oprint_parm) then
         write(6,1) gnorm_tol, maxiter, tol2e
         if (ouser_changed_conv) write(6,11) shifts, nr_gswitch
         write(6,111)
 1       format(//,
     $        1x,'----------------------------------------------',/
     $        1x,'        Quadratically convergent UKS',//,
     $        1x,'Convergence threshold     :',9x,1p,e10.3,0p,/,
     $        1x,'Maximum no. of iterations :',9x,i4,/,
     $        1x,'Integral*density screening:',9x,1p,e10.3,0p)
 11      format(/,
     $        1x,'PCG initial level shift   :',9x,f10.3,/,
     $        1x,'PCG change shift at maxg  :',9x,f10.3,/,
     $        1x,'PCG final level shift     :',9x,f10.3,/,
     $        1x,'NR  initial level shift   :',9x,f10.3,/,
     $        1x,'NR  change shift at maxg  :',9x,f10.3,/,
     $        1x,'NR  final level shift     :',9x,f10.3,/,
     $        1x,'NR  enabled at maxg       :',9x,f10.3)
 111     format(
     $        1x,'----------------------------------------------',/)
         call util_flush(6)
      end if
c
      ododiag = .true.
      odisable_nr = .false.
c     
c     PCG iterative loop
c     
      time_prev_iter = 0
      time_iter_start = util_wallsec()
c
      mode = 'startup'
      converged = .false.
 10   if (.not. converged) then
         call ga_pcg_minim(cuhf_vlen, iter, energy, g_grad, g_work,
     $        g_search, step, ls_tol, ls_max, eprec, oconjugacy, 
     $        oprint_conv, oprint_ls, iwork, dwork, mode)
c     
         if (mode .eq. 'energy+gradient') then
c     
c           Compute the energy and gradient at step*search direction
c     
            call dft_uks_step_energy(rtdb, step, g_search,
     $           eone, etwo, exc, enrep, energy, edisp, g_grad, nexc)
            gnorm = sqrt(ga_ddot(g_grad, g_grad))
            call ecce_print1('total energy', mt_dbl, energy, 1)
            call ecce_print1('orbital gradient norm', mt_dbl, gnorm, 1)
            goto 10
c     
         else if (mode .eq. 'precondition') then
c     
c           Precondition the gradient direction with approx./exact
c           hessian
c     
            call dft_uks_search_precond(rtdb, g_grad, g_work)
            gnorm = sqrt(ga_ddot(g_grad, g_grad))
            goto 10
c     
         else if (mode .eq. 'accept step') then
c     
c           Apply the rotation and check for overall convergence.
c           The current fock matrices and energy correspond to the
c           updated MO coefficients.
c     
            call uhf_rotate_movecs(step, g_search)
            converged = gnorm .lt. gnorm_tol
            time_prev_iter = util_wallsec() - time_iter_start
            time_iter_start = util_wallsec()
            if ((iter.le.maxiter).and.(.not. converged)) then
c     
c              Not finished ... dump mo-vectors to disk for restart and
c              go back to top of loop
c     
               if (oprint_vecs) then
                  if (ga_nodeid() .eq. 0) then
                     write(6,*)
                     call util_print_centered(6,
     $                    'Intermediate MO vectors',40,.true.)
                     write(6,*)
                     call util_flush(6)
                  end if
                  call ga_print(g_movecs)
                  call ga_print(g_movecs(2))
               end if
               ttest = util_wallsec()-tlastwrite
               call ga_dgop(1324,ttest,1,'max')
               if (ttest .gt. 300) then
*     if (olock) call scf_movecs_lock
                 call scf_movecs_write(rtdb)
                 tlastwrite = util_cpusec()
               endif
               if (util_test_time_remaining(rtdb,time_prev_iter*3))
     $              goto 10
            end if
c            
         end if
      end if
c     
c     End SCF minimisation
c     
      if (ga_nodeid().eq.0) call util_flush(6)
c     
c     *ALWAYS* return canonical MOs ... do not do aufbau
c     
      call uhf_canon(.false., oprint_eval)
      if (oadapt) then
        call scf_movecs_sym_adapt(basis, g_movecs, .false.,
     $        0, 'after canon', .true., int_mb(k_irs))
        call scf_movecs_sym_adapt(basis, g_movecs(2), .false.,
     $        0, 'after canon', .true., int_mb(k_irs+nmo))
      endif
      call movecs_fix_phase(g_movecs)
      call movecs_fix_phase(g_movecs(2))
      if (olock) call scf_movecs_lock
      call scf_movecs_write(rtdb)
c     
c     Free globals
c     
      if (.not. ga_destroy(g_grad)) call errquit
     $     ('dft_uks_nr_solve: ga_destroy grad', 0, GA_ERR)
      if (.not. ga_destroy(g_search)) call errquit
     $     ('dft_uks_nr_solve: ga_destroy search', 0, GA_ERR)
      if (.not. ga_destroy(g_work)) call errquit
     $     ('dft_uks_nr_solve: ga_destroy work', 0, GA_ERR)
c     
      if (ga_nodeid().eq.0) call util_flush(6)
      call tpi_ga_sync()
c     
      dft_uks_nr_solve = converged
c     
      end
