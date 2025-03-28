CTITLE
       program rdhold
c     file,site,year,doy,rtype,isInDb
c     --PURPOSE--

c     --ALGORITHM--

c     --EXAMPLE--

c     --MODIFICATIONS--

      IMPLICIT NONE
C      INCLUDE '../../../inc/ftk.h'

c     >>VAR_DEC
c     --INPUT--
      character*1023 file
      character*10230 sitestr
      integer*4 year,doy

c     --OUTPUT--
      character*1 rtype
      integer*4 isInDb

c     --EXTERNAL--

c     --Local Parameters--
      integer*4 fid,ioerr,pos
      character*1023 tmpstr,line
      character*4 sitet
      integer*4 yeart,doyt

      integer*4 nblen,iargc

c     <<VAR_DEC

c      url=''
      if (iargc().lt.4) then
         write(*,*) 'rdhold holdfile year doy sites'
         stop
      endif

      call getarg(1,file)
      call getarg(2,tmpstr)
      read(tmpstr,*) year
      call getarg(3,tmpstr)
      read(tmpstr,*) doy
      call getarg(4,sitestr)

c      write(*,*) sitestr(1:nblen(sitestr))
      call getlun(fid)
c      write(file,('2a')) 'N:\\mirror_ftp\\garner.ucsd.edu\\pub\\',
c      write(file,('2a')) 'N:\mirror_ftp\garner.ucsd.edu\pub\GSAC\',
c     &     'GSAC\\full\\sopac.2001.001.full.dhf'
      open(unit=fid,file=file,iostat=ioerr)
      if (ioerr.ne.0) then
         write(*,'(a)') ' [QUERY_HOLD_DB]FATAL: error when open file',
     &        file(1:nblen(file)),'.'
         goto 899
      endif
      
      isInDb=0
 800  read(fid,'(a1023)',end=899) line
      if (line(1:1).eq.' ') goto 800
c      pos=index(line,site)
c      if (pos.gt.0) then
c         url=line
c         goto 899
c      endif
      read(line,'(a4,1x,i4,1x,i3,1x,a1)') sitet,yeart,doyt,rtype
      if (doyt.lt.doy) goto 800
      pos=index(sitestr,sitet)
      if (pos.gt.0.and.yeart.eq.year.and.doyt.eq.doy) then
         write(*,'(a4)') sitet
c         isInDb=1
c         goto 899
      endif
      if (doyt.gt.doy) goto 899
      goto 800
      
 899  close(fid)

c      RETURN
      END
