;APR09 2007 TIAN
;  +A LITTLE PROGRESS FOR LOOP, MUCH FASTER NOW;
;SIO:
;	COMMENTS LINES START WITH A '#'
;
PRO READ_ISCEA, FILE, SITE = SITE, $
    FIRSTEPOCH = FIRSTEPOCH, $
    LASTEPOCH = LASTEPOCH, $
    XYZREF = XYZREF, $
    NEUREF = NEUREF, $
    DATA = DATA, $
    NH=NH, $
    NS=NS, $
    NL=NL, $
    HEADERS = HEADERS, $
    IOERR=IOERR ;ADDED BY TIANYF ON APRIL 14, 2012
  ;
  IOERR=0
  
  NH=1
  ;
  IF N_PARAMS() LT 1 THEN BEGIN  ;test example
    FILE=FILEPATH(ROOT_DIR=!IGPS_ROOT,SUBDIRECTORY=['example','sio', $
      'cleanedNeuUnf'],'bjfsCleanUnf.neu')
  ENDIF
  ;
  ;ON APRIL 14, 2012 BY TIANYF
  ;check whether the file is zero
  IF TXT_LINES(FILE) LE 0 THEN BEGIN
    IOERR=1
    DATA=''
    RETURN
  ENDIF
  NL=TXT_LINES(FILE)-NH

  ;stop
  IF NL GT 0 THEN BEGIN
    READ_COLS_ASCII,FILE,SKIP=NH,DATA=DATAC,HEADERS = HEADERS  
    IF KEYWORD_SET(STR) THEN BEGIN
      DATA=DATAC
    ENDIF ELSE BEGIN
      DATA=DOUBLE(DATAC)
    ENDELSE    
    IF N_PARAMS() LT 1 THEN BEGIN
      HELP,HEADERS,DATAC,DATA
      PRINT, DATA[*,0:1]
    ENDIF
  ENDIF
END
