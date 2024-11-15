CTITLE SIO2CATS
      PROGRAM sio2cats

      IMPLICIT NONE
      INCLUDE '../../../inc/ftk.h'

c     --PURPOSE--

c     --ALGORITHM--

c     --EXAMPLE--

c     --MODIFICATIONS--
c     APR-19-2008 Tian:
c       Created.

c     >>VAR_DEC
c     --INPUT--
c     --Command-line Parameters--
      character*1024 path,opath

c     --OUTPUT--
c     NONE

c     --Local Parameters--
      character*120 filter,dt,suf,tmpstr
      character*1000 files(nmax_site),file,ofile,headers(nmax_head)
      integer*4 fido,ioerr
c     number of sites found
      integer*4 n,is_out_header
c     array index
      integer*4 i,j,fi
c     data matrix
      real*8 data(nmax_row,nmax_col)
      integer*4 nrow,ncol,nhead
c     for date conversion
      integer*4 idate(5),ymd(3),doy
      real*8 jd,secr8,yr
      
c     external functions
      integer iargc,nblen

c     <<VAR_DEC

       if (iargc().lt.2) then
         write(*,*) 'Syntax: sio2cats path opath [TYPE]'
         write(*,*) '    TYPE: sioneu[default],sioxyz'
         stop
      endif
      call getarg(1,path)
      call getarg(2,opath)
c      write(*,*) path(1:nblen(path))
c      write(*,*) opath(1:nblen(opath))

c     input file suffix
      filter='*.neu'
c     output file suffix
      suf='.cats'
      is_out_header=1
      do i=3,iargc()
         call getarg(i,tmpstr)
         if (tmpstr(1:5).eq.'--dt=') then
c     Data Type
            if (nblen(tmpstr).le.5) then
               write(*,'(a)') 'Invalid input parameter '//
     &              tmpstr(1:nblen(tmpstr))
               stop
            endif
            dt=tmpstr(6:nblen(tmpstr))
            if (dt(1:6).eq.'sioneu') then
               filter='*.neu'
            elseif (dt(1:6).eq.'sioxyz') then
               filter='*.xyz'
            else
               write(*,*) 'Wrong time series type:',dt(1:nblen(dt))
            endif
         else if (tmpstr(1:9).eq.'--suffix=') then
            if (nblen(tmpstr).le.8) then
               write(*,'(a)') 'Warning: output file suffix is blank!'
c               stop
            endif
            suf=tmpstr(10:nblen(tmpstr))
         else if (tmpstr(1:9).eq.'--header=') then
            if (nblen(tmpstr).gt.10.and.
     &           tmpstr(10:nblen(tmpstr)).eq.'n') then
               is_out_header=0
            endif
         else
            write(*,'(a)') 'Invalid input option '//
     &           tmpstr(1:nblen(tmpstr)) 
         endif
      enddo
         

      if (iargc().ge.4) then
         call getarg(3,suf)
      endif

      call ffind(path,files,filter,n,1) 
      write(*,'(a,i10)') '#total files:',n
      call getlun(fido)
      do fi=1,n
         file=files(fi)
         write(*,'(a)') '<< '//file(1:nblen(file))
         call read_sio(file,data,nrow,ncol,nhead,headers)
         if (debug) write(*,'(a,2i10)') '  #row/col:',nrow,ncol
         call getfilename(file,ofile)
         ofile=opath(1:nblen(opatH))//pathsep//
     .        ofile(1:nblen(ofile))//suf(1:nblen(suf))
         write(*,'(a)') '>> '//ofile(1:nblen(ofile))
         open(unit=fido,file=ofile)
c     output headers
         if (is_out_header.eq.1) then
            do i=1,nhead
               tmpstr=headers(i)
               write(fido,'(a)') tmpstr(1:nblen(tmpstr))
            enddo
         endif
         do i=1,nrow
c$$$            call mjd_to_ymdhms(data(i,3),idate,secr8)
c$$$c            if (debug) write(*,*) idate
c$$$            ymd(1)=idate(1)
c$$$            ymd(2)=idate(2)
c$$$            ymd(3)=idate(3)
c$$$            call ymd_to_doy(ymd,doy)
c$$$            call jd_to_decyrs(data(i,3)+2400000.5d0,yr)
c            write(fido,700) data(i,1),(data(i,j),j=4,9)
c     Wed Feb 25 12:38:17 CST 2009
            write(fido,701) data(i,1),(data(i,j),j=4,9)
         enddo
 700     format(f9.4,3f15.5,3f10.5)
c$$$  QOCA SOPAC neu fmt
c$$$  mt: read unexpected character
c$$$  apparent state: internal I/O
c$$$  last format: (F9.4,3F11.4,3F8.4)
c$$$  lately reading sequential formatted internal IO
c$$$  Abort
 701     format(f9.4,3f11.4,3f8.4)

         close(fido)
c         stop
      enddo

      STOP
      END
