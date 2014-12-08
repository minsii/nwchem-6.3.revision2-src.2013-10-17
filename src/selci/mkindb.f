      subroutine selci_mkindb(norbs, iocc, indbar, listd, lists, ns, nd)
*
* $Id: mkindb.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      dimension iocc(norbs), indbar(norbs), listd(norbs), lists(norbs)
c
c     make indbar array and lists of socc/docc orbitals
c     indbar(i) = position of orbital i if placed in the ordered
c                 set of singly occupied orbitals
c
      ns = 0
      nd = 0
      do 10 i = 1,norbs
         indbar(i) = ns + 1
         if (iocc(i).eq.1) then
            ns = ns + 1
            lists(ns) = i
         else if (iocc(i).eq.3) then
            nd = nd + 1
            listd(nd) = i
         endif
 10   continue
c
      end
