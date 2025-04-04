      subroutine read_sio(file,data,nrow,ncol,nhead,headers)

C     Inputs:
c     file: character*256
c     firstepoch: int(2)
c     lastepoch: int(2)
c     xyzref: double(3)
c     neuref: double(3)
c     headers: character*256 n
c     data: double (M*N)

c     
      implicit none
      include '../../../inc/ftk.h'
c     --

      character*(*) file
      character*1000 buf

      integer*4 fid,ioerr
      integer*4 nrow,ncol,nhead
 
      character*(*) headers(nmax_head)
      real*8 data(nmax_row,nmax_col)

      integer*4 i,j
      integer*4 nblen

      
c      file='/home/tianyf/data/sio/bjfsCleanUnf.neu'
c      file='/e/data/garner.ucsd.edu/pub/timeseries/'//
c     .  'reason/sopac/cleanedNeuUnfTimeSeries20070430/bjfsCleanUnf.neu'
c      file='/e/data/garner.ucsd.edu/pub/timeseries/reason/sopac/'//
c     . 'cleanedNeuUnfTimeSeries20070430/bjfsCleanUnf.neu'
c      file='e:\\tmp\\bjfsCleanUnf.neu'
c      write(*,*) file
 
      nhead=100
      call file_info (file,nrow,ncol,nhead,headers)
      if (nrow.gt.nmax_row) then
         write(*,'(2a,i6,a,i6,a)') '[read_sio]ERROR: number of ',
     +        'lines (' ,nrow,
     +        ') exceeds program limit (',nmax_row,')!!!'
         write(*,'(17x,2a)') 'Please edit the nmax_row item in',
     +        ' $GPSF/inc/cgps.h .'
         stop
      endif
c      nrow=nrow-nhead-1
c     MOD:Tian:JUL26/07:What about the last null (with nothing) line.
      nrow=nrow-nhead
c      write(*,*) nrow, ncol,nhead

      fid=90
      call getlun(fid)
c      write(*,*) 'fid is ',fid, 'for ', file(1:nblen(file))

      open(unit=fid,file=file)  
      i=0   
      if (nhead.eq.0) goto 801
c     MOD Tian Jun-23-2008
c       Fixed a bug when there are no header lines.
 30   read(fid,'(a1000)', iostat=ioerr, end=90) buf
      i=i+1
c      if (buf(1:1).eq.'#') then
c         write(*,*) buf(1:nblen(buf))
      if (i.ge.nhead) goto 801
      goto 30
c      endif
c$$$      if (index(bufline,'END OF HEADER').gt.1) then
c$$$         write(*,*) 'end of header, data section start'
c$$$         goto 32
c$$$      endif
801   continue
c       write(*,*) buf(1:nblen(buf))
c      strsplit(buf,' ',n,strs)

c     the below code cannot work for files converted by IDL; however,
c     it do work for the origional copy.
c      read(fid,*), ((data(i,j),j=1,ncol),i=1,nrow)

c     The following line-by-line reading works for both types of data.


c     read the data line by line
      do i=1,nrow
c         write(*,*) i
         read(fid,*,end=90) (data(i,j),j=1,ncol)
c         write(*,'(9f10.4)') (data(i,j),j=1,ncol)
      enddo
      
c      do i=nrow-5,nrow
c      	write(*,*) 'line',i,(data(i,j),j=1,ncol)
c      enddo
c      goto 30
 90   continue
      close(fid)
      return
      end


