      subroutine dpssb3 (ido,l1,cc,ch,wa1,wa2)
*
* $Id: dpssb3.F 19695 2010-10-29 16:51:02Z d3y133 $
*
      double precision cc(ido,3,l1), ch(ido,l1,3), wa1(1), wa2(1),
     1 ci2, ci3, cr2, cr3, di2, di3, dr2, dr3, taui, taur, ti2, tr2
      data taur / -0.5 d0 /
      data taui  /  0.8660254037 8443864676 3723170752 93618d0/
c
c     one half sqrt(3) = .866025.....  .
c
      if (ido .ne. 2) go to 102
      do 101 k=1,l1
         tr2 = cc(1,2,k)+cc(1,3,k)
         cr2 = cc(1,1,k)+taur*tr2
         ch(1,k,1) = cc(1,1,k)+tr2
         ti2 = cc(2,2,k)+cc(2,3,k)
         ci2 = cc(2,1,k)+taur*ti2
         ch(2,k,1) = cc(2,1,k)+ti2
         cr3 = taui*(cc(1,2,k)-cc(1,3,k))
         ci3 = taui*(cc(2,2,k)-cc(2,3,k))
         ch(1,k,2) = cr2-ci3
         ch(1,k,3) = cr2+ci3
         ch(2,k,2) = ci2+cr3
         ch(2,k,3) = ci2-cr3
  101 continue
      return
c
  102 do 104 k=1,l1
         do 103 i=2,ido,2
            tr2 = cc(i-1,2,k)+cc(i-1,3,k)
            cr2 = cc(i-1,1,k)+taur*tr2
            ch(i-1,k,1) = cc(i-1,1,k)+tr2
            ti2 = cc(i,2,k)+cc(i,3,k)
            ci2 = cc(i,1,k)+taur*ti2
            ch(i,k,1) = cc(i,1,k)+ti2
            cr3 = taui*(cc(i-1,2,k)-cc(i-1,3,k))
            ci3 = taui*(cc(i,2,k)-cc(i,3,k))
            dr2 = cr2-ci3
            dr3 = cr2+ci3
            di2 = ci2+cr3
            di3 = ci2-cr3
            ch(i,k,2) = wa1(i-1)*di2+wa1(i)*dr2
            ch(i-1,k,2) = wa1(i-1)*dr2-wa1(i)*di2
            ch(i,k,3) = wa2(i-1)*di3+wa2(i)*dr3
            ch(i-1,k,3) = wa2(i-1)*dr3-wa2(i)*di3
  103    continue
  104 continue
c
      return
      end
