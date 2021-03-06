c      program file_info
      subroutine file_info(file,nrow,ncol,nhead,headers)
      integer*4 nrow,ncol,nhead
      character*(*) file,headers(nhead)
     
      integer*4 ioerr,fid,i
      character*1000 buf
      character*1000 tmpstrs(1000)
      integer*4 nblen
      integer*4 nrowL,ncolL,nheadL

c      file='/home/tianyf/data/sio/bjfsCleanUnf.neu'
c      write(*,*) file
      nrowL=0
      ncolL=0
      nheadL=0
c      write(*,*) 'getting fid for file_info'
      call getlun(fid)
c      write(*,*) 'fid:',fid
      open(unit=fid,file=file,status='old',iostat=ioerr)
      if (ioerr.ne.0) then
         write(*,*) 'Error: cannot open file [',
     &        file(1:nblen(file)),'].'
         stop
      endif
      
c      write(*,*) 'here.'
 30   read(fid, '(a)', iostat=ioerr, end=90) buf
c      write(*,*) buf(1:nblen(buf))
      call trimlead(buf)
      if (buf(1:1).eq.'#') then
         nheadL=nheadL+1
         headers(nheadL)=buf
      endif
      nrowL = nrowL+1
      goto 30
 90   continue
      close(fid)
      call strsplit(buf, ' ', ncolL, tmpstrs)
c      write(*,*) 'number of headers:', nheadL
c      write(*,*) (headers(i),i=1,nhead)
c      write(*,*) '#row:', nrowL
c      write(*,*) '#col:', ncolL
c      write(*,*) buf
      nrow=nrowL
      ncol=ncolL
      nhead=nheadL
      return
      end
