      program tpi_profile_test
      implicit none
include 'mpif.h'
      integer error
      integer i
      integer j
      integer max_timers
      integer timer_id

      call mpi_init(error)    

      max_timers = 5
      call tpi_start(max_timers)

      call tpi_push_name("test_name1")
      timer_id = 1
      call tpi_start_timer(timer_id)
      do i=1,100
        j = j + i*i
      enddo
      call tpi_stop_timer(timer_id)
      call tpi_pop_name("test_name1")

      call tpi_push_name("test_name2")
      timer_id = 1
      call tpi_start_timer(timer_id)
      do i=1,100
        j = j + i*i
      enddo
      timer_id = 2
      call tpi_start_timer(timer_id)
      do i=1,100
        j = j + i*(i+1)
      enddo
      call tpi_stop_timer(timer_id)
      call tpi_pop_name("test_name2")

      call tpi_stop()

      call mpi_finalize(error)    

      end
