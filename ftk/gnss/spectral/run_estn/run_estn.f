CTITLE SIO2CATS
      PROGRAM run_estn

      IMPLICIT NONE
      INCLUDE '../../../inc/ftk.h'

c     --PURPOSE--

c     --ALGORITHM--
c$$$  Langbein, J. (2008), Noise in GPS displacement measurements from 
c$$$  Southern California and Southern Nevada, J. Geophys.
c$$$  Res., 113, B05405, doi:10.1029/2007JB005247.
c
c$$$  Table 4. Best Noise Model for SCIGN and SBAR Data
c$$$  Noise Model
c$$$  Percentage of All Sites
c$$$  North East Vertical
c$$$  FL 32 27 41
c$$$  RW 21 35 18
c$$$  PL 11 11 6
c$$$  FLRW 20 16 21
c$$$  FOGMRW 8 3 9
c$$$  BPPL 8 9 5

c$$$  Six different noise models were tested, which
c$$$  were flicker noise (FL), random-walk noise (RW), power law
c$$$  noise (PL), a combination of flicker and random-walk noise
c$$$  (FLRW), a combination of first-order Gauss-Markov plus
c$$$  random-walk noise (FOGMRW), and a combination of bandpass
c$$$  filtered and power law noise(BPPL). In all of these
c$$$  models, the amplitude of white noise was estimated, too.

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
      character*20 filter,dt
      character*1023 files(nmax_site),file,ofile,headers(nmax_head)
      character*1023 tmpstr,cmdstr,ostr,sys,redirstr,tmpdir,tfile

c     offset and post-seismic decay definition file name
      character*1023 opfile
      
      integer*4 noff,nps,offi,psi,tdate(5),tyr,tdoy,tsecod
c     offset & psdecay read from definition file.
      real*8 offs(100),pss(100)
c     offset & psdecay in time axis range
      integer*4 noffU,npsU
      real*8 offsU(100),pssU(100)
c     That is, maximum number of offsets: 100.

      character*4 site,tmplock
      character*1 neustr(3),neu1
      data neustr/'n','e','u'/
      integer*4 fido,ioerr,fidt
c     number of sites found
      integer*4 n
c     array index
      integer*4 i,j,fi,neui,isTrend,isfn,isrwn,isfpln,npln,isgm,isbp
      integer*4 isAnn,isSemi
c     data matrix
      real*8 data(nmax_row,nmax_col)
      integer*4 nrow,ncol,nhead
c     for date conversion
      integer*4 idate(5),ymd(3),doy,ys,ye,ds,de
      real*8 jd,secr8,yr
c     starting & ending time
      real*8 dyrs,dyre,fdoy,dyr
     

      integer*4 isOver
      logical exi

      integer*4 pid,getpid
      
c     external functions
      integer*4 iargc,nblen,status,system,hostnm
      character*128 hostname
      integer*4 ndoyr

c     <<VAR_DEC

       if (iargc().lt.2) then
         write(*,*) 'Syntax: run_estn path opath'
         write(*,*) '          [--trend=y|n]'
         write(*,*) '          [--ann=y|n]'
         write(*,*) '          [--semi=y|n]'
         write(*,*) '          [--fn=y|n]'
         write(*,*) '          [--rwn=y|n]'
         write(*,*) '          [--fpln=y|n]'
         write(*,*) '          [--gm=y|n]'
         write(*,*) '          [--overwrite=y|n]'
         write(*,*) '          [--offps=offset_ps_file(.def)]'
         write(*,*) '          [--ptn=pattern(.u)]'
         stop
      endif
      call getarg(1,path)
      call getarg(2,opath)
      pid=getpid()
      status=hostnm(hostname)
c     create tmporary output directory ${opath}/.tmp_
      cmdstr='mkdir -p '//opath(1:nblen(opath))//pathsep//'.tmp_'
      cmdstr=cmdstr(1:nblen(cmdstr))//hostname(1:nblen(hostname))
      write(tmpdir,700) opath(1:nblen(opath)),pathsep,
     &     hostname(1:nblen(hostname)),pid
 700  format(a,a,'.tmp_',a,'_',i20.20,'/')
      cmdstr='mkdir -p '//tmpdir(1:nblen(tmpdir))
      write(*,'(a)') '[run_estn] executing '//cmdstr(1:nblen(cmdstr))
      status=system(cmdstr)
c      stop
c      write(*,*) path(1:nblen(path))
c      write(*,*) opath(1:nblen(opath))

      filter='*.n'
