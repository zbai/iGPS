;FUNCTION GET_INTERSECT_POINT_BETWEEN_FAULT_AND_PROFILE, xys_fvec, a1,b1
FUNCTION INTERSECT_BETWEEN_POLYLINE_AND_LINE, xys_fvec, a1,b1,beta=beta,x1=x1,y1=y1
  npt=N_ELEMENTS(xys_fvec[0,*])
;  window,1
;  !p.multi=-1
;  plot,xys_fvec[0,*],xys_fvec[1,*],psym=2,background='ffffff'x,color='0'x,/ynozero,/iso
  ;
  FOR pi=0, npt-2 DO BEGIN
    x1=xys_fvec[*,pi]
    y1=xys_fvec[*,pi+1]
    rate=(y1[1]-x1[1])/(y1[0]-x1[0])
;    plot,[x1[0],y1[0],a1[0],b1[0]],[x1[1],y1[1],a1[1],b1[1]],psym=2,background='ffffff'x,color='0'x,/ynozero;,/iso
  
    LINE_INTERSECT_LINE, a1,b1, x1, rate, c1
    IF N_ELEMENTS(WHERE(FINITE(c1) EQ 1)) NE 2 THEN BEGIN
    ;PRINT,'problem with c1'
      CONTINUE
    ENDIF
;    OPLOT,[x1[0],y1[0]],[x1[1],y1[1]],color='ff0000'x
;    OPLOT,[a1[0],b1[0]],[a1[1],b1[1]],color='00ff00'x
;    OPLOT,[x1[0],c1[0]],[x1[1],c1[1]],color='0000ff'x,linestyle=0,thick=4
    IF c1[0] GT MAX([x1[0],y1[0]]) || c1[0] LT MIN([x1[0],y1[0]]) || $
      (c1[1] - MAX([x1[1],y1[1]])) gt 1d-6 || (MIN([x1[1],y1[1]])-c1[1]) gt 1d-06 THEN BEGIN
;      print,c1[0] GT MAX([x1[0],y1[0]]) , c1[0] LT MIN([x1[0],y1[0]]) , $
;      c1[1] GT MAX([x1[1],y1[1]]), c1[1] LT MIN([x1[1],y1[1]])
;      print,(c1[0] - MAX([x1[0],y1[0]])) gt 1d-6 , c1[0] LT MIN([x1[0],y1[0]]) , $
;      (c1[1] - MAX([x1[1],y1[1]])) gt 1d-6, (MIN([x1[1],y1[1]])-c1[1]) gt 1d-06
      ;print,'problem with x1/y1'
      ;stop
      CONTINUE
    ENDIF
    tmp=(x1[1]-y1[1])/(x1[0]-y1[0])
    beta=ATAN(tmp)
    
    ;stop
    RETURN,c1
  ENDFOR
  RETURN,REPLICATE(!values.D_NAN,2)
END
