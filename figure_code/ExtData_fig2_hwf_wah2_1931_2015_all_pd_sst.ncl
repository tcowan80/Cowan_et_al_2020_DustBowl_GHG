;*************************************************
; ExtData_fig2_hwf_wah2_1931_2015_all_pd_sst.ncl
;
; plots the top and bottom ranked 200 simulations based on HWF for WAH2_1931, WAH2_PD_1931, and WAH2_2015
; 
;
;
;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
    
 err = NhlGetErrorObjectId() 
  setvalues err 
    "errLevel" : "Fatal" ; only report Fatal errors 
  end setvalues 


begin

 top_ranked = 200 ; top/bottom 200 ranked simulations
 ofile = "ExtData_fig2_hwf_usa_JJA_1931_2015_wah_all_pd_sst_top_bot"+top_ranked ; outfile
 
 indir = "$WORK/NatCC_wah_2019/data/weather_at_home/"
 all_fil = addfile(indir+"hwf_usa_JF-SON_1931_from_r0-9_1921-1948_clim.wah_all_every_exp_bias_corr.nc","r")
 pd_fil = addfile(indir+"hwf_usa_JF-SON_1931_from_r0-9_1921-1948_clim.wah_all_pd_every_exp_bias_corr.nc","r")
 sst_fil = addfile(indir+"hwf_usa_JF-SON_2015_from_r0-9_1921-1948_clim.wah_pd_ghg_sst_every_exp_bias_corr.nc","r")
 
 ; region of interest
  latS = 30
  latN = 44
  lonL = 255
  lonR = 275
  lonLL = -105
  lonRR = -85

 hw_all = all_fil->hwf(:,2,0,:,:)
 hw_pd = pd_fil->hwf(:,2,0,:,:)
 hw_sst = sst_fil->hwf(:,2,0,:,:)
 lat = all_fil->lat
 lon = all_fil->lon 
 
 ji := region_ind (lat,lon,latS,latN,lonL,lonR)
 jStrt := ji(0)      ; lat start
 jLast := ji(1)      ; lat last
 iStrt := ji(2)      ; lon start
 iLast := ji(3)      ; lon last   
 lat2d := lat(jStrt:jLast,iStrt:iLast)
 lon2d := lon(jStrt:jLast,iStrt:iLast)
 clat2d := cos(lat*0.01745329)

; land-sea mask 
 a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
 lsm_m := landsea_mask(a->LSMASK,lat,lon) 

 tmp_hw_a := wgt_areaave2(hw_all(:,jStrt:jLast,iStrt:iLast),clat2d(jStrt:jLast,iStrt:iLast),0)
 tmp_hw_p := wgt_areaave2(hw_pd(:,jStrt:jLast,iStrt:iLast),clat2d(jStrt:jLast,iStrt:iLast),0)
 tmp_hw_g := wgt_areaave2(hw_sst(:,jStrt:jLast,iStrt:iLast),clat2d(jStrt:jLast,iStrt:iLast),0)
 
; top ranked experiments by HWF
 long_name1 = "Top"
 tmp_hw_a_sort1 := dim_pqsort_n(tmp_hw_a,-1,0) 
 tmp_hw_p_sort1 := dim_pqsort_n(tmp_hw_p,-1,0) 
 tmp_hw_g_sort1 := dim_pqsort_n(tmp_hw_g,-1,0)

; bottom ranked experiments by HWF
 long_name2 = "Bottom"
 tmp_hw_a_sort2 := dim_pqsort_n(tmp_hw_a,1,0) 
 tmp_hw_p_sort2 := dim_pqsort_n(tmp_hw_p,1,0) 
 tmp_hw_g_sort2 := dim_pqsort_n(tmp_hw_g,1,0) 

; only use the top/bottom 200
 avg_hw_a1 = dim_avg_n_Wrap(hw_all(tmp_hw_a_sort1(0:top_ranked-1),:,:),0)
 avg_hw_p1 = dim_avg_n_Wrap(hw_pd(tmp_hw_p_sort1(0:top_ranked-1),:,:),0)
 avg_hw_s1 = dim_avg_n_Wrap(hw_sst(tmp_hw_g_sort1(0:top_ranked-1),:,:),0)
 avg_hw_a2 = dim_avg_n_Wrap(hw_all(tmp_hw_a_sort2(0:top_ranked-1),:,:),0)
 avg_hw_p2 = dim_avg_n_Wrap(hw_pd(tmp_hw_p_sort2(0:top_ranked-1),:,:),0)
 avg_hw_s2 = dim_avg_n_Wrap(hw_sst(tmp_hw_g_sort2(0:top_ranked-1),:,:),0)  
 

 wks = gsn_open_wks("eps",ofile)     ; Open a workstation
 maps = new((/6/),graphic)

; resources for plotting
 res = True
