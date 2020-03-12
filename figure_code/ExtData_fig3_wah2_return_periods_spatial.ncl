;*************************************************
; ExtData_fig3_wah2_return_periods_spatial.ncl 
;
; plots the return periods for WAH2_1930s, WAH2_PD & WAH2_2015 experiments
; TDC 20 June 2018
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$WORK/ncl_scripts/tickmarks.ncl" ; for LambertEqualArea plots
  
  
 err = NhlGetErrorObjectId() 
  setvalues err 
    "errLevel" : "Fatal" ; only report Fatal errors 
  end setvalues 


begin

 reg = "usa" ; region to be plotted
 seas = "JJA"
 bias = "yes" 

 met = "hwf"
 obs = "BEST"
 xtype = "earliest"
 
; exps = "all_pd" ; "all_nat"
 exps = "all_pd_ghg" ; "all_nat_pd"
 wah_dir = "$WORK/NatCC_wah_2019/data/weather_at_home/"

if (exps.eq."all_nat") then
 dset_names = (/"BEST (obs)","ALL (w@h)","NAT (w@h)","ALL-NAT (diff)"/)
end if
if (exps.eq."all_pd") then
 dset_names = (/"OBS","WAH2~B~ALL","WAH2~B~PD~N~-WAH2~B~ALL"/)
end if 
if (exps.eq."all_nat_pd")
 dset_names = (/"BEST (obs)","ALL (w@h)","ALL-NAT","PD-ALL"/)
end if
if (exps.eq."all_pd_ghg")
 dset_names = (/"WAH2~B~1930s","WAH2~B~PD","WAH2~B~2015"/)
end if

 years = (/1934,1936/)
 dimyears = dimsizes(years)
 npanels = dimyears
 
 outfile = "figS5_"+met+"_"+xtype+"_return_periods_all_pd_2015_"+reg+"_"+seas


;************************************************
; plotting parameters
;*************************b***********************

wks = gsn_open_wks("eps",outfile)     ; Open a workstation and
gsn_define_colormap(wks, "WhiteYellowOrangeRed") ; new color map
;gsn_define_colormap(wks,"so4_23") ; old color map

; plotting resources
 res			 = True
 res@gsnDraw		 = False
 res@gsnFrame		 = False
 res@gsnAddCyclic	  = False    ; data already has cyclic point

 res@mpMinLatF  	  = 25.
 res@mpMaxLatF  	  = 45.
 res@mpMinLonF  	  = 235.
 res@mpMaxLonF  	  = 285.
 res@mpCenterLonF	  = 260.
 res@mpCenterLatF	  = 40.0
 res@pmTickMarkDisplayMode  = "Always"  	; turn on fancy 
 res@mpGridLineDashPattern = 2  
 res@mpGridLineThicknessF = 0.25

 res@cnFillOn		  = True     ; turn on color fill
 res@cnLinesOn  	  = False    ; turn of contour lines
 res@cnLineLabelsOn	      = False
 res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
 res@lbLabelBarOn = False
 res@lbLabelFontHeightF = 0.03

 res@pmLabelBarOrthogonalPosF = .17	      ; move whole thing down
 res@pmLabelBarWidthF = 0.6 


  res@gsnCenterStringFontHeightF = 0.05
 
; res@cnFillColors    = (/0,13,14,15,16,17,18,19,20,21,22/) ; for "so4_23" 11 colours
  res@cnFillColors    = (/2,25,48,71,94,117,140,163,186,209,255/) ; for "WhiteYellowOrangeRed" 11 colours
 
 
  res@gsnLeftString = " "
  res@gsnRightString = " "
  res@tmYLOn = True
  res@tmXBOn = True
  res@tmYROn = False
  res@tmXTOn = False  
  res@tmYLLabelFontHeightF = 0.04
  res@tmXBLabelFontHeightF = 0.04 
  
  res@gsnMajorLatSpacing = 10              ; change maj lat tm spacing
  res@gsnMajorLonSpacing = 10              ; change maj lon tm spacing
  res@tmXBMinorOn        = False           ; no lon minor tickmarks
  res@tmYLMinorOn        = False           ; no lon minor tickmarks
  
  maps = new((/3,npanels/),graphic)

; tick mark resources   
  tmres = True
  tmres@tmXBValues = ispan(-135,-30,15)
  tmres@tmXBLabelFontHeightF = 0.025
  tmres@tmYRValues = ispan(10,50,10)
  tmres@tmYRLabelFontHeightF = 0.025
  tmres@YUseLeft = False
  
;LAND SEA MASK
;*************************************************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")

kount = 1

