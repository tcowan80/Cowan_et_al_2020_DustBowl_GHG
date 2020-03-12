;***************************************************
;
; fig1_BEST_GHCN_hw_metrics_1934_1936.ncl
;
;
; This file calls in GHCN-daily & BEST heatwave metric data
; and plots heat wave frequency, duration & amplitude for 1936 (or 1934 if selected)
;
;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$WORK/ncl_scripts/tickmarks.ncl" ; for LambertEqualArea plots
;****************************************************

begin

reg = "usa" ; region
seas = "JJA" ; season
years = 1934 ; select 1934 to plot Extended Data Figure 1 ; 1936 to plot Figure 1
dimyears = dimsizes(years)
met = (/"hwf","hwd","hwa"/) ; HW metrics
met_names = oneDtostring(met)
met_names = str_sub_str(met_names, ",", "_")
nmets = dimsizes(met)
pctl = "daily" ; daily or monthly percentiles
version = "BEST"  ; use BEST observed temperatures


reg_longname = str_upper(reg)


if (version.eq."V2c") then
 year1 = 1852
 year2 = 2011
 clm_year1 = 1920
 clm_year2 = 2011
end if
if (version.eq."V2") then
 year1 = 1872
 year2 = 2012
 clm_year1 = 1920
 clm_year2 = 2012
end if
if (version.eq."BEST") then
 year1 = 1880
 year2 = 2013
 clm_year1 = 1921
 clm_year2 = 1948
end if


; lats and lons for Dust Bowl region
ypts1 = (/ 30, 30, 44, 44, 30/)
xpts1 = (/ -105, -85, -85, -105, -105/)
;--------------------------------------
  
;;;;;;;;;; observations (stations) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 obs_hw_dir = "$WORK/NatCC_wah_2019/data/GHCN/"
 
 fils = systemfunc ("ls "+obs_hw_dir+"*hw_stats_from_daily_threshold_1920-2012_"+seas+"_from_1920-2012_clim.nc") ; file paths
 dimfils = dimsizes(fils)
 lats = new((/dimfils/),float)
 lons = new((/dimfils/),float)
 ave_tmax = new((/dimyears,dimfils/),float)
 ave_tmin = new((/dimyears,dimfils/),float)

 f = addfiles (fils, "r")
 ListSetType (f, "join")
 lats    = f[:]->lat
 lons    = f[:]->lon
 time	= f[0]->time
 hwn_t	= f[:]->pezHWstats(:,:,0,0,0)
 hwd_t	= f[:]->pezHWstats(:,:,0,0,1)
 hwf_t	= f[:]->pezHWstats(:,:,0,0,2)
 hwm_t	= f[:]->pezHWstats(:,:,0,0,3)
 hwa_t	= f[:]->pezHWstats(:,:,0,0,4)
 indx1 = years
 nstations = dimfils

if (dimsizes(years).eq.1) then
 avg_hwn = hwn_t(:,{years}) 
 avg_hwd = hwd_t(:,{years})
 avg_hwf = hwf_t(:,{years})
 avg_hwa = hwa_t(:,{years}) 
 avg_hwm = hwm_t(:,{years})
else 
 avg_hwn = dim_avg_n_Wrap(hwn_t(:,{years}),1) 
 avg_hwd = dim_avg_n_Wrap(hwd_t(:,{years}),1)
 avg_hwf = dim_avg_n_Wrap(hwf_t(:,{years}),1)
 avg_hwa = dim_avg_n_Wrap(hwa_t(:,{years}),1) 
 avg_hwm = dim_avg_n_Wrap(hwm_t(:,{years}),1) 
end if


; ---- rank HWF, HWD and HWA ------------
 tmp_hwf = hwf_t
 tmp_hwd = hwd_t
 tmp_hwa = hwa_t
 ip_hwf = dim_pqsort(tmp_hwf, -2)
 ip_hwd = dim_pqsort(tmp_hwd, -2)
 ip_hwa = dim_pqsort(tmp_hwa, -2)
 copy_VarCoords(tmp_hwf,ip_hwf)
 copy_VarCoords(tmp_hwd,ip_hwd)
 copy_VarCoords(tmp_hwa,ip_hwa)
 rankd_hwfs = new((/nstations/),float)
 rankd_hwds = new((/nstations/),float)
 rankd_hwas = new((/nstations/),float)


