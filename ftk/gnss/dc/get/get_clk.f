CTITLE get_orb
      PROGRAM get_clk

      IMPLICIT NONE
      INCLUDE '../../../inc/ftk.h'

c     --PURPOSE--
c     Download SP3/gfile from IGS Data Center.

c     --ALGORITHM--
c
c     CDDIS directories:
c$$$  ncftp /gps/products/1456 > ls *.sp3.Z
c$$$  emr14560.sp3.Z         igr14562.sp3.Z         igu14562_18.sp3.Z      jpl14566.sp3.Z
c$$$  emr14561.sp3.Z         igr14563.sp3.Z         igu14563_00.sp3.Z      mit14560.sp3.Z
c$$$  emr14562.sp3.Z         igr14564.sp3.Z         igu14563_06.sp3.Z      mit14561.sp3.Z
c$$$  emr14563.sp3.Z         igr14565.sp3.Z         igu14563_12.sp3.Z      mit14562.sp3.Z
c$$$  emr14564.sp3.Z         igr14566.sp3.Z         igu14563_18.sp3.Z      mit14563.sp3.Z
c$$$  emr14565.sp3.Z         igs14560.sp3.Z         igu14564_00.sp3.Z      mit14564.sp3.Z
c$$$  emr14566.sp3.Z         igs14561.sp3.Z         igu14564_06.sp3.Z      mit14565.sp3.Z
c$$$  esa14560.sp3.Z         igs14562.sp3.Z         igu14564_12.sp3.Z      mit14566.sp3.Z
c$$$  esa14561.sp3.Z         igs14563.sp3.Z         igu14564_18.sp3.Z      ngs14560.sp3.Z
c$$$  esa14562.sp3.Z         igs14564.sp3.Z         igu14565_00.sp3.Z      ngs14561.sp3.Z
c$$$  esa14563.sp3.Z         igs14565.sp3.Z         igu14565_06.sp3.Z      ngs14562.sp3.Z
c$$$  esa14564.sp3.Z         igs14566.sp3.Z         igu14565_12.sp3.Z      ngs14563.sp3.Z
c$$$  esa14565.sp3.Z         igu14560_00.sp3.Z      igu14565_18.sp3.Z      ngs14564.sp3.Z
c$$$  esa14566.sp3.Z         igu14560_06.sp3.Z      igu14566_00.sp3.Z      ngs14565.sp3.Z
c$$$  gfz14560.sp3.Z         igu14560_12.sp3.Z      igu14566_06.sp3.Z      ngs14566.sp3.Z
c$$$  gfz14561.sp3.Z         igu14560_18.sp3.Z      igu14566_12.sp3.Z      sio14560.sp3.Z
c$$$  gfz14562.sp3.Z         igu14561_00.sp3.Z      igu14566_18.sp3.Z      sio14561.sp3.Z
c$$$  gfz14563.sp3.Z         igu14561_06.sp3.Z      jpl14560.sp3.Z         sio14562.sp3.Z
c$$$  gfz14564.sp3.Z         igu14561_12.sp3.Z      jpl14561.sp3.Z         sio14563.sp3.Z
c$$$  gfz14565.sp3.Z         igu14561_18.sp3.Z      jpl14562.sp3.Z         sio14564.sp3.Z
c$$$  gfz14566.sp3.Z         igu14562_00.sp3.Z      jpl14563.sp3.Z         sio14565.sp3.Z
c$$$  igr14560.sp3.Z         igu14562_06.sp3.Z      jpl14564.sp3.Z         sio14566.sp3.Z
c$$$  igr14561.sp3.Z         igu14562_12.sp3.Z      jpl14565.sp3.Z


c     --EXAMPLE--

c     --MODIFICATIONS--

c     >>VAR_DEC
c     --INPUT--
c     --Command-line Parameters--
      integer year,doy,ndays
      character*10 archive

c     --OUTPUT--

c     --Local Parameters--
      character*4096 dir,dir_cur,dir_remote,tmpstr,cmdstr,host,tmpstr2
      character*1023 file_erp, file_clk
      character*10 orbType
      integer*4 ndaysofyr, yr,gpsw,gpsd,gpswOld
      integer*4 i,j

      character*512 files(1000),file,ptn,file_cmd,file_log,dir_log
      character*512 file_remote,file_local
      integer*4 nf,fid,ioerr

      logical exi
      
      integer iargc
      integer*4 ndoyr,nblen
      integer*4 status,system
      integer*4 today(3),now(3)



