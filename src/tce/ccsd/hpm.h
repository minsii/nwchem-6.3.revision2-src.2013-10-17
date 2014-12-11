#ifdef __bgp__
void HPM_Init(void);                                   /*   initialize the counters          */
void HPM_Start(char *label);                           /*   start counting                   */
void HPM_Stop(char *label);                            /*   stop  counting                   */
void HPM_Print(void);                                  /*   print counter values and labels  */
void HPM_Print_Flops(void);                            /*   print flops                      */
void HPM_Print_Flops_Agg(void);                        /*   print aggregate flops file       */
void HPM_Flops(char *label, float f0, float f1 );      /*   return flops                     */
#else
#define HPM_Init
#define HPM_Start
#define HPM_Stop
#define HPM_Print
#define HPM_Print_Flops
#define HPM_Print_Flops_Agg
#define HPM_Flops
#endif
