      subroutine add_hash_block(d_file,array,size,hash,key)
c
c $Id: add_hash_block.F 19706 2010-10-29 17:52:31Z d3y133 $
c
      implicit none
      integer d_file
      integer size
      integer hash(*)
      integer key
      integer offset
      double precision array(size)
c
      call tce_hash(hash,key,offset)
      call add_block(d_file,array,size,offset)
      return
      end









      subroutine add_hash_block_nb(d_file,array,size,hash,key,nbh)
c
      implicit none
c
      integer d_file
      integer size
      integer hash(*)
      integer key
      integer offset
      integer nbh
      double precision array(size)
c
      call tce_hash(hash,key,offset)
      call add_block_nb(d_file,array,size,offset,nbh)
c
      return
      end
