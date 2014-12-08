/* begin_generated_IBM_copyright_prolog                             */
/*                                                                  */
/* ---------------------------------------------------------------- */
/* (C)Copyright IBM Corp.  2007, 2008                               */
/* IBM BSD License                                                  */
/* ---------------------------------------------------------------- */
/*                                                                  */
/* end_generated_IBM_copyright_prolog                               */
/**
 * \file armci/src/armcix/dcmf/armcix_impl.c
 * \brief DCMF ARMCI Extension implementation.
 */

#include "armcix_impl.h"
#include "strings.h"
#include <stdio.h>

ARMCIX_DCMF_Connection_t __global_connection;
ARMCIX_DCMF_Connection_t * __connection;
DCMF_Memregion_t __local_mem_region;

static DCMF_CollectiveProtocol_t __gbarrier_proto, __lbarrier_proto;
static DCMF_Geometry_t world_geometry;
static DCMF_CollectiveRequest_t barrier_request;

static DCMF_Geometry_t *getGeometry(int comm)
{
   return &world_geometry;
}

static void barrier_done(void *cd, DCMF_Error_t *error)
{
   volatile unsigned *work_left = (unsigned*)cd;
   (*work_left)--;
   return;
}

volatile unsigned __memregions_to_receive;

static pthread_t armcix_advance_thread;
//volatile int armcix_advance_active;
int armcix_advance_active;

unsigned tp = 0;  /* total number of events processed */
double tt = 0.0;  /* total time spent processing events */

void *armcix_advance(void * dummy)
{
    size_t me   = DCMF_Messager_rank();
    unsigned ep;      /* events processed in a single DCMF_Messager_advance() call */
    double t0,t1,dt;
    DCMF_CriticalSection_enter (0);
    while (1)
    {
        t0 = DCMF_Timer();
        ep = DCMF_Messager_advance (0);
        t1 = DCMF_Timer();
        dt = t1-t0;
        tt += dt;
        tp += ep;
        if ( dt>0.5 ) { 
           fprintf(stdout,"%5u: DCMF_Messager_advance took %f seconds to process %u events\n",
                           me,                             dt,                   ep);
        }
        DCMF_CriticalSection_cycle (0);
    }
    DCMF_CriticalSection_exit (0); 
}

typedef struct ARMCIX_DCMF_RequestInfo_t
{
  ARMCIX_DCMF_Request_t              info;
  DCMF_Callback_t                    cb_free;
  struct ARMCIX_DCMF_RequestInfo_t * next;
  unsigned                           unused;
} ARMCIX_DCMF_RequestInfo_t __attribute__ ((__aligned__ (16)));

typedef struct ARMCIX_DCMF_RequestPool_t
{
  ARMCIX_DCMF_RequestInfo_t * head;
  unsigned max;
  unsigned current;
  unsigned increment;
} ARMCIX_DCMF_RequestPool_t;


ARMCIX_DCMF_RequestPool_t __armcix_dcmf_requestpool;

void ARMCIX_DCMF_request_print (char * label)
{
  char str[1024];
  if (label == NULL) str[0] = 0;
  else snprintf (str, 1024, "[%s] ", label);

  fprintf (stderr, "%s__armcix_dcmf_requestpool { head = %p, max = %d, current = %d, increment = %d }\n", str, __armcix_dcmf_requestpool.head, __armcix_dcmf_requestpool.max, __armcix_dcmf_requestpool.current, __armcix_dcmf_requestpool.increment);

  ARMCIX_DCMF_RequestInfo_t * p = __armcix_dcmf_requestpool.head;
  while (p != NULL)
  {
    fprintf (stderr, "    (%p)->next = %p\n", p, p->next);
    p = p->next;
  }
}

void ARMCIX_DCMF_request_initialize (unsigned max, unsigned increment)
{
  unsigned count = max;
  if (increment > 0 && increment < max) count = increment;

  __armcix_dcmf_requestpool.head = (ARMCIX_DCMF_RequestInfo_t *) malloc (sizeof(ARMCIX_DCMF_RequestInfo_t) * count);
  assert (__armcix_dcmf_requestpool.head!=NULL);

  __armcix_dcmf_requestpool.max = max;
  __armcix_dcmf_requestpool.current = count;
  __armcix_dcmf_requestpool.increment = increment;

  unsigned i;
  for (i=1; i<count; i++) __armcix_dcmf_requestpool.head[i-1].next = & __armcix_dcmf_requestpool.head[i];
  __armcix_dcmf_requestpool.head[count-1].next = NULL;

  //ARMCIX_DCMF_request_print ("init");
}