do kk=0,nstations-1
 
 rankd_yrs1 := tmp_hwf&time(ip_hwf(kk,:))
 rankd_yrs2 := tmp_hwd&time(ip_hwd(kk,:))
 rankd_yrs3 := tmp_hwa&time(ip_hwa(kk,:))
 
 if (rankd_yrs1(0).eq.years) then
  rankd_hwfs(kk) = 1
 end if 
 if (rankd_yrs2(0).eq.years) then
  rankd_hwds(kk) = 1
 end if 
 if (rankd_yrs3(0).eq.years) then
  rankd_hwas(kk) = 1
 end if  

end do 
 print("No. of record-breaking HWF stations in Year:" + years + " " + sum(rankd_hwfs))
 print("No. of record-breaking HWD stations in Year:" + years + " " + sum(rankd_hwds))
 print("No. of record-breaking HWA stations in Year:" + years + " " + sum(rankd_hwas))
 
 delete(time)
;------------------------------------------------------------------------------------------------------ 
 
;;;;;;;;;; BEST observations ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 ren_hw_dir = "$WORK/NatCC_wah_2019/data/BEST/"
  
 if (pctl.eq."daily") then
  ren_hw_file = addfile(ren_hw_dir+"hw_dates_usa_hottest_event_JJA_1880-2013_from_daily_90pctl_1920-2012_clim_raw.nc","r")
 end if

 lat = ren_hw_file->lat
 lon = ren_hw_file->lon
 time = ren_hw_file->time
 indx2 = years

;LAND SEA MASK
;*************************************************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
  lsm = landsea_mask(a->LSMASK,lat,lon)
;*************************************************************************************


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 outfile = "fig1_BEST_GHCN_hw_metrics_"+met_names+"_"+years+"_"+reg+"_"+seas+"_from_"+pctl+"_90pctl_final"
 wks   = gsn_open_wks ("eps",outfile)                  ; open workstation 
 
;  gsn_define_colormap(wks,"so4_23") ; old colour map
 gsn_define_colormap(wks,"WhiteYellowOrangeRed") ; new colour map


;;;;;;;; plot stations first ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
 maps = new((/2,nmets/),graphic)

; tick mark resources
 tmres          = True
 tmres@tmYRValues = ispan(20,60,10)
 tmres@tmXBValues = ispan(-135,-30,15)
 tmres@tmXBLabelFontHeightF = 0.02
 tmres@tmYRLabelFontHeightF = 0.02
 tmres@YUseLeft = False
;
; Set up some map resources.
  mpres              = True
  mpres@gsnDraw     = False            ; Don't advance the frame
  mpres@gsnFrame     = False            ; Don't advance the frame
;
; Zoom in on United States.
;
  mpres@mpMinLatF    = 25.
  mpres@mpMaxLatF    = 50.
  mpres@mpMinLonF    = 235.
  mpres@mpMaxLonF    = 290.
  mpres@mpCenterLonF = 260
  mpres@mpCenterLatF = 40.0

  mpres@gsnCenterStringFontHeightF = 0.03
  mpres@tmYLLabelsOn = False
  mpres@tmXBLabelsOn = False
  mpres@tmYRLabelsOn = False
  mpres@tmXTLabelsOn = False
  mpres@tmYLOn = False
  mpres@tmXBOn = False
  mpres@tmYROn = False
  mpres@tmXTOn = False  
  mpres@gsnPaperOrientation = "Portrait"    
  mpres@mpOutlineOn = True
  mpres@tiYAxisFontHeightF = 0.035
  mpres@mpProjection          = "LambertEqualArea"
  mpres@mpGridAndLimbOn       = True
  mpres@mpGridLatSpacingF     = 10
  mpres@mpLimitMode           = "LatLon"  
  mpres@pmTickMarkDisplayMode  = "Always"           ; turn on fancy tickmarks
  mpres@mpGridLineDashPattern = 2  
  mpres@mpGridLineThicknessF = 0.25 
  
