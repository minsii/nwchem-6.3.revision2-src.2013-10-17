#
# $Id: GNUmakefile 23264 2012-12-09 19:49:02Z niri $
#


   OBJ_OPTIMIZE = hnd_efgmap.o \
         hnd_efgmap_z4.o \
         hnd_elfmap.o \
         hnd_elpmap.o \
         hnd_eldmap.o \
         hnd_spind.o \
         hnd_elfcon.o \
         hnd_elfcon_symm.o \
         hnd_mtpcon.o \
         hnd_mtpole.o \
         prop_input.o \
         prop.o \
         prp.o \
         hnd_mulken.o \
         wnbofile.o \
         wefgfile.o \
         whypfile.o \
         wgshiftfile.o \
         wshldfile.o \
         hnd_prp_get_dens.o \
         hnd_prp_vec_read.o \
         hnd_prop_dens_make.o \
         hnd_property.o \
         cosmo.o \
         giaofock.o \
         hnd_giaox.o \
         hnd_hyperfine_zora.o \
         hnd_gshift_zora.o \
         hnd_giaox_zora.o \
         int_giao_1ega.o \
         giao_aotomo.o \
         hnd_diag.o \
         hnd_spinspin.o \
         hnd_sdfc.o \
         hnd_psoten.o \
         hnd_dsoten.o \
         prop_atom.o  \
         aoresponse_driver.o \
         aoresponse_driver_new.o \
         int_mpole_1ega.o \
         aoresponse.o \
         aoresponse_beta.o \
         aoresponse_beta2.o \
         fiao_f1_movecs.o \
         aor_r1_tensor.o \
         aor_r1_beta.o \
         aor_r1_beta_anl.o \
         giao_b1_movecs.o \
         fiao_b1_movecs.o \
	 get_vecB1.o \
	 get_vecF1.o \
	 get_allAOints.o \
         aoresponse_giao_rhs.o \
	 get_alfaorbeta_reim.o \
         CalcPerturbedTDPmat1.o \
         CalcPerturbedTDPmat1_opt.o \
         localization_driver.o \
         hnd_vec_write.o \
         ao_1prdm_read.o \
      	 giao_b1_movecs_tools.o \
         aor_r1_beta_anl_tools.o\
	 task_raman.o \
	 raman_input.o \
	 raman.o \
	 prop_grid.o

#   OBJ = aoresponse_giao_rhs.o

   LIBRARY = libproperty.a

# If you add -DJEFF_OUTPUT to LIB_DEFINES, the dipole polarizability will be printed in the same format as the TCE.
# This is very useful (1) if you wrote scripts to parse that particular formatting and (2) if you want the anisotrophy.
#   THE LAPACK CALL ENABLED BY THIS IS BROKEN ON SOME ARCHITECTURES
#   LIB_DEFINES = -DJEFF_OUTPUT

   LIB_INCLUDES = -I../nwdft/include -I../ddscf

USES_BLAS = hnd_elfcon.F wnbofile.F hnd_spinspin.F hnd_mtpole.F hnd_mulken.F \
            hnd_elpmap.F hnd_elfmap.F hnd_mtpcon.F giaofock.F hnd_spinspin.F \
            aoresponse_driver.F  raman.F hnd_efgmap_z4.F hnd_gshift_zora.F \
            wshldfile.F int_giao_1ega.F whypfile.F wefgfile.F aoresponse_driver_new.F \
            hnd_elfcon_symm.F wgshiftfile.F hnd_hyperfine_zora.F

HEADERS = prop.fh atomdata.fh

include ../config/makefile.h
include ../config/makelib.h

#FDEBUG += -O0
