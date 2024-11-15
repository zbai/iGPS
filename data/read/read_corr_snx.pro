;+
;
;PURPOSE:
;	CALCUALTE CORRELATION COEFFICIENTS MATRIX FOR A SET OF CGPS SITES.
;
;  *)TIME SERIES COORELATION ANALYSIS IS BASED UPON RSIDUALS.
;  *) > 500 COMMON EPOCHS.
;  *)BLENANCE IS IN ANGULAR DEGREES.
;  *)REMOVE COMMON MODE SIGNAL WILL PRODUCE ZERO COEFFICIENTS.
;INPUT:
;    SIO/IND_NEU (ONLY)
;
;-
PRO READ_CORR_SNX, $
    FILE, $
    SITES=SITES, $
    CORR=CORR, $
    BLEN_DEG=BLEN_DEG, $
    BLEN_KM=BLEN_KM, $
    LLH=LLH
    
  IF N_PARAMS() LT 1 THEN BEGIN
    file='CMONOC-IEP_CORR_NEU.snx'
  ENDIF
  
  NLINE = TXT_LINES(FILE)
  LINES = STRARR(NLINE)
  OPENR, FID, FILE, /GET_LUN
  READF, FID, LINES
  FREE_LUN, FID
  
  ;READ SITES INFORMATION
  SITES=''
  IS_DATA=0
  FOR LI=0ULL, NLINE-1 DO BEGIN
    LINE=LINES[LI]
    IF STRTRIM(LINE,2) EQ '+SITE/ID' THEN BEGIN
      IS_DATA=1
      CONTINUE
    ENDIF
    IF STRMID(STRTRIM(LINE,2),0,1) EQ '*' THEN CONTINUE  ;COMMENT LINE
    IF STRTRIM(LINE,2) EQ '-SITE/ID' THEN BEGIN
      I=LI
      GOTO, END_OF_SITES
    ENDIF
    LINET=STRSPLIT(LINE,/EXTRACT)
    SITES = [SITES, (STRSPLIT(LINE,/EXTRACT))[0] ]
    IF N_ELEMENTS(LLH) EQ 0 THEN BEGIN
      LLH=DOUBLE(LINET[[1,2,3]] )
    ENDIF ELSE BEGIN
      LLH=[[LLH],[DOUBLE(LINET[[1,2,3]] )] ]
    ENDELSE
  ENDFOR
  END_OF_SITES:
  SITES=SITES[1:*]
  ;HELP, SITES
  NP = N_ELEMENTS(SITES)
  
  ;READ IN DATA
  CORR = DBLARR(NP, NP, 3)
  BLEN_DEG = DBLARR(NP, NP)
  BLEN_KM = DBLARR(NP, NP)
  
  IS_DATA=0
  FOR LI=I+1ULL, NLINE-1 DO BEGIN
    LINE=LINES[LI]
    IF STRMID(STRTRIM(LINE,2),0,5) EQ '+CORR' THEN BEGIN
      IS_DATA=1
      CASE (STRSPLIT(LINE,'/',/EXTRACT))[1] OF
        'N': NEUI=0
        'E': NEUI=1
        'U': NEUI=2
      ENDCASE
      CONTINUE
    ENDIF
    IF STRMID(STRTRIM(LINE,2),0,5) EQ '-CORR' THEN BEGIN
      IS_DATA=0
      CONTINUE
    ENDIF
    
    IF STRTRIM(LINE,2) EQ '+BLEN/DEG' THEN BEGIN
      IS_DATA=2
      CONTINUE
    ENDIF
    IF STRTRIM(LINE,2) EQ '-BLEN/DEG' THEN BEGIN
      IS_DATA=0
      CONTINUE
    ENDIF
    
    IF STRTRIM(LINE,2) EQ '+BLEN/KM' THEN BEGIN
      IS_DATA=3
      CONTINUE
    ENDIF
    IF STRTRIM(LINE,2) EQ '-BLEN/KM' THEN BEGIN
      IS_DATA=0
      CONTINUE
    ENDIF
    
    ;PRINT, IS_DATA, NEUI, LINE
    LINE=STRSPLIT(LINE, /EXTRACT)
    IF N_ELEMENTS(LINE) LT 2 THEN CONTINUE
    ROWI=FIX(LINE[0])-1
    COLI=FIX(LINE[1])-1
    CASE IS_DATA OF
      1: BEGIN  ; CORR
        FOR PI=0, N_ELEMENTS(LINE)-1-2 DO BEGIN
          CORR[ROWI, COLI+PI, NEUI] = DOUBLE(LINE[2+PI])
          CORR[COLI+PI, ROWI, NEUI] = DOUBLE(LINE[2+PI])
        ;PRINT, CORR[ROWI, COLI+PI, NEUI]
        ENDFOR
      END
      2: BEGIN
        FOR PI=0, N_ELEMENTS(LINE)-1-2 DO BEGIN
          BLEN_DEG[ROWI, COLI+PI] = DOUBLE(LINE[2+PI])
          BLEN_DEG[COLI+PI, ROWI] = DOUBLE(LINE[2+PI])
        ;PRINT, ROWI, COLI+PI, BLEN_DEG[ROWI, COLI+PI],BLEN_DEG[COLI+PI, ROWI]
        ENDFOR
      END
      3: BEGIN
        FOR PI=0, N_ELEMENTS(LINE)-1-2 DO BEGIN
          BLEN_KM[ROWI, COLI+PI] = DOUBLE(LINE[2+PI])
          BLEN_KM[COLI+PI, ROWI] = DOUBLE(LINE[2+PI])
        ENDFOR
      END
    ENDCASE
  ENDFOR
  
  IF N_PARAMS() LT 1 THEN BEGIN
    HELP, SITES, CORR, BLEN_DEG, BLEN_KM,LINES,LLH
  ;PRINT, BLEN_DEG
  ;STOP
  ENDIF
END
