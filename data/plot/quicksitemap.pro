PRO QSM_GET_COORDS,SITE=SITE, FILE=COORDSFILE,XYZ=XYZ,ALONG=ALONG,ALAT=ALAT,HGHT=HGHT, TYPE=TYPE
  CASE TYPE OF
    1: BEGIN
      QUERY_APR, COORDSFILE, SITE, XYZ=XYZ
    END
    0: BEGIN
      READ_NET, COORDSFILE,SITE=SITE,LLH=LLH
    END
  ENDCASE
  
END
;-----------------------------------------------------------------
PRO ON_QSM_INIT, WWIDGET
  ID=WIDGET_INFO(WWIDGET,FIND_BY_UNAME='QSM_RAD_SITEFILE')
  WIDGET_CONTROL, ID, /SET_BUTTON
  ID=WIDGET_INFO(WWIDGET,FIND_BY_UNAME='QSM_RAD_APR')
  WIDGET_CONTROL, ID, /SET_BUTTON
  ID=WIDGET_INFO(WWIDGET,FIND_BY_UNAME='QSM_TXT_SITESDEFAULTS')
  WIDGET_CONTROL, ID, SENSITIVE=0
  ID=WIDGET_INFO(WWIDGET,FIND_BY_UNAME='QSM_TXT_XYZ')
  WIDGET_CONTROL, ID, SENSITIVE=0
END
;-----------------------------------------------------------------


;-----------------------------------------------------------------
PRO ON_QSM_RAD_SITEFILE, EV
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_SITEFILE')
  WIDGET_CONTROL, ID, SENSITIVE=1
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_SITESDEFAULTS')
  WIDGET_CONTROL, ID, SENSITIVE=0
END
;-----------------------------------------------------------------
;

;-----------------------------------------------------------------
PRO ON_QSM_RAD_SITESDEFAULTS, EV
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_SITEFILE')
  WIDGET_CONTROL, ID, SENSITIVE=0
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_SITESDEFAULTS')
  WIDGET_CONTROL, ID, SENSITIVE=1
END
;-----------------------------------------------------------------

;-----------------------------------------------------------------
PRO ON_QSM_BTN_OK, EV

  ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_OUT')
  WIDGET_CONTROL, ID, GET_VALUE=OFILE
  OFILE=STRTRIM(OFILE[0])
  IF OFILE EQ '' THEN BEGIN
    MSGBOX,'No output Postscript file (*.ps) specified!',TITLE='iGPS',/ERROR,DIALOG_PARENT=EV.TOP
    RETURN
  ENDIF
  IF FILE_TEST(OFILE,/REGULAR) THEN BEGIN
    YESNO=MSGBOX('Output file already exist! Overwrite?',/QUESTION,/DEFAULT_NO, $
      TITLE='iGPS',PARENT=EV.TOP)
    IF YESNO EQ 'No' THEN RETURN
  ENDIF
  
  ON_QSM_BTN_PREVIEW, EV, OFILE=OFILE, SITES_NODATA=SITES_NODATA, WRITEPS=1
  STR='File "'+OFILE+'" has been created!'
  IF SITES_NODATA[0] NE '' THEN BEGIN
    STR=[STR, '', $
    'iGPS cannot find apriori coordiante for '+STRTRIM(N_ELEMENTS(SITES_NODATA),2)+' sites.',$
    'Please check the IDL log for more informaiton.']
  ENDIF
  MSGBOX,STR, $
    DIALOG_PARENT=EV.TOP,/INFO, $
    TITLE='iGPS: Quick Site Map'
END
;-----------------------------------------------------------------


;-----------------------------------------------------------------
PRO ON_QSM_BTN_CANCEL, EV
  WIDGET_CONTROL, EV.TOP, /DESTROY
END
;-----------------------------------------------------------------


;-----------------------------------------------------------------
PRO ON_QSM_BTN_HELP, EV
  STR=['iGPS: Quick Site Map', $
    '',$
    'Purpose:',$
    '  Get a fast view of the spatial distribution of your selected GPS sites', $
    '', $
    'To preview GPS stations positions on the map,',$
    '  a. select a site file;', $
  '  b. select a coordinates file;', $
  '  c. click Preview button and there it is.', $
    'Optionally, map window title can be specified.',$
    '',$
    'Expected Features:', $
    '  * save the drawing as a JPEG/Postscript file;', $
  '  * support various projections;', $
  '  * display site info when mouse over;', $
  '  * use object graphics instead of direct graphic [rotatable].', $
    '']
  MSGBOX,STR,TITLE='iGPS',/INFO,DIALOG_PARENT=EV.TOP
