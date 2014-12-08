
/************************************************************************************
 *   dirac.c 4/3/2007
 *  author     - Patrick Nichols
 *
 *  This file contains routines for integrating the radial
 *  Dirac equation.
 *
   $Id: zora.c 19707 2010-10-29 17:59:36Z d3y133 $

 ***********************************************************************************/

#include <stdio.h>
#include "loggrid.h"
#include "pred_cor.h"
#include "dirac.h"

#define Max_Iterations		100
#define tolerance 		1.0e-10
#define Corrector_Iterations	6

#define Min(x,y)	((x<y) ? x : y)
#define Max(x,y)	((x>y) ? x : y)



/**********************************
 *                                *
 *          R_zora                *
 *                                *
 **********************************/

void
R_ZORA (int n, int l, int s2, double Z, const double *v, int *mch,
         double *Eig, double *u, double *uprime)
{
    int i, j, iteration, node, match, Ninf, Ngrid;

    double E, de, kappa,
    Emax,
    Emin,
    log_amesh,
    log_amesh2,
    fss, gamma,
    L2, L0,
    r2,
    sum, a, scale, m1scale,
    uout, upout, upin, *r, *f_upp, *dv, *frp, *fr, *upp;

    /* define eigenvalues */
    E = *Eig;
    L2 = ((double) (l * (l + 1)));
    fss = 1.0 / 137.03602;
    fss = fss * fss;
    kappa = -1;
    if (l)
    {
        if (s2 > 0)
        {
            kappa = -(l + 1);
        }
        else
        {
            kappa = l;
        }
    }
    gamma = sqrt (kappa * kappa - fss * Z * Z);

    /* define log grid parameters */
    Ngrid = N_LogGrid ();
    log_amesh = log_amesh_LogGrid ();
    log_amesh2 = log_amesh * log_amesh;

    r = r_LogGrid ();
    f_upp = alloc_LogGrid ();
    upp = alloc_LogGrid ();
    fr = alloc_LogGrid ();
    frp = alloc_LogGrid ();
    dv = alloc_LogGrid ();


    /* set up bounds for eigenvalue */
    Emax = v[Ngrid - 1] + 0.5 * L2 / (r[Ngrid - 1] * r[Ngrid - 1]);
    Emin = 0.0;
    for (i = 0; i < Ngrid; ++i)
    {
        r2 = r[i];
        r2 = r2 * r2;
        Emin = Min (Emin, (v[i] + 0.5 * L2 / r2));
    }
    if (E > Emax)
        E = 1.25 * Emax;
    if (E < Emin)
        E = 0.75 * Emin;
    if (E > Emax)
        E = 0.5 * (Emax + Emin);

    for (i = 0; i < 4; ++i)
    {
        u[i] = 0.0;
        uprime[i] = 0.0;
        upp[i] = 0.0;
    }
    iteration = 0;
    while (iteration < Max_Iterations)
    {
        ++iteration;
        /* define f_upp */
        for (i = 0; i < Ngrid; ++i)
        {
            r2 = r[i];
            r2 = r2 * r2;
            f_upp[i] = log_amesh2 * (L2 + 2.0 * (v[i] - E) * r2);
        }
        /* define dV/dr */
        Derivative_LogGrid (v, dv);
        for (i = 0; i < Ngrid; ++i)
        {
            r2 = r[i] * r[i];
            fr[i] = -log_amesh2 * r2
                    * (fss * v[i] * (v[i] - E) +
                       0.5 * fss * dv[i] * kappa / (r[i] *
                       (1.0 - 0.5 * fss * v[i])));
            frp[i] =
                -log_amesh * r[i] * 0.5 * fss * dv[i] / 
                       (1.0 - 0.5 * fss * (v[i]));
        }

        /* find the classical turning point, */
        /* which is used for matching        */
        match = Ngrid - 1;
        while (f_upp[match - 1] * f_upp[match] > 0.0)
        {
            match = match - 1;

            if (match < 2)
            {
                printf ("Error in R_Pauli: no turning point\n");

                /* deallocate memory */
                dealloc_LogGrid (f_upp);
                dealloc_LogGrid (upp);
                dealloc_LogGrid (fr);
                dealloc_LogGrid (frp);
                dealloc_LogGrid (dv);

                return;
            }
        }

        /* set the boundry condition near zero */
        m1scale = 1.0;
        for (i = 0; i < (n - l - 1); ++i)
            m1scale *= -1.0;
        for (i = 0; i < 4; ++i)
        {
            u[i] = m1scale * pow (r[i], gamma);
            uprime[i] = log_amesh * gamma * u[i];
            upp[i] = (log_amesh + frp[i]) * uprime[i]
                     + (f_upp[i] + fr[i]) * u[i];
        }

        /* integrate from 0 to match */
        node = 0;
        for (i = 3; i < match; ++i)
        {
            /* predictors */
            u[i + 1] = Predictor_Out (i, u, uprime);
            uprime[i + 1] = Predictor_Out (i, uprime, upp);

            /* correctors */
            for (j = 0; j < Corrector_Iterations; ++j)
            {
                upp[i + 1] = (log_amesh + frp[i + 1]) * uprime[i + 1]
                             + (f_upp[i + 1] + fr[i + 1]) * u[i + 1];
                uprime[i + 1] = Corrector_Out (i, uprime, upp);
                u[i + 1] = Corrector_Out (i, u, uprime);
            }

            /* finding nodes */
            if (u[i + 1] * u[i] <= 0)
                node = node + 1;
        }
        uout = u[match];
        upout = uprime[match];

        /* not enough nodes in u */
        if ((node - n + l + 1) < 0)
        {
            Emin = E;
            E = 0.5 * (Emin + Emax);
        }
        /* too many nodes in u */
        else if ((node - n + l + 1) > 0)
        {
            Emax = E;
            E = 0.5 * (Emin + Emax);
        }
        /* number of nodes ok, start integration inward */
        else
        {

            /* find infinity */
            Ninf = match + floor (2.3 / log_amesh);
            if ((Ninf + 5) > Ngrid)
                Ninf = Ngrid - 5;

            /* define boundry near infinity */
            a = sqrt (L2 / (r[Ninf] * r[Ninf]) + 2.0 * (v[Ninf] - E));
            for (i = Ninf; i <= (Ninf + 4); ++i)
            {
                u[i] = exp (-a * (r[i] - r[Ninf]));
                uprime[i] = -r[i] * log_amesh * a * u[i];
                upp[i] = (log_amesh + frp[i]) * uprime[i]
                         + (f_upp[i] + fr[i]) * u[i];
            }

            /* integrate from infinity to match */
            for (i = Ninf; i >= (match + 1); --i)
            {
                /* predictors */
                u[i - 1] = Predictor_In (i, u, uprime);
                uprime[i - 1] = Predictor_In (i, uprime, upp);

                /* Correctors */
                for (j = 0; j < Corrector_Iterations; ++j)
                {
                    upp[i - 1] = (log_amesh + frp[i - 1]) * uprime[i - 1]
                                 + (f_upp[i - 1] + fr[i - 1]) * u[i - 1];
                    uprime[i - 1] = Corrector_In (i, uprime, upp);
                    u[i - 1] = Corrector_In (i, u, uprime);
                }
            }

            /* make the outside u, match the inside u */
            scale = uout / u[match];
            for (i = match; i <= Ninf; ++i)
            {
                u[i] = scale * u[i];
                uprime[i] = scale * uprime[i];
            }
            upin = uprime[match];

            /* Find Integral(u**2) */
            sum = Norm_LogGrid (Ninf, gamma, u);

            sum = 1.0 / sqrt (sum);
            uout = sum * uout;
            upout = sum * upout;
            upin = sum * upin;
            for (i = 0; i <= Ninf; ++i)
            {
                u[i] = sum * u[i];
                uprime[i] = sum * uprime[i];
            }
            for (i = Ninf + 1; i < Ngrid; ++i)
            {
                u[i] = 0.0;
                uprime[i] = 0.0;
            }

            /* figure out new eigenvalue */
            de = 0.5 * uout * (upout - upin) / (log_amesh * r[match]);

            /* eigenvalue is converged, exit */
            if (fabs (de) < (Max (fabs (E), 0.2) * tolerance))
            {
                *mch = match;
                *Eig = E;

                /* deallocate memory */
                dealloc_LogGrid (f_upp);
                dealloc_LogGrid (upp);
                dealloc_LogGrid (fr);
                dealloc_LogGrid (frp);
                dealloc_LogGrid (dv);

                return;
            }

            if (de > 0.0)
                Emin = E;
            else
                Emax = E;
            E = E + de;
            if ((E > Emax) || (E < Emin))
                E = 0.5 * (Emin + Emax);

        }			/* nodes ok */
    }				/* while */

    printf ("Error R_ZORA: More than %d iterations\n", Max_Iterations);
    *mch = match;
    *Eig = E;

    /* deallocate memory */
    dealloc_LogGrid (f_upp);
    dealloc_LogGrid (upp);
    dealloc_LogGrid (fr);
    dealloc_LogGrid (frp);
    dealloc_LogGrid (dv);

    return;
}