ARMCIX_DCMF_Request_t * ARMCIX_DCMF_request_allocate (DCMF_Callback_t cb_free)
{
  //ARMCIX_DCMF_request_print ("allocate");

  if (__armcix_dcmf_requestpool.head == NULL)
  {
    if (__armcix_dcmf_requestpool.current < __armcix_dcmf_requestpool.max)
    {
      // Allocate a new block of request objects and add them to the request pool.
      __armcix_dcmf_requestpool.head = 
        (ARMCIX_DCMF_RequestInfo_t *) malloc (sizeof(ARMCIX_DCMF_RequestInfo_t) * __armcix_dcmf_requestpool.increment);
      assert (__armcix_dcmf_requestpool.head!=NULL);

      __armcix_dcmf_requestpool.current += __armcix_dcmf_requestpool.increment;
      unsigned i;
      for (i=1; i<__armcix_dcmf_requestpool.increment; i++)
        __armcix_dcmf_requestpool.head[i-1].next = & __armcix_dcmf_requestpool.head[i];
      __armcix_dcmf_requestpool.head[__armcix_dcmf_requestpool.increment-1].next = NULL;
      //fprintf (stderr, "ARMCIX_DCMF_request_allocate() .. allocate a new block of requests (current = %d -> %d)\n", previous, __armcix_dcmf_requestpool.current);
    }
    else
    {
      // The request pool has already reached its maximum size, advance until a request is freed.
      do
      {
        DCMF_Messager_advance ();
      } while (__armcix_dcmf_requestpool.head == NULL);
    }
  }

  // Get the next free request object from the request pool, and set the
  // request pool pointer to the next available request object.
  ARMCIX_DCMF_RequestInfo_t * _request = (ARMCIX_DCMF_RequestInfo_t *) __armcix_dcmf_requestpool.head;
  __armcix_dcmf_requestpool.head = _request->next;

  // Initialize the new request object before return
  _request->cb_free = cb_free;
  _request->next = NULL;

  return (ARMCIX_DCMF_Request_t *) _request;
}

void ARMCIX_DCMF_request_free (ARMCIX_DCMF_Request_t * request)
{
  ARMCIX_DCMF_RequestInfo_t * _request = (ARMCIX_DCMF_RequestInfo_t *) request;

  // Invoke the "free" callback if it is specified.
  if (_request->cb_free.function != NULL)
    _request->cb_free.function (_request->cb_free.clientdata, NULL);

  // Return the request to the free request pool.
  _request->next = __armcix_dcmf_requestpool.head;
  __armcix_dcmf_requestpool.head = _request;
}

/**
 * \brief Generic decrement callback
 *
 * \param[in] clientdata Address of the variable to decrement
 */
void ARMCIX_DCMF_cb_decrement (void * clientdata, DCMF_Error_t *err)
{
  unsigned * value = (unsigned *) clientdata;
  (*value)--;
}

/**
 * \brief Callback function for non-blocking operations
 *
 * \param[in] clientdata The non-blocking handle to complete
 */
void ARMCIX_DCMF_NbOp_cb_done (void * clientdata, DCMF_Error_t *err)
{
  armci_ihdl_t nb_handle = (armci_ihdl_t) clientdata;
  armcix_dcmf_opaque_t * dcmf = (armcix_dcmf_opaque_t *) &nb_handle->cmpl_info;
  dcmf->active--;
  dcmf->connection->active--;
  __global_connection.active--;
}

/**
 * \brief DCMF ARMCI Extention receive memory region short callback
 *
 * \see DCMF_RecvSend
 */
void ARMCIX_DCMF_RecvMemregion1 (void           * clientdata,
                                 const DCQuad   * msginfo,
                                 unsigned         count,
                                 unsigned         peer,
                                 const char     * src,
                                 unsigned         bytes)
{
  ARMCIX_DCMF_Connection_t * connection = (ARMCIX_DCMF_Connection_t *) clientdata;
  memcpy (&connection[peer].remote_mem_region, src, bytes);
  __memregions_to_receive--;
}


/**
 * \brief DCMF ARMCI Extention receive memory region long callback
 *
 * \see DCMF_RecvSend
 */