c     <<VAR_DEC

      if (iargc().lt.3) then
         write(*,*) 'Usage: get_orb YEAR|YR DOY NDAYS'
         write(*,*) '               [--orbt=igsf|gfile|igsr] '
         write(*,*) '               [--dir=output_directory]'
         write(*,*) '                   Default: `pwd`'
         write(*,*) '               [--dirlog=log_directory]'
         write(*,*) '                   ABSOLUTE path name.'   
         write(*,*) '               [--archive=sopac|cddis|kasi]'
         write(*,*) '                      Default:cddis'
         write(*,*) '   output_directory is the home '//
     .        'directory of orbits...'
         write(*,*) '     e.g.: /igs/pub/products'
         write(*,*) 'EXAMPLES'
         write(*,*) '    get_orb 2008 1 20'
         write(*,*) 'For more information, see get_orb man pages.'
         stop
      endif

c     default setting
      orbType='igsf'
      archive='cddis'

      call getarg(1,tmpstr)
      read(tmpstr,*) year
      call getarg(2,tmpstr)
      read(tmpstr,*) doy
      call getarg(3,tmpstr)
      read(tmpstr,*) ndays

c     for debug in solaris
      dir='/export/home/tianyf/tmp/rinex'
c     for debug in solaris
      dir='/export/home/tianyf/tmp/products'
      dir='.'
      dir_log='/tmp'
      dir_log='./'

      do i=4,iargc()
         call getarg(i,tmpstr)
c     write(*,*) tmpstr(1:nblen(tmpstr))
         if (tmpstr(1:7).eq.'--orbt=') then
            write(*,*) 'using orbit:'//tmpstr(8:nblen(tmpstr))
            orbType=tmpstr(8:nblen(tmpstr))
            write(*,*) 'Orbit Type:',orbType
         else if (tmpstr(1:6).eq.'--dir=') then
            write(*,*) 'using dir:'//tmpstr(7:nblen(tmpstr))
            dir=tmpstr(7:nblen(tmpstr))
c            stop
         else if (tmpstr(1:10).eq.'--archive=') then
            archive=tmpstr(11:nblen(tmpstr))
            write(*,*) 'using archive:'//archive(1:nblen(archive))
         else if (tmpstr(1:9).eq.'--dirlog=') then
c     write(*,*) nblen(tmpstr)
            if (nblen(tmpstr).le.9) then
               write(*,*) 'Error: invalid parameter ',
     &              tmpstr(1:nblen(tmpstr))
               stop
            endif
            dir_log=tmpstr(10:nblen(tmpstr))
            write(*,*) 'INFO: temporary path is ',
     &           dir_log(1:nblen(dir_log))
         else
            write(*,*) 'Error: invalid command-line parameters!'
            stop
         endif
      enddo


      if (orbType(1:4).eq.'gpsf') then
         orbType='igs'
      else if (orbType(1:5).eq.'gfile') then
         orbType='gfile'
      else if (orbType(1:4).eq.'igsr') then
         orbType='igr'
      else
         orbType='igs'
      endif

      ndaysofyr=ndoyr(year)
      if (year.ge.2000) then
         yr=year-2000
      else if (year.gt.1950) then
         yr=year-1900
      endif

     
c     open command file
      call getlun(fid)
      call idate(today)
      call itime(now)
      write(file_cmd,703) dir_log(1:nblen(dir_log)),pathsep,
     &     today,now,'.cmd'
 703  format(a,a1,"get-orb-",I2.2,I2.2,I4.4,"-",3I2.2,a)
c      write(*,*) file_cmd,today,now
c      write(file_log,703) today,now,'.log'
      write(file_log,703) dir_log(1:nblen(dir_log)),pathsep,
     &     today,now,'.log'
c      stop
      open(file=file_cmd,unit=fid,iostat=ioerr)
      if (ioerr.ne.0) then
         write(*,*) 'Error: cannot open temporary command file'
         stop
      endif
      write(fid,*) 'binary'

c     Loop for each day
      nf=0
      gpswOld=-1
      do i=1,ndays
c         write(*,700) dir(1:nblen(dir)),yr,doy
c     Calculate GPSW/GPSD
         call doygwk(doy,year,gpsw,gpsd)
         write(dir_cur,700) dir(1:nblen(dir)),gpsw
 700     format(A,"/",I4.4)