;----------------------------------------------------------------------
; Labelbar resources
;---------------------------------------------------------------------- 
  lbres                    = True 
  lbres@vpWidthF           = 0.15             ; width  ; 0.10 for 10 years, 0.15 for 2 years
  lbres@vpHeightF          = 0.03             ; height
  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.01            ; label font height
  lbres@lbTitlePosition      = "Bottom" 			; title location
  lbres@lbTitleFontHeightF   = 0.01				; font height
  lbres@lbAutoManage          = False             ; we control label bar
  lbres@lbLabelStride         = 1                 ; skip every other label
;---------------------------------------------------------------------- 

; figure text resources  
  txres               = True
  txres@txFontHeightF = 0.015

;******************************************************************************************************************
; resources for box showing Dust Bowl region
  resB2  = True                      ; polyline mods desired
  resB2@cnFillOn = False
  resB2@cnInfoLabelOn   = False                      ; turn off contour label
  resB2@cnLineLabelsOn = False
  resB2@gsLineThicknessF = 1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

met_longname = new((/nmets/),string)

R = new((/nmets,nstations/),float)
R@_FillValue = -999

do j=0,nmets-1

;-------Options--------

if (met(j).eq."hwn") then

 if (seas.eq."DJF") then
  arr = fspan(10,18,9)
 else if (seas.eq."MAM") then
  arr = fspan(1,5,9)
 else if (seas.eq."JJA") then
  arr = fspan(1.5,6,10)
 end if
 end if
 end if
 arr_str = arr(::1)
end if

if (met(j).eq."hwf") then

 if (seas.eq."DJF") then
  arr = fspan(4,20,9)
 else if (seas.eq."MAM") then
  arr = fspan(4,20,9)
 else if (seas.eq."JJA") then
  arr = fspan(5,50,10)
 end if
 end if
 end if
 arr_str = arr(::1)
end if

if (met(j).eq."hwd") then
 if (seas.eq."DJF") then
  arr = fspan(3,11,9)
 else if (seas.eq."MAM") then
  arr = fspan(3,11,9)
 else if (seas.eq."JJA") then
  arr = fspan(2,20,10)
 end if
 end if
 end if
 arr_str = arr(::1)
end if

if (met(j).eq."hwa") then
 if (seas.eq."DJF") then
  arr = fspan(10,18,9)
 else if (seas.eq."MAM") then
  arr = fspan(10,18,9)
 else if (seas.eq."JJA") then
  arr = fspan(35,44,10)
 end if
 end if
 end if
 arr_str = arr(::1)
end if

if (met(j).eq."hwm") then
 if (seas.eq."DJF") then
  arr = fspan(10,18,9)
 else if (seas.eq."MAM") then
  arr = fspan(10,18,9)
 else if (seas.eq."JJA") then
  arr = fspan(33,42,10)
 end if
 end if
 end if
 arr_str = arr(::1)
end if

