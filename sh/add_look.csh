#!/bin/csh -f
# (c) Copyright Disclaimer
# This is was downloaded from the old GMTSAR forum: http://gmt.soest.hawaii.edu/boards/6/topics/3271
# It is uploaded to the forum by Xiaohua(Eric).
#
#	try to subsample and find the look vector for the InSAR data
#
  if ($#argv <1 || $#argv >4) then
	echo ""
	echo "Usage: add_look.csh input.llde input_PRM_file Satellite dem.grd"
	echo ""
	echo "LED and PRM files are needed for ENVI_look/ALOS_look"
	echo ""
	echo "Example: add_look.csh subsample.llde e2_127_2907_23027.PRM ENVI "
	echo ""
	echo "output: subsample.lltnde"
	exit 1
  endif
#
  set SAT = $3
  if($SAT == ERS) then
 	set SAT = 'ENVI'
  endif
#
  set file = ` echo $1 | awk '{ print substr($1,1,length($1)-5)}'`
  awk '{print $1,$2}' $file.llde > temp.ll
  gmt grdtrack temp.ll -G$4 > temp.llt 
  #awk '{print $1,$2,'0.000000'}' $file.llde > temp.llt
  #exit
  $SAT"_"look $2 < temp.llt > temp.lltn
  awk '{ a=$3;b=$4;getline <"temp.lltn";print $1,$2,$3,$4,$5,$6,a,b}' $file.llde > $file.lltnde
  #rm temp*