END
;-----------------------------------------------------------------


;-----------------------------------------------------------------
PRO ON_QSM_BTN_PREVIEW, EV, OFILE=OFILE, SITES_NODATA=SITES_NODATA, $
  WRITEPS=WRITEPS
  
  IF N_ELEMENTS(WRITEPS) EQ 0 THEN WRITEPS=0
  
  ID_LBL_STATUS=WIDGET_INFO(EV.TOP,FIND_BY_UNAME='QSM_LBL_STATUS')
  
  ;GET SITES
  ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_RAD_SITEFILE')
  OPT = WIDGET_INFO(ID, /BUTTON_SET)
  CASE OPT OF
    1: BEGIN
      ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_SITEFILE')
      WIDGET_CONTROL, ID, GET_VALUE=SITEFILE
      ;PRINT, SITEFILE
      SITEFILE=STRTRIM(SITEFILE[0])
      IF SITEFILE EQ '' THEN BEGIN
        MSGBOX,'No iGPS site list file selected!',TITLE='iGPS',/ERROR,DIALOG_PARENT=EV.TOP
        RETURN
      ENDIF
      RDSIT, SITEFILE, SITES=SITES
      INFILE=SITEFILE
    END
    0: BEGIN
      ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_SITESDEFAULTS')
      WIDGET_CONTROL, ID, GET_VALUE=SITESDEFAULTS
      PRINT, SITESDEFAULTS
      SITESDEFAULTS=STRTRIM(SITESDEFAULTS[0])
      IF SITESDEFAULTS EQ '' THEN BEGIN
        MSGBOX,'No GAMIT sites.defaults file selected!',TITLE='iGPS',/ERROR,DIALOG_PARENT=EV.TOP
        RETURN
      ENDIF
      SITESDEFAULTS_READ, SITESDEFAULTS, EXPT=EXPT, SITES=SITES
      INFILE=SITESDEFAULTS
    END
  ENDCASE
  
  
  IND_NODATA=INTARR(N_ELEMENTS(SITES))
  
  
  WIDGET_CONTROL,ID_LBL_STATUS,SET_VALUE='Query apriori coordinates for '+ $
    STRTRIM(N_ELEMENTS(SITES),2)+' sites...'
  ;GET COORDIANTES FOR SITES
  ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_RAD_APR')
  OPT_COORD = WIDGET_INFO(ID, /BUTTON_SET)
  CASE OPT_COORD OF
    1: BEGIN
      ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_APR')
      WIDGET_CONTROL, ID, GET_VALUE=COORDSFILE
      COORDSFILE=STRTRIM(COORDSFILE[0])
      IF COORDSFILE EQ '' THEN BEGIN
        MSGBOX,'No GAMIT ITRF file selected!',TITLE='iGPS',/ERROR,DIALOG_PARENT=EV.TOP
        RETURN
      ENDIF
      SITE_NAMES=''
      FOR SI=0, N_ELEMENTS(SITES)-1 DO BEGIN
        SITE=SITES[SI]
        QSM_GET_COORDS, FILE=COORDSFILE, SITE=SITE, XYZ=XYZ, TYPE=OPT_COORD
        IF XYZ[0] EQ -1 THEN BEGIN
          IND_NODATA[SI]=1
          PRINT, '[QUICKSITEMAP]WARNING: no a priori coordinates for '+SITE+'!',FORMAT='(A)'
          CONTINUE
        ENDIF
        WGS84XYZ,ALAT,ALONG,HGHT,XYZ[0],XYZ[1],XYZ[2],2
        ;PRINT,ALAT,ALONG,HGHT
        LL=[ALONG,ALAT]
        IF N_ELEMENTS(SITE_NAMES) EQ 0 || SITE_NAMES[0] EQ '' THEN BEGIN
          SITE_NAMES=SITE
          SITE_LLS=LL
        ENDIF ELSE BEGIN
          SITE_NAMES=[SITE_NAMES, SITE]
          SITE_LLS=[[SITE_LLS], [LL]]
        ;PRINT, SITE, XYZ
        ENDELSE
      ;HELP, SITE_NAMES, SITE_LLS
        
      ENDFOR
    END
    0: BEGIN
      ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_XYZ')
      WIDGET_CONTROL, ID, GET_VALUE=COORDSFILE
      COORDSFILE=STRTRIM(COORDSFILE[0])
      IF COORDSFILE EQ '' THEN BEGIN
        MSGBOX,'No QOCA coordinates file (*.net) selected!',TITLE='iGPS',/ERROR,DIALOG_PARENT=EV.TOP
        RETURN
      ENDIF
      SITE_NAMES=''
      
      ;READ_LLHXYZ, COORDSFILE,SITE=SITES,XYZ=XYZS,LLH=LLHS
      READ_NET, COORDSFILE,SITE=SITES,LLH=LLHS
      INDS=INTARR(N_ELEMENTS(SITES))
      FOR SI=0, N_ELEMENTS(SITES)-1 DO BEGIN
        ;SITE=SITES[SI]
        ;READ_LLHXYZ, COORDSFILE,site=site,xyz=xyz,llh=llh
        ;QSM_GET_COORDS, FILE=COORDSFILE, SITE=SITE, XYZ=XYZ, TYPE=OPT_COORD
        ;XYZ=REFORM(XYZS[*,SI])
        LLH=REFORM(LLHS[*,SI])
        ;IF XYZ[0] EQ 0 || XYZ[0] EQ -9999 || LLH[0] EQ -1 || LLH[0] EQ 0 || $
        IF TOTAL(LLH) EQ 0 THEN BEGIN
          IND_NODATA[SI]=1
          PRINT, '[QUICKSITEMAP]WARNING: no a priori coordinates for '+SITES[SI]+'!',FORMAT='(A)'
          CONTINUE
        ENDIF
        
        INDS[SI]=1
      ;LL=llh[0:1]
      ;IF N_ELEMENTS(SITE_NAMES) EQ 0 || SITE_NAMES[0] EQ '' THEN BEGIN
      ;SITE_NAMES=SITE
      ;SITE_LLS=LL
      ;ENDIF ELSE BEGIN
      ;SITE_NAMES=[SITE_NAMES, SITE]
      ;SITE_LLS=[[SITE_LLS], [LL]]
      ;PRINT, SITE, XYZ
      ;ENDELSE
      ;HELP, SITE_NAMES, SITE_LLS
        
      ENDFOR
      POS=WHERE(INDS EQ 1)
      SITE_NAMES=SITES[POS]
      SITE_LLS=REFORM(LLHS[0:1,POS])
    END
  ENDCASE
  
  ID  = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_OUT')
  WIDGET_CONTROL, ID, GET_VALUE=OFILE
  OFILE=STRTRIM(OFILE[0])
  
  ID=WIDGET_INFO(EV.TOP,FIND_BY_UNAME='TXT_TITLE')
  WIDGET_CONTROL,ID,GET_VALUE=MAP_TITLE
  MAP_TITLE=STRTRIM(MAP_TITLE[0],2)
  IF MAP_TITLE EQ '' THEN MAP_TITLE=((INFILE))
  ;PRINT,MAP_TITLE
  
  IF WRITEPS EQ 0 THEN BEGIN
    PLOT_SITE_MAP, SITE_NAMES, SITE_LLS, MAP_TITLE=MAP_TITLE
  ENDIF ELSE BEGIN
    PLOT_SITE_MAP_PS, OFILE,SITE_NAMES, SITE_LLS, MAP_TITLE=MAP_TITLE
    JFILE=DESUFFIX(OFILE)+'.jpg'
    PLOT_SITE_MAP_JPG, JFILE,SITE_NAMES, SITE_LLS, MAP_TITLE=MAP_TITLE
  ENDELSE
  
  IND=WHERE(IND_NODATA EQ 1)
  IF IND[0] EQ -1 THEN BEGIN
    SITES_NODATA=''
  ENDIF ELSE BEGIN
    SITES_NODATA=SITES[IND]
  ENDELSE
  
  WIDGET_CONTROL,ID_LBL_STATUS,SET_VALUE='Done! Ready!'