do i=0,npanels-1

 
   wah_all_fil = addfile(wah_dir+ met+"_"+xtype+"_"+seas+"_return_period_all_"+years(i)+".nc","r")
   wah_nat_fil = addfile(wah_dir+met+"_"+xtype+"_"+seas+"_return_period_nat_"+years(i)+".nc","r")
   wah_pd_fil = addfile(wah_dir+met+"_"+xtype+"_"+seas+"_return_period_pd_"+years(i)+".nc","r")
   wah_pd_ghg_sst_fil = addfile(wah_dir+met+"_"+xtype+"_"+seas+"_return_period_sst_"+years(i)+".nc","r")
   
   lat = wah_all_fil->lat
   lon = wah_all_fil->lon
   lsm_m = landsea_mask(a->LSMASK,lat,lon)
  
   var_a = wah_all_fil->RetPer_all
   var_n = wah_nat_fil->RetPer_nat
   var_p = wah_pd_fil->RetPer_pd
   var_g = wah_pd_ghg_sst_fil->RetPer_sst

   var_a@lat = lat
   var_n@lat = lat 
   var_p@lat = lat 
   var_g@lat = lat 

   var_a@lon = lon
   var_n@lon = lon
   var_p@lon = lon
   var_g@lon = lon 


 if (exps.eq."all_pd" .or. exps.eq."all_nat_pd" .or. exps.eq."all_pd_ghg") then  
 if (met.eq."hwf") then
  met_longname = "Frequency (days/"+seas+")"
  var_a = mask(var_a,lsm_m.eq.0.or.lsm_m.eq.2,False)	     ; mask out all ocean points from data
  var_n = mask(var_n,lsm_m.eq.0.or.lsm_m.eq.2,False)	     ; mask out all ocean points from data
  var_p = mask(var_p,lsm_m.eq.0.or.lsm_m.eq.2,False)	     ; mask out all ocean points from data
  var_g = mask(var_g,lsm_m.eq.0.or.lsm_m.eq.2,False)	      ; mask out all ocean points from data
  if(seas.eq."JJA".or.seas.eq."SON") then
    minLevel_m  = 1	   ; set min contour level
    maxLevel_m  = 1200	   ; set max contour level
    interval_m  = 100	   ; set contour spacing     
  end if
  if(seas.eq."DJF".or.seas.eq."MAM") then
    minLevel_m  = 1	   ; set min contour level
    maxLevel_m  = 8.5	   ; set max contour level
    interval_m  = 1.5	   ; set contour spacing
  end if
 end if 
end if ;  if (exps.eq."all_pd") then 

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
 
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels = (/2,5,10,20,50,100,200,500,1000/)

  res@mpProjection	    = "LambertEqualArea" ; "CylindricalEquidistant"
  res@mpGridAndLimbOn	    = True
  res@mpGridLatSpacingF     = 10
  res@mpLimitMode	    = "LatLon"
  res@mpMinLatF	 = 25.
  res@mpMaxLatF	 = 45.
  res@mpMinLonF	 = 235.
  res@mpMaxLonF	 = 285.
  
  res@tiYAxisString = "~F22~"+years(i)
  res@tiYAxisFontHeightF = 0.04 ; 0.075
  res@tiYAxisFontColor = "black"
  res@gsnCenterStringFontHeightF = 0.04

  res@tmYLLabelsOn = False
  res@tmXBLabelsOn = False
  res@tmYRLabelsOn = False
  res@tmXTLabelsOn = False
  res@tmYLOn = False
  res@tmXBOn = False
  res@tmYROn = False
  res@tmXTOn = False 
  res@lbLabelStride = 2
   
 if (i.eq.0) then 
  res@gsnCenterString = dset_names(0) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if 

 res@sfXArray		   = lon
 res@sfYArray		   = lat

 maps(0,i)=gsn_csm_contour_map(wks,var_a,res) ; rectangular  
 maps(0,i) = add_map_tickmarks(wks,maps(0,i),tmres)   


 res@tiYAxisString = ""

 if (i.eq.0) then 
  res@gsnCenterString = dset_names(1) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if 

if (exps.eq."all_pd".or. exps.eq."all_pd_ghg") then
 maps(1,i)=gsn_csm_contour_map(wks,var_p,res) ; rectangular
 maps(1,i) = add_map_tickmarks(wks,maps(1,i),tmres)
end if

 if (i.eq.0) then 
  res@gsnCenterString = dset_names(2) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if 

 if (i.eq.0) then 
  res@gsnCenterString = dset_names(2) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if  


if (exps.eq."all_pd" .or. exps.eq."all_pd_ghg") then
  maps(2,i)=gsn_csm_contour_map(wks,var_g,res) ; rectangular 
  maps(2,i) = add_map_tickmarks(wks,maps(2,i),tmres)
end if


 delete([/wah_all_fil,wah_nat_fil,wah_pd_fil/])
 delete([/var_a,var_n,var_p,var_g/])
 
end do ; do i

maps!0="row"
maps!1="col"

plot1d = ndtooned(maps(col | :, row | :))
plot1d(0) = maps(0,0)
plot1d(1) = maps(1,0)
plot1d(2) = maps(2,0)
plot1d(3) = maps(0,1)
plot1d(4) = maps(1,1)
plot1d(5) = maps(2,1)

;************************************************
; create panel
;************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelLabelBar = True                  ; add common colorbar  
  resP@lbTitleString      = "Year"  ; bar title
  resP@lbTitlePosition    = "Bottom" 	
  resP@pmLabelBarOrthogonalPosF = -0.03
  resP@lbTitleFontHeightF = 0.02
  
  resP@txString = "Return period "+str_upper(met); +"~B~"+seas     ; new resource added in NCL V6.4.0
  
  resP@txFontHeightF = 0.03
  resP@gsnMaximise = True
  resP@gsnPanelYWhiteSpacePercent = 1
  resP@gsnPanelXWhiteSpacePercent = 0 
  resP@gsnPanelFigureStrings= (/"~F22~a","~F22~b","~F22~c","~F22~d","~F22~e","~F22~f"/) ; add strings to panel
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStringsPerimOn = False
  resP@amJust   = "TopLeft"
  resP@gsnPanelRowSpec = True                   ; tell panel what order to plot
  resP@gsnPanelTop = 1.0
  resP@gsnPanelBottom   = 0.5                  ; add space at bottom

  gsn_panel(wks,plot1d(0:5),(/3,3/),resP)

  frame(wks)
  delete(wks)
  system("convert -density 144x144 -trim " + outfile + ".eps " + outfile + ".png")
end
