CTITLE chk_dc_hold
      PROGRAM chk_dc_hold

      IMPLICIT NONE
C      INCLUDE '../../../inc/ftk.h'

c     --PURPOSE--
c     

c     --ALGORITHM--
c     

c     --EXAMPLE--

c     --MODIFICATIONS--

c     >>VAR_DEC
c     --INPUT--
c     --Command-line Parameters--
      integer yr,doy,ndays

c     --OUTPUT--

c     --Local Parameters--
      character*1023 dir,dir_cur,tmpstr,cmdstr
      integer*4 ndaysofyr,yr2
      integer*4 i,j

      character*1023 files(10000),file,ptn,fileun,filez,ofile
      integer*4 nf,ofid,ioerr
      
      character site*4,dtype*1,zipped*1

      logical exi
      
      integer iargc
      integer*4 ndoyr,nblen
      integer*4 status,system



c     <<VAR_DEC

      if (iargc().lt.3) then
         write(*,'(a)') 'Usage:'
         write(*,'(4x,a)') 'chk_dc_hold YEAR DOY NDAYS'
         write(*,'(8x,a)') '[--dir=ROOT_DIR] [--ofile=OUT_FILE]'
         write(*,'(8x,a)') '[--type=D|O|N|M]'
         write(*,'(12x,2a)') 'ROOT_DIR:'
         write(*,'(16x,a)') 'parent directory of rinex/nav/met/...'
         write(*,'(16x,a)') 'Default is current directory (`pwd`).'
         write(*,'(12x,a)') 'Types:'
         write(*,'(16x,2a)') 'D - Hatanaka RINEX observations',
     &        '(SITEDOY0.YRd.Z)'
         write(*,'(16x,2a)') 'O - RINEX observations',
     &        '(SITEDOY0.YRo.Z)'
         write(*,'(16x,2a)') 'N - RINEX broadcast emphemis',
     &        '(SITEDOY0.YRn.Z)'
         write(*,'(16x,2a)') 'M - RINEX meteorological observation',
     &        '(SITEDOY0.YRm.Z)'
         write(*,'(12x,2a)') 'OUT_FILE:'
         write(*,'(16x,a)') 'Output file name.'
         write(*,'(16x,a)') 'Default is standard output device(screen).'
         stop
      endif
      
      call getarg(1,tmpstr)
      read(tmpstr,*) yr
      call getarg(2,tmpstr)
      read(tmpstr,*) doy
      call getarg(3,tmpstr)
      read(tmpstr,*) ndays

      ndaysofyr=ndoyr(yr)
c      ndaysofyr=365

c      dir='/cygdrive/h/gps/igs/pub/rinex'
      dir='.'
c      if (yr.ge.2002) then
c         dir='/cygdrive/i/data.server/pub/rinex'
c      endif

      if (yr.ge.2000) then
         yr2=yr-2000
      else
         yr2=yr-1900
      endif

c     for debug in solaris
c      dir='/export/home/tianyf/tmp'
c      dir='/igs1/gps/igs/pub/rinex'
      ofid=6
c     default output device = screen/console

      do i=4,iargc()
         call getarg(i,tmpstr)
c     write(*,*) tmpstr(1:nblen(tmpstr))
         if (tmpstr(1:6).eq.'--dir=') then
            write(*,'(1x,a)') 'Working in '//tmpstr(8:nblen(tmpstr))
            dir=tmpstr(7:nblen(tmpstr))
         else if(tmpstr(1:8).eq.'--ofile=') then
            ofile=tmpstr(9:nblen(tmpstr))
            call getlun(ofid)
            open(unit=ofid,file=ofile,iostat=ioerr)
            if (ioerr.ne.0) then
               write(*,*) ' Error open output file.'
               stop
            endif             
          else
             write(*,'(2a)') 'Error: invalid parameter:',
     &            tmpstr(1:nblen(tmpstr))
             stop             
          endif
       enddo
       
 

c      ptn='*.Z'


      do i=1,ndays

         write(*,700) ' '//dir(1:nblen(dir)),yr,doy
         write(dir_cur,700) dir(1:nblen(dir)),yr,doy
 700     format(A,"/",I4,"/",I3.3)
c         write(*,*) yr,doy,i
c     How to get a listing a current files?
c         inquire (file=dir_cur, exist=exi)
c         inquire (directory=dir_cur, exist=exi)
         call dir_test(dir_cur,exi)
c     not working with ifort. Why?
c         write(*,*) 'EX:',exi
c     
         if (.NOT.exi) then
            write(*,*) '  Not Exist: ',dir_cur(1:nblen(dir_cur))
            goto 800
         endif

         write(ptn,701) doy,yr2
 701     format("????",I3.3,"?.",I2.2,"*")

         write(*,*) ' working in ',dir_cur(1:nblen(dir_cur))
         write(*,*) ' searcing for ',ptn(1:nblen(ptn))

c         status=system('ls')
         call ffind(dir_cur,files,ptn,nf,1)
         write(*,*)' NF:',nf
c         goto 800
         if (nf.le.0) goto 800
         do j=1,nf
            file=files(j)
            call getfilename(file,tmpstr)
            site=tmpstr(1:4)
            dtype=tmpstr(12:12)
            call getfileext(file,tmpstr)
            if (tmpstr(1:1).eq.'Z') then
               zipped='y'
            else
               zipped='n'
            ENDIF
            
c            write(*,*) file(1:nblen(file)),
c            write(*,703) site,yr,doy,dtype,zipped,file(1:nblen(file))
            write(ofid,703) site,yr,doy,dtype,zipped,file(1:nblen(file))
 703        format(a4,1x,i4,1x,i3.3,1x,a1,1x,a1,1x,a)
c            write(*,*) 'ext:',tmpstr(1:nblen(tmpstr))
            
           
         enddo

 800     doy=doy+1         
         if (doy.gt.ndaysofyr) then
c            write(*,*) ' Exceed the day boundary of current year!'
c            goto 898        
c     no warp of year-boundary now.
            doy=1
            yr=yr+1
            ndaysofyr=ndoyr(yr)
            if (yr.ge.2000) then
               yr2=yr-2000
            else
               yr2=yr-1900
            endif
c            ndaysofyr=365
c$$$            if (yr.ge.2002) then
c$$$               dir='/cygdrive/i/data.server/pub/rinex'
c$$$               dir='/igs2/j/data.server/pub/rinex'
c$$$            endif
         endif
      enddo

 898  continue
      if (ofid.ne.6) close(ofid)

      STOP
      END
