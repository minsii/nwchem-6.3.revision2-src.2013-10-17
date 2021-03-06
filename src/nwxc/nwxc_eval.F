C> \ingroup nwxc
C> @{
C>
C> \file nwxc_eval.F
C> Routines that evaluate the current density functional
C>
C> The routines in this file evaluate the current density functional.
C> They use a variety of other routines that implement specific
C> functional terms. However, those other routines are not part of the
C> API.
C>
C> @}
C
C> \ingroup nwxc_api
C> @{
C>
C> \brief Evaluate the exchange-correlation energy and the 1st order
C> partial derivatives
C>
C> Whenever density functionals are used we need the 
C> exchange-correlation energy as well as the 1st order derivatives. 
C> Hence there seemed little point in implementing a routine for the
C> exchange-correlation energy only. 
C>
C> A given density functional may consist of a variety of terms. The
C> evaluation of the functional simply loops over all the terms and
C> adds each contribution to the outputs. Therefore we first of all
C> zero all the output variables, and subsequently add all the 
C> required terms.
C>
C> Experience has shown that for these kinds of routines it is 
C> essential to be precise about the arguments are. Hence we define
C> them here is detail. First of all the inputs are:
C>
C> Rho (density)
C> -------------
C> 
C> Rho is the electron density. In closed shell cases the total 
C> electron density is used, in open shell cases the \f$\alpha\f$-electron
C> and \f$\beta\f$-electron densities are used. The density is defined as
C> \f{eqnarray*}{
C>   \rho^\alpha(\vec{r}) 
C>   &=& \sum_{i \in \{occupied\}}{\;}^\alpha\phi^*_i(\vec{r})\;^\alpha\phi_i(\vec{r}) \\\\
C>   &=& \sum_{\mu\nu}\chi_\mu(\vec{r})D^\alpha_{\mu\nu}\chi_\nu(\vec{r}) \\\\
C>   \rho^\beta(\vec{r}) 
C>   &=& \sum_{i \in \{occupied\}}{\;}^\beta\phi^*_i(\vec{r})\;^\beta\phi_i(\vec{r}) \\\\
C>   &=& \sum_{\mu\nu}\chi_\mu(\vec{r})D^\beta_{\mu\nu}\chi_\nu(\vec{r}) \\\\
C>   \rho^t(\vec{r}) &=& \rho^\alpha(\vec{r})+\rho^\beta(\vec{r})
C> \f}
C> where \f$ D^\alpha \f$ and \f$ D^\beta \f$ are the \f$\alpha\f$- and 
C> \f$\beta\f$-electron density matrices, the functions \f$^\alpha\phi\f$ and
C> \f$^\beta\phi\f$ are spin-orbitals.
C>
C> Gamma (density gradient)
C> ------------------------
C>
C> Gamma is the norm of the density gradient squared. In closed shell cases
C> norm of the gradient of the total electron density squared is used. In open
C> shell cases the various spin components are used. The different components
C> are defined as:
C> \f{eqnarray*}{
C>   \gamma^{\alpha\alpha}(\vec{r})
C>   &=& \nabla\rho^\alpha(\vec{r})\cdot\nabla\rho^\alpha(\vec{r}) \\\\
C>   \gamma^{\alpha\beta}(\vec{r})
C>   &=& \nabla\rho^\alpha(\vec{r})\cdot\nabla\rho^\beta(\vec{r}) \\\\
C>   \gamma^{\beta\beta}(\vec{r})
C>   &=& \nabla\rho^\beta(\vec{r})\cdot\nabla\rho^\beta(\vec{r}) \\\\
C>   \gamma^{tt}(\vec{r})
C>   &=& \gamma^{\alpha\alpha}(\vec{r})+\gamma^{\beta\beta}(\vec{r})
C>    +  2\gamma^{\alpha\beta}(\vec{r})
C> \f}
C> In the above the gradient of the density for one spin channel is of course
C> \f{eqnarray*}{
C>    \nabla\rho^\sigma(\vec{r})
C>    &=& \sum_{\mu\nu}\left\{
C>    \left(\nabla\chi_\mu(\vec{r})\right)D^\sigma_{\mu\nu}\chi_\nu(\vec{r})+
C>    \chi_\mu(\vec{r})D^\sigma_{\mu\nu}\left(\nabla\chi_\nu(\vec{r})\right)
C>    \right\}
C> \f}
C>
C> Tau (kinetic energy density)
C> ----------------------------
C>
C> Tau is the kinetic energy density which encapsulates 2nd derivative
C> information about the electron density. This quantity is defined
C> as:
C> \f{eqnarray*}{
C>   \tau^\sigma(\vec{r}) 
C>   &=& \frac{1}{2}\sum_{i\in\{occupied\}}|\nabla\phi_i(\vec{r})|^2
C> \f}
C>
C> Next the outputs are:
C>
C> The functional
C> --------------
C>
C> The exchange-correlation energy at every point, in general terms defined
C> as:
C> \f{eqnarray*}{
C>   f &=& 
C>   f\left(\rho^\alpha,\rho^\beta,\gamma^{\alpha\alpha},\gamma^{\alpha\beta},
C>          \gamma^{\beta\beta}\right)
C> \f}
C>
C> The derivatives of \f$f\f$ with respect to the density
C> ------------------------------------------------------
C>
C> The derivative of the exchange-correlation energy with respect to the
C> electron density (`dfdr`), defined as:
C> \f{eqnarray*}{
C>   \frac{\mathrm{d}f}{\mathrm{d}\rho^\alpha} \\\\
C>   \frac{\mathrm{d}f}{\mathrm{d}\rho^\beta}
C> \f}
C>
C> The derivatives \f$f\f$ with respect to the density gradient
C> ------------------------------------------------------------
C>
C> The routine evaluates the following derivatives related to the density
C> gradients (`dfdg`):
C> \f{eqnarray*}{
C>    \frac{\mathrm{d}f}{\mathrm{d}\gamma^{\alpha\alpha}} \\\\
C>    \frac{\mathrm{d}f}{\mathrm{d}\gamma^{\alpha\beta}} \\\\
C>    \frac{\mathrm{d}f}{\mathrm{d}\gamma^{\beta\beta}}
C> \f}
C>
C> Conversions
C> -----------
C>
C> This routine assumes that the functional is defined in terms of one 
C> particular set of quantities. In practice there are a number of different
C> conventions that may be used and that are all equally valid. For example
C> we have described the functional in terms of the \f$\alpha\f$- and 
C> \f$\beta\f$-electron density. However, the functional could also be defined
C> in terms of the total- and spin-densities. There are a number of these
C> equally valid representations that can be used. This leads to the question
C> quantities from one representation can be expressed in terms of those of 
C> another representation. Here we will present a number of these conversions
C> that we have encountered and worked out. 
C>
C> Converting between the norm of gradient squared and the norm
C> ------------------------------------------------------------
C>
C> In the Gaussian basis set DFT code in NWChem the functional is differentiated
C> with respect to the norm of the gradient squared. In the planewave codes
C> by contrast the norm of the gradient is used. Hence we need to be able to
C> convert the derivatives from one representation to another. Some of these
C> conversions are simple, for example:
C> \f{eqnarray*}{
C>   \frac{\partial f}{\partial |\gamma^{\alpha\alpha}|}
C>   &=& 
C>   \frac{\partial f}{\partial \gamma^{\alpha\alpha}}
C>   \frac{\partial \gamma^{\alpha\alpha}}{\partial |\gamma^{\alpha\alpha}|} \\\\
C>   \frac{\partial f}{\partial |\gamma^{\alpha\alpha}|}
C>   &=& 
C>   \frac{\partial f}{\partial \gamma^{\alpha\alpha}}
C>   \frac{\partial |\gamma^{\alpha\alpha}|^2}{\partial |\gamma^{\alpha\alpha}|} \\\\
C>   \frac{\partial f}{\partial |\gamma^{\alpha\alpha}|}
C>   &=& 2
C>   \frac{\partial f}{\partial \gamma^{\alpha\alpha}}
C>   |\gamma^{\alpha\alpha}|
C> \f}
C> Similarly we have for the \f$\gamma^{\beta\beta}\f$ component:
C> \f{eqnarray*}{
C>   \frac{\partial f}{\partial |\gamma^{\beta\beta}|}
C>   &=& 2
C>   \frac{\partial f}{\partial \gamma^{\beta\beta}}
C>   |\gamma^{\beta\beta}|
C> \f}
C> To work out how to convert
C> between these representations we start by considering the functional as
C> a functional of the density matrices. Next we express the functional in
C> terms of the desired quantities
C> \f{eqnarray*}{
C>   f\left(D^\alpha,D^\beta\right)
C>   &=& f\left(\gamma^{\alpha\alpha}(D^\alpha),\gamma^{\beta\beta}(D^\beta),
C>             \gamma^{\alpha\beta}(D^\alpha,D^\beta)\right) \\\\\
C>   &=& f\left(|\gamma^{\alpha\alpha}(D^\alpha)|,
C>              |\gamma^{\beta\beta}(D^\beta)|,
C>              |\gamma^{tt}(D^\alpha,D^\beta)|\right) \\\\\
C> \f}
C> Because of the equalities we know that the derivatives with respect to a
C> particular property also have to equate to eachother as, for example
C> \f{eqnarray*}{
C>   \frac{\mathrm{d} f\left(\gamma^{\alpha\alpha},
C>         \gamma^{\beta\beta},
C>         \gamma^{\alpha\beta}\right)}{\mathrm{d}\gamma^{\alpha\alpha}}
C>   &=&
C>   \frac{\mathrm{d} f\left(|\gamma^{\alpha\alpha}|,
C>         |\gamma^{\beta\beta}|,
C>         |\gamma^{tt}|\right)}{\mathrm{d}\gamma^{\alpha\alpha}} \\\\
C>   \frac{\mathrm{d} f\left(\gamma^{\alpha\alpha},
C>         \gamma^{\beta\beta},
C>         \gamma^{\alpha\beta}\right)}{\mathrm{d}\gamma^{\beta\beta}}
C>   &=&
C>   \frac{\mathrm{d} f\left(|\gamma^{\alpha\alpha}|,
C>         |\gamma^{\beta\beta}|,
C>         |\gamma^{tt}|\right)}{\mathrm{d}\gamma^{\beta\beta}} \\\\
C>   \frac{\mathrm{d} f\left(\gamma^{\alpha\alpha},
C>         \gamma^{\beta\beta},
C>         \gamma^{\alpha\beta}\right)}{\mathrm{d}\gamma^{\alpha\beta}}
C>   &=&
C>   \frac{\mathrm{d} f\left(|\gamma^{\alpha\alpha}|,
C>         |\gamma^{\beta\beta}|,
C>         |\gamma^{tt}|\right)}{\mathrm{d}\gamma^{\alpha\beta}} \\\\
C> \f}
C> On the left hand sides we have the quantities that this routine
C> `nwxc_eval_df` calculates. Here we are particularly interested in the last
C> equation.
C> Working out the right hand sides we get:
C> \f{eqnarray*}{
C>   \frac{\mathrm{d} f\left(\gamma^{\alpha\alpha},
C>         \gamma^{\beta\beta},
C>         \gamma^{\alpha\beta}\right)}{\mathrm{d}\gamma^{\alpha\beta}}
C>   &=&
C>   \frac{\mathrm{d} f\left(|\gamma^{\alpha\alpha}|,
C>         |\gamma^{\beta\beta}|,
C>         |\gamma^{tt}|\right)}{\mathrm{d}|\gamma^{tt}|}
C>   \frac{\mathrm{d}|\gamma^{tt}|}{\mathrm{d}\gamma^{\alpha\beta}}
C> \f}
C> Using the definition
C> \f$|\gamma^{tt}|=(\gamma^{\alpha\alpha}+\gamma^{\beta\beta}+2\gamma^{\alpha\beta})^{1/2}\f$
C> we can simplify this expression further to
C> \f{eqnarray*}{
C>   \frac{\mathrm{d} f\left(\gamma^{\alpha\alpha},
C>         \gamma^{\beta\beta},
C>         \gamma^{\alpha\beta}\right)}{\mathrm{d}\gamma^{\alpha\beta}}
C>   &=&
C>   \frac{\mathrm{d} f\left(|\gamma^{\alpha\alpha}|,
C>         |\gamma^{\beta\beta}|,
C>         |\gamma^{tt}|\right)}{\mathrm{d}|\gamma^{tt}|}
C>   (\gamma^{tt})^{-1/2} \\\\
C>   \frac{\mathrm{d} f\left(\gamma^{\alpha\alpha},
C>         \gamma^{\beta\beta},
C>         \gamma^{\alpha\beta}\right)}{\mathrm{d}\gamma^{\alpha\beta}}
C>   |\gamma^{tt}|
C>   &=&
C>   \frac{\mathrm{d} f\left(|\gamma^{\alpha\alpha}|,
C>         |\gamma^{\beta\beta}|,
C>         |\gamma^{tt}|\right)}{\mathrm{d}|\gamma^{tt}|}
C> \f}
C> Interestingly this relationship does not depend on \f$\gamma^{\alpha\alpha}\f$
C> or \f$\gamma^{\beta\beta}\f$ even though these quantities are contained
C> in the norm of the total density gradient.
C>
       subroutine nwxc_eval_df(ipol,nq,rho,gamma,tau,f,dfdr,dfdg,dfdt)
       implicit none
c#include "errquit.fh"
#include "nwxcP.fh"
#include "nwxc_param.fh"
       integer ipol !< [Input] The number of spin channels
       integer nq   !< [Input] The number of points
C
       double precision rho(nq,ipol)     !< [Input] Density
       double precision gamma(nq,ipol+1) !< [Input] |Density gradient|^2
       double precision tau(nq,ipol)     !< [Input] Kinetic energy 
                                         !< density
C
       double precision f(nq)           !< [Output] Energy
       double precision dfdr(nq,ipol)   !< [Output] Derivative wrt rho
       double precision dfdg(nq,ipol+1) !< [Output] Derivative wrt gamma
       double precision dfdt(nq,ipol)   !< [Output] Derivative wrt tau
C
       integer iq !< Counter over points
       integer ip !< Counter over spin channels
       integer it !< Counter of functional terms
       integer n  !< Counter
C
       logical nwxc_is_gga  !< Is the functional a GGA
       logical nwxc_is_mgga !< Is the functional a meta-GGA
C
       integer nd1r(2) !< The number of partial derivatives wrt rho as
                       !< a function of ipol
       integer nd1g(2) !< The number of partial derivatives wrt gamma as
                       !< a function of ipol
       integer nd1t(2) !< The number of partial derivatives wrt tau as
                       !< a function of ipol
C
       integer max_param
       parameter (max_param = 50)
       double precision param(max_param)
       double precision Axlsda
       parameter (Axlsda = -0.9305257363491d0 )
C
       data nd1r / D1_RA,  D1_RB  /
       data nd1g / D1_GAA, D1_GBB /
       data nd1t / D1_TA,  D1_TB  /
C
       do iq = 1, nq
         f(iq) = 0.0d0
       enddo
       do ip = 1, nd1r(ipol)
         do iq = 1, nq
           dfdr(iq,ip) = 0.0d0
         enddo
       enddo
       if (nwxc_is_gga()) then
         do ip = 1, nd1g(ipol)
           do iq = 1, nq
             dfdg(iq,ip) = 0.0d0
           enddo
         enddo
       endif
       if (nwxc_is_mgga()) then
         do ip = 1, nd1t(ipol)
           do iq = 1, nq
             dfdt(iq,ip) = 0.0d0
           enddo
         enddo
       endif
C
       do it = 1, nwxc_num_f
         select case (nwxc_ids(it))
           case (NWXCP_X_SLATER)
             call nwxc_x_dirac(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                         rho,f,dfdr)
           case (NWXCP_X_B88)
             call nwxc_x_b88(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_BNL)
             param(1) = nwxc_cam_gamma
             call nwxc_x_bnl(param,nwxc_rho_tol,ipol,nq,
     +                       nwxc_wghts(it),rho,f,dfdr)
           case (NWXCP_X_CAMB88)
             param(1) = nwxc_cam_alpha
             param(2) = nwxc_cam_beta
             param(3) = nwxc_cam_gamma
             call nwxc_x_camb88(param,nwxc_rho_tol,ipol,nq,
     +                          nwxc_wghts(it),rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_CAMLSD)
             param(1) = nwxc_cam_alpha
             param(2) = nwxc_cam_beta
             param(3) = nwxc_cam_gamma
             call nwxc_x_camlsd(param,nwxc_rho_tol,ipol,nq,
     +                          nwxc_wghts(it),rho,f,dfdr)
           case (NWXCP_X_CAMPBE)
             param(1) = 0.8040d0
             param(2) = 0.2195149727645171d0
             param(3) = nwxc_cam_alpha
             param(4) = nwxc_cam_beta
             param(5) = nwxc_cam_gamma
             call nwxc_x_campbe(param,nwxc_rho_tol,ipol,nq,
     +                          nwxc_wghts(it),rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_DLDF)
             call nwxc_x_dldf(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M05)
             param( 1) =    0.08151d0
             param( 2) =   -0.43956d0
             param( 3) =   -3.22422d0
             param( 4) =    2.01819d0
             param( 5) =    8.79431d0
             param( 6) =   -0.00295d0
             param( 7) =    9.82029d0
             param( 8) =   -4.82351d0
             param( 9) =  -48.17574d0
             param(10) =    3.64802d0
             param(11) =   34.02248d0
             call nwxc_x_m05(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M05_2X)
             param( 1) =   -0.56833d0
             param( 2) =   -1.30057d0
             param( 3) =    5.50070d0
             param( 4) =    9.06402d0
             param( 5) =  -32.21075d0
             param( 6) =  -23.73298d0
             param( 7) =   70.22996d0
             param( 8) =   29.88614d0
             param( 9) =  -60.25778d0
             param(10) =  -13.22205d0
             param(11) =   15.23694d0
             call nwxc_x_m05(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M06)
             param( 1) =  1.422057D-01*Axlsda
             param( 2) =  7.370319D-04*Axlsda
             param( 3) = -1.601373D-02*Axlsda
             param( 4) =  0.000000D+00
             param( 5) =  0.000000D+00
             param( 6) =  0.000000D+00
             param( 7) =  5.877943D-01
             param( 8) = -1.371776D-01
             param( 9) =  2.682367D-01
             param(10) = -2.515898D+00
             param(11) = -2.978892D+00
             param(12) =  8.710679D+00
             param(13) =  1.688195D+01
             param(14) = -4.489724D+00
             param(15) = -3.299983D+01
             param(16) = -1.449050D+01
             param(17) =  2.043747D+01
             param(18) =  1.256504D+01
             call nwxc_x_m06(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M06_HF)
             param( 1) = -1.179732D-01*Axlsda
             param( 2) = -2.500000D-03*Axlsda
             param( 3) = -1.180065D-02*Axlsda
             param( 4) =  0.000000D+00
             param( 5) =  0.000000D+00
             param( 6) =  0.000000D+00
             param( 7) =  1.179732D-01
             param( 8) = -1.066708D+00
             param( 9) = -1.462405D-01
             param(10) =  7.481848D+00
             param(11) =  3.776679D+00
             param(12) = -4.436118D+01
             param(13) = -1.830962D+01
             param(14) =  1.003903D+02
             param(15) =  3.864360D+01
             param(16) = -9.806018D+01
             param(17) = -2.557716D+01
             param(18) =  3.590404D+01
             call nwxc_x_m06(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M06_L)
             param( 1) =  6.012244D-01*Axlsda
             param( 2) =  4.748822D-03*Axlsda
             param( 3) = -8.635108D-03*Axlsda
             param( 4) = -9.308062D-06*Axlsda
             param( 5) =  4.482811D-05*Axlsda
             param( 6) =  0.000000D+00
             param( 7) =  3.987756D-01
             param( 8) =  2.548219D-01
             param( 9) =  3.923994D-01
             param(10) = -2.103655D+00
             param(11) = -6.302147D+00
             param(12) =  1.097615D+01
             param(13) =  3.097273D+01
             param(14) = -2.318489D+01
             param(15) = -5.673480D+01
             param(16) =  2.160364D+01
             param(17) =  3.421814D+01
             param(18) = -9.049762D+00
             call nwxc_x_m06(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M06_2X)
             param( 1) =  4.600000D-01
             param( 2) = -2.206052D-01
             param( 3) = -9.431788D-02
             param( 4) =  2.164494D+00
             param( 5) = -2.556466D+00
             param( 6) = -1.422133D+01
             param( 7) =  1.555044D+01
             param( 8) =  3.598078D+01
             param( 9) = -2.722754D+01
             param(10) = -3.924093D+01
             param(11) =  1.522808D+01
             param(12) =  1.522227D+01
             call nwxc_x_m06_2x(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M08_HX)
c            parameters A
             param(01) =  1.3340172D+00
             param(02) = -9.4751087D+00
             param(03) = -1.2541893D+01
             param(04) =  9.1369974D+00
             param(05) =  3.4717204D+01
             param(06) =  5.8831807D+01
             param(07) =  7.1369574D+01
             param(08) =  2.3312961D+01
             param(09) =  4.8314679D+00
             param(10) = -6.5044167D+00
             param(11) = -1.4058265D+01
             param(12) =  1.2880570D+01
c            parameters B
             param(13) = -8.5631823D-01
             param(14) =  9.2810354D+00
             param(15) =  1.2260749D+01
             param(16) = -5.5189665D+00
             param(17) = -3.5534989D+01
             param(18) = -8.2049996D+01
             param(19) = -6.8586558D+01
             param(20) =  3.6085694D+01
             param(21) = -9.3740983D+00
             param(22) = -5.9731688D+01
             param(23) =  1.6587868D+01
             param(24) =  1.3993203D+01
c            parameters C and D
             do n = 25, 48
               param(n) = 0.0d0
             enddo
             call nwxc_x_m08(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M08_SO)
c            parameters A
             param(01) = -3.4888428D-01
             param(02) = -5.8157416D+00
             param(03) =  3.7550810D+01
             param(04) =  6.3727406D+01
             param(05) = -5.3742313D+01
             param(06) = -9.8595529D+01
             param(07) =  1.6282216D+01
             param(08) =  1.7513468D+01
             param(09) = -6.7627553D+00
             param(10) =  1.1106658D+01
             param(11) =  1.5663545D+00
             param(12) =  8.7603470D+00
c            parameters B
             param(13) =  7.8098428D-01
             param(14) =  5.4538178D+00
             param(15) = -3.7853348D+01
             param(16) = -6.2295080D+01
             param(17) =  4.6713254D+01
             param(18) =  8.7321376D+01
             param(19) =  1.6053446D+01
             param(20) =  2.0126920D+01
             param(21) = -4.0343695D+01
             param(22) = -5.8577565D+01
             param(23) =  2.0890272D+01
             param(24) =  1.0946903D+01
c            parameters C and D
             do n = 25, 48
               param(n) = 0.0d0
             enddo
             call nwxc_x_m08(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M11)
c            parameters A
             param(01) =  8.121131D-01
             param(02) =  1.738124D+01
             param(03) =  1.154007D+00
             param(04) =  6.869556D+01
             param(05) =  1.016864D+02
             param(06) = -5.887467D+00
             param(07) =  4.517409D+01
             param(08) = -2.773149D+00
             param(09) = -2.617211D+01
             param(10) =  0.000000D+00
             param(11) =  0.000000D+00
             param(12) =  0.000000D+00
c            parameters B
             param(13) =  1.878869D-01
             param(14) = -1.653877D+01
             param(15) =  6.755753D-01
             param(16) = -7.567572D+01
             param(17) = -1.040272D+02
             param(18) =  1.831853D+01
             param(19) = -5.573352D+01
             param(20) = -3.520210D+00
             param(21) =  3.724276D+01
             param(22) =  0.000000D+00
             param(23) =  0.000000D+00
             param(24) =  0.000000D+00
c            parameters C and D
             do n = 25, 48
               param(n) = 0.0d0
             enddo
             call nwxc_x_m11(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_M11_L)
c            parameters A
             param(01) =  8.121131D-01
             param(02) =  1.738124D+01
             param(03) =  1.154007D+00
             param(04) =  6.869556D+01
             param(05) =  1.016864D+02
             param(06) = -5.887467D+00
             param(07) =  4.517409D+01
             param(08) = -2.773149D+00
             param(09) = -2.617211D+01
             param(10) =  0.000000D+00
             param(11) =  0.000000D+00
             param(12) =  0.000000D+00
c            parameters B
             param(13) =  1.878869D-01
             param(14) = -1.653877D+01
             param(15) =  6.755753D-01
             param(16) = -7.567572D+01
             param(17) = -1.040272D+02
             param(18) =  1.831853D+01
             param(19) = -5.573352D+01
             param(20) = -3.520210D+00
             param(21) =  3.724276D+01
             param(22) =  0.000000D+00
             param(23) =  0.000000D+00
             param(24) =  0.000000D+00
c            parameters C
             param(25) = -4.386615D-01
             param(26) = -1.214016D+02
             param(27) = -1.393573D+02
             param(28) = -2.046649D+00
             param(29) =  2.804098D+01
             param(30) = -1.312258D+01
             param(31) = -6.361819D+00
             param(32) = -8.055758D-01
             param(33) =  3.736551D+00
             param(34) =  0.000000D+00
             param(35) =  0.000000D+00
             param(36) =  0.000000D+00
c            parameters D
             param(37) =  1.438662D+00
             param(38) =  1.209465D+02
             param(39) =  1.328252D+02
             param(40) =  1.296355D+01
             param(41) =  5.854866D+00
             param(42) = -3.378162D+00
             param(43) = -4.423393D+01
             param(44) =  6.844475D+00
             param(45) =  1.949541D+01
             param(46) =  0.000000D+00
             param(47) =  0.000000D+00
             param(48) =  0.000000D+00
             call nwxc_x_m11(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_PBE)
             param(1) = 0.8040d0
             param(2) = 0.2195149727645171d0
             call nwxc_x_pbe(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_PBESOL)
             param(1) = 0.8040d0
             param(2) = 10.0d0/81.0d0
             call nwxc_x_pbe(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_REVPBE)
             param(1) = 1.245d0
             param(2) = 0.2195149727645171d0
             call nwxc_x_pbe(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_RPBE)
             call nwxc_x_rpbe(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_TPSS)
             call nwxc_x_tpss03(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                          rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_X_WPBE)
             param(1) = nwxc_cam_gamma
             call nwxc_x_wpbe(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,gamma,f,dfdr,dfdg)
           case (NWXCP_X_VS98)
             param(1) =  -9.800683d-01
             param(2) =  -3.556788d-03
             param(3) =   6.250326d-03
             param(4) =  -2.354518d-05
             param(5) =  -1.282732d-04
             param(6) =   3.574822d-04
             call nwxc_x_vs98(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_B95)
             param(1) = 0.0031d0
             param(2) = 0.038d0
             call nwxc_c_b95(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_DLDF)
             call nwxc_c_dldf(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M05)
             param( 1) =   1.00000d0
             param( 2) =   3.78569d0
             param( 3) = -14.15261d0
             param( 4) =  -7.46589d0
             param( 5) =  17.94491d0
             param( 6) =   1.00000d0
             param( 7) =   3.77344d0
             param( 8) = -26.04463d0
             param( 9) =  30.69913d0
             param(10) =  -9.22695d0
             call nwxc_c_m05(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M05_2X)
             param( 1) =   1.00000d0
             param( 2) =   1.09297d0
             param( 3) =  -3.79171d0
             param( 4) =   2.82810d0
             param( 5) = -10.58909d0
             param( 6) =   1.00000d0
             param( 7) =  -3.05430d0
             param( 8) =   7.61854d0
             param( 9) =   1.47665d0
             param(10) = -11.92365d0
             call nwxc_c_m05(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M06)
c
             param( 1) =  -2.741539D+00
             param( 2) =  -6.720113D-01
             param( 3) =  -7.932688D-02
             param( 4) =   1.918681D-03
             param( 5) =  -2.032902D-03
             param( 6) =   0.000000D+00
             param( 7) =   4.905945D-01
             param( 8) =  -1.437348D-01
             param( 9) =   2.357824D-01
             param(10) =   1.871015D-03
             param(11) =  -3.788963D-03
             param(12) =   0.000000D+00
c
             param(13) =   3.741539D+00
             param(14) =   2.187098D+02
             param(15) =  -4.531252D+02
             param(16) =   2.936479D+02
             param(17) =  -6.287470D+01
             param(18) =   5.094055D-01
             param(19) =  -1.491085D+00
             param(20) =   1.723922D+01
             param(21) =  -3.859018D+01
             param(22) =   2.845044D+01
c
             call nwxc_c_m06(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M06_HF)
c
             param( 1) =  -6.746338D-01
             param( 2) =  -1.534002D-01
             param( 3) =  -9.021521D-02
             param( 4) =  -1.292037D-03
             param( 5) =  -2.352983D-04
             param( 6) =   0.000000D+00
             param( 7) =   8.976746D-01
             param( 8) =  -2.345830D-01
             param( 9) =   2.368173D-01
             param(10) =  -9.913890D-04
             param(11) =  -1.146165D-02
             param(12) =   0.000000D+00
c
             param(13) =   1.674634D+00
             param(14) =   5.732017D+01
             param(15) =   5.955416D+01
             param(16) =  -2.311007D+02
             param(17) =   1.255199D+02
             param(18) =   1.023254D-01
             param(19) =  -2.453783D+00
             param(20) =   2.913180D+01
             param(21) =  -3.494358D+01
             param(22) =   2.315955D+01
c
             call nwxc_c_m06(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M06_L)
c
             param( 1) =   3.957626D-01
             param( 2) =  -5.614546D-01
             param( 3) =   1.403963D-02
             param( 4) =   9.831442D-04
             param( 5) =  -3.577176D-03
             param( 6) =   0.000000D+00
             param( 7) =   4.650534D-01
             param( 8) =   1.617589D-01
             param( 9) =   1.833657D-01
             param(10) =   4.692100D-04
             param(11) =  -4.990573D-03
             param(12) =   0.000000D+00
c
             param(13) =   6.042374D-01
             param(14) =   1.776783D+02
             param(15) =  -2.513252D+02
             param(16) =   7.635173D+01
             param(17) =  -1.255699D+01
             param(18) =   5.349466D-01
             param(19) =   5.396620D-01
             param(20) =  -3.161217D+01
             param(21) =   5.149592D+01
             param(22) =  -2.919613D+01
c
             call nwxc_c_m06(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M06_2X)
c
             param( 1) =   1.166404D-01
             param( 2) =  -9.120847D-02
             param( 3) =  -6.726189D-02
             param( 4) =   6.720580D-05
             param( 5) =   8.448011D-04
             param( 6) =   0.000000D+00
             param( 7) =   6.902145D-01
             param( 8) =   9.847204D-02
             param( 9) =   2.214797D-01
             param(10) =  -1.968264D-03
             param(11) =  -6.775479D-03
             param(12) =   0.000000D+00
c
             param(13) =   8.833596D-01
             param(14) =   3.357972D+01
             param(15) =  -7.043548D+01
             param(16) =   4.978271D+01
             param(17) =  -1.852891D+01
             param(18) =   3.097855D-01
             param(19) =  -5.528642D+00
             param(20) =   1.347420D+01
             param(21) =  -3.213623D+01
             param(22) =   2.846742D+01
c
             call nwxc_c_m06(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M08_HX)
c            parameters A
             param(1)  =    1.0000000D+00
             param(2)  =   -4.0661387D-01
             param(3)  =   -3.3232530D+00
             param(4)  =    1.5540980D+00
             param(5)  =    4.4248033D+01
             param(6)  =   -8.4351930D+01
             param(7)  =   -1.1955581D+02
             param(8)  =    3.9147081D+02
             param(9)  =    1.8363851D+02
             param(10) =   -6.3268223D+02
             param(11) =   -1.1297403D+02
             param(12) =    3.3629312D+02
c            parameters B
             param(13) =    1.3812334D+00
             param(14) =   -2.4683806D+00
             param(15) =   -1.1901501D+01
             param(16) =   -5.4112667D+01
             param(17) =    1.0055846D+01
             param(18) =    1.4800687D+02
             param(19) =    1.1561420D+02
             param(20) =    2.5591815D+02
             param(21) =    2.1320772D+02
             param(22) =   -4.8412067D+02
             param(23) =   -4.3430813D+02
             param(24) =    5.6627964D+01
             call nwxc_c_m11(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M08_SO)
c            parameters A
             param(1)  =   1.0000000D+00
             param(2)  =   0.0000000D+00
             param(3)  =  -3.9980886D+00
             param(4)  =   1.2982340D+01
             param(5)  =   1.0117507D+02
             param(6)  =  -8.9541984D+01
             param(7)  =  -3.5640242D+02
             param(8)  =   2.0698803D+02
             param(9)  =   4.6037780D+02
             param(10) =  -2.4510559D+02
             param(11) = -1.9638425D+02
             param(12) =  1.1881459D+02
c            parameters B
             param(13) =   1.0000000D+00
             param(14) =  -4.4117403D+00
             param(15) =  -6.4128622D+00
             param(16) =   4.7583635D+01
             param(17) =   1.8630053D+02
             param(18) =  -1.2800784D+02
             param(19) =  -5.5385258D+02
             param(20) =   1.3873727D+02
             param(21) =   4.1646537D+02
             param(22) =  -2.6626577D+02
             param(23) =   5.6676300D+01
             param(24) =   3.1673746D+02
             call nwxc_c_m11(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M11)
c            parameters A
             param(1)  =  1.0000000D+00
             param(2)  =  0.0000000D+00
             param(3)  = -3.8933250D+00
             param(4)  = -2.1688455D+00
             param(5)  =  9.3497200D+00
             param(6)  = -1.9845140D+01
             param(7)  =  2.3455253D+00
             param(8)  =  7.9246513D+01
             param(9)  =  9.6042757D+00
             param(10) = -6.7856719D+01
             param(11) = -9.1841067D+00
             param(12) =  0.0000000D+00
c            parameters B
             param(13) =  7.2239798D-01
             param(14) =  4.3730564D-01
             param(15) = -1.6088809D+01
             param(16) = -6.5542437D+01
             param(17) =  3.2057230D+01
             param(18) =  1.8617888D+02
             param(19) =  2.0483468D+01
             param(20) = -7.0853739D+01
             param(21) =  4.4483915D+01
             param(22) = -9.4484747D+01
             param(23) = -1.1459868D+02
             param(24) =  0.0000000D+00
             call nwxc_c_m11(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_M11_L)
c            parameters A
             param(1)  =  1.000000D+00
             param(2)  =  0.000000D+00
             param(3)  =  2.750880D+00
             param(4)  = -1.562287D+01
             param(5)  =  9.363381D+00
             param(6)  =  2.141024D+01
             param(7)  = -1.424975D+01
             param(8)  = -1.134712D+01
             param(9)  =  1.022365D+01
             param(10) =  0.000000D+00
             param(11) =  0.000000D+00
             param(12) =  0.000000D+00
c            parameters B
             param(13) =  1.000000D+00
             param(14) = -9.082060D+00
             param(15) =  6.134682D+00
             param(16) = -1.333216D+01
             param(17) = -1.464115D+01
             param(18) =  1.713143D+01
             param(19) =  2.480738D+00
             param(20) = -1.007036D+01
             param(21) = -1.117521D-01
             param(22) =  0.000000D+00
             param(23) =  0.000000D+00
             param(24) =  0.000000D+00
             call nwxc_c_m11(param,nwxc_rho_tol,ipol,nq,
     +            nwxc_wghts(it),rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_PW6B95)
             param(1) = 0.00262d0
             param(2) = 0.03668d0
             call nwxc_c_b95(param,nwxc_rho_tol,ipol,nq,
     +                       nwxc_wghts(it),rho,gamma,tau,
     +                       f,dfdr,dfdg,dfdt)
           case (NWXCP_C_PWB6K)
             param(1) = 0.00353d0
             param(2) = 0.04120d0
             call nwxc_c_b95(param,nwxc_rho_tol,ipol,nq,
     +                       nwxc_wghts(it),rho,gamma,tau,
     +                       f,dfdr,dfdg,dfdt)
           case (NWXCP_C_PW91LDA)
             call nwxc_c_pw91lda(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                           rho,f,dfdr)
           case (NWXCP_C_LYP)
             call nwxc_c_lyp(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,f,dfdr,dfdg)
           case (NWXCP_C_PBE)
             param(1) = 0.066724550603149d0
             call nwxc_c_pbe(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,f,dfdr,dfdg)
           case (NWXCP_C_PBESOL)
             param(1) = 0.046d0
             call nwxc_c_pbe(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                       rho,gamma,f,dfdr,dfdg)
           case (NWXCP_C_TPSS)
             call nwxc_c_tpss03(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                          rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_VS98)
             param(1)  =  7.035010d-01
             param(2)  =  7.694574d-03
             param(3)  =  5.152765d-02
             param(4)  =  3.394308d-05
             param(5)  = -1.269420d-03
             param(6)  =  1.296118d-03
             param(7)  =  3.270912d-01
             param(8)  = -3.228915d-02
             param(9)  = -2.942406d-02
             param(10) =  2.134222d-03
             param(11) = -5.451559d-03
             param(12) =  1.577575d-02
             call nwxc_c_vs98(param,nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,gamma,tau,f,dfdr,dfdg,dfdt)
           case (NWXCP_C_VWN1)
             call nwxc_c_vwn1(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,f,dfdr)
           case (NWXCP_C_VWN1_RPA)
             call nwxc_c_vwn1_rpa(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                            rho,f,dfdr)
           case (NWXCP_C_VWN2)
             call nwxc_c_vwn2(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,f,dfdr)
           case (NWXCP_C_VWN3)
             call nwxc_c_vwn3(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,f,dfdr)
           case (NWXCP_C_VWN4)
             call nwxc_c_vwn4(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,f,dfdr)
           case (NWXCP_C_VWN5)
             call nwxc_c_vwn5(nwxc_rho_tol,ipol,nq,nwxc_wghts(it),
     +                        rho,f,dfdr)
           case default
c            call errquit("nwxc_eval_df: invalid functional",
c    +                    nwxc_ids(it),UERR)
             write(*,*)"nwxc_eval_df: invalid functional",nwxc_ids(it)
         end select
       enddo
C
       end
C> @}