c     get extra command-line-parameters
      isfn=0
      isrwn=0
      isfpln=0
      isOver=0
      isTrend=1
      isAnn=1
      isSemi=1
      opfile=''
      if (iargc().ge.3) then
         do i=3,iargc()
            call getarg(i,tmpstr)
c            write(*,*) i,tmpstr(1:nblen(tmpstr))
            if (tmpstr(1:8).eq.'--trend=') then
               if (tmpstr(9:9).eq.'y') then
                  isTrend=1
               else
                  isTrend=0
               endif
            else if (tmpstr(1:6).eq.'--ann=') then
               if (tmpstr(7:7).eq.'y') then
                  isAnn=1
               else
                  isAnn=0
               endif
            else if (tmpstr(1:7).eq.'--semi=') then
               if (tmpstr(8:8).eq.'y') then
                  isSemi=1
               else
                  isSemi=0
               endif
            else if (tmpstr(1:5).eq.'--fn=') then
               if (tmpstr(6:6).eq.'y') then
                  isfn=1
               else
                  isfn=0
               endif
            else if (tmpstr(1:6).eq.'--rwn=') then
               if (tmpstr(7:7).eq.'y') then
                  isrwn=1
               else
                  isrwn=0
               endif
            else if (tmpstr(1:7).eq.'--fpln=') then
               if (tmpstr(8:8).eq.'y') then
                  isfpln=1
               else
                  isfpln=0
               endif
            else if (tmpstr(1:5).eq.'--gm=') then
               if (tmpstr(6:6).eq.'y') then
                  isgm=1
               else
                  isgm=0
               endif
            else if (tmpstr(1:5).eq.'--bp=') then
               if (tmpstr(6:6).eq.'y') then
                  isbp=1
               else
                  isbp=0
               endif
            else if (tmpstr(1:12).eq.'--overwrite=') then
               if (tmpstr(13:13).eq.'y') then
                  isOver=1
               else
                  isOver=0
               endif
            else if (tmpstr(1:8).eq.'--offps=') then
               if (nblen(tmpstr).le.8) then
                  write(*,'(a)') 'Not valid offset definition file.'
                  stop
               endif
               opfile=tmpstr(9:nblen(tmpstr))
            else if (tmpstr(1:6).eq.'--ptn=') then
               if (nblen(tmpstr).le.6) then
                  write(*,'(a)') 'Not valid file filter.'
                  stop
               endif
               filter=tmpstr(7:nblen(tmpstr))
            else
               write(*,*) 'Error: invalid command line parameters!',
     &              tmpstr(1:nblen(tmpstr))
               stop
            endif
         enddo
      endif
      write(*,'(3(a,i2))') '[run_estn] fn:',isfn,' rwn:',isrwn,
     &     ' fpln:',isfpln
      npln=isfn+isrwn

c     searching files to process
      filter='*'//filter(1:nblen(filter))
      write(*,'(2a)') '[run_estn] file filter: ',filter(1:nblen(filter))
      call ffind(path,files,filter,n,1) 
      write(*,'(a,i10)') '[run_estn] #total files:',n
      if (n.le.0) then
         write(*,'(a)') '[run_estn] no files found.'
         stop
      endif


      call getlun(fido)
      call getlun(fidt)

      redirstr=' >& '
c     get system type
c     How to guess the OS type?
c     How to call `uname` and return the results?
c      call getenv('HOME',sys)
c      write(*,*) 'OS Type:',sys(1:nblen(sys))
c      if (sys(1:nblen(sys)).ne.'/export/home/tianyf') then
c         sys='other'
c      else
c         sys='SunOS'
c      endif

c     method 2
      cmdstr='uname > /tmp/uname0'
      status=system(cmdstr)

      open(unit=fido,file='/tmp/uname0')
      read(fido,*) sys
      close(fido,status='delete')
      write(*,'(2a)') '[run_estn] OS Type: ',sys(1:nblen(sys))
      if (sys(1:nblen(sys)).ne.'SunOS') then
         sys='other'
      else
         sys='SunOS'
      endif

      do fi=1,n
         file=files(fi)
         call getfilename(file,tmpstr)
         site=tmpstr(1:4)
         write(*,'(a)') '[run_estn] processing '//site(1:nblen(site))
         
         do neui=1,3
c     get offset for current site
            noff=0
            nps=0
            
            if (opfile.ne.'') then
c            write(*,*) opfile,site
               neu1=neustr(neui)
               call read_offps(opfile,site,100,offs,noff,pss,nps,
     7              neu1)