DCMF_Request_t * ARMCIX_DCMF_RecvMemregion2 (void             * clientdata,
                                             const DCQuad     * msginfo,
                                             unsigned           count,
                                             unsigned           peer,
                                             unsigned           sndlen,
                                             unsigned         * rcvlen,
                                             char            ** rcvbuf,
                                             DCMF_Callback_t  * cb_done)
{
  assert(0);
  ARMCIX_DCMF_Connection_t * connection = (ARMCIX_DCMF_Connection_t *) clientdata;

  *rcvlen = sndlen;
  *rcvbuf = (char *) &connection[peer].remote_mem_region;

  cb_done->function   = (void (*)(void *, DCMF_Error_t *))free; // still works, for now.
  cb_done->clientdata = (void *) malloc (sizeof (DCMF_Request_t));

  return cb_done->clientdata;
}

void ARMCIX_DCMF_Connection_initialize ()
{
  DCMF_CriticalSection_enter(0);

  __global_connection.peer = (unsigned) -1;

  unsigned rank = DCMF_Messager_rank ();
  unsigned size = DCMF_Messager_size ();
  posix_memalign ((void **)&__connection, 16, sizeof(ARMCIX_DCMF_Connection_t) * size);
  bzero ((void *)__connection, sizeof(ARMCIX_DCMF_Connection_t) * size);

  void * base  = NULL;
  size_t bytes = (size_t) -1;

  unsigned i;
  for (i = 0; i < size; i++)
  {
    __connection[i].peer = i;
#warning fix memregion setup to handle non-global address space pinning.
    //DCMF_Result result =
      DCMF_Memregion_create (&__connection[i].local_mem_region,
                             &bytes, (size_t) -1, NULL, 0);
  }

  // Register a send protocol to exchange memory regions
  DCMF_Protocol_t send_protocol;
  DCMF_Send_Configuration_t send_configuration = {
    DCMF_DEFAULT_SEND_PROTOCOL,
    DCMF_DEFAULT_NETWORK,
    ARMCIX_DCMF_RecvMemregion1,
    __connection,
    ARMCIX_DCMF_RecvMemregion2,
    __connection
  };
  DCMF_Send_register (&send_protocol, &send_configuration);

  ARMCIX_CS_Sync();

  DCMF_Request_t request;
  volatile unsigned active;
  DCMF_Callback_t cb_done = { ARMCIX_DCMF_cb_decrement, (void *) &active };

  // Exchange the memory regions
  __memregions_to_receive = size;
  for (i = 0; i < size; i++)
  {
    unsigned peer = (rank+i)%size;
    active = 1;
    DCMF_Send (&send_protocol,
               &request,
               cb_done,
               DCMF_SEQUENTIAL_CONSISTENCY,
               peer,
               sizeof(DCMF_Memregion_t),
               (char *) &__connection[peer].local_mem_region,
               (DCQuad *) NULL,
               0);
    while (active) DCMF_Messager_advance();
  }
  while (__memregions_to_receive) DCMF_Messager_advance();

  DCMF_CriticalSection_exit(0);
}


static inline int
ENV_Bool(char * env, int * dval)
{
  int result = *dval;
  if(env != NULL)
    {
      if (strcmp(env, "0") == 0)
        result = 0;
      else if  (strcmp(env, "0") == 1)
        result = 1;
    }
  return *dval = result;
}

static inline int
ENV_Int(char * env, int * dval)
{
  int result = *dval;
  if(env != NULL)
    {
      result = (int) strtol((const char *)env, NULL, 10);
    }
  return *dval = result;
}

int ARMCIX_CS_Sync(void)
{
   /* register a GI barrier and a local barrier */
   int num_barriers = 0;
   int i;
   int rc = 0;
   unsigned *ranks_array;
   unsigned rank = DCMF_Messager_rank();
   unsigned size = DCMF_Messager_size();
   DCMF_Barrier_Configuration_t barrier_config;

   barrier_config.protocol = DCMF_GI_BARRIER_PROTOCOL;
   barrier_config.cb_geometry = getGeometry;
   rc = DCMF_Barrier_register(&__gbarrier_proto, &barrier_config);
   if(rc == DCMF_SUCCESS)
      num_barriers++;

   barrier_config.protocol = DCMF_LOCKBOX_BARRIER_PROTOCOL;
   rc = DCMF_Barrier_register(&__lbarrier_proto, &barrier_config);
   if(rc == DCMF_SUCCESS)
      num_barriers++;

   assert(num_barriers == 2);
   ranks_array = malloc(sizeof(int) * size);
   for(i = 0; i < (int)size; i++) ranks_array[i] = i;
   
   DCMF_CollectiveProtocol_t *gbar_p = &__gbarrier_proto;
   DCMF_CollectiveProtocol_t *lbar_p = &__lbarrier_proto;
   DCMF_Geometry_initialize(&world_geometry, 0, ranks_array, size, 
      &gbar_p, 1, &lbar_p, 1, &barrier_request, 0, 1);
   volatile unsigned active = 1;
   
   DCMF_Callback_t callback = {barrier_done, (void*)&active};

   DCMF_Barrier(&world_geometry, callback, DCMF_MATCH_CONSISTENCY);

   while(active)
   {
      DCMF_Messager_advance();
   }

   DCMF_Geometry_free(&world_geometry);
   free(ranks_array);
   return(0);
}
   
