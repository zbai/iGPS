;+
; :Name:
;   GIF_FROM_PNG
;
; :DESCRIPTION:
;   Create a GIF animation from PNG files.
;
; :PARAMS:
;    PATH
;    OFILE
;
; :KEYWORDS:
;    DELAY - in miliseconds. Default to .1 second (=100).
;
; :EXAMPLES:
;
; :Modifications:
;   Released on May 13, 2010
;
; :AUTHOR:
;   tianyf
;-
;/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
PRO GIF_FROM_PNG, $
    PATH, $
    OFILE, $
    DELAY=DELAY, $
    LONG_DELAY=DELAY_LONG
    
  IF N_PARAMS() LT 2 THEN BEGIN
    ;PATH=FILEPATH(ROOT_DIR=!IGPS_ROOT,SUBDIRECTORY=['example','sio'],'cleanedNeuUnf.resid.smoothed')
    ;OFILE=FILEPATH(ROOT_DIR=!IGPS_ROOT,SUBDIRECTORY=['example','sio'],'cleanedNeuUnf.resid.smoothed.gif')
  
    path='D:\Papers\paper.kangding\figure\1.catalog.animation\'
    ofile='D:\Papers\paper.kangding\figure\1.catalog.animation\quakes.gif'
    
    path='D:\ICD\Eighth\2019\20190325.ground.radar.miyun.shouyun.mining.spot\a'
    PTN='*.png'
    
    ofile=path+path_sep()+'ani.gif'
    
    delay=200
    delay_long=200
    delay=30
    delay_long=30
    ;    delay=10
    ;    delay_long=10
;    delay=10
;    delay_long=10
;;        delay=5
;        delay_long=5
    
    IF N_ELEMENTS(PATH) EQ 0 THEN PATH = DIALOG_PICKFILE(/DIRECTORY)
    IF PATH EQ '' THEN RETURN
    IF N_ELEMENTS(OFILE) EQ 0 THEN OFILE = DIALOG_PICKFILE(/WRITE, FILTER='*.gif')
    IF OFILE EQ '' THEN RETURN
    
  ENDIF
  
  IF N_ELEMENTS(PTN) EQ 0 THEN PTN='*.jpg'
  PRINT,'[GIF_FROM_PNG]Searching PNG files in '+PATH+'.',FORMAT='(A)'
  
  FILES=FILE_SEARCH(PATH+PATH_SEP()+PTN,COUNT=NF)
  ;stop
  ;PRINT,NF
  IF NF LE 0 THEN BEGIN
    PRINT,'[GIF_FROM_PNG]Warning: no PNG files found.',FORMAT='(A)'
    RETURN
  ENDIF
  PRINT,'[GIF_FROM_PNG]Found '+STRTRIM(NF,2)+' PNG files.',FORMAT='(A)'
  PRINT,'[GIF_FROM_PNG]Output to '+OFILE+'.',FORMAT='(A)'
  
  I=0
  READ_PNG, FILES[I], IMAGE, r,g,b
  SZ=SIZE(IMAGE,/DIMENSION)/1
  ;PRINT,SZ
  
  IMG=IMAGE
  ;IMG=CONGRID(IMG,SZ[0],SZ[1],1)
  IF N_ELEMENTS(DELAY) EQ 0 THEN DELAY=50
  IF N_ELEMENTS(DELAY_LONG) EQ 0 THEN DELAY_LONG=150
  ;IF N_ELEMENTS(DELAY_LONG) EQ 0 THEN DELAY_LONG=20
  WRITE_GIF,OFILE,IMG,r,g,b,REPEAT_COUNT=0,DELAY_TIME=DELAY
  
  ;STOP
  ;IMAGES=BYTARR(SZ[1],SZ[2],NF)
  FOR I=0,NF-1,1 DO BEGIN
    PRINT,'[GIF_FROM_PNG]Adding ',GETFILENAME(FILES[I]),'...',FORMAT='(3A)'
    READ_PNG, FILES[I], IMAGE, COLTAB
    
    SZ2=SIZE(IMAGE,/DIMENSION)
    IMG=IMAGE
    IF SZ[0] NE SZ2[0] || SZ[1] NE SZ2[1] THEN BEGIN
      ;stop
      IMG=CONGRID(IMG,SZ[0],SZ[1],1)
    ENDIF
    IF I MOD 2 EQ 0 THEN BEGIN
      WRITE_GIF,OFILE,IMG,COLTAB[*,0],COLTAB[*,1],COLTAB[*,2],/MULTIPLE,DELAY_TIME=DELAY,REPEAT_COUNT=0
    ENDIF ELSE BEGIN
      WRITE_GIF,OFILE,IMG,COLTAB[*,0],COLTAB[*,1],COLTAB[*,2],/MULTIPLE,DELAY_TIME=DELAY_LONG,REPEAT_COUNT=0
    ENDELSE
  ENDFOR
  
  READ_PNG, FILES[I-1], IMAGE, COLTAB
  IMG=IMAGE
  IMG=CONGRID(IMG,SZ[0],SZ[1],1)
  WRITE_GIF,OFILE,IMG,COLTAB[*,0],COLTAB[*,1],COLTAB[*,2],/MULTIPLE,DELAY_TIME=DELAY,/CLOSE,REPEAT_COUNT=0
  
  PRINT,'[GIF_FROM_PNG]Normal end.',FORMAT='(A)'
  
END