/**********************************
 *                                *
 *          R_ZORA_Fixed_E       *
 *                                *
 **********************************/

void
R_ZORA_Fixed_E (int n, int l, int s2, double Z, const double *v, int match,
                 double E, double *u, double *uprime)
{
    int i, j, node, Ngrid;

    double log_amesh,kappa,m1scale,
    log_amesh2, fss, gamma, L2, L0, r2, sum, *r, *f_upp, *dv, *frp, *fr, *upp;

    /* define eigenvalues */
    L2 = ((double) (l * (l + 1)));

    fss = 1.0 / 137.03602;
    fss = fss * fss;
    kappa = -1;
    if (l)
    {
        if (s2 > 0)
        {
            kappa = -(l + 1);
        }
        else
        {
            kappa = l;
        }
    }
    gamma = sqrt (kappa * kappa - fss * Z * Z);

    /* define log grid parameters */
    Ngrid = N_LogGrid ();
    log_amesh = log_amesh_LogGrid ();
    log_amesh2 = log_amesh * log_amesh;

    r = r_LogGrid ();
    f_upp = alloc_LogGrid ();
    upp = alloc_LogGrid ();
    fr = alloc_LogGrid ();
    frp = alloc_LogGrid ();
    dv = alloc_LogGrid ();


    for (i = 0; i < 4; ++i)
    {
        u[i] = 0.0;
        uprime[i] = 0.0;
        upp[i] = 0.0;
    }

    /* define f_upp */
    for (i = 0; i < Ngrid; ++i)
    {
        r2 = r[i];
        r2 = r2 * r2;
        f_upp[i] = log_amesh2 * (L2 + 2.0 * (v[i] - E) * r2);
    }
    /* define dV/dr */
    Derivative_LogGrid (v, dv);
    for (i = 0; i < Ngrid; ++i)
    {
        r2 = r[i] * r[i];
        fr[i] = -log_amesh2 * r2
                * (fss * (v[i]) * (v[i] - E) +
                   0.5 * fss * dv[i] * kappa / (r[i] *
                   (1.0 - 0.5 * fss * (v[i]))));
        frp[i] =
            -log_amesh * r[i] * 0.5 * fss * dv[i] / (1.0 -
                    0.5 * fss * (v[i]));
    }


    /* set the boundry condition near zero */
    m1scale = 1.0;
    for (i = 0; i < (n - l - 1); ++i)
        m1scale *= -1.0;
    for (i = 0; i < 4; ++i)
    {
        u[i] = m1scale * pow (r[i], gamma);
        uprime[i] = log_amesh * gamma * u[i];
        upp[i] = (log_amesh + frp[i]) * uprime[i]
                 + (f_upp[i] + fr[i]) * u[i];
    }

    /* integrate from 0 to match */
    node = 0;
    for (i = 3; i < match; ++i)
    {
        /* predictors */
        u[i + 1] = Predictor_Out (i, u, uprime);
        uprime[i + 1] = Predictor_Out (i, uprime, upp);

        /* correctors */
        for (j = 0; j < Corrector_Iterations; ++j)
        {
            upp[i + 1] = (log_amesh + frp[i + 1]) * uprime[i + 1]
                         + (f_upp[i + 1] + fr[i + 1]) * u[i + 1];
            uprime[i + 1] = Corrector_Out (i, uprime, upp);
            u[i + 1] = Corrector_Out (i, u, uprime);
        }

        /* finding nodes */
        if (u[i + 1] * u[i] <= 0)
            node = node + 1;
    }


    /* Find Integral(u**2) */
    sum = Norm_LogGrid (match, gamma, u);

    sum = 1.0 / sqrt (sum);
    for (i = 0; i <= match; ++i)
    {
        u[i] = sum * u[i];
        uprime[i] = sum * uprime[i];
    }
    for (i = match + 1; i < Ngrid; ++i)
    {
        u[i] = 0.0;
        uprime[i] = 0.0;
    }


    /* deallocate memory */
    dealloc_LogGrid (f_upp);
    dealloc_LogGrid (upp);
    dealloc_LogGrid (fr);
    dealloc_LogGrid (frp);
    dealloc_LogGrid (dv);

    return;

}