;  colors    = (/0,13,14,15,16,17,18,19,20,21,22/) ; for "so4_23" 11 colours
  colors    = (/2,25,48,71,94,117,140,163,186,209,255/) ; for "WhiteYellowOrangeRed" 11 colours
  mpres@cnFillColors    = colors ; for BlAqGrYeOrReVi200 for 7 colours  (HWN, H
  labels = new(dimsizes(arr)+1,string)  ; Labels for legend.
  lbres@lbFillColors	   = colors	      ; Colors for boxes.
  num_distinct_markers = dimsizes(arr)+1        ; number of distinct markers


if (j.eq.0) then
 dum1 = new((/num_distinct_markers,nmets/),graphic) ; for filled dots
 dum2 = new((/num_distinct_markers,nmets/),graphic) ; for hollow dots
 arrs = new((/nmets,dimsizes(arr)/),string)
 met_longnames = new((/nmets/),string)
end if

arrs(j,:) = arr

;--------------------------------------------------------------------------------

 if (met(j).eq."hwn") then
  met_longname(j) = "HW number~C~ (events/"+seas+")"
  R(j,:)   = avg_hwn(:)   ; This is dummy data for determining
 end if
 if (met(j).eq."hwd") then
  met_longname(j) = "HW duration~C~    (days)"
  R(j,:)   = avg_hwd(:)   ; This is dummy data for determining
 end if
 if (met(j).eq."hwf") then
  met_longname(j) = "HW frequency~C~  (days/"+seas+")"  
  R(j,:)   = avg_hwf(:)   ; This is dummy data for determining
 end if
 if (met(j).eq."hwm") then
  met_longname(j) = "HW magnitude~C~     (~S~o~N~C)"
  R(j,:)   = avg_hwm(:)   ; This is dummy data for determining
 end if
 if (met(j).eq."hwa") then
  met_longname(j) = "HW amplitude~C~     (~S~o~N~C)"
  R(j,:)   = avg_hwa(:)   ; This is dummy data for determining
 end if

; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;

  if (j.eq.0) then
   lat_u = where(rankd_hwfs.eq.1,lats,-9999)   
   lon_u = where(rankd_hwfs.eq.1,lons,-9999)
  end if
  if (j.eq.1) then
   lat_u = where(rankd_hwds.eq.1,lats,-9999)   
   lon_u = where(rankd_hwds.eq.1,lons,-9999)  
  end if  
  if (j.eq.2) then
   lat_u = where(rankd_hwas.eq.1,lats,-9999)   
   lon_u = where(rankd_hwas.eq.1,lons,-9999)  
  end if
  
  lat_new = new((/num_distinct_markers,dimsizes(R(j,:))/),float,-999)
  lon_new = new((/num_distinct_markers,dimsizes(R(j,:))/),float,-999)
  lat_uu = new((/num_distinct_markers,dimsizes(R(j,:))/),float,-999)
  lon_uu = new((/num_distinct_markers,dimsizes(R(j,:))/),float,-999);

; Group the points according to which range they fall in. At the
; same time, create the label that we will use later in the legend.
;       
  do i = 0, num_distinct_markers-1
    if (i.eq.0) then
      indexes = ind(R(j,:).lt.arr(0))
      labels(i) = "x < " + arr(0)
    end if
    if (i.eq.num_distinct_markers-1) then
      indexes = ind(R(j,:).ge.max(arr))
      labels(i) = "x >= " + max(arr)
    end if
    if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
      indexes = ind(R(j,:).ge.arr(i-1).and.R(j,:).lt.arr(i))
      labels(i) = arr(i-1) + " <= x < " + arr(i)
    end if
;
; Now that we have the set of indexes whose values fall within 
; the given range, take the corresponding lat/lon values and store
; them, so later we can color this set of markers with the appropriate
; color.
;
    if (.not.any(ismissing(indexes))) then 
      npts_range = dimsizes(indexes)   ; # of points in this range.
      lat_new(i,0:npts_range-1) = lats(indexes)
      lon_new(i,0:npts_range-1) = lons(indexes)
      lat_uu(i,0:npts_range-1) = lat_u(indexes)
      lon_uu(i,0:npts_range-1) = lon_u(indexes)
    end if
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do ; i
  
 if (j.eq.0) then 
  mpres@gsnCenterString = "GHCN-D"
 else
  mpres@gsnCenterString = ""
 end if

 if (j.ne.3) then
  mpres@tiYAxisString   = str_upper(met(j))
 else
  mpres@tiYAxisString   = "HWAA"
 end if

  maps(0,j) = gsn_csm_map(wks,mpres)
  maps(0,j) = add_map_tickmarks(wks,maps(0,j),tmres)

;
;  Create logical variables to hold the marker and text resources.
;  These markers are different than the XY markers, because they are not
;  associated with an XY plot. You can put these markers on any plot.
;
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
  
  gsres1	      = True
  gsres1@gsMarkerIndex = 4           ; Hollow dots  
  gsres1@gsMarkerColor = "black"
  gsres1@gsMarkerThicknessF = 0.5  

  do i = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(i,0)))
      gsres@gsMarkerColor      = colors(i)
      dum1(i,j) = gsn_add_polymarker(wks,maps(0,j),lon_new(i,:),lat_new(i,:),gsres)
      dum2(i,j) = gsn_add_polymarker(wks,maps(0,j),lon_uu(i,:),lat_uu(i,:),gsres1)
     if (i.eq.0) then
      boxi3 = gsn_add_polyline(wks,maps(0,0),xpts1,ypts1,resB2)
     end if
    end if
   end do ; i




 delete([/lat_new,lon_new,lon_uu,lat_uu/])
 delete([/arr,labels,arr_str/])

 ;---------------------------------------------------------------------- 
 print(met(j)+" done")