END


PRO ON_QSM_RAD_APR, EV
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_APR')
  WIDGET_CONTROL, ID, SENSITIVE=1
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_XYZ')
  WIDGET_CONTROL, ID, SENSITIVE=0
END


PRO ON_QSM_RAD_XYZ, EV
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_APR')
  WIDGET_CONTROL, ID, SENSITIVE=0
  ID = WIDGET_INFO(EV.TOP, FIND_BY_UNAME='QSM_TXT_XYZ')
  WIDGET_CONTROL, ID, SENSITIVE=1
END

;
; Empty stub procedure used for autoloading.
;
PRO QUICKSITEMAP_EVENTCB
END

PRO QSM_BASE_EVENT, EV

  wTarget = (WIDGET_INFO(EV.ID,/NAME) EQ 'TREE' ?  $
    WIDGET_INFO(EV.ID, /tree_root) : EV.ID)
    
    
  wWidget =  EV.TOP
  
  CASE wTarget OF
  
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_BASE'): BEGIN
    END
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_RAD_SITEFILE'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_RAD_SITEFILE, EV
    END
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_RAD_SITESDEFAULTS'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_RAD_SITESDEFAULTS, EV
    END
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_BTN_OK'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_BTN_OK, EV
    END
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_BTN_CANCEL'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_BTN_CANCEL, EV
    END
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_BTN_HELP'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_BTN_HELP, EV
    END
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_BTN_PREVIEW'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_BTN_PREVIEW, EV
    END
    
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_RAD_APR'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_RAD_APR, EV
    END
    WIDGET_INFO(wWidget, FIND_BY_UNAME='QSM_RAD_XYZ'): BEGIN
      IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
        ON_QSM_RAD_XYZ, EV
    END
    
    ELSE:
  ENDCASE
  
