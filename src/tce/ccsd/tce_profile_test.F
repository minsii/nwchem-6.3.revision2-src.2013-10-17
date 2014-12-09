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

      call tpi_push_name_level1("level-1")
      call tpi_push_name_level2("level-2-1")
      call tpi_start_timer(1)
      do i=1,1000
        j = j + i*i*i*1000 + i*0.5
      enddo
      call tpi_stop_timer(1)
      call tpi_pop_name_level2("level-2-1")

      call tpi_push_name_level2("level-2-2")
      call tpi_start_timer(1)
      do i=1,1000
        j = j + i*i*i*1000 + i*0.5
      enddo
      call tpi_stop_timer(1)

      call tpi_start_timer(2)
      do i=1,1000
        j = j + i*(i+1)*i*1000 + i*0.5
      enddo
      call tpi_stop_timer(2)
      call tpi_pop_name_level2("level-2-2")
      call tpi_pop_name_level1("level-1")
      call tpi_stop()

      call mpi_finalize(error)    

      end