c         write(*,*) yr,doy,i
c         write(*,*) dir_cur(1:nblen(dir_cur)
         write(file,701) dir_cur(1:nblen(dir_cur)),
     &        orbType(1:nblen(orbType)),gpsw,gpsd
 701     format(A,"/",a3,I4.4,I1,".clk.Z")
c         write(*,*) file(1:nblen(file))
c     ,orbType
c     , year,doy,gpsw,gpsd
c         goto 800
         inquire (file=file, exist=exi)
c         write(*,*) 'EX:',exi
         if (exi) then
            write(*,*) 'already exist: '//
     &           file(1:nblen(file))
            goto 800
c     Here, checking the validation of existing files is not performed.
c
         endif
         
         write(*,*) 'queuing ',file(1:nblen(file))
c     first, create the target directory.
         cmdstr='mkdir -p '//dir_cur(1:nblen(dir_cur))
         status=system(cmdstr)
         if (status.ne.0) then
            write(*,*) 'Error: cannot create output directory [',
     &           dir_cur(1:nblen(dir_cur)),'], skipping'
            goto 800
         endif

c     append the file to cmd_file
c         write(fid,*) 'lcd '//dir_cur(1:nblen(dir_cur))

         if (archive.eq.'sopac') then
            write(dir_remote,704) gpsw
 704        format("/pub/products/",I4.4)
         else if (archive.eq.'gpsdc') then
            write(dir_remote,704) gpsw
         else if (archive.eq.'cddis') then
            write(dir_remote,707) gpsw
 707        format("/gps/products/",I4.4) 
         else if (archive.eq.'kasi') then
            write(dir_remote,707) gpsw
 708        format("/gps/data/daily/",I4.4,"/",I3.3,"/",I2.2,"n")  
         else if (archive.eq.'pbo') then
            write(dir_remote,709) gpsw
 709        format("/pub/rinex/obs/",I4.4,"/",I3.3)
         else
            write(*,*) 'Error: wrong archive [',
     &           archive(1:nblen(archive)),']'
            stop
         endif

         if (gpsw.ne.gpswOld) then 
            gpswOld=gpsw
c            write(fid,*) 'lcd ..'
            write(fid,*) 'lcd '//dir_cur(1:nblen(dir_cur))
            write(fid,*) 'cd '//dir_remote(1:nblen(dir_remote))
         endif

         write(file_remote,702) orbType,gpsw,gpsd
 702     format(A3,I4.4,I1,".clk.Z")
c         write(file_local,702) 'brdc',doy,yr
         write(fid,*) 'get -z '//file_remote(1:nblen(file_remote))//
     &        ' '//file_remote(1:nblen(file_remote))
         nf=nf+1


 800     doy=doy+1         
         if (doy.gt.ndaysofyr) then
            doy=1
            year=year+1
            if (year.ge.2000) then
               yr=year-2000
            else if (year.gt.1950) then
               yr=year-1900
            endif
            ndaysofyr=ndoyr(year)
c            if (year.ge.2002) then
c               dir='/cygdrive/i/data.server/pub/rinex'
c            endif
         endif
c         write(*,*) year
      enddo

      write(fid,*) 'quit'

      close(fid)

c     download the file
      if (nf.ge.1) then
         write(*,*) '#files to be download:',nf
         if (archive(1:5).eq.'sopac') then
            host='garner.ucsd.edu'
         else if (archive(1:5).eq.'gpsdc') then
            host='gpsdc'
         else if (archive(1:5).eq.'cddis') then
            host='cddis.gsfc.nasa.gov'
         else if (archive(1:4).eq.'kasi') then
            host='nfs.kasi.re.kr'
         else if (archive(1:3).eq.'pbo') then
            host='data-out.unavco.org'
         endif
         cmdstr='ncftp -u anonymous '//host(1:nblen(host))//
     &        ' < '//file_cmd(1:nblen(file_cmd))
c     &           //' | grep -v "^230"'
     &        //' > '//file_log(1:nblen(file_log))
     &        //' 2>&1 '
         write(*,*) 'executing ... '//cmdstr(1:nblen(cmdstr))

C         cmdstr='ncftp garner.ucsd.edu < '//file_cmd(1:nblen(file_cmd))
C     &        //' | grep -v "^230" >> '//file_log(1:nblen(file_log))
C         write(*,*) 'executing ... '//cmdstr(1:nblen(cmdstr))
c         stop
         status=system(cmdstr)
      endif
      
c     delete temporary files
      cmdstr='rm -f '//file_cmd(1:nblen(file_cmd))
c      status=system(cmdstr)

      STOP
      END