; gsn_define_colormap(wks,"so4_23")  ; old colour map
 gsn_define_colormap(wks,"WhiteYellowOrangeRed") ; new colour map
 res@gsnDraw		 = False
 res@gsnFrame		 = False
 res@gsnAddCyclic         = False    ; data already has cyclic point

 res@mpMinLatF  = 25.
 res@mpMaxLatF  = 45.
 res@mpMinLonF		  = 235.
 res@mpMaxLonF		  = 285.
 res@mpCenterLonF	  = 260.
 res@mpCenterLatF	  = 40.0
 res@pmTickMarkDisplayMode  = "Always"		; turn on fancy 
 res@mpGridLineDashPattern = 2  
 res@mpGridLineThicknessF = 0.25
 res@mpOutlineOn = True
	
 res@cnFillOn		  = True     ; turn on color fill
 res@cnLinesOn		  = False    ; turn of contour lines
 res@cnLineLabelsOn           = False

 res@tmXBMinorOn	= False 	  ; no lon minor tickmarks
 res@tmYLMinorOn	= False 	  ; no lon minor tickmarks
 res@mpProjection	  = "LambertEqualArea" ; "CylindricalEquidistant"
 res@mpGridAndLimbOn	  = True
 res@mpGridLatSpacingF     = 10
 res@mpLimitMode	  = "LatLon"
;  res@cnFillColors    = (/0,13,14,15,16,17,18,19,20,21,22/) ; for "so4_23" 11 colours
 res@cnFillColors    =  (/2,25,48,71,94,117,140,163,186,209,255/) ; for "WhiteYellowOrangeRed" 11 colours
 res@tmYLLabelsOn = True
 res@tmXBLabelsOn = True
 res@tmYRLabelsOn = False
 res@tmXTLabelsOn = False
 res@tmYLOn = True
 res@tmXBOn = True
 res@tmYROn = False
 res@tmXTOn = False  
 res@lbLabelBarOn = False
 res@gsnLeftString = " "
 res@gsnRightString = " "
 res@sfXArray  	  = lon
 res@sfYArray  	  = lat
 res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
 res@cnMinLevelValF   = 5	   ; set min contour level
 res@cnMaxLevelValF   = 50	   ; set max contour level
 res@cnLevelSpacingF  = 5	   ; set contour spacing  

 res@tiYAxisFontHeightF = 0.03
 res@tiYAxisFontColor = "black"
 res@tmYLLabelFontHeightF = 0.02
 res@tmXBLabelFontHeightF = 0.02 

 res@tiYAxisString = "~F22~Top "+top_ranked+" avg"
 res@tiMainFontHeightF = 0.03
 res@tiMainString  = "~F22~1931 (WAH2~B~1930s~N~)" 

 maps(0) = gsn_csm_contour_map(wks,avg_hw_a1,res) ; rectangular 
  
 res@tiYAxisString = ""
 res@tiMainString  = "~F22~1931 (WAH2~B~PD~N~)" 
 
 maps(1) = gsn_csm_contour_map(wks,avg_hw_p1,res) ; rectangular ,
 
 res@tiMainString  = "~F22~WAH2~B~2015" 
 
 maps(2) = gsn_csm_contour_map(wks,avg_hw_s1,res) ; rectangular 

 res@tiYAxisString = "~F22~Bottom "+top_ranked+" avg"
 res@tiMainString  = ""

 maps(3) = gsn_csm_contour_map(wks,avg_hw_a2,res) ; rectangular 
 
 res@tiYAxisString = "" 
 
 maps(4) = gsn_csm_contour_map(wks,avg_hw_p2,res) ; rectangular ,
 
 maps(5) = gsn_csm_contour_map(wks,avg_hw_s2,res) ; rectangular 


;************************************************
; create panel
;************************************************
  resP = True
  resP@gsnPanelMainString = "HWF, 1931 & 2015"
  resP@gsnPanelMainFontHeightF = 0.02
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.007               ; make labels smaller
  resP@lbBoxEndCapStyle           = "TriangleBothEnds"
   
  resP@lbTitleString      = "Frequency (days/JJA)" ; bar title
  resP@lbTitlePosition      = "Bottom" 
  resP@lbTitleFontHeightF = 0.01
  resP@pmLabelBarOrthogonalPosF = -0.01
  
  resP@gsnPanelFigureStrings= (/"~F22~a","~F22~b","~F22~c","~F22~d","~F22~e","~F22~f"/) ; add strings to panel
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStringsPerimOn = False
  resP@amJust   = "TopLeft"

  gsn_panel(wks,maps,(/2,3/),resP)             ; now draw as one plot

  delete(wks)

  system("convert -density 144x144 -trim " + ofile + ".eps " + ofile + ".png")
;  system("rm " + ofile + ".eps")
 end
 