end do 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
 
;;;;;;;; plot BEST second ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

res			 = True
res@gsnDraw		 = False
res@gsnFrame		 = False
res@gsnAddCyclic         = False    ; data already has cyclic point

res@cnFillOn		  = True     ; turn on color fill
res@cnLinesOn		  = False    ; turn of contour lines
res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res@cnFillColors    = colors ; for hotres for 6 colours  (HWN, HWD)
res@lbLabelBarOn = True
res@lbLabelFontHeightF = 0.02
res@lbTitlePosition = "Bottom"
res@pmLabelBarOrthogonalPosF = .10           ; move whole thing down
res@pmLabelBarParallelPosF = -0.2
res@pmLabelBarWidthF = 0.85
res@gsnCenterStringFontHeightF = 0.03
;res@gsnLeftStringFontHeightF = 0.03
res@cnSpanFillPalette = True

res@mpProjection	  = "LambertEqualArea"
res@mpGridAndLimbOn	  = True
res@mpGridLatSpacingF	  = 10
res@mpLimitMode 	  = "LatLon"
res@mpMinLatF		  = 25
res@mpMaxLatF		  = 50
res@mpMinLonF		  = 235
res@mpMaxLonF		  = 290
res@mpCenterLonF	  = 260
res@mpCenterLatF	  = 40.0
res@pmTickMarkDisplayMode  = "Always"		; turn on fancy tickmarks
res@mpGridLineDashPattern = 2
res@mpGridLineThicknessF = 0.25
res@mpInlandWaterFillColor = 0                             ; fill the inland water with index 0 (=white)

met_longname = new((/nmets/),string)

do j=0,nmets-1
 
 if (met(j).eq."hwn") then
  met_longname(j) = "HW number (events/"+seas+")"
  res@lbTitleString    = "events/summer" ; "~S~o~N~C"
  var = ren_hw_file->hwn({years},:,:)
  var = mask(var,lsm.eq.0.or.lsm.eq.2,False)        ; mask out all ocean points from data
  if(seas.eq."JJA".or.seas.eq."SON") then
    minLevel  = 1.5 ; 0.5 ; 1	   ; set min contour level
    maxLevel  = 6 ; 3 ; 3.5	   ; set max contour level
    interval  = 0.5	   ; set contour spacing  
   end if
  if(seas.eq."DJF".or.seas.eq."MAM") then
    minLevel  = 1	   ; set min contour level
    maxLevel  = 5	   ; set max contour level
    interval  = 1	   ; set contour spacing  
   end if   
 end if 
 if (met(j).eq."hwd") then
  met_longname(j) = "HW duration (days)"
  res@lbTitleString    = "days" ; "~S~o~N~C"
  var = ren_hw_file->hwl({years},:,:)
  var = mask(var,lsm.eq.0.or.lsm.eq.2,False)        ; mask out all ocean points from data
  if(seas.eq."JJA".or.seas.eq."SON") then
    minLevel  = 2 ; 3	   ; set min contour level
    maxLevel  = 20 ; 13 ; 18	   ; set max contour level
    interval  = 2 ; 2 ; 3	   ; set contour spacing
  end if
  if(seas.eq."DJF".or.seas.eq."MAM") then
    minLevel  = 6	   ; set min contour level
    maxLevel  = 22	   ; set max contour level
    interval  = 2	   ; set contour spacing
  end if
 end if 
 if (met(j).eq."hwf") then
  met_longname(j) = "HW frequency (days/"+seas+")"
  res@lbTitleString    = "days/summer" ; "~S~o~N~C"
  var = ren_hw_file->hwf({years},:,:)
  var = mask(var,lsm.eq.0.or.lsm.eq.2,False)        ; mask out all ocean points from data
  if(seas.eq."JJA".or.seas.eq."SON") then
    minLevel  = 5 ; 3 ; 4	   ; set min contour level
    maxLevel  = 50 ; 18 ; 24	   ; set max contour level
    interval  = 5 ; 3 ; 4	   ; set contour spacing
  end if
  if(seas.eq."DJF".or.seas.eq."MAM") then
    minLevel  = 5	   ; set min contour level
    maxLevel  = 45	   ; set max contour level
    interval  = 5	   ; set contour spacing
  end if
 end if 
 if (met(j).eq."hwm") then
  met_longname(j) = "HW magnitude (~S~o~N~C)"
  var = ren_hw_file->hwm({years},:,:)
  var = mask(var,lsm.eq.0.or.lsm.eq.2,False)        ; mask out all ocean points from data
  if(seas.eq."JJA".or.seas.eq."SON") then
    minLevel  = 33	   ; set min contour level
    maxLevel  = 42   ; set max contour level
    interval  = 1	   ; set contour spacing  
  end if
  if(seas.eq."DJF".or.seas.eq."MAM") then
    minLevel  = 7	   ; set min contour level
    maxLevel  = 15	   ; set max contour level
    interval  = 1	   ; set contour spacing
  end if
 end if 
 if (met(j).eq."hwa") then
  met_longname(j) = "HW amplitude (~S~o~N~C)"
  res@lbTitleString    = "~S~o~N~C"
  var = ren_hw_file->hwa({years},:,:)
  var = mask(var,lsm.eq.0.or.lsm.eq.2,False)        ; mask out all ocean points from data
  if(seas.eq."JJA".or.seas.eq."SON") then
    minLevel  = 35	   ; set min contour level
    maxLevel  = 44   ; set max contour level
    interval  = 1	   ; set contour spacing
  end if
  if(seas.eq."DJF".or.seas.eq."MAM") then
    minLevel  = 7	   ; set min contour level
    maxLevel  = 15	   ; set max contour level
    interval  = 1	   ; set contour spacing
  end if
 end if 

  res@cnMinLevelValF	 = minLevel  	      ; set min contour level
  res@cnMaxLevelValF	 = maxLevel  	      ; set max contour level
  res@cnLevelSpacingF	 = interval 	      ; set contour spacing
 if (j.eq.0) then 
  res@gsnCenterString = "BEST"
 else
  res@gsnCenterString = ""
 end if
  res@gsnRightString = " "
  res@gsnLeftString = " "

  res@tmYLLabelsOn = False
  res@tmXBLabelsOn = False
  res@tmYRLabelsOn = False
  res@tmXTLabelsOn = False  
  res@tmYLOn = False
  res@tmXBOn = False
  res@tmYROn = False
  res@tmXTOn = False

  maps(1,j)=gsn_csm_contour_map(wks,var(:,:),res)
  maps(1,j) = add_map_tickmarks(wks,maps(1,j),tmres)
  delete([/minLevel,maxLevel,interval,res@cnMinLevelValF,res@cnMaxLevelValF,res@cnLevelSpacingF/])
  delete(var)
