CTITLE
       program rdgsac
c     (file,site,url)
c     --PURPOSE--

c     --ALGORITHM--

c     --EXAMPLE--

c     --MODIFICATIONS--

      IMPLICIT NONE
C      INCLUDE '../../../inc/ftk.h'

c     >>VAR_DEC
c     --INPUT--
      character*1023 file
      character*10000 sitestr
c     site str is seperated by comma (,)

c     --OUTPUT--
c      character*(*) url
      character*4 osites(1000)

c     --EXTERNAL--

c     --Local Parameters--
      integer*4 fid,ioerr,pos,np
      character*10230 tmpstr,line
      character*4 site
      character*1023 parts(100),dtype,filer

      integer*4 nblen,iargc

c     <<VAR_DEC

c      url=''

      if (iargc().lt.2) then
         write(*,*) 'Usage: rdgsac gsac_file sites_to_found'
         stop
      endif
      
      call getarg(1,file)
      call getarg(2,sitestr)

      call getlun(fid)
      open(unit=fid,file=file,iostat=ioerr)
      if (ioerr.ne.0) then
         write(*,'(a)') ' [QUERY_GSAC_DHF]FATAL: error when open file',
     &        file(1:nblen(file)),'.'
         goto 899
      endif
      
 800  read(fid,'(a1023)',end=899) line
      call trimlead(line)
      if (line(1:1).eq.'#') goto 800
      call strsplit(line,';',np,parts)
      if (np.lt.4) then 
         goto 800
      endif
      dtype=parts(3)
c      write(*,*) dtype
      if (dtype(1:nblen(dtype)).ne.'rinex_obs') then
         goto 800
      endif
      filer=parts(4)
      read(filer,'(a4)') site
c      write(*,*) site
      
      pos=index(sitestr,site)
c      write(*,*)
      if (pos.gt.0) then
         write(*,'(a4)') site
c         goto 899
      endif
      goto 800
      
 899  close(fid)
c      write(*,*) sitestr

c      RETURN
      END
