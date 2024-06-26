CTITLE
      SUBROUTINE read_corr_snx(file,sites,nsit,corr,blen_deg, 
     +     blen_km,llh)
c     --PURPOSE--

c     --ALGORITHM--

c     --EXAMPLE--

c     --MODIFICATIONS--

      IMPLICIT NONE
      INCLUDE '../../../inc/ftk.h'

c     >>VAR_DEC
c     --INPUT--
      character*1023 file

c     --OUTPUT--
      character*4 sites(nmax_sites)
      integer*4 nsit
      real*8 corr(nmax_sites,nmax_sites,3),llh(3,nmax_sites)
      real*8 blen_deg(nmax_sites,nmax_sites)
      real*8 blen_km(nmax_sites,nmax_sites)

c     --EXTERNAL--
      integer*4 nblen

c     --Local Parameters--
      real*8 lon,lat,ht
      real*8 rval

      integer*4 fid,ioerr

      character*10240 line
      character*1023 parts(100),tmpstr
      character*4 site
      integer*4 is_data,np,i,j,k,neui,rowi,coli,pi
      real*8 r1,r2,r3,r123(3)
      integer*4 i1,i2,coli_pi

c     <<VAR_DEC
      
      call getlun(fid)
      open(unit=fid,file=file,iostat=ioerr,status='old')
      if (ioerr.ne.0) then
         write(*,*) 'error when open file to read :',
     +        file(1:nblen(file))
         stop
      endif
      
      nsit=0
      is_data=0

c     Get sites information.
 701  read(fid,'(a10240)',end=799) line
c      write(*,*) line(1:70)
      if (line(1:nblen(line)).eq.'+SITE/ID') then
         is_data=1
         goto 701
      endif
      if (line(1:1).eq.'*') then
         goto 701
      endif
      if (line(1:nblen(line)).eq.'-SITE/ID') then
         goto 702
      endif
      
      nsit=nsit+1
c      call strsplit(line,' ',np,parts)
      read(line,*) site,lon,lat,ht
      sites(nsit)=site
      llh(1,nsit)=lon
      llh(2,nsit)=lat
      llh(3,nsit)=ht
c      write(*,*) site, lon,lat,ht
c     loop for read each site line of input file
      goto 701
      
c     continue to read corr/blen blocks
 702  continue
      write(*,*) '#sites:',nsit
c      write(*,'(a)') (sites(i),i=1,nsit)

      write(*,'(a)') 'reading corr/blen ...'
      is_data=0
 703  read(fid,'(a10240)',end=799) line
      if (line(1:5).eq.'+CORR') then
         is_data=1
         if (line(7:7).eq.'N') neui=1
         if (line(7:7).eq.'E') neui=2
         if (line(7:7).eq.'U') neui=3
         write(*,'(a)') line(1:nblen(line))
         goto 703
      endif
      if (line(1:5).eq.'-CORR') then
         is_data=0
c         goto 799
         goto 703
      endif

      if (line(1:9).eq.'+BLEN/DEG') then
         write(*,'(a)') line(1:nblen(line))
         is_data=2
         goto 703
      endif
      if (line(1:9).eq.'-BLEN/DEG') then
         is_data=0
         goto 703
      endif

      if (line(1:8).eq.'+BLEN/KM') then
         write(*,'(a)') line(1:nblen(line))
         is_data=3
         goto 703
      endif
      if (line(1:8).eq.'-BLEN/KM') then
         is_data=0
         goto 703
      endif

c      write(*,*) line(1:nblen(line))
c      call strsplit2(line,' ',np,parts)
c     240.486u 0.262s 4:00.73 100.0%	0+0k 0+0io 0pf+0w
c$$$      write(*,*) 'np:',np
c$$$      do pi=1,np
c$$$         tmpstr=parts(pi)
c$$$         write(*,*) pi,'|'//tmpstr(1:nblen(tmpstr))//'|'
c$$$      enddo
c$$$      write(*,*) line(1:nblen(line))
c$$$      stop
      call strsplit(line,' ',np,parts)
c     70.285u 0.250s 1:10.53 100.0%	0+0k 412400+0io 0pf+0w

      if (np.lt.2) goto 703
      read(line,*) rowi,coli
      
      if (is_data.eq.1) then
         do pi=0, np-2-1
c            write(*,*) parts(2+pi+1)
            read(parts(2+pi+1),*) rval
            corr(rowi,coli+pi,neui)=rval
         enddo
      elseif (is_data.eq.2) then
         do pi=0, np-2-1
            read(parts(2+pi+1),*) rval
            blen_deg(rowi,coli+pi)=rval
         enddo
      elseif (is_data.eq.3) then
         do pi=0, np-2-1
            read(parts(2+pi+1),*) rval
            blen_km(rowi,coli+pi)=rval
         enddo
      endif

      goto 703

 799  continue
      close(fid)

c$$$      write(*,*) 'Corr North:'
c$$$      do i=1,nsit
c$$$         write(*,'(2000(1x,f5.2))') (corr(i,j,1),j=1,nsit)
c$$$      enddo
c$$$      write(*,*) 'Corr East:'
c$$$      do i=1,nsit
c$$$         write(*,'(1000(1x,f5.2))') (corr(i,j,2),j=1,nsit)
c$$$      enddo
c$$$      write(*,*) 'Corr Up:'
c$$$      do i=1,nsit
c$$$         write(*,'(1000(1x,f5.2))') (corr(i,j,3),j=1,nsit)
c$$$      enddo
c$$$      write(*,*) 'Blen Deg:'
c$$$      do i=1,nsit
c$$$         write(*,'(1000(1x,f5.2))') (blen_deg(i,j),j=1,nsit)
c$$$      enddo
c$$$      write(*,*) 'Blen Km:'
c$$$      do i=1,nsit
c$$$         write(*,'(1000(1x,f8.2))') (blen_km(i,j),j=1,nsit)
c$$$      enddo

      write(*,'(a)') '[READ_CORR_SNX]Normal end.'
c      stop
      RETURN
      END
