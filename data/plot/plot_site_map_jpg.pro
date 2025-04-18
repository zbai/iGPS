PRO PLOT_SITE_MAP_JPG, ofile,SITES, LLS, MAP_TITLE=MAP_TITLE

  IF N_PARAMS() LT 2 THEN BEGIN
    PRINT,'No input parameters!'
    PRINT,'This procedure is for calls from Quick Site Map.'
    RETURN
  ENDIF
  
  ;HELP,MAP_TITLE
  IF N_ELEMENTS(MAP_TILTE) EQ 0 THEN BEGIN
    MAP_TITLE=''
  ENDIF
  ;
  ; Handle TrueColor displays:
  window,0,xsize=1100*2,ysize=700*2,TITLE=MAP_TITLE,/PIXMAP
  ;GEOG=WIDGET_INFO(0,/GEOMETRY)
  TV,MAKE_ARRAY(VALUE=255^3+255^2+255^1,1100*2,700*2)
  ;HELP,GEOT,/ST
  DEVICE, DECOMPOSED=1
  
  
  XMIN=MIN(LLS[0,*],MAX=XMAX)
  YMIN=MIN(LLS[1,*],MAX=YMAX)
  
  ;PRINT,(YMAX+YMIN)/2D0,(XMAX+XMIN)/2D0, YMAX-YMIN,XMAX-XMIN
  ;STOP
  IF (YMAX-YMIN) GT 360 || XMAX-XMIN GT 720 THEN BEGIN
    MAP_SET, /LAMBERT, (YMAX+YMIN)/2D0,(XMAX+XMIN)/2D0, 0, $
      LIMIT= [YMIN,XMIN,YMAX,XMAX], $
      TITLE=MAP_TITLE, $
      COLOR='000000'X, $
      XMARGIN=2, $
      YMARGIN=3, $
      /NOBORDER, $
      /NOERASE
  ENDIF ELSE BEGIN
    MAP_SET, /MERCATOR, (YMAX+YMIN)/2D0,(XMAX+XMIN)/2D0, 0, $
      /ISOTROPIC, LIMIT= [YMIN,XMIN,YMAX,XMAX], $
      /GRID, LABEL=1, $
      XMARGIN=2, $
      YMARGIN=3, $
      TITLE=MAP_TITLE, $
      COLOR='000000'X, $
      /NOBORDER, $
      /NOERASE
      
  ENDELSE
  
  IF ABS(XMIN-XMAX) LE 10 || ABS(YMIN-YMAX) LE 10 THEN BEGIN ;HIGH RESOLUTION
    MAP_HORIZON, COLOR='EE5C0C'X, FILL=1,/HIRES
    MAP_CONTINENTS, /COASTS, COLOR='AAAAAA'X, /FILL_CONTINENTS,/HIRES
    MAP_CONTINENTS, /COUNTRIES, COLOR='0000FF'X, MLINETHICK=2,/HIRES,NLINESTYLE=3
  ENDIF ELSE BEGIN
    MAP_HORIZON, COLOR='EE5C0C'X, FILL=1
    MAP_CONTINENTS, /COASTS, COLOR='AAAAAA'X, /FILL_CONTINENTS
    MAP_CONTINENTS, /COUNTRIES, COLOR='0000FF'X, MLINETHICK=2,NLINESTYLE=3
  ENDELSE
  
  
  
  MAP_GRID, /BOX_AXES, COLOR='000000'X,$
    /LABEL
  PLOTS,LLS[0,*],LLS[1,*], COLOR='0000FF'X, PSYM=5
  XYOUTS,LLS[0,*],LLS[1,*],SITES, COLOR='000000'X
  
  
  WRITE_JPEG,OFILE,TVRD(TRUE=1),TRUE=1,QUALITY=100

END