end do
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
;*********************************************************************************************************
; create panel1
;*********************************************************************************************************

  maps!0="row"
  maps!1="col"

  plot1d = ndtooned(maps(col | :, row | :)) 

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelLabelBar = False                  ; add common colorbar     
  resP@lbLabelFontHeightF = 0.01
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom ; turn off ususally

  resP@gsnMaximise = True
  resP@gsnPanelFigureStrings= (/"~F22~a","~F22~b","~F22~c","~F22~d","~F22~e","~F22~f","~F22~g","~F22~h"/) ; add strings to panel
  resP@gsnPanelFigureStringsPerimOn = False
  resP@amJust   = "TopLeft"
  resP@gsnPanelFigureStringsFontHeightF = 0.015
  resP@gsnPanelYWhiteSpacePercent = 15
  resP@gsnPanelXWhiteSpacePercent = 2

  gsn_panel(wks,plot1d,(/nmets,2/),resP)
  frame(wks)
  delete(wks)
  
  system("convert -alpha off -background white -trim -density 900 " +\
          outfile+".eps " + outfile + ".png")
  
;  system("convert -alpha off -background white -trim -density 300 " +\
;          outfile+".ps " + outfile + ".tiff")  
	  
;  system("ps2pdf -dPDFSETTINGS=/prepress -dEPSCrop " + outfile + ".ps " + outfile + ".pdf")
;  system("pdfcrop " + outfile + ".pdf " + outfile + "_crop.pdf")
;  system("rm " + outfile + ".pdf")
;  system("convert -density 144x144 -trim " + outfile + ".ps " + outfile + ".png")
;  system("rm " + outfile + ".eps")

end