c     &           neustr(neui))

c            write(*,*) noff,nps,(offs(i),i=1,noff),opfile,site
c            stop
            endif

c     construct input file name (*).[neu]
            ofile=file
            call desuffix(ofile,file)
            ofile=file
            file=ofile(1:nblen(ofile))//'.'//neustr(neui)
c     read in data
            write(*,'(a)') '[run_estn] << '//file(1:nblen(file))
            call read_sio(file,data,nrow,ncol,nhead,headers)
            if (debug) write(*,'(a,2i10)') '[run_estn] #row/col:',nrow,
     &           ncol
c     set starting & ending time
            dyrs=data(1,1)+data(1,2)*1d0/ndoyr(data(1,1))
            dyre=data(nrow,1)+data(nrow,2)*1d0/ndoyr(data(nrow,1))
            write(*,'(a,f10.5,a,f10.5)') '[run_estn] time span: ',
     &           dyrs,'-',dyre
c            stop
c     check whether offset/psdecay is in this range.
            if (opfile.ne.'') then
               noffU=0
               write(*,*) '#offsets:',noff,(offs(i),i=1,noff)
c     If all offsets are outside the tiem span
               if (offs(1).gt.dyre.or.offs(noff).lt.dyrs) then
c     No offset will be used. (noffU=0; unchanged.)
                  goto 800
               else
                  do offi=1,noff
                     write(*,'(a,3f11.5)') '[run_estn]',dyrs,
     &                    offs(offi),dyre
                     if (offs(offi).gt.dyrs.and.offs(offi).lt.dyre) then
                        noffU=noffU+1
                        offsU(noffU)=offs(offi)
                     endif
                  enddo
               endif
 800           continue
               write(*,*) 'tatal offset:',noff,' #used:',noffU
               npsU=0
               if (pss(1).gt.dyre.or.pss(nps).lt.dyrs) then
                  goto 802
               else
                  do psi=1,nps
                     write(*,'(a,3f11.5)') '[run_estn]',dyrs,
     &                    pss(psi),dyre
                     if (pss(psi).gt.dyrs.and.pss(psi).lt.dyre) then
                        npsU=npsU+1
                        pssU(npsU)=pss(psi)
                     endif
                  enddo
               endif
 802           continue
               write(*,*) 'tatal psdecay:',nps,' #used:',npsU
            endif

c     construct output file name (est+)
            call getfilename(file,ofile)
            ofile=opath(1:nblen(opatH))//pathsep//
     &           ofile(1:nblen(ofile))
            if (isfn.eq.1) then
               ofile=ofile(1:nblen(ofile))//'_fn'
            endif
            if (isrwn.eq.1) then
               ofile=ofile(1:nblen(ofile))//'_rwn'
            endif
            if (isfpln.eq.1) then
               ofile=ofile(1:nblen(ofile))//'_fpln'
            endif
            if (isgm.eq.1) then
               ofile=ofile(1:nblen(ofile))//'_gm'
            endif
            if (isbp.eq.1) then
               ofile=ofile(1:nblen(ofile))//'_bp'
            endif
            ostr=ofile

