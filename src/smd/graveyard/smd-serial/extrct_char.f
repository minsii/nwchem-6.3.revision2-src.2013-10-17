c
c $Id: extrct_char.f 19707 2010-10-29 17:59:36Z d3y133 $
c

      SUBROUTINE ex_4char(iposition,irecord,word)

      implicit none

      integer i,iposition,irec_len

      character word*4,letter*1,irecord*1

      parameter(irec_len=100)

      dimension letter(0:3),irecord(irec_len)

      do i=0,3
        letter(i)=irecord(iposition+i)
      enddo

      word=letter(0)//letter(1)//letter(2)//letter(3)

      return

      END
