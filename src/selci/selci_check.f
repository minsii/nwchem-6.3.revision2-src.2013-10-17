      subroutine selci_check(node)
*
* $Id: selci_check.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      logical opn
      character*80 filename
      do i = 1, 99
         if (i.ne.5 .and. i.ne.6) then
            inquire(i,opened=opn,name=filename)
            if (opn) then
               write(6,*) ' node ', node, ' unit ', i,
     $              ' name ', filename
            endif
         endif
      enddo
      end

            