/**
 * \brief Initialize the DCMF ARMCI resources
 */
int ARMCIX_Init ()
{
  DCMF_CriticalSection_enter(0);

  DCMF_Messager_initialize ();
  ARMCIX_CS_Sync();

  ARMCIX_DCMF_Connection_initialize ();

  /* Determine request pool defaults */
  int ARMCIX_DCMF_REQUESTPOOL_MAX = 1000;
  ENV_Int (getenv ("ARMCIX_DCMF_REQUESTPOOL_MAX"), &ARMCIX_DCMF_REQUESTPOOL_MAX);
  int ARMCIX_DCMF_REQUESTPOOL_INC = 0;
  ENV_Int (getenv ("ARMCIX_DCMF_REQUESTPOOL_INC"), &ARMCIX_DCMF_REQUESTPOOL_INC);
  ARMCIX_DCMF_request_initialize (ARMCIX_DCMF_REQUESTPOOL_MAX, ARMCIX_DCMF_REQUESTPOOL_INC);

  ARMCIX_DCMF_Get_register ();
  ARMCIX_DCMF_Put_register (__connection);
  ARMCIX_DCMF_Acc_register (__connection);
  ARMCIX_DCMF_Fence_register (__connection);
  ARMCIX_DCMF_Rmw_register ();

  /* Initializer helper thread or configure interrupt mode */

  int interrupts = 0;
  ENV_Bool (getenv ("DCMF_INTERRUPT"),  &interrupts);
  ENV_Bool (getenv ("DCMF_INTERRUPTS"), &interrupts);

  int armcix_nothread = 0;
  ENV_Bool (getenv ("ARMCIX_NOTHREAD"),  &armcix_nothread);
  ENV_Bool (getenv ("ARMCIX_NOTHREADS"), &armcix_nothread);

  DCMF_Configure_t config;
  memset (&config, 0x00, sizeof(DCMF_Configure_t));
  config.interrupts = (interrupts==0)?DCMF_INTERRUPTS_OFF:DCMF_INTERRUPTS_ON;

  DCMF_CriticalSection_exit(0);

  DCMF_Messager_configure (&config, &config);
  DCMF_Messager_configure (NULL, &config);

  if (interrupts==0) {
      if ( 0==DCMF_Messager_rank() ) fprintf(stdout,"DCMF interrupts OFF\n");
      if ( armcix_nothread!=1 ) {
         int ret = pthread_create(&armcix_advance_thread, NULL, armcix_advance, NULL);
         if ( ret != 0 ) {
            if( 0==DCMF_Messager_rank() ) fprintf(stdout,"pthread_create failed\n");
            armcix_advance_active = 0;
         } else {
            if( 0==DCMF_Messager_rank() ) fprintf(stdout,"pthread_create succeeded\n");
            armcix_advance_active = 1;
         }
      } else {
         if( 0==DCMF_Messager_rank() ) fprintf(stdout,"ARMCIX helper thread disabled\n");
      }
  } else {
      if ( 0==DCMF_Messager_rank() ) fprintf(stdout,"DCMF interrupts ON\n");
  }

  return 0;
}

int ARMCIX_Finalize ()
{
  if ( armcix_advance_active==1 )
  {
     size_t me = DCMF_Messager_rank();
     fprintf(stdout,"%5u: DCMF_Messager_advance took %8.3f seconds to process %9u events (TOTAL)\n",
                     me,                             tt,                      tp);
     fflush(stdout);

     int ret = pthread_cancel(armcix_advance_thread);
     if ( ret!=0 && 0==DCMF_Messager_rank() ) fprintf(stderr,"pthread_cancel return %d\n",ret);
  }

  DCMF_CriticalSection_enter(0);
  DCMF_Messager_finalize ();
  DCMF_CriticalSection_exit(0);

  return 0;
}



