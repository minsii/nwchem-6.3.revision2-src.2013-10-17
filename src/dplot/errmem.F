      SubRoutine ErrMem(LResult,Note,iRC)
*
* $Id: errmem.F 19697 2010-10-29 16:57:34Z d3y133 $
*
      Implicit None
#include "errquit.fh"
*
************************************************************************
*
*---- Arguments of a ErrMem call
      Logical LResult
      Character*(*) Note
      Integer iRC
*
************************************************************************
*
      If (LResult) Then
         Return
      Else
         Call ErrQuit(Note,iRC, UNKNOWN_ERR)
      End If
*
*---- Normal termination
      End
