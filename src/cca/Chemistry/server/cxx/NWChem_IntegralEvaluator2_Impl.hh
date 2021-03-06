// 
// File:          NWChem_IntegralEvaluator2_Impl.hh
// Symbol:        NWChem.IntegralEvaluator2-v0.4
// Symbol Type:   class
// Babel Version: 0.10.12
// Description:   Server-side implementation for NWChem.IntegralEvaluator2
// 
// WARNING: Automatically generated; only changes within splicers preserved
// 
// babel-version = 0.10.12
// xml-url       = /home/windus/CCA/mcmd-paper/nwchem/src/cca/repo/NWChem.IntegralEvaluator2-v0.4.xml
// 

#ifndef included_NWChem_IntegralEvaluator2_Impl_hh
#define included_NWChem_IntegralEvaluator2_Impl_hh

#ifndef included_sidl_cxx_hh
#include "sidl_cxx.hh"
#endif
#ifndef included_NWChem_IntegralEvaluator2_IOR_h
#include "NWChem_IntegralEvaluator2_IOR.h"
#endif
// 
// Includes for all method dependencies.
// 
#ifndef included_Chemistry_QC_GaussianBasis_CompositeIntegralDescr_hh
#include "Chemistry_QC_GaussianBasis_CompositeIntegralDescr.hh"
#endif
#ifndef included_Chemistry_QC_GaussianBasis_IntegralDescr_hh
#include "Chemistry_QC_GaussianBasis_IntegralDescr.hh"
#endif
#ifndef included_NWChem_IntegralEvaluator2_hh
#include "NWChem_IntegralEvaluator2.hh"
#endif
#ifndef included_sidl_BaseException_hh
#include "sidl_BaseException.hh"
#endif
#ifndef included_sidl_BaseInterface_hh
#include "sidl_BaseInterface.hh"
#endif
#ifndef included_sidl_ClassInfo_hh
#include "sidl_ClassInfo.hh"
#endif


// DO-NOT-DELETE splicer.begin(NWChem.IntegralEvaluator2._includes)
// Insert-Code-Here {NWChem.IntegralEvaluator2._includes} (includes or arbitrary code)
// DO-NOT-DELETE splicer.end(NWChem.IntegralEvaluator2._includes)

namespace NWChem { 

  /**
   * Symbol "NWChem.IntegralEvaluator2" (version 0.4)
   */
  class IntegralEvaluator2_impl
  // DO-NOT-DELETE splicer.begin(NWChem.IntegralEvaluator2._inherits)
  // Insert-Code-Here {NWChem.IntegralEvaluator2._inherits} (optional inheritance here)
  // DO-NOT-DELETE splicer.end(NWChem.IntegralEvaluator2._inherits)
  {

  private:
    // Pointer back to IOR.
    // Use this to dispatch back through IOR vtable.
    IntegralEvaluator2 self;

    // DO-NOT-DELETE splicer.begin(NWChem.IntegralEvaluator2._implementation)
    // Insert-Code-Here {NWChem.IntegralEvaluator2._implementation} (additional details)
    // DO-NOT-DELETE splicer.end(NWChem.IntegralEvaluator2._implementation)

  private:
    // private default constructor (required)
    IntegralEvaluator2_impl() 
    {} 

  public:
    // sidl constructor (required)
    // Note: alternate Skel constructor doesn't call addref()
    // (fixes bug #275)
    IntegralEvaluator2_impl( struct NWChem_IntegralEvaluator2__object * s ) : 
      self(s,true) { _ctor(); }

    // user defined construction
    void _ctor();

    // virtual destructor (required)
    virtual ~IntegralEvaluator2_impl() { _dtor(); }

    // user defined destruction
    void _dtor();

    // static class initializer
    static void _load();

  public:


    /**
     * Get buffer pointer for given type.
     * @return Buffer pointer. 
     */
    void*
    get_buffer (
      /* in */ ::Chemistry::QC::GaussianBasis::IntegralDescr desc
    )
    throw ( 
      ::sidl::BaseException
    );

    /**
     * user defined non-static method.
     */
    ::Chemistry::QC::GaussianBasis::CompositeIntegralDescr
    get_descriptor() throw ( 
      ::sidl::BaseException
    );

    /**
     * Compute a shell doublet of integrals.
     * @param shellnum1 Gaussian shell number 1.
     * @param shellnum2 Gaussian shell number 2.
     * @param deriv_level Derivative level. 
     */
    void
    compute (
      /* in */ int64_t shellnum1,
      /* in */ int64_t shellnum2
    )
    throw ( 
      ::sidl::BaseException
    );


    /**
     * Compute a shell doublet of integrals and return as a borrowed
     * sidl array.
     * @param shellnum1 Gaussian shell number 1.
     * @param shellnum2 Gaussian shell number 2.
     * @return Borrowed sidl array buffer. 
     */
    ::sidl::array<double>
    compute_array (
      /* in */ int64_t shellnum1,
      /* in */ int64_t shellnum2
    )
    throw ( 
      ::sidl::BaseException
    );


    /**
     * Compute integral bounds.
     * @param shellnum1 Gaussian shell number 1.
     * @param shellnum2 Gaussian shell number 2. 
     */
    double
    compute_bounds (
      /* in */ int64_t shellnum1,
      /* in */ int64_t shellnum2
    )
    throw ( 
      ::sidl::BaseException
    );


    /**
     * Compute array of integral bounds.
     * @param shellnum1 Gaussian shell number 1.
     * @param shellnum2 Gaussian shell number 2. 
     */
    ::sidl::array<double>
    compute_bounds_array (
      /* in */ int64_t shellnum1,
      /* in */ int64_t shellnum2
    )
    throw ( 
      ::sidl::BaseException
    );

  };  // end class IntegralEvaluator2_impl

} // end namespace NWChem

// DO-NOT-DELETE splicer.begin(NWChem.IntegralEvaluator2._misc)
// Insert-Code-Here {NWChem.IntegralEvaluator2._misc} (miscellaneous things)
// DO-NOT-DELETE splicer.end(NWChem.IntegralEvaluator2._misc)

#endif