c     check existing
            inquire(file=ostr(1:nblen(ostr))//'.max.dat',exist=exi)
c            write(*,*) isOver,exi
            write(*,'(a,i2,a,l2)') '[run_estn] overwrite? ', isOver,
     &           '  exist? ',exi
            if (isOver.eq.0.and.exi) then
               write(*,'(a)'),'[run_estn] !!!exist. skip..'//
     &              ostr(1:nblen(ostr))//'.max.dat'
               goto 801
            endif

            tfile=ofile(1:nblen(ofile))//'.lock'
            ofile=ofile(1:nblen(ofile))//'.est_'
c     create temporary lock file
            open(unit=fidt,file=tfile)
            read(fidt,*,iostat=ioerr) tmplock
c            write(*,*) 'ioerr:',ioerr
            if (ioerr.eq.0.and.tmplock(1:4).eq.'lock') then
               write(*,'(2a)') '[run_estn] locked. skip ',
     &              file(1:nblen(file))
               close(fidt)
               goto 801
            endif
            write(fidt,'(a4)') 'lock'
            write(*,'(a)') '[run_estn] >> '//ofile(1:nblen(ofile))
            open(unit=fido,file=ofile)
c            write(fido,'(a)') '#!/bin/sh'
            write(fido,'(a)') '  #  from sample est+ of est_noise'
            write(fido,'(a)') 'cd '//opath(1:nblen(opath))
            write(fido,'(a)') 'cd '//tmpdir(1:nblen(tmpdir))
            write(fido,'(2a,1x,a)') 'cp -f ',file(1:nblen(file)),
c     &           opath(1:nblen(tmpdir))
     &           tmpdir(1:nblen(tmpdir))
c            write(fido,'(a)') 'cd /tmp'
            write(fido,'(a)') 'rm -f seed.dat '
            write(fido,'(a)') 'echo 82789427 > seed.dat'
            write(fido,'(a)') 'rm -f junk.in'
            write(fido,'(a)') 'cat > junk.in <<EOF'
            write(fido,'(a)') 'otr'
            write(fido,'(a)') '1 #  Number of data sets  ( always 1)' 
            ys=data(1,1)
            ds=data(1,2)
            ye=data(nrow,1)
            de=data(nrow,2)
            write(fido,701) ys,ds,ye,de
 701        format(i4,1x,i3,1x,i4,1x,i3,' # time span')
            if (isTrend.eq.1) then
               write(fido,'(a)') 'y   # rate'
            else
               write(fido,'(a)') 'n   # rate'
            endif
            write(fido,'(a)') '0   # num of rate change'
c     Modification Tianyf Wed Jun 23 22:36:32 CST 2010
c     Added options to use ann & semi:
c            write(fido,'(a)') '2  # num of periods'
            write(fido,'(I9,a)') isAnn+isSemi,'  # num of periods'
            if (isAnn.eq.1) then
               write(fido,'(a)') '365.25 '
            endif
            if (isSemi.eq.1) then
               write(fido,'(a)') '182.625 #  period in days'
            endif
c     include the spurious periodicities
c$$$            write(fido,'(a)') '8  # num of periods'
c$$$            write(fido,'(a)') '365.25 '
c$$$            write(fido,'(a)') '182.625 #  period in days' 
c$$$            write(fido,'(f)') 365.25/(1*1.039)
c$$$            write(fido,'(f)') 365.25/(2*1.039)
c$$$            write(fido,'(f)') 365.25/(3*1.039)
c$$$            write(fido,'(f)') 365.25/(4*1.039)
c$$$            write(fido,'(f)') 365.25/(5*1.039)
c$$$            write(fido,'(f)') 365.25/(6*1.039)

            write(fido,'(i9,a)') noffU,' #  Number of offsets in data'
c     BUG Tian Fri Nov 21 09:56:46 CST 2008
c     est_noise will fail to run if epochs of some offsets are outside
c     the time span of current time series.
c     --Curent solution is careful inspection before run the program.
c
c            write(fido,'(a)') '2003 357.0   # time of offset'
            do offi=1,noffU
               call decyrs_to_jd(offsU(offi),jd)
               call jd_to_yds(jd, tyr, tdoy, tsecod)
               write(*,*) offi,noff,offs(offi),jd,tyr,tdoy,tsecod
               if (tyr.lt.20) then
                  tyr=tyr+2000
               else if (tyr.lt.100) then
                  tyr=tyr+1900
               endif                     
               write(fido,'(i4,1x,f9.4)') tyr,tdoy+tsecod/(24*3600d0)
c               tyr=int(offs(offi))
c               fdoy=(offs(offi)-tyr)*ndoyr(tyr)
c               write(fido,'(i4,1x,f9.4)') tyr,fdoy
            enddo
            write(fido,'(i9,a)') npsU,' # number of exponential '
            do psi=1,npsU
c               tyr=int(pss(psi))
c               call decyrs_to_ydhms(offs(offi),tdate )
               call decyrs_to_jd(pssU(psi),jd)
               call jd_to_yds(jd, tyr, tdoy, tsecod)
               if (tyr.lt.20) then
                  tyr=tyr+2000
               else if (tyr.lt.100) then
                  tyr=tyr+1900
               endif                     
               write(fido,'(i4,1x,f9.4)') tyr,tdoy+tsecod/(24*3600d0)
               write(fido,'(f9.4,1x,a)') 10/365.25,'float'
               write(fido,'(a)') 'm'
            enddo
            write(fido,'(a)') 'otr #format style of input data'
            call getfilename(file,tmpstr)
            write(fido,'(a)') tmpstr(1:nblen(tmpstr))
            write(fido,'(a)') '0    #  Number auxillary data'
            write(fido,'(a)') '1   # mininum sampling in days'
            write(fido,'(a)') 'n   # This is usually n for "no"'
            write(fido,'(a)') 'n  # n for "no" unless you want to'
            write(fido,'(a)') '0   #  decimation parmeter; ..'
            write(fido,'(a)') '1 float    #white noise  '
            if (isfpln.eq.1) then
               write(fido,'(a)') '1 float   #power law amplitude;'
               write(fido,'(a)') '1 float   #power law index;'
            else
               if (isfn.eq.1) then
                  write(fido,'(a)') '1 float   #power law amplitude;'
                  write(fido,'(a)') '1 fix     #power law index;'
               endif
               if (isrwn.eq.1.and.isfn.ne.1) then
                  write(fido,'(a)') '1 float   #power law amplitude;'
                  write(fido,'(a)') '2 fix     #power law index;'
               endif
               if(isrwn.ne.1.and.isfn.ne.1) then
                  write(fido,'(a)') '0 fix   #power law amplitude;'
                  write(fido,'(a)') '1 fix   #power law index;'
               endif
            endif
            if (isgm.eq.1) then
               write(fido,'(a)') '1 float #Gauss Markov time constant'
            else
               write(fido,'(a)') '0 fix #Gauss Markov time constant'
            endif
            write(fido,'(a)') '.5 2.   # Pass-band limits'
            write(fido,'(a)') '1      #  Number of poles in the BP'
            if (isbp.eq.1) then
               write(fido,'(a)') '1 float  # Amplitude of BP'
            else
               write(fido,'(a)') '0 fix  # Amplitude of BP'
            endif
            if (isrwn.eq.1.and.isfn.eq.1) then
               write(fido,'(a)') '2 fix   # power law index'
               write(fido,'(a)') '1 float  # power law amplitude'
            else
               write(fido,'(a)') '2 fix   # power law index'
               write(fido,'(a)') '0.0 fix  # power law amplitude'
            endif
            write(fido,'(a)') '0  #  Additional white noise'
            write(fido,'(a)') 'EOF'
c            write(*,*) 'OS Type:',sys(1:nblen(sys))
            if (sys(1:5).eq.'SunOS') then
               write(fido,'(a)') 'time estn < junk.in > '
     &              //ofile(1:nblen(ofile))//'.log 2>&1'
            else
               write(fido,'(a)') 'time estn < junk.in >& '
     &              //ofile(1:nblen(ofile))//'.log'
            endif
            write(fido,'(a)') ''
            write(fido,'(a)') '#clear files'
            write(fido,'(a)') 'rm -f '//tmpstr(1:nblen(tmpstr))
            write(fido,'(a)') 'mv -f max.dat '//ostr(1:nblen(ostr))
     &           //'.max.dat'
            write(fido,'(a)') 'mv -f model.dat '//ostr(1:nblen(ostr))
     &           //'.model.dat'
            write(fido,'(a)') 'mv -f resid.out '//ostr(1:nblen(ostr))
     &           //'.resid.out'
            write(fido,'(a)') 'mv -f resid_dec.out '//
     &           ostr(1:nblen(ostr))
     &           //'.resid_dec.out'
            write(fido,'(a)') 'mv -f prob1.out '//ostr(1:nblen(ostr))
     &           //'.prob1.out'
            write(fido,'(a)') 'mv -f prob2.out '//ostr(1:nblen(ostr))
     &           //'.prob2.out'
            write(fido,'(a)') ''
            write(fido,'(a)') ''
            close(fido)
            cmdstr='chmod +x '//ofile(1:nblen(ofile))
            status=system(cmdstr)


c     in one directoy, only one session is allowed.
c     create distinct temporary directories?
            
            write(*,'(a)') '[run_estn] executing est_noise...'
            cmdstr='/bin/sh '//ofile
c            stop
            
            write(*,'(a)') '[run_estn] '//cmdstr(1:nblen(cmdstr))
            status=system(cmdstr)
c            stop
c     delete temporary lock file
            close(fidt,status='delete')
            cmdstr='/bin/rm -rf '//tfile(1:nblen(tfile))
            status=system(cmdstr)
            write(*,'(2a)') '[run_estn] done! Lock file cleared: ',
     &           tfile(1:nblen(tfile))
c            stop
 801        continue
         enddo
c         stop
      enddo

      cmdstr='/bin/rm -rf '//tmpdir(1:nblen(tmpdir))
c      write(*,*) cmdstr(1:nblen(cmdstr))
      status=system(cmdstr)

      STOP
      END
