;*************************************************
; fig2_hwf_1934_1936_nat_all_pd_WAH2_top200.ncl
;
; plot HWF for summers of 1934 and 1936 for WAH2_1930s, WAH2_1930s - WAH2_NAT, and WAH2_PD - WAH2_1930s
; 
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

 reg = "usa"
 seas = "JJA"
 bias = "yes"  ; choose the bias corrected model runs (doesn't affect HWF, but affects HWA)

 met = "hwf" ; (/"hwn","hwf","hwl","hwm","hwa"/)  hwl = longest event, hwa = hottest event
 obs = "GHCN"
 dset = "wah"
 type = "raw"
 xtype = "hottest"
 analogs = "no"
 pct = 100  ; if choose 100 then all simulations are chosen ; if choose 200 then top 200 simulations (ranked by HWF) are chosen
 Ttest = "mU" ; mU (Mann-Whitney U test)
 stats = "rms" ; "correl" ; "rms"  (analogues selected by correlation or RMSE)
 
 exps = "all_pd_ghg"  ; choose exps where we see the HIST, 1930s GHG influence and present day GHG influence
 dset_names = (/"WAH2~B~1930s","~F33~D~F21~(WAH2~B~1930s~N~,WAH2~B~NAT~N~)",\
  "~F33~D~F21~(WAH2~B~PD~N~,WAH2~B~1930s~N~)","WAH2~B~2015"/)

 years = (/1934,1936/)
 dimyears = dimsizes(years)
 npanels = dimyears
 
if (bias.eq."yes") then
if (analogs.eq."yes") then
 outfile = "fig2_"+obs+"_"+dset+"_"+met+"_"+xtype+"_ave_all_pd_2015_"+reg+"_"+seas+"_"+type+"_bias_corr_top"+pct+"p_analogs_"+Ttest+"_final"
else
 outfile = "fig2_"+obs+"_"+dset+"_"+met+"_"+xtype+"_ave_all_pd_"+reg+"_"+seas+"_"+type+"_bias_corr_top"+pct+"p_"+Ttest+"_final"
end if

else
 outfile = "fig2_"+obs+"_"+dset+"_"+met+"_"+xtype+"_ave_all_pd_"+reg+"_"+seas+"_"+type+"_top"+pct+"_"+Ttest+"_final"
end if

 wah_dir = "$WORK/NatCC_wah_2019/data/weather_at_home/"
 anlg_dir = "$WORK/NatCC_wah_2019/data/analogs/"
 
if (xtype.eq."earliest") then
 gettype = 0
end if
if (xtype.eq."longest") then
 gettype = 1
end if
if (xtype.eq."hottest") then
 gettype = 2
end if
 
 if (seas.eq."JJA") then
  getseas = 2
 end if
 if (seas.eq."MAM") then
  getseas = 1
 end if 
 
;************************************************
; plotting parameters
;************************************************

wks = gsn_open_wks("eps",outfile)     ; Open a workstation
gsn_define_colormap(wks, "WhiteYellowOrangeRed") ; new colour palette
; gsn_define_colormap(wks,"so4_23") ; old colour palette

 res			 = True
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
 res@mpPerimOn = False ;  Turns off the box perimeter.
 res@mpOutlineOn = True
	
 res@cnFillOn		  = True     ; turn on color fill
 res@cnLinesOn		  = False    ; turn of contour lines
 res@cnLineLabelsOn           = False
 res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
 res@lbLabelBarOn = False
 res@lbLabelFontHeightF = 0.03
 
 res@pmLabelBarOrthogonalPosF = .17           ; move whole thing down
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
  
  maps = new((/4,npanels/),graphic)
  plots = new((/4,npanels/),graphic)
  boxs = new((/4,4,npanels/),graphic)  
   
  tmres = True
  tmres@tmXBValues = ispan(-135,-30,15)
  tmres@tmXBLabelFontHeightF = 0.025
  tmres@tmYRValues = ispan(10,50,10)
  tmres@tmYRLabelFontHeightF = 0.025
  tmres@YUseLeft = False

  ypts = (/ 32, 32, 40, 40, 32/)
  xpts = (/ -100, -92, -92, -100, -100/)
  
  ypts1 = (/ 30, 30, 44, 44, 30/)
  xpts1 = (/ -105, -85, -85, -105, -105/) 

; region of interest ;
  latS = 30
  latN = 44
  lonL = 255
  lonR = 275
  lonLL = -105
  lonRR = -85
;------------------------------------------------- 

  opt = True 
  opt@gsnShadeFillType = "pattern" ; pattern fill 
  opt@gsnShadeHigh = 17  
  opt@gsnShadeFillDotSizeF = 0.0001
                             ; Use fill pattern #17 (stipple) 
  res2 = True
  res2@gsnDraw = False
  res2@gsnFrame = False
  res2@cnFillOn = False
  res2@cnFillColor = "black"
  res2@cnInfoLabelOn   = False                      ; turn off contour label
  res2@cnLineLabelsOn = False
  res2@cnLinesOn = False   ; turn of contour lines
  res2@mpMinLatF = 25.
  res2@mpMaxLatF = 45.
  res2@mpMinLonF = 235.
  res2@mpMaxLonF = 285.
  res2@mpCenterLonF = 260.
  res2@mpCenterLatF = 40.0
  res2@pmTickMarkDisplayMode  = "Always"		; turn on fancy  
  res2@gsnAddCyclic         = False    ; data already has cyclic point 
  res2@gsnMajorLatSpacing = 10              ; change maj lat tm spacing
  res2@gsnMajorLonSpacing = 10              ; change maj lon tm spacing
  res2@tmXBMinorOn        = False           ; no lon minor tickmarks
  res2@tmYLMinorOn        = False           ; no lon minor tickmarks
  res2@mpProjection	    = "LambertEqualArea" ; "CylindricalEquidistant"
  res2@mpGridAndLimbOn	    = True
  res2@mpGridLatSpacingF     = 10
  res2@mpLimitMode	    = "LatLon"
  res2@tmYLLabelsOn = False
  res2@tmXBLabelsOn = False
  res2@tmYRLabelsOn = False
  res2@tmXTLabelsOn = False
  res2@tmYLOn = False
  res2@tmXBOn = False
  res2@tmYROn = False
  res2@tmXTOn = False  
  res2@gsFillColor = "black"
  res2@cnMonoFillScale  = True
  res2@cnFillScaleF = 0.5

;******************************************************************************************************************
; resources for central US box (polygon)
  resB2 	       = True			   ; polyline mods desired
  resB2@gsnDraw = False
  resB2@gsnFrame = False
  resB2@cnFillOn = False
  resB2@cnInfoLabelOn	= False 		     ; turn off contour label
  resB2@cnLineLabelsOn = False
  resB2@cnFillColor = "black"
  resB2@gsLineThicknessF = 2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; resources for Mann-Whitney plots ;; 
  resM  		= True  		    ; polyline mods desired
  resM@gsnDraw = False
  resM@gsnFrame = False
  resM@cnFillOn = False
  resM@cnInfoLabelOn   = False                      ; turn off contour label
  resM@cnLineLabelsOn = False
  resM@cnLinesOn = False   ; turn of contour lines
  resM@cnFillColor = "black"
  resM@cnLinesOn = False   ; turn of contour lines  
  resM@cnMinLevelValF       = 0.98               ; set min contour level
  resM@cnMaxLevelValF       = 1.05              ; set max contour level
  resM@cnLevelSpacingF      = 0.01               ; set contour spacing 
  resM@cnMonoFillScale  = True
  resM@cnFillScaleF = 0.5 ;	
  resM@gsnAddCyclic         = False    ; data already has cyclic point 
  
;LAND SEA MASK
;*************************************************************************************
 a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
;*************************************************************************************  

kount = 1

do i=0,npanels-1

  if (bias.eq."yes") then

   wah_all_fil = addfile(wah_dir + met+"_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_all_every_exp_bias_corr.nc","r")
   wah_nat_fil = addfile(wah_dir + met+"_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_nat_every_exp_bias_corr.nc","r")
   wah_pd_fil = addfile(wah_dir + met+"_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_all_pd_every_exp_bias_corr.nc","r")
   wah_pd_ghg_sst_fil = addfile(wah_dir + met+"_usa_JF-SON_2015_from_r0-9_1921-1948_clim.wah_pd_ghg_sst_every_exp_bias_corr.nc","r")

   hwf_all_fil = addfile(wah_dir + "hwf_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_all_every_exp_bias_corr.nc","r")
   hwf_nat_fil = addfile(wah_dir + "hwf_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_nat_every_exp_bias_corr.nc","r")
   hwf_pd_fil = addfile(wah_dir + "hwf_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_all_pd_every_exp_bias_corr.nc","r")
   hwf_pd_ghg_sst_fil = addfile(wah_dir + "hwf_usa_JF-SON_2015_from_r0-9_1921-1948_clim.wah_pd_ghg_sst_every_exp_bias_corr.nc","r")

  else
   
   wah_all_fil = addfile(wah_dir + met+"_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_all_every_exp.nc","r")
   wah_nat_fil = addfile(wah_dir + met+"_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_nat_every_exp.nc","r")
   wah_pd_fil = addfile(wah_dir + met+"_usa_JF-SON_"+years(i)+"_from_r0-9_1921-1948_clim.wah_all_pd_every_exp.nc","r")
   wah_pd_ghg_sst_fil = addfile(wah_dir + met+"_usa_JF-SON_2015_from_r0-9_1921-1948_clim.wah_pd_ghg_sst_every_exp.nc","r")
 
  end if 
 
   lat = wah_all_fil->lat
   lon = wah_all_fil->lon
   lsm_m = landsea_mask(a->LSMASK,lat,lon)
  
 if (bias.eq."yes") then
   var_a := wah_all_fil->$met$(:,getseas,gettype,:,:)
   var_n := wah_nat_fil->$met$(:,getseas,gettype,:,:)
   var_p := wah_pd_fil->$met$(:,getseas,gettype,:,:)
   var_g := wah_pd_ghg_sst_fil->$met$(:,getseas,gettype,:,:)
   hwf_a := hwf_all_fil->hwf(:,getseas,gettype,:,:)
   hwf_n := hwf_nat_fil->hwf(:,getseas,gettype,:,:)
   hwf_p := hwf_pd_fil->hwf(:,getseas,gettype,:,:)
   hwf_g := hwf_pd_ghg_sst_fil->hwf(:,getseas,gettype,:,:)    
 end if 
 if (bias.eq."no") then
   var_a := wah_all_fil->$met$(:,getseas-1,gettype,:,:)
   var_n := wah_nat_fil->$met$(:,getseas-1,gettype,:,:)
   var_p := wah_pd_fil->$met$(:,getseas,gettype,:,:)
   var_g := wah_pd_ghg_sst_fil->$met$(:,getseas,gettype,:,:)
 end if  
   
   var_a@lat = lat
   var_n@lat = lat 
   var_p@lat = lat 
   var_g@lat = lat 

   var_a@lon = lon
   var_n@lon = lon
   var_p@lon = lon
   var_g@lon = lon 
 
   hwf_a@lat = lat
   hwf_n@lat = lat 
   hwf_p@lat = lat 
   hwf_g@lat = lat 

   hwf_a@lon = lon
   hwf_n@lon = lon
   hwf_p@lon = lon
   hwf_g@lon = lon    
  
   

;    Circulation analogues
   ids_all_file = systemfunc("ls "+anlg_dir+"analogs5_hgt500_dtr_"+stats+"_20CR_hottest_HW_all_"+years(i)+"**avg.*")
   ids_nat_file = systemfunc("ls "+anlg_dir+"analogs5_hgt500_dtr_"+stats+"_20CR_hottest_HW_nat_"+years(i)+"**avg.*")
   ids_pd_file = systemfunc("ls "+anlg_dir+"analogs5_hgt500_dtr_"+stats+"_20CR_hottest_HW_all_pd_"+years(i)+"**avg.*")
   ids_pd_ghg_sst_file = systemfunc("ls "+anlg_dir+"analogs5_hgt500_dtr_"+stats+"_20CR_hottest_HW_pd_ghg_sst_"+years(i)+"**avg.*")
   ids_all_f = addfile(ids_all_file,"r")
   ids_nat_f = addfile(ids_nat_file,"r")
   ids_pd_f = addfile(ids_pd_file,"r")
   ids_pd_ghg_sst_f = addfile(ids_pd_ghg_sst_file,"r")
   expm_ids_a := wah_all_fil->exp_ids
   expm_ids_n := wah_nat_fil->exp_ids
   expm_ids_p := wah_pd_fil->exp_ids
   expm_ids_g := wah_pd_ghg_sst_fil->exp_ids
   
   wah_ids_a := tostring(expm_ids_a)
   wah_ids_n := tostring(expm_ids_n)
   wah_ids_p := tostring(expm_ids_p)
   wah_ids_g := tostring(expm_ids_g)
   
   anlog_data_all := asciiread(ids_all_file,-1,"string")
   anlog_ids_all := str_get_field(anlog_data_all, 1,"  ")
   anlog_distance_all :=  stringtofloat(str_get_field(anlog_data_all, 2,"  "))
   anlog_correlation_all := stringtofloat(str_get_field(anlog_data_all, 3,"  "))
   id_indx_all := get1Dindex(wah_ids_a,anlog_ids_all)   
   iz_all := ind(.not.ismissing(id_indx_all))
   id_indx2_all := id_indx_all(iz_all)      

   anlog_data_nat := asciiread(ids_nat_file,-1,"string")
   anlog_ids_nat := str_get_field(anlog_data_nat, 1,"  ")
   anlog_distance_nat :=  stringtofloat(str_get_field(anlog_data_nat, 2,"  "))
   anlog_correlation_nat := stringtofloat(str_get_field(anlog_data_nat, 3,"  "))
   id_indx_nat := get1Dindex(wah_ids_n,anlog_ids_nat)   
   iz_nat := ind(.not.ismissing(id_indx_nat))
   id_indx2_nat := id_indx_nat(iz_nat) 
     
   anlog_data_pd := asciiread(ids_pd_file,-1,"string")
   anlog_ids_pd := str_get_field(anlog_data_pd, 1,"  ")
   anlog_distance_pd :=  stringtofloat(str_get_field(anlog_data_pd, 2,"  "))
   anlog_correlation_pd := stringtofloat(str_get_field(anlog_data_pd, 3,"  "))
   id_indx_pd := get1Dindex(wah_ids_p,anlog_ids_pd)     
   iz_pd := ind(.not.ismissing(id_indx_pd))
   id_indx2_pd := id_indx_pd(iz_pd) 
   dim_exps := dimsizes(id_indx2_pd)

   anlog_data_pd_ghg_sst := asciiread(ids_pd_ghg_sst_file,-1,"string")
   anlog_ids_pd_ghg_sst := str_get_field(anlog_data_pd_ghg_sst, 1,"  ")
   anlog_distance_pd_ghg_sst :=  stringtofloat(str_get_field(anlog_data_pd_ghg_sst, 2,"  "))
   anlog_correlation_pd_ghg_sst := stringtofloat(str_get_field(anlog_data_pd_ghg_sst, 3,"  "))
   id_indx_pd_ghg_sst := get1Dindex(wah_ids_g,anlog_ids_pd_ghg_sst)     
   iz_pd_ghg_sst := ind(.not.ismissing(id_indx_pd_ghg_sst))
   id_indx2_pd_ghg_sst := id_indx_pd_ghg_sst(iz_pd_ghg_sst)    
   
      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; sort model HW metrics into top 10% ;;;;;;;;;;;;;;;;;;
   ji = region_ind (lat,lon,latS,latN,lonL,lonR)
   jStrt = ji(0)      ; lat start
   jLast = ji(1)      ; lat last
   iStrt = ji(2)      ; lon start
   iLast = ji(3)      ; lon last   
   lat2d = lat(jStrt:jLast,iStrt:iLast)
   lon2d = lon(jStrt:jLast,iStrt:iLast)
   clat2d = cos(lat*0.01745329)

   tmp_a := wgt_areaave2(var_a(:,jStrt:jLast,iStrt:iLast),clat2d(jStrt:jLast,iStrt:iLast),0)
   tmp_n := wgt_areaave2(var_n(:,jStrt:jLast,iStrt:iLast),clat2d(jStrt:jLast,iStrt:iLast),0)
   tmp_p := wgt_areaave2(var_p(:,jStrt:jLast,iStrt:iLast),clat2d(jStrt:jLast,iStrt:iLast),0)
   tmp_g := wgt_areaave2(var_g(:,jStrt:jLast,iStrt:iLast),clat2d(jStrt:jLast,iStrt:iLast),0) 
   
   
   ip_a := dim_pqsort(tmp_a, -2)
   ip_n := dim_pqsort(tmp_n, -2)
   ip_p := dim_pqsort(tmp_p, -2)
   ip_g := dim_pqsort(tmp_g, -2)
   
   no_a := round(dimsizes(tmp_a)*(int2flt(pct)/100),3)
   no_n := round(dimsizes(tmp_n)*(int2flt(pct)/100),3)
   no_p := round(dimsizes(tmp_p)*(int2flt(pct)/100),3)
   no_g := round(dimsizes(tmp_g)*(int2flt(pct)/100),3)
   
   print(no_a + " " + no_n + " " + no_p + " " + no_g)
   
if (analogs.eq."yes") then
   var_a := var_a(id_indx2_all(0:149),:,:)
   var_n := var_n(id_indx2_nat(0:149),:,:)  
   var_p := var_p(id_indx2_pd(0:149),:,:)	
   var_g := var_g(id_indx2_pd_ghg_sst(0:149),:,:)
else

if (pct.gt.100) then
   var_a := var_a(ip_a(0:pct-1),:,:)
   var_n := var_n(ip_n(0:pct-1),:,:)  
   var_p := var_p(ip_p(0:pct-1),:,:)   
   var_g := var_g(ip_g(0:pct-1),:,:)
else
   var_a := var_a(ip_a(0:no_a-1),:,:)
   var_n := var_n(ip_n(0:no_n-1),:,:)  
   var_p := var_p(ip_p(0:no_p-1),:,:)   
   var_g := var_g(ip_g(0:no_g-1),:,:) 
end if	
end if
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  hwf_a_test := var_a ; test_all_fil->$met$(:,getseas,2,:,:)
  hwf_n_test := var_n ; test_nat_fil->$met$(:,getseas,2,:,:) 
  hwf_p_test := var_p ; test_pd_fil->$met$(:,getseas,2,:,:)  
  hwf_g_test := var_g ; test_pd_fil->$met$(:,getseas,1,:,:)
 

 if (exps.eq."all_pd" .or. exps.eq."all_nat_pd" .or. exps.eq."all_pd_ghg") then 
  if (met.eq."hwn") then
   res@lbLabelStride = 2
   met_longname = "Number (events/"+seas+")"
   var_m_a = dim_avg_n_Wrap(var_a,0)
   var_m_n = dim_avg_n_Wrap(var_n,0)
   var_m_p = dim_avg_n_Wrap(var_p,0)
   var_m_g = dim_avg_n_Wrap(var_g,0)
   diff_an = var_m_a - var_m_n
   diff_pa = var_m_p - var_m_a
   var_m_a = mask(var_m_a,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
   var_m_n = mask(var_m_n,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
   var_m_p = mask(var_m_p,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
   var_m_g = mask(var_m_g,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
   copy_VarCoords(var_m_a,diff_an)
   copy_VarCoords(var_m_a,diff_pa)
   diff_an = mask(diff_an,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
   diff_pa = mask(diff_pa,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
  if (seas.eq."JJA") then
    minLevel_m  = 1.5	   ; set min contour level
    maxLevel_m  = 6 	   ; set max contour level
    interval_m  = 0.5	   ; set contour spacing
    minLevel_g  = 1.5	   ; set min contour level
    maxLevel_g  = 6 	   ; set max contour level
    interval_g  = 0.5	   ; set contour spacing  
    minLevel_d  = 0.1; 0.3    ; set min contour level
    maxLevel_d  = 1; 1.2	  ; set max contour level
    interval_d  = 0.1    ; set contour spacing 	 
    minLevel_d1  = 0.1	   ; set min contour level
    maxLevel_d1  = 0.6	   ; set max contour level
    interval_d1  = 0.1	   ; set contour spacing          
   end if 
 end if
  
 if (met.eq."hwl") then
  res@lbLabelStride = 1
  met_longname = "Duration (days)"
  var_m_a = dim_avg_n_Wrap(var_a,0)
  var_m_n = dim_avg_n_Wrap(var_n,0)
  var_m_p = dim_avg_n_Wrap(var_p,0)
  var_m_g = dim_avg_n_Wrap(var_g,0)
  diff_an = var_m_a - var_m_n
  diff_pa = var_m_p - var_m_a
  var_m_a = mask(var_m_a,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_n = mask(var_m_n,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_p = mask(var_m_p,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_g = mask(var_m_g,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
  copy_VarCoords(var_m_a,diff_an)
  copy_VarCoords(var_m_a,diff_pa)
  diff_an = mask(diff_an,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  diff_pa = mask(diff_pa,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  if (seas.eq."JJA") then
    minLevel_m  = 2	   ; set min contour level
    maxLevel_m  = 20  	   ; set max contour level
    interval_m  = 2	   ; set contour spacing
    minLevel_g  = 2	   ; set min contour level
    maxLevel_g  = 20  	   ; set max contour level
    interval_g  = 2	   ; set contour spacing    
    minLevel_d  = 0.2; 0.5	   ; set min contour level
    maxLevel_d  = 3.8; 5	   ; set max contour level
    interval_d  = 0.4; 0.5	   ; set contour spacing 
    minLevel_d1  = 0.3	   ; set min contour level
    maxLevel_d1  = 1.8	   ; set max contour level
    interval_d1  = 0.3	   ; set contour spacing  
   if (pct.eq.100) then
    minLevel_d  = 1	   ; set min contour level
    maxLevel_d  = 5	   ; set max contour level
    interval_d  = .5	   ; set contour spacing          
    minLevel_m  := 1	   ; set min contour level
    maxLevel_m  := 10	   ; set max contour level
    interval_m  := 1   	   ; set contour spacing
   end if
  end if
 end if 
 
 if (met.eq."hwf") then
  met_longname = "Frequency (days/"+seas+")"
  var_m_a = dim_avg_n_Wrap(var_a,0)
  var_m_n = dim_avg_n_Wrap(var_n,0)
  var_m_p = dim_avg_n_Wrap(var_p,0)
  var_m_g = dim_avg_n_Wrap(var_g,0)
  diff_an = var_m_a - var_m_n
  diff_pa = var_m_p - var_m_a
  var_m_a = mask(var_m_a,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_n = mask(var_m_n,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_p = mask(var_m_p,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_g = mask(var_m_g,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
  copy_VarCoords(var_m_a,diff_an)
  copy_VarCoords(var_m_a,diff_pa)
  diff_an = mask(diff_an,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  diff_pa = mask(diff_pa,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  if (seas.eq."JJA") then 
    minLevel_m  = 5	   ; set min contour level
    maxLevel_m  = 50	   ; set max contour level
    interval_m  = 5   	   ; set contour spacing
    minLevel_g  = 5	   ; set min contour level
    maxLevel_g  = 50	   ; set max contour level
    interval_g  = 5	   ; set contour spacing
   if (pct.eq.100) then
    minLevel_d  = 1	   ; set min contour level
    maxLevel_d  = 5	   ; set max contour level
    interval_d  = .5	   ; set contour spacing       
    minLevel_m  = 2	   ; set min contour level
    maxLevel_m  = 20	   ; set max contour level
    interval_m  = 2   	   ; set contour spacing
   else
    minLevel_d  = 1	   ; set min contour level
    maxLevel_d  = 10	   ; set max contour level
    interval_d  = 1	   ; set contour spacing          
   end if 
    minLevel_d1  = 1.5	   ; set min contour level
    maxLevel_d1  = 4	   ; set max contour level
    interval_d1  = 0.5	   ; set contour spacing       
  end if
 end if 
 
 if (met.eq."hwa") then
  met_longname = "Amplitude (~S~o~N~C)"
  var_m_a = dim_avg_n_Wrap(var_a,0)
  var_m_n = dim_avg_n_Wrap(var_n,0)
  var_m_p = dim_avg_n_Wrap(var_p,0)
  var_m_g = dim_avg_n_Wrap(var_g,0)
  diff_an = var_m_a - var_m_n
  diff_pa = var_m_p - var_m_a
  var_m_a = mask(var_m_a,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_n = mask(var_m_n,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_p = mask(var_m_p,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_g = mask(var_m_g,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
  copy_VarCoords(var_m_a,diff_an)
  copy_VarCoords(var_m_a,diff_pa)
  diff_an = mask(diff_an,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  diff_pa = mask(diff_pa,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  if (seas.eq."JJA") then
    minLevel_m  = 35	   ; set min contour level
    maxLevel_m  = 44	   ; set max contour level
    interval_m  = 1	   ; set contour spacing
    minLevel_g  = 35	   ; set min contour level
    maxLevel_g  = 44	   ; set max contour level
    interval_g  = 1	   ; set contour spacing
    minLevel_d  = 0.1; 0.05	   ; set min contour level
    maxLevel_d  = 1.0; 0.5	   ; set max contour level
    interval_d  = 0.1	   ; set contour spacing            
    minLevel_d1  = 0.0	   ; set min contour level
    maxLevel_d1  = 0.5	   ; set max contour level
    interval_d1  = 0.1	   ; set contour spaci
  end if
 end if 

 if (met.eq."hwaa") then
  met_longname = "Amplitude (~S~o~N~C)"
  var_m_a = dim_avg_n_Wrap(var_a,0)
  var_m_n = dim_avg_n_Wrap(var_n,0)
  var_m_p = dim_avg_n_Wrap(var_p,0)
  var_m_g = dim_avg_n_Wrap(var_g,0)
  diff_an = var_m_a - var_m_n
  diff_pa = var_m_p - var_m_a
  var_m_a = mask(var_m_a,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_n = mask(var_m_n,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_p = mask(var_m_p,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_g = mask(var_m_g,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
  copy_VarCoords(var_m_a,diff_an)
  copy_VarCoords(var_m_a,diff_pa)
  diff_an = mask(diff_an,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  diff_pa = mask(diff_pa,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  if (seas.eq."JJA") then
    minLevel_m  = 3	   ; set min contour level
    maxLevel_m  = 12	   ; set max contour level
    interval_m  = 1	   ; set contour spacing
    minLevel_g  = 3	   ; set min contour level
    maxLevel_g  = 12	   ; set max contour level
    interval_g  = 1	   ; set contour spacing
    minLevel_d  = 0.05	   ; set min contour level
    maxLevel_d  = 0.5	   ; set max contour level
    interval_d  = 0.05	   ; set contour spacing            
    minLevel_d1  = 0.0	   ; set min contour level
    maxLevel_d1  = 0.5	   ; set max contour level
    interval_d1  = 0.1	   ; set contour spaci
  end if
 end if 
 
 if (met.eq."hwt") then
  met_longname = "Timing (days after Jun 1)"
  var_m_a = dim_avg_n_Wrap(var_a,0)
  var_m_n = dim_avg_n_Wrap(var_n,0)
  var_m_p = dim_avg_n_Wrap(var_p,0)
  var_m_g = dim_avg_n_Wrap(var_g,0)
  diff_an = var_m_a - var_m_n
  diff_pa = var_m_p - var_m_a
  var_m_a = mask(var_m_a,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_n = mask(var_m_n,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_p = mask(var_m_p,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  var_m_g = mask(var_m_g,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
  copy_VarCoords(var_m_a,diff_an)
  copy_VarCoords(var_m_a,diff_pa)
  diff_an = mask(diff_an,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  diff_pa = mask(diff_pa,lsm_m.eq.0.or.lsm_m.eq.2,False)	 ; mask out all ocean points from data
  if (seas.eq."JJA") then  
    minLevel_m  = 20	   ; set min contour level
    maxLevel_m  = 38	   ; set max contour level
    interval_m  = 2	   ; set contour spacing
    minLevel_d  = -9	   ; set min contour level
    maxLevel_d  = 0	   ; set max contour level
    interval_d  = 1	   ; set contour spacing    
    minLevel_d1  = -4	   ; set min contour level
    maxLevel_d1  = 1	   ; set max contour level
    interval_d1  = 1	   ; set contour spacing 
  end if
 end if 
end if ;  if (exps.eq."all_pd") then 


;;;;;;;;;;;;;;;; Mann-Whitney U Test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mdir = "$WORK/NatCC_wah_2019/data/MannWhitney/"

if (Ttest.eq."mU") then 
 if (analogs.eq."yes") then
  Mfile1 = mdir+"M_array_all_nat_"+years(i)+"_"+dset+"_hwf_"+\
  "hottest_ave_all_pd_2015_"+reg+"_"+seas+"_"+type+"_bias_corr_top"+pct+"p_analogs.nc"
  Mfile2 = mdir+"M_array_all_pd_"+years(i)+"_"+dset+"_hwf_"+\
  "hottest_ave_all_pd_2015_"+reg+"_"+seas+"_"+type+"_bias_corr_top"+pct+"p_analogs.nc"
 else 
  Mfile1 = mdir+"M_array_all_nat_"+years(i)+"_"+dset+"_hwf_"+\
  "hottest_ave_all_pd_2015_"+reg+"_"+seas+"_"+type+"_bias_corr_top"+pct+".nc"
  Mfile2 = mdir+"M_array_all_pd_"+years(i)+"_"+dset+"_hwf_"+\
  "hottest_ave_all_pd_2015_"+reg+"_"+seas+"_"+type+"_bias_corr_top"+pct+".nc"
 end if
 
if (.not.fileexists(Mfile1)) then

  U_array = new((/nlatX,nlonX/),float,-999)
  copy_VarCoords(diff_pa,U_array)

  do ilatX = 0, nlatX-1
   do ilonX = 0, nlonX-1
    print(ilatX+" hwf  all_nat") 
    x1 = hwf_a_test(:,ilatX,ilonX)
    x2 = hwf_n_test(:,ilatX,ilonX)
  
    arry = new((/max((/dimsizes(x1),dimsizes(x2)/)),7/),float)
 
    arry(:,0) = x1(:)
    arry(:,1) = x2(:)
    arry(:,2) = 0
    arry(:,3) = 1
    sort_no = array_append_record(arry(:,0),arry(:,1),0)
    sort_zero = array_append_record(arry(:,2),arry(:,3),0)
    ip = dim_pqsort_n(sort_no,1,0) ; + 1
  
    arry2 = sort_no(ip)
    zero = sort_zero(ip) 
       
    n1 = int2flt(dimsizes(x1))
    n2 = int2flt(dimsizes(x2))
		
  sort_rnk = new(dimsizes(arry2),float,arry2@_FillValue) 

  asciiwrite ("foo.txt" , sprintf("%9.3f", arry2 ))
  rnk = systemfunc("awk -f $WORK/ncl_scripts/ranking_f.awk foo.txt") 
  sort_rnk = stringtofloat(rnk)
   
  y1 = where(zero.eq.0,sort_rnk,0)
  y2 = where(zero.eq.1,sort_rnk,0)

  
  R1 = sum(y1)
  R2 = sum(y2)
 
    
  U1 = R1 - (0.5*(n1*(n1+1)))
  U2 = R2 - (0.5*(n2*(n2+1)))
 
  UU = min (array_append_record(U1,U2,0))

  mU = (n1*n2)*0.5
  tauU = ((n1*n2*(n1+n2+1))/12)^0.5
  zU = (UU - mU)/tauU
  
  U_array(ilatX,ilonX) = zU
  
  delete([/sort_rnk,rnk,y1,y2,R1,R2,U1,U2,UU,mU,tauU,zU/])
  delete([/n1,n2,x1,x2,arry,zero,arry2,ip,sort_zero,sort_no/])    

   end do
  end do  

 
 fout1 = addfile(Mfile1,"c")
 fout1->U_all_nat = U_array
 U_all_nat = U_array

else

 fout1 = addfile(Mfile1,"r")
 U_all_nat = fout1->U_all_nat

end if


if (.not.fileexists(Mfile2)) then

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  U_array := new((/nlatX,nlonX/),float,-999)
  copy_VarCoords(diff_pa,U_array)

  do ilatX = 0, nlatX-1
   do ilonX = 0, nlonX-1
    print(ilatX+" hwf all_pd") 
    x1 = hwf_a_test(:,ilatX,ilonX)
    x2 = hwf_p_test(:,ilatX,ilonX)
        
    arry = new((/max((/dimsizes(x1),dimsizes(x2)/)),7/),float)

    arry(:,0) = x1(:)
   if (years(i).eq.1934) then 
    arry(0:1257,1) = x2(:)
   end if
   if (years(i).eq.1936) then  
     arry(0:1221,1) = x2(:)     
   end if 
    arry(:,2) = 0
    arry(:,3) = 1
    sort_no = array_append_record(arry(:,0),arry(:,1),0)
    sort_zero = array_append_record(arry(:,2),arry(:,3),0)
    ip = dim_pqsort_n(sort_no,1,0) ; + 1
  
    arry2 = sort_no(ip)
    zero = sort_zero(ip) 
       
    n1 = int2flt(dimsizes(x1))
    n2 = int2flt(dimsizes(x2))
		
  sort_rnk = new(dimsizes(arry2),float,arry2@_FillValue) 

  asciiwrite ("foo.txt" , sprintf("%9.3f", arry2 ))
  rnk = systemfunc("awk -f $WORK/ncl_scripts/ranking_f.awk foo.txt") 
  sort_rnk = stringtofloat(rnk)
   
  y1 = where(zero.eq.0,sort_rnk,0)
  y2 = where(zero.eq.1,sort_rnk,0)
  
  R1 = sum(y1)
  R2 = sum(y2)
    
  U1 = R1 - (0.5*(n1*(n1+1)))
  U2 = R2 - (0.5*(n2*(n2+1)))
 
  UU = min (array_append_record(U1,U2,0))
  
  mU = (n1*n2)*0.5
  tauU = ((n1*n2*(n1+n2+1))/12)^0.5
  zU = (UU - mU)/tauU
  
  U_array(ilatX,ilonX) = zU
  
  delete([/sort_rnk,rnk,y1,y2,R1,R2,U1,U2,UU,mU,tauU,zU/])
  delete([/n1,n2,x1,x2,arry,zero,arry2,ip,sort_zero,sort_no/])    

   end do
  end do  
 
 
 fout2 = addfile(Mfile2,"c")
 fout2->U_all_pd = U_array

 U_all_pd = U_array
 delete(U_array)
 

else
 

 fout2 = addfile(Mfile2,"r")
 U_all_pd = fout2->U_all_pd

 end if

 npts1 := num(U_all_nat(jStrt:jLast,iStrt:iLast).ne.0)

 UU_all_nat = where(abs(U_all_nat).ge.1.96,1,0)  ; 1.645 for 90%,  1.96 for 95%
 UU_all_nat = mask(UU_all_nat,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
 copy_VarCoords(U_all_nat,UU_all_nat)
 U_an_cus := ndtooned(U_all_nat(jStrt:jLast,iStrt:iLast))
 U_an_cus_indx := ind(U_an_cus.ne.0)
 asciiwrite("U_"+met+"_"+xtype+"_all_nat_cUSA_"+seas+"_"+type+"_bias_corr_top"+pct+"p_"+Ttest+"_"+years(i)+".txt",U_an_cus(U_an_cus_indx))           ; Write it to a file


 npts2 := num(U_all_pd(jStrt:jLast,iStrt:iLast).ne.0)
 UU_all_pd = where(abs(U_all_pd).ge.1.96,1,0)  ; 1.645 for 90%,  1.96 for 95%
 UU_all_pd = mask(UU_all_pd,lsm_m.eq.0.or.lsm_m.eq.2,False)	  ; mask out all ocean points from data
 copy_VarCoords(U_all_pd,UU_all_pd)
 U_ap_cus := ndtooned(U_all_pd(jStrt:jLast,iStrt:iLast))
 U_ap_cus_indx := ind(U_ap_cus.ne.0)
 asciiwrite("U_"+met+"_"+xtype+"_all_pd_cUSA_"+seas+"_"+type+"_bias_corr_top"+pct+"p_"+Ttest+"_"+years(i)+".txt",U_ap_cus(U_ap_cus_indx))           ; Write it to a file

end if ; pc.ne.100


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; resources for maps
   
  res@mpProjection	    = "LambertEqualArea" ; "CylindricalEquidistant"
  res@mpGridAndLimbOn	    = True
  res@mpGridLatSpacingF     = 10
  res@mpLimitMode	    = "LatLon"
  res@mpMinLatF	 = 25.
  res@mpMaxLatF	 = 45.
  res@mpMinLonF	 = 235.
  res@mpMaxLonF	 = 285.
   
  res@tiYAxisFontHeightF = 0.04
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
  res2@gsnMajorLatSpacing = 10              ; change maj lat tm spacing
  res@gsnCenterString = ""
 end if 

if (i.eq.npanels-1) then 
 res@lbLabelBarOn = True
 res@lbTitleString      = met_longname ; bar title
 res@lbTitlePosition      = "Bottom" 			; title location
end if 

 res@sfXArray		   = lon
 res@sfYArray		   = lat
 res2@sfXArray		   = lon
 res2@sfYArray		   = lat

 res@tiYAxisString = "~F22~"+years(i)
 delete([/res@cnMinLevelValF,res@cnMaxLevelValF,res@cnLevelSpacingF/])
 res@cnMinLevelValF	= minLevel_m	     ; set min contour level
 res@cnMaxLevelValF	= maxLevel_m	     ; set max contour level
 res@cnLevelSpacingF	= interval_m	     ; set contour spacing  

 if (i.eq.0) then 
  res@gsnCenterString = dset_names(0) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if 

if (exps.eq."all_pd".or. exps.eq."all_pd_ghg") then

  res@lbLabelBarOn = False 

 if (i.eq.1) then
  res@lbLabelBarOn = True
 end if

 maps(0,i)=gsn_csm_contour_map(wks,var_m_a,res) ; rectangular
 maps(0,i) = add_map_tickmarks(wks,maps(0,i),tmres)

if (met.eq."hwf") then
 boxi3 = gsn_add_polyline(wks,maps(0,0),xpts1,ypts1,resB2)
end if 
end if

 if (i.eq.0) then 
  res@gsnCenterString = dset_names(1) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if 

 getvalues maps@contour
    "cnLevels"               : levels1
 end getvalues

 delete([/res@cnMinLevelValF,res@cnMaxLevelValF,res@cnLevelSpacingF/])
 res@cnMinLevelValF	= minLevel_d	     ; set min contour level
 res@cnMaxLevelValF	= maxLevel_d	     ; set max contour level
 res@cnLevelSpacingF	= interval_d	     ; set contour spacing  
 res@tiYAxisString = ""
 
 if (i.eq.0) then 
  res@gsnCenterString = dset_names(2) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if  

if (exps.eq."all_pd" .or. exps.eq."all_pd_ghg") then  

 if (i.eq.0) then 
  res@gsnCenterString = dset_names(1) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if  
 
 if (i.eq.1) then
  res@lbLabelBarOn = True
 end if

 if (Ttest.eq."mU") then 
  multi = where(UU_all_nat.eq.1,1,UU_all_nat@_FillValue) ; for MWU test  
 end if 
 
  resM@sfXArray = lon
  resM@sfYArray = lat
  
 if (pct.eq.100) then 
  diff_all_nat = diff_an*multi
 else 
  diff_all_nat = diff_an
 end if 
 
  copy_VarCoords(diff_an,diff_all_nat)
  maps(1,i)=gsn_csm_contour_map(wks,diff_all_nat,res) ; rectangular 
  maps(1,i) = add_map_tickmarks(wks,maps(1,i),tmres)
  
 if (Ttest.eq."mU") then   
  plots(0,i) = gsn_csm_contour(wks,int2flt(UU_all_nat),resM) ; contours are at 95,100 
  copy_VarCoords(diff_an,UU_all_nat)
  count1 := UU_all_nat(jStrt:jLast,iStrt:iLast)
  print("ALL_NAT count " + sum(count1) + " out of " + npts1 + " or " + round(sum(int2flt(count1))/int2flt(npts1)*100,0))
 end if 
  
  plots(0,i) = gsn_contour_shade(plots(0,i),0,0.9,opt) ; pattern fill all areas   
 
 if (pct.ne.100) then
  overlay(maps(1,i),plots(0,i)) 
 end if 
  
 if (i.eq.0) then 
  res@gsnCenterString = dset_names(2) ;  +"~B~"+seas      ; add common title
 else
  res@gsnCenterString = ""
 end if 

 if (Ttest.eq."mU") then 
  multi1 = where(UU_all_pd.eq.1,1,UU_all_pd@_FillValue) ; for MWU test 
  copy_VarCoords(diff_pa,multi1)
  count1 := multi1(jStrt:jLast,iStrt:iLast)
  print("ALL_PD count " + sum(count1) + " out of " + npts2 + " or " + round(sum(int2flt(count1))/int2flt(npts2)*100,0)) 
 end if 
  diff_all_pd = diff_pa*multi1
  copy_VarCoords(diff_pa,diff_all_pd)
  maps(2,i)=gsn_csm_contour_map(wks,diff_all_pd,res) ; rectangular 
  maps(2,i) = add_map_tickmarks(wks,maps(2,i),tmres)

end if
 
 getvalues maps@contour
    "cnLevels"               : levels2
 end getvalues
  
 delete([/res@sfXArray ,res@sfYArray /])
 
 delete([/wah_all_fil,wah_nat_fil,wah_pd_fil/])
 delete([/var_a,var_n,var_p,var_m_a,var_m_n,var_m_p/])
 
end do ; do i

if (exps.eq."all_pd_ghg") then
 res@tiYAxisFontHeightF = 0.04
 res@tiYAxisString = "~F22~2015"
 res@tiYAxisOffsetXF = -0.006
 res@sfXArray		   = lon
 res@sfYArray		   = lat
 delete([/res@cnMinLevelValF,res@cnMaxLevelValF,res@cnLevelSpacingF/])
 res@cnMinLevelValF	= minLevel_g	     ; set min contour level
 res@cnMaxLevelValF	= maxLevel_g	     ; set max contour level
 res@cnLevelSpacingF	= interval_g	     ; set contour spacing   
 res@gsnCenterString = dset_names(3) ;  +"~B~"+seas      ; add common title
 maps1=gsn_csm_contour_map(wks,var_m_g,res) ; rectangular
 maps1 = add_map_tickmarks(wks,maps1,tmres)
 delete([/res@cnMinLevelValF,res@cnMaxLevelValF,res@cnLevelSpacingF/])
end if

maps!0="row"
maps!1="col"

plot1d = ndtooned(maps(col | :, row | :))
plot1d(0) = maps(0,0)
plot1d(1) = maps(1,0)
plot1d(2) = maps(2,0)
plot1d(3) = maps(0,1)
plot1d(4) = maps(1,1)
plot1d(5) = maps(2,1)
plot1d(6) = maps1

if (exps.eq."all_pd_ghg" .and. pct.eq.200) then
 txres  	     = True
 txres@txFontHeightF = 0.02
 text1 = gsn_add_text(wks,plot1d(1),"3%" ,-122,25,txres)
 text2 = gsn_add_text(wks,plot1d(4),"13%",-122,25,txres)
 text3 = gsn_add_text(wks,plot1d(2),"67%",-122,25,txres)
 text4 = gsn_add_text(wks,plot1d(5),"93%",-122,25,txres)
end if

;************************************************
; create panel
;************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelLabelBar = False                   ; add common colorbar  
  
 if (bias.eq."yes") then 
  if (met.eq."hwl") then
   resP@txString = "HWD" ; ~B~"+seas     ; new resource added in NCL V6.4.0
  else
   resP@txString = str_upper(met); +"~B~"+seas     ; new resource added in NCL V6.4.0
  end if 
 else
  resP@txString = str_upper(met); +"~B~"+seas     ; new resource added in NCL V6.4.0 
 end if 
  resP@txFontHeightF = 0.03
  resP@gsnPanelYWhiteSpacePercent = 1
  resP@gsnPanelXWhiteSpacePercent = 0  
 if (met.eq."hwf") then 
  resP@gsnPanelFigureStrings= (/"~F22~a","~F22~b","~F22~c","~F22~d","~F22~e","~F22~f"/) ; add strings to panel
 end if 
 if (met.eq."hwl") then 
  resP@gsnPanelFigureStrings= (/"~F22~b","~F22~b","~F22~c","~F22~e","~F22~e","~F22~f"/) ; add strings to panel
 end if 
  if (met.eq."hwa") then 
  resP@gsnPanelFigureStrings= (/"~F22~c","~F22~b","~F22~c","~F22~f","~F22~e","~F22~f"/) ; add strings to panel
 end if 
  resP@gsnPanelFigureStringsFontHeightF = 0.012
  resP@gsnPanelFigureStringsPerimOn = False
  resP@amJust   = "TopLeft"
  resP@gsnPanelRowSpec = True                   ; tell panel what order to plot
  resP@gsnPanelTop = 1.0
  resP@gsnPanelBottom   = 0.5                  ; add space at bottom
  gsn_panel(wks,plot1d(0:5),(/3,3/),resP)
 
  frame(wks)
  delete(wks)

  system("convert -alpha off -background white -trim -density 900 " +\
          outfile+".eps " + outfile + ".png")
  
;  system("convert -alpha off -background white -trim -density 300 " +\
;          outfile+".eps " + outfile + ".tiff")  
	  
;  system("ps2pdf -dPDFSETTINGS=/prepress -dEPSCrop " + outfile + ".ps " + outfile + ".pdf")
;  system("pdfcrop " + outfile + ".pdf " + outfile + "_crop.pdf")
;  system("rm " + outfile + ".pdf")
;  system("convert -density 144x144 -trim " + outfile + ".ps " + outfile + ".png")
;  system("rm " + outfile + ".eps")
end

 
 