END

PRO QSM_BASE, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_


  QSM_BASE = WIDGET_BASE( GROUP_LEADER=wGroup, UNAME='QSM_BASE'  $
    ;,XOFFSET=100 ,YOFFSET=100 ,$
    ,NOTIFY_REALIZE='ON_QSM_INIT'  $
    ,MAP=0 $
    ,TITLE='iGPS: Quick Site Map' ,COLUMN=1, /ALIGN_RIGHT, SPACE=0, XPAD=0, YPAD=0)
    
    
  LBL=WIDGET_LABEL(QSM_BASE,VALUE='Sites to plot (two types of input formats accepted):',/ALIGN_LEFT)
  
  WID_BASE_1 = WIDGET_BASE(QSM_BASE, UNAME='WID_BASE_1' ,TITLE='IDL'  $
    ,ROW=1 ,/EXCLUSIVE, SPACE=0, XPAD=0, YPAD=0,/ALIGN_CENTER)
    
    
  QSM_RAD_SITEFILE = WIDGET_BUTTON(WID_BASE_1,  $
    UNAME='QSM_RAD_SITEFILE', /ALIGN_CENTER ,VALUE='From iGPS Site List File (*.sit)')
    
    
  QSM_RAD_SITESDEFAULTS = WIDGET_BUTTON(WID_BASE_1,  $
    UNAME='QSM_RAD_SITESDEFAULTS', /ALIGN_CENTER  $
    ,VALUE='From GAMIT sites.defaults File')
    
    
    
  QSM_TXT_SITEFILE = CW_DIRFILE(QSM_BASE,  $
    UNAME='QSM_TXT_SITEFILE',TITLE='iGPS Site List File:',XSIZE=50,/ALIGN_RIGHT,STYLE='FILE', $
    FILTER=[['*.sit' ,'*'],['iGPS Site List File (*.sit)','iGPS Site List File (*)']])
    
    
    
  QSM_TXT_SITESDEFAULTS = CW_DIRFILE(QSM_BASE,  $
    UNAME='QSM_TXT_SITESDEFAULTS',title='            GAMIT sites.defaults File:',XSIZE=50,/ALIGN_RIGHT ,$
    STYLE='FILE',FILTER=[['sites.defaults','*'],['GAMIT sites.defaults File','GAMIT sites.defaults File (*)']])
    
  LBL=WIDGET_LABEL(QSM_BASE,VALUE='A Priori Site Coordinates:',/align_left)
  
  WID_BASE_RAD_COORDS = WIDGET_BASE(QSM_BASE, UNAME='WID_BASE_1' ,TITLE='IDL'  $
    ,ROW=1 ,/EXCLUSIVE, space=0, XPAD=0, YPAD=0,/ALIGN_CENTER)
    
    
  QSM_RAD_APR = WIDGET_BUTTON(WID_BASE_RAD_COORDS,  $
    UNAME='QSM_RAD_APR' ,/ALIGN_LEFT ,VALUE='GAMIT L-file/.apr')
    
    
  QSM_RAD_XYZ = WIDGET_BUTTON(WID_BASE_RAD_COORDS,  $
    UNAME='QSM_RAD_XYZ' ,/ALIGN_LEFT  $
    ,VALUE='QOCA Network File v3.0 (*.net)')
    
  QSM_TXT_APR = CW_DIRFILE(QSM_BASE,  $
    UNAME='QSM_TXT_APR',title='GAMIT L-file/.apr:',XSIZE=50, $
    /ALIGN_RIGHT,STYLE='FILE' ,FILTER=[['*','*.apr'],['GAMIT L-file/ITRF (lfile.*;*.apr)','GAMIT L-file/ITRF (lfile.*;*.apr)']] )
    
  QSM_TXT_XYZ = CW_DIRFILE(QSM_BASE,  $
    UNAME='QSM_TXT_XYZ',title='QOCA Network File v3.0 (*.net):', $
    XSIZE=50,/ALIGN_RIGHT,STYLE='FILE',FILTER=[['*.net','*'],['QOCA Network File v3.0 (*.net)','QOCA Network File v3.0 (*)']] )
    
  WID_BASE_5 = WIDGET_BASE(QSM_BASE, UNAME='WID_BASE_5' , $
    /ALIGN_RIGHT ,TITLE='IDL' ,ROW=1, space=0, XPAD=0, YPAD=0)
    
  QSM_TXT_OUT = cw_DIRfile(QSM_BASE,  $
    UNAME='QSM_TXT_OUT',title='Output Postscript file (*.ps):',$
    XSIZE=50,/ALIGN_RIGHT,STYLE='FILE',SENSITIVE=1, $
    FILTER=[['*.ps','*'],['Postcript(*.ps)','Postscript (*)']])
    
  WID_BASE_8 = WIDGET_BASE(QSM_BASE,/ROW,XPAD=0,YPAD=0,SPACE=0)
  LBL=WIDGET_LABEL(WID_BASE_8,VALUE='Map title:')
  TXT_TITLE=WIDGET_TEXT(WID_BASE_8,UNAME='TXT_TITLE',/EDITABLE,XSIZE=50)
  
  WID_BASE_7 = WIDGET_BASE(QSM_BASE, UNAME='WID_BASE_7' , space=0, XPAD=0, YPAD=0 ,ROW=1)
  
  
  QSM_BTN_OK = WIDGET_BUTTON(WID_BASE_7, UNAME='QSM_BTN_OK'  $
    ,/ALIGN_CENTER ,VALUE='O K', SENSITIVE=1)
    
    
  QSM_BTN_CANCEL = WIDGET_BUTTON(WID_BASE_7, UNAME='QSM_BTN_CANCEL'  $
    ,XOFFSET=33 ,/ALIGN_CENTER ,VALUE='Quit')
    
    
  QSM_BTN_HELP = WIDGET_BUTTON(WID_BASE_7, UNAME='QSM_BTN_HELP'  $
    ,XOFFSET=81 ,/ALIGN_CENTER ,VALUE='Help')
    
    
  QSM_BTN_PREVIEW = WIDGET_BUTTON(WID_BASE_7, UNAME='QSM_BTN_PREVIEW'  $
    ,XOFFSET=118 ,/ALIGN_CENTER ,VALUE='Preview')
    
  QSM_LBL_STATUS = WIDGET_TEXT(QSM_BASE,UNAME='QSM_LBL_STATUS',VALUE='Ready!')
  
  WIDGET_CONTROL, /REALIZE, QSM_BASE
  CENTERBASE,QSM_BASE
  WIDGET_CONTROL,QSM_BASE,/MAP
  
  XMANAGER, 'QSM_BASE', QSM_BASE, /NO_BLOCK
  
END
;
; Empty stub procedure used for autoloading.
;
PRO QUICKSITEMAP, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  QSM_BASE, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
END