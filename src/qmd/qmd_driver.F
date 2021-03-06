c
c     qmd_driver: main driver
c
      logical function qmd_driver(rtdb)
c
      implicit none
c
#include "errquit.fh"
#include "rtdb.fh"
#include "mafdecls.fh"
#include "inp.fh"
#include "util.fh"
#include "global.fh"
#include "geom.fh"
#include "stdio.fh"
c
#include "qmd_common.fh"
c
      integer rtdb
c
      integer geom                  ! geometry object
c
      integer l_r, k_r              ! coordinates
      double precision r(3)
c
      integer l_v, k_v              ! velocities
      double precision v(3)
c
      integer l_g, k_g              ! gradients
      integer l_m, k_m              ! masses
c
      integer l_act, k_act          ! active atoms
c
      integer nat                   ! number of atoms
      integer nactive               ! number of active atoms
      integer nstep_nucl           ! total nuclear steps
      integer istep_nucl           ! nuclear md step
      double precision dt_nucl      ! nuclear md time step
      double precision esys         ! system energy (from task_gradient)
      double precision ekin         ! kinetic energy from the md part
      double precision etotal       ! total energy: esys + ekin
c
      logical status
c
      character*32 pname
      integer xyzfileunit
      character*255 xyzfilename
      integer rstfileunit
      character*255 rstfilename
c
      logical task_gradient
      external task_gradient
c
c     preliminaries
      status = .true.
      pname = "qmd_driver: "
      esys = 0.d0
      ekin = 0.d0
      etotal = 0.d0
c
c     get xyzfileunit
      if(.not.util_get_io_unit(xyzfileunit))
     &   call errquit("cannot get file unit",0,0)
c
c     get xyzfilename
      call util_file_name('xyz',.false.,.false.,xyzfilename)
c
c     get rstfileunit
      if(.not.util_get_io_unit(rstfileunit))
     &   call errquit("cannot get file unit",0,0)
c
c     get rstfilename
      call util_file_name('qmdrst',.false.,.false.,rstfilename)
c
c     initialize parameters
      call qmd_init(rtdb,nstep_nucl,dt_nucl)
c
c     create geometry object 
      if (.not. geom_create(geom,'geometry'))
     &   call errquit(pname//'geom_create', 911, GEOM_ERR)
c
c     load in the geometry
      if (.not. geom_rtdb_load(rtdb,geom,'geometry'))
     &   call errquit(pname//'geom_rtdb_load', geom, RTDB_ERR)
c
c     get number of atoms
      if (.not. geom_ncent(geom,nat))
     $   call errquit(pname//'geom_ncent',geom, GEOM_ERR)
      if (nat.eq.0) return
c
c     local memory and initialization
      if(.not.ma_push_get(mt_dbl,nat,'mass',l_m,k_m))  ! mass
     $   call errquit(pname//'ma_push_get mass', nat,MA_ERR)
      call dfill(nat, 0.0d0, dbl_mb(k_m), 1)
c
      if(.not.ma_push_get(mt_dbl,3*nat,'coords',l_r,k_r)) ! coords
     $   call errquit(pname//'ma_push_get coords', 3*nat,MA_ERR)
      call dfill(3*nat, 0.0d0, dbl_mb(k_r), 1)
c
      if(.not.ma_push_get(mt_dbl,3*nat,'vels',l_v,k_v))  ! vels
     $   call errquit(pname//'ma_push_get vels', 3*nat,MA_ERR)
      call dfill(3*nat, 0.0d0, dbl_mb(k_v), 1)
      if (.not.geom_vel_set(geom,dbl_mb(k_v))) ! init vels
     $   call errquit(pname//'geom_vel_set',0,GEOM_ERR)
c
      if(.not.ma_push_get(mt_dbl,3*nat,'grads',l_g,k_g))  ! grads
     $   call errquit(pname//'ma_push_get grads',3*nat,MA_ERR)
      call dfill(3*nat, 0.0d0, dbl_mb(k_g), 1)
c
c     get the active atoms (also need a check for linearity)
c     need to implement constraints
      if (.not. ma_push_get(mt_log,nat,'active atoms',l_act,k_act)) ! active
     $   call errquit(pname//'grad_active_atoms',nat,MA_ERR)
      call grad_active_atoms(rtdb, nat, log_mb(k_act), nactive)
      if (do_linear) then    ! check for linear flag
        ndeg = 3*nactive-5   ! 3N-5 (linear)
      else
        ndeg = 3*nactive-6   ! 3N-6 (general)
      end if
c
c     get the masses, initial coordinates
      if (.not.geom_masses_get(geom,nat,dbl_mb(k_m)))  ! masses
     $   call errquit(pname//'geom_masses_get',geom,GEOM_ERR)
      if (.not.geom_cart_coords_get(geom,dbl_mb(k_r)))
     $   call errquit(pname//'geom_cart_coords_get',0,GEOM_ERR)
c
c     perform energy gradient calculation on initial coordinates
      call qmd_gradient(rtdb,nat,dbl_mb(k_g),esys)
c
c     initialize velocity and acceleration 
      call qmd_nucl_dt(nat,dt_nucl,dbl_mb(k_m),dbl_mb(k_v),dbl_mb(k_g))
c
c     apply thermostat to initial velocities
      call qmd_thermostat(nat,dt_nucl,dbl_mb(k_m),dbl_mb(k_v),ekin)
c
c     start nuclear molecular dynamics loop
      do istep_nucl = 1,nstep_nucl
c
c       update position and velocity at half step: dt2
        call qmd_nucl_dt2(nat,dt_nucl,dbl_mb(k_m),dbl_mb(k_r),
     &      dbl_mb(k_v),dbl_mb(k_g))
c
c       apply thermostat
        call qmd_thermostat(nat,dt_nucl,dbl_mb(k_m),dbl_mb(k_v),ekin)
c
c       update geom and store in rtdb
        call qmd_geom_store(rtdb,geom,nat,dbl_mb(k_r))
c
c       calculate energy and gradient
        call qmd_gradient(rtdb,nat,dbl_mb(k_g),esys)
c
c       update velocity at full step: dt
        call qmd_nucl_dt(nat,dt_nucl,dbl_mb(k_m),dbl_mb(k_v),
     &             dbl_mb(k_g))
c
c       apply thermostat
        call qmd_thermostat(nat,dt_nucl,dbl_mb(k_m),dbl_mb(k_v),ekin)
c
c       persist updated velocity in geom
        if (.not.geom_vel_set(geom,dbl_mb(k_v)))
     $   call errquit(pname//'geom_vel_set',0,GEOM_ERR)
c
c       instantaneous total energy: instantaneous kinetic energy + system energy
        etotal = ekin + esys
c
c       instantaneous temperature
        final_temp = 2.0d0*ekin/kb/(1.d0*ndeg)
c
c       print md run information
        if (ga_nodeid().eq.0) then
c
         write(luout,*)
         write(luout,*)
         call util_print_centered(LuOut,'QMD Run Information',20,.true.)
         write(luout,*) "istep_nucl: ",istep_nucl
         write(luout,*) "Time elapsed: ",istep_nucl*dt_nucl*au2fs
         write(luout,*) "ekin: ",ekin
         write(luout,*) "esys: ",esys
         write(luout,*) "etotal: ",etotal
         write(luout,*) "targ_temp: ",targ_temp
         write(luout,*) "final_temp: ",final_temp
         write(luout,*)
c
c        write trajectory
         call qmd_write_trj(xyzfilename,xyzfileunit,.true.,nat,
     &          istep_nucl,etotal,geom)
        end if  ! ga_nodeid()
c
      end do  ! istep_nucl
c
c     write restart information
      if (ga_nodeid().eq.0) then
         call qmd_write_rst(rstfilename,rstfileunit,
     &             nat,istep_nucl-1,esys,ekin,geom)
      end if
c
c     clear memory
      if(.not.ma_pop_stack(l_act))! active
     + call errquit(pname//'ma_pop_stack act',0,MA_ERR)
      if(.not.ma_pop_stack(l_g))  ! gradient
     + call errquit(pname//'ma_pop_stack g',0,MA_ERR)
      if(.not.ma_pop_stack(l_v))  ! velocity
     + call errquit(pname//'ma_pop_stack v',0,MA_ERR)
      if(.not.ma_pop_stack(l_r))  ! positions
     + call errquit(pname//'ma_pop_stack r',0,MA_ERR)
      if(.not.ma_pop_stack(l_m))  ! masses
     + call errquit(pname//'ma_pop_stack m',0,MA_ERR)
      if(.not.ma_verify_allocator_stuff())
     + call errquit(pname//'ma_verify_allocator_stuff',0,MA_ERR)
      if(.not.geom_destroy(geom))
     + call errquit(pname//'geom_destroy',0,GEOM_ERR)
c
      qmd_driver = status
c
      end
