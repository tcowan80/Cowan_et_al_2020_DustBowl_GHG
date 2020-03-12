;*************************************************
; fig3_JJA_prcp_ef_hwf_hwd_hwa_hwt_1934_1936_all_pd_wah2.ncl
;
; plots the summer prcp, ef and hw metrics based on the order of driest to wettest ranked central US spring seasons
; uses 200-experiment running mean (x-axis)
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

 rad    = 4.0*atan(1.0)/180.0 ; deg to rad.

 reg = "gp" ; or "ngp" or "sgp" ; region of interest
 seas = "JJA"
 pr_seas = "MAM"
 top = 1200  ; show top whatever number
 xave = 200  ; ensemble of simulations
 top_or_bot = "top" ; sort by driest to wettest (top) or wettest to driest (bot)

 dset = "wah"
 type = "raw"
 exps = "nat_all_pd_sst"
 sorted_by = "pr" ; "hw" or "pr" or "soil"
 letters = (/(/"~F22~a","~F22~b","~F22~c","~F22~d","~F22~e"/),(/"~F22~f","~F22~g","~F22~h","~F22~i","~F22~j"/)/)

; -2 largest to smallest (hottest to colder) (wettest to drier)
; +2 smallest to largest (coldest to hotter) (driest to wetter)

if (sorted_by.eq."hw") then
 if (top_or_bot.eq."top") then
  sorti =  -1  
 end if
 if (top_or_bot.eq."bot") then
  sorti =  1
 end if
else
 if (top_or_bot.eq."top") then
  sorti =  1  
 end if
 if (top_or_bot.eq."bot") then
  sorti =  -1
 end if
end if


 dset_names = (/"WAH2~B~ALL","WAH2~B~PD"/)


 years = (/1934,1936/)
 dimyears = dimsizes(years)
 npanels = dimyears
 nsets = dimsizes(dset_names)
 
 ofile = "fig3_"+dset+"_pr_ef_hwf_hwl_hwa_hwt_"+exps+"_avg_over_"+reg+"_"+type+"_sorted_by_"+sorted_by+pr_seas+"_"+top_or_bot+top ; outfile

;************************************************
; plotting parameters
;************************************************

;LAND SEA MASK
;*************************************************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
  
if (reg.eq."gp") then
  latS = 30
  latN = 44
  lonL = 255
  lonR = 275
  lonLL = -105
  lonRR = -85
end if
if (reg.eq."ngp") then
  latS = 35
  latN = 44
  lonL = 255
  lonR = 265
  lonLL = -105
  lonRR = -95
end if
if (reg.eq."sgp") then
  latS = 30
  latN = 35
  lonL = 255
  lonR = 265
  lonLL = -105
  lonRR = -95
end if

kount = 1
indir = "$WORK/NatCC_wah_2019/data/weather_at_home/"

do i=0,npanels-1


if (i.eq.0) then
 wks = gsn_open_wks("eps",ofile)     ; Open a workstation and
 resXY = True
 resXY@gsnDraw		= False
 resXY@gsnFrame		= False
 resXY@gsnCenterStringFontHeightF = 0.05

 resXY@tmYLOn = True
 resXY@tmXBOn = True
 resXY@tmYROn = False
 resXY@tmXTOn = False  
 resXY@tmYLLabelFontHeightF = 0.03
 resXY@tmXBLabelFontHeightF = 0.03 
 resXY@xyLineThicknessF = 1
 resXY@gsnLeftStringFontHeightF = 0.04
 resXY@gsnRightStringFontHeightF = 0.04
 resXY@gsnCenterStringFontHeightF = 0.05
 resXY@mpShapeMode  = "FreeAspect"
 resXY@vpWidthF      = 0.9
 resXY@vpHeightF     = 0.3

 resXY@tmYRBorderOn     = False			; turn off right border
 resXY@tmYROn	     = False			; no YR tick marks

 resXY@tmXTBorderOn     = False			; turn off top border
 resXY@tmXTOn	     = False			; no XT tick marks

;******************************************************************************************************************
 resB		       = True			   ; polyline mods desired 
 resB@tfPolyDrawOrder	= "Predraw"		     ; put line on top
 resB@gsnDraw = False
 resB@gsnFrame = False
 resB@gsFillOpacityF = 0.2
 
 plotsXYa = new((/5,2/),graphic)
 plotsXYn = new((/5,2/),graphic)
 plotsXYp = new((/5,2/),graphic)
 plotsXYs = new((/5,2/),graphic)
 
 plotsCFa = new((/5,2/),graphic)
 plotsCFn = new((/5,2/),graphic)
 plotsCFp = new((/5,2/),graphic)
 plotsCFs = new((/5,2/),graphic)
 
  
 resXY@tmXBMode          = "Explicit"                ; explicit labels
 resXY@tmXBValues        = (/200,400,600,800,1000/)
 resXY@tmXBLabels        = (/"200","400","600","800","1000"/)         ; make strings
 resXY@tmXBMinorValues   =  resXY@tmXBValues - 100
 resXY@tmYLMode          = "Explicit"
end if

; avg_a = WAH2_1930s
; avg_p = WAH2_PD
; avg_n = WAH2_NAT

ncol = 6
pr_avg_a_f := asciiread(indir+"avg_a_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , -1, "float")
nrow = dimsizes(pr_avg_a_f)/ncol

pr_avg_a_f := asciiread(indir+"avg_a_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
pr_cnf_a_f := asciiread(indir+"stdev_a_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
pr_avg_p_f := asciiread(indir+"avg_p_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
pr_cnf_p_f := asciiread(indir+"stdev_p_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwl_avg_a_f := asciiread(indir+"avg_a_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwl_cnf_a_f := asciiread(indir+"stdev_a_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwl_avg_p_f := asciiread(indir+"avg_p_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwl_cnf_p_f := asciiread(indir+"stdev_p_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwa_avg_a_f := asciiread(indir+"avg_a_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwa_cnf_a_f := asciiread(indir+"stdev_a_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwa_avg_p_f := asciiread(indir+"avg_p_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwa_cnf_p_f := asciiread(indir+"stdev_p_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwt_avg_a_f := asciiread(indir+"avg_a_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwt_cnf_a_f := asciiread(indir+"stdev_a_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwt_avg_p_f := asciiread(indir+"avg_p_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwt_cnf_p_f := asciiread(indir+"stdev_p_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")

ncol = 2
pr_avg_n_f := asciiread(indir+"avg_n_pr_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , -1, "float")
nrow = dimsizes(pr_avg_n_f)/ncol
pr_avg_n_f := asciiread(indir+"avg_n_pr_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
pr_cnf_n_f := asciiread(indir+"stdev_n_pr_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
pr_avg_s_f := asciiread(indir+"avg_s_pr_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
pr_cnf_s_f := asciiread(indir+"stdev_s_pr_hwf_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")

hwl_avg_n_f := asciiread(indir+"avg_n_pr_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwl_cnf_n_f := asciiread(indir+"stdev_n_pr_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwl_avg_s_f := asciiread(indir+"avg_s_pr_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwl_cnf_s_f := asciiread(indir+"stdev_s_pr_hwl_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")

hwa_avg_n_f := asciiread(indir+"avg_n_pr_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwa_cnf_n_f := asciiread(indir+"stdev_n_pr_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwa_avg_s_f := asciiread(indir+"avg_s_pr_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwa_cnf_s_f := asciiread(indir+"stdev_s_pr_hwa_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")

hwt_avg_n_f := asciiread(indir+"avg_n_pr_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwt_cnf_n_f := asciiread(indir+"stdev_n_pr_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwt_avg_s_f := asciiread(indir+"avg_s_pr_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")
hwt_cnf_s_f := asciiread(indir+"stdev_s_pr_hwt_"+seas+"_sorted_by_"+sorted_by+pr_seas+"_"+years(i)+"_"+xave+"runave.txt" , (/nrow,ncol/), "float")


dima = dimsizes(pr_avg_a_f)
dimp = dimsizes(pr_avg_p_f)
dimn = dimsizes(pr_avg_n_f)
dimS = dimsizes(pr_avg_s_f)
expa = dima(0)
expp = dimp(0)
expn = dimn(0)
expS = dimS(0)


 resXY@trXMinF  = 0                 ; min value on y-axis
 resXY@trXMaxF  = expa + 2                 ; max value on y-axis


; create bounds

do kkk=0,4
  xx_a := ispan(1,expa,1)
  xp_a := new((/2*expa/),float)  
  bounds_a := new((/2*expa/),float)
  
  xx_p := ispan(1,expp,1)
  xp_p := new((/2*expp/),float)
  bounds_p := new((/2*expp/),float)

  xx_n := ispan(1,expn,1)
  xp_n := new((/2*expn/),float)
  bounds_n := new((/2*expn/),float)

  xx_s := ispan(1,expS,1)
  xp_s := new((/2*expS/),float)
  bounds_s := new((/2*expS/),float)
  

 do xx=0,expa-1
  xp_a(xx) = xx_a(xx)
  xp_a(2*expa-1-xx) = xx_a(xx) 
  xp_p(xx) = xx_p(xx)   
  xp_p(2*expp-1-xx) = xx_p(xx)
  xp_n(xx) = xx_n(xx)   
  xp_n(2*expn-1-xx) = xx_n(xx)
  xp_s(xx) = xx_s(xx)   
  xp_s(2*expS-1-xx) = xx_s(xx)     
  
 if (kkk.eq.0) then 
  bounds_a(xx) = pr_avg_a_f(xx,0) + pr_cnf_a_f(xx,0)
  bounds_p(xx) = pr_avg_p_f(xx,0) + pr_cnf_p_f(xx,0)
  bounds_n(xx) = pr_avg_n_f(xx,0) + pr_cnf_n_f(xx,0)
  bounds_s(xx) = pr_avg_s_f(xx,0) + pr_cnf_s_f(xx,0)
  bounds_a(2*expa-1-xx) = pr_avg_a_f(xx,0) - pr_cnf_a_f(xx,0)
  bounds_p(2*expp-1-xx) = pr_avg_p_f(xx,0) - pr_cnf_p_f(xx,0) 
  bounds_n(2*expn-1-xx) = pr_avg_n_f(xx,0) - pr_cnf_n_f(xx,0)
  bounds_s(2*expS-1-xx) = pr_avg_s_f(xx,0) - pr_cnf_s_f(xx,0)   
 end if ; kkk.eq.0
 if (kkk.eq.1) then 
  bounds_a(xx) = pr_avg_a_f(xx,5) + pr_cnf_a_f(xx,5)
  bounds_p(xx) = pr_avg_p_f(xx,5) + pr_cnf_p_f(xx,5)
  bounds_n(xx) = pr_avg_n_f(xx,1) + pr_cnf_n_f(xx,1)
  bounds_s(xx) = pr_avg_s_f(xx,1) + pr_cnf_s_f(xx,1)
  bounds_a(2*expa-1-xx) = pr_avg_a_f(xx,5) - pr_cnf_a_f(xx,5)
  bounds_p(2*expp-1-xx) = pr_avg_p_f(xx,5) - pr_cnf_p_f(xx,5) 
  bounds_n(2*expn-1-xx) = pr_avg_n_f(xx,1) - pr_cnf_n_f(xx,1)
  bounds_s(2*expS-1-xx) = pr_avg_s_f(xx,1) - pr_cnf_s_f(xx,1) 
 end if ; kkk.eq.1
 if (kkk.eq.2) then 
  bounds_a(xx) = hwa_avg_a_f(xx,5) + hwa_cnf_a_f(xx,5)
  bounds_p(xx) = hwa_avg_p_f(xx,5) + hwa_cnf_p_f(xx,5)
  bounds_a(2*expa-1-xx) = hwa_avg_a_f(xx,5) - hwa_cnf_a_f(xx,5)
  bounds_p(2*expp-1-xx) = hwa_avg_p_f(xx,5) - hwa_cnf_p_f(xx,5) 
  bounds_n(xx) = hwa_avg_n_f(xx,1) + hwa_cnf_n_f(xx,1)
  bounds_s(xx) = hwa_avg_s_f(xx,1) + hwa_cnf_s_f(xx,1)
  bounds_n(2*expn-1-xx) = hwa_avg_n_f(xx,1) - hwa_cnf_n_f(xx,1)
  bounds_s(2*expS-1-xx) = hwa_avg_s_f(xx,1) - hwa_cnf_s_f(xx,1)    
 end if ; kkk.eq.2
 if (kkk.eq.3) then 
  bounds_a(xx) = hwt_avg_a_f(xx,5) + hwt_cnf_a_f(xx,5)
  bounds_p(xx) = hwt_avg_p_f(xx,5) + hwt_cnf_p_f(xx,5)
  bounds_a(2*expa-1-xx) = hwt_avg_a_f(xx,5) - hwt_cnf_a_f(xx,5)
  bounds_p(2*expp-1-xx) = hwt_avg_p_f(xx,5) - hwt_cnf_p_f(xx,5)
  bounds_n(xx) = hwt_avg_n_f(xx,1) + hwt_cnf_n_f(xx,1)
  bounds_s(xx) = hwt_avg_s_f(xx,1) + hwt_cnf_s_f(xx,1)
  bounds_n(2*expn-1-xx) = hwt_avg_n_f(xx,1) - hwt_cnf_n_f(xx,1)
  bounds_s(2*expS-1-xx) = hwt_avg_s_f(xx,1) - hwt_cnf_s_f(xx,1)    
 end if ; kkk.eq.3
 if (kkk.eq.4) then 
  bounds_a(xx) = pr_avg_a_f(xx,4) + pr_cnf_a_f(xx,4)
  bounds_p(xx) = pr_avg_p_f(xx,4) + pr_cnf_p_f(xx,4)
  bounds_a(2*expa-1-xx) = pr_avg_a_f(xx,4) - pr_cnf_a_f(xx,4)
  bounds_p(2*expp-1-xx) = pr_avg_p_f(xx,4) - pr_cnf_p_f(xx,4)
 end if ; kkk.eq.4
end do ; xx


; set up vertical axis properties ---

 if (kkk.eq.0) then
  variable = "Precipitation"
  units =  "mm/day"
  resXY@tiXAxisString = "" 
  if (i.eq.0) then
   resXY@gsnCenterString = "~F22~1934"
  else
   resXY@gsnCenterString = "~F22~1936"
  end if
   resXY@trYMinF  := 1.45              ; min value on y-axis
   resXY@trYMaxF  := 1.9                 ; max value on y-axis 
   resXY@tmYLValues        := (/1.5,1.6,1.7,1.8,1.9/)
   resXY@tmYLLabels        := (/"1.5","1.6","1.7","1.8","1.9"/)         ; make strings
   resXY@tmYLMinorValues := resXY@tmYLValues - 0.05
   resXY@gsnRightString = letters(i,kkk)
   resXY@tmYLPrecision = 2		; set the precision to 3 significant digits
 end if

 if (kkk.eq.1) then
  resXY@gsnCenterString = ""
  variable = "Heatwave frequency"
  units = "days"
  resXY@trYMinF  := 5.8 	     ; min value on y-axis
  resXY@trYMaxF  := 17  	      ; max value on y-axis
  resXY@tmYLValues	  := (/6,8,10,12,14,16/)
  resXY@tmYLLabels	  := (/"6","8","10","12","14","16"/)	     ; make strings
  resXY@tmYLMinorValues := resXY@tmYLValues + 1       
  resXY@gsnRightString = letters(i,kkk)
  resXY@tmYLPrecision = 2	       ; set the precision to 3 significant digits
 end if
 if (kkk.eq.2) then
  variable = "Heatwave amplitude"
  units = "~S~o~N~C"
  resXY@trYMinF  := 38.3	      ; min value on y-axis
  resXY@trYMaxF  := 40  	      ; max value on y-axis 
  resXY@tmYLValues	  := (/38.4,38.8,39.2,39.6,40/)
  resXY@tmYLLabels	  := (/"38.4","38.8","39.2","39.6","40.0"/)
  resXY@tmYLMinorValues := resXY@tmYLValues + 0.2       
  resXY@gsnRightString = letters(i,kkk)
  resXY@tmYLPrecision = 3	       ; set the precision to 3 significant digits
 end if
 if (kkk.eq.3) then
  variable = "Heatwave timing"
  units = "days since 1st June"
  resXY@trYMinF  := 20  	    ; min value on y-axis
  resXY@trYMaxF  := 40  	      ; max value on y-axis 
  resXY@tmYLValues	  := (/22,26,30,34,38/)
  resXY@tmYLLabels	  := (/"22","26","30","34","38"/)
  resXY@tmYLMinorValues := (/20,24,28,32,36,40/)    
  resXY@tiYAxisFontHeightF = 0.03
  resXY@gsnRightString = letters(i,kkk)
  resXY@tmYLPrecision = 2		; set the precision to 3 significant digits
 end if
 if (kkk.eq.4) then
  resXY@gsnCenterString = ""
  variable = "Evaporative fraction"
  units = ""
  resXY@trYMinF  := 0.43               ; min value on y-axis
  resXY@trYMaxF  := 0.53               ; max value on y-axis 
  resXY@tmYLValues	  := (/0.44,0.46,0.48,0.50,0.52/)
  resXY@tmYLLabels	  := (/"0.44","0.46","0.48","0.50","0.52"/)
  resXY@tmYLMinorValues := resXY@tmYLValues + 0.01     
  resXY@tiXAxisString = "~F21~"+xave+" member running avg"
  resXY@gsnRightString = letters(i,kkk)
  resXY@tmYLPrecision = 2		; set the precision to 4 significant digits
 end if
  
 
 resXY@tiYAxisString = "~F21~"+units
 resXY@tiYAxisFontHeightF = 0.03
 resXY@gsnLeftString = variable
 
; plot out time series ------
if (kkk.eq.0) then
 resXY@xyLineColor       = "black" ; "blue3"
 plotsXYn(kkk,i) = gsn_csm_xy(wks,ispan(1,expn,1),pr_avg_n_f(:,0),resXY) ; rectangular
 resXY@xyLineColor       = "darkorange2"
 plotsXYa(kkk,i) = gsn_csm_xy(wks,ispan(1,expa,1),pr_avg_a_f(:,0),resXY) ; rectangular 
 resXY@xyLineColor       = "red"
 plotsXYp(kkk,i) = gsn_csm_xy(wks,ispan(1,expp,1),pr_avg_p_f(:,0),resXY) ; rectangular 
 resB@gsFillColor       = "grey55" ; "cyan1" 
 plotsCFn(kkk,i) = gsn_add_polygon (wks,plotsXYn(kkk,i),xp_n,bounds_n,resB)
 resB@gsFillColor       = "orange"
 plotsCFa(kkk,i) = gsn_add_polygon (wks,plotsXYa(kkk,i),xp_a,bounds_a,resB)
 resB@gsFillColor       = "Pink" 
 plotsCFp(kkk,i) = gsn_add_polygon (wks,plotsXYp(kkk,i),xp_p,bounds_p,resB)
end if
if (kkk.eq.1) then
 resXY@xyLineColor       = "black" ; "blue3"
 plotsXYn(kkk,i) = gsn_csm_xy(wks,ispan(1,expn,1),pr_avg_n_f(:,1),resXY) ; rectangular
 resXY@xyLineColor       = "darkorange2"
 plotsXYa(kkk,i) = gsn_csm_xy(wks,ispan(1,expa,1),pr_avg_a_f(:,5),resXY) ; rectangular 
 resXY@xyLineColor       = "red"
 plotsXYp(kkk,i) = gsn_csm_xy(wks,ispan(1,expp,1),pr_avg_p_f(:,5),resXY) ; rectangular 
 resB@gsFillColor       = "grey55"; "cyan1" 
 plotsCFn(kkk,i) = gsn_add_polygon (wks,plotsXYn(kkk,i),xp_n,bounds_n,resB)
 resB@gsFillColor       = "orange"
 plotsCFa(kkk,i) = gsn_add_polygon (wks,plotsXYa(kkk,i),xp_a,bounds_a,resB)
 resB@gsFillColor       = "Pink" 
 plotsCFp(kkk,i) = gsn_add_polygon (wks,plotsXYp(kkk,i),xp_p,bounds_p,resB)
end if
if (kkk.eq.2) then 
 resXY@xyLineColor       = "black" ; "blue3"
 plotsXYn(kkk,i) = gsn_csm_xy(wks,ispan(1,expn,1),hwa_avg_n_f(:,1),resXY) ; rectangular
 resXY@xyLineColor       = "darkorange2"
 plotsXYa(kkk,i) = gsn_csm_xy(wks,ispan(1,expa,1),hwa_avg_a_f(:,5),resXY) ; rectangular 
 resXY@xyLineColor       = "red"
 plotsXYp(kkk,i) = gsn_csm_xy(wks,ispan(1,expp,1),hwa_avg_p_f(:,5),resXY) ; rectangular 
 resB@gsFillColor       = "grey55" ; "cyan1" 
 plotsCFn(kkk,i) = gsn_add_polygon (wks,plotsXYn(kkk,i),xp_n,bounds_n,resB)
 resB@gsFillColor       = "orange"
 plotsCFa(kkk,i) = gsn_add_polygon (wks,plotsXYa(kkk,i),xp_a,bounds_a,resB)
 resB@gsFillColor       = "Pink" 
 plotsCFp(kkk,i) = gsn_add_polygon (wks,plotsXYp(kkk,i),xp_p,bounds_p,resB)  
end if
if (kkk.eq.3) then 
 resXY@xyLineColor       = "black" ; "blue3"
 plotsXYn(kkk,i) = gsn_csm_xy(wks,ispan(1,expn,1),hwt_avg_n_f(:,1),resXY) ; rectangular
 resXY@xyLineColor       = "darkorange2"
 plotsXYa(kkk,i) = gsn_csm_xy(wks,ispan(1,expa,1),hwt_avg_a_f(:,5),resXY) ; rectangular 
 resXY@xyLineColor       = "red"
 plotsXYp(kkk,i) = gsn_csm_xy(wks,ispan(1,expp,1),hwt_avg_p_f(:,5),resXY) ; rectangular 
 resB@gsFillColor       = "grey55" ; "cyan1" 
 plotsCFn(kkk,i) = gsn_add_polygon (wks,plotsXYn(kkk,i),xp_n,bounds_n,resB)
 resB@gsFillColor       = "orange"
 plotsCFa(kkk,i) = gsn_add_polygon (wks,plotsXYa(kkk,i),xp_a,bounds_a,resB)
 resB@gsFillColor       = "Pink" 
 plotsCFp(kkk,i) = gsn_add_polygon (wks,plotsXYp(kkk,i),xp_p,bounds_p,resB) 
end if
if (kkk.eq.4) then
 resXY@xyLineColor       = "darkorange2"
 plotsXYa(kkk,i) = gsn_csm_xy(wks,ispan(1,expa,1),pr_avg_a_f(:,4),resXY) ; rectangular 
 resXY@xyLineColor       = "red"
 plotsXYp(kkk,i) = gsn_csm_xy(wks,ispan(1,expp,1),pr_avg_p_f(:,4),resXY) ; rectangular 
 resB@gsFillColor       = "orange"
 plotsCFa(kkk,i) = gsn_add_polygon (wks,plotsXYa(kkk,i),xp_a,bounds_a,resB)
 resB@gsFillColor       = "Pink" 
 plotsCFp(kkk,i) = gsn_add_polygon (wks,plotsXYp(kkk,i),xp_p,bounds_p,resB)
end if

if (kkk.ne.4) then
 overlay(plotsXYa(kkk,i),plotsXYn(kkk,i))
 overlay(plotsXYa(kkk,i),plotsXYp(kkk,i))
else
 overlay(plotsXYa(kkk,i),plotsXYp(kkk,i))
end if

end do ; kkk


end do ; i


;;;;;;;;;; create legend ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

resL_text		     = True		     ; text mods desired
resL_text@txFontHeightF      = 0.03		    ; change text size
resL_text@txJust	     = "CenterLeft"	     ; text justification

resL_lines		     = True		     ; polyline mods desired
resL_lines@gsLineDashPattern = 0.		     ; solid line
resL_lines@gsLineThicknessF  = 2.		     ; line thicker

if (pr_seas.eq."MAM") then
 pr1 = 1.50
 pr2 = 1.60
end if
if (pr_seas.eq."JJA") then
 pr1 = 1.2
 pr2 = 1.5
end if

xx1 = (/200,250/)
xx2 = (/500,550/)
xx3 = (/800,850/)
yy1 = (/pr1,pr1/)

resL_lines@gsLineColor = "black" ; "blue3"                 ; line color
dum1 = gsn_add_polyline(wks,plotsXYa(0,1),xx1,yy1,resL_lines)              ; add polyline
dum2 = gsn_add_text(wks,plotsXYa(0,1),"WAH2~B~NAT",xx1(1)+10,pr1,resL_text); add

resL_lines@gsLineColor = "darkorange2"                 ; line color
dum3 = gsn_add_polyline(wks,plotsXYa(0,1),xx2,yy1,resL_lines)              ; add polyline
dum4 = gsn_add_text(wks,plotsXYa(0,1),"WAH2~B~1930s",xx2(1)+10,pr1,resL_text); add

resL_lines@gsLineColor = "red"                 ; line color
dum5 = gsn_add_polyline(wks,plotsXYa(0,1),xx3,yy1,resL_lines)              ; add polyline
dum6 = gsn_add_text(wks,plotsXYa(0,1),"WAH2~B~PD",xx3(1)+10,pr1,resL_text); add

;-- polygon resources
  xxx1 = (/200, 250, 250, 200, 200/)
  xxx2 = xxx1+300
  xxx3 = xxx2+300
  yyy = (/pr1-0.025, pr1-0.025, pr1+0.025, pr1+0.025, pr1-0.025/)


; resources for legend
  pgresL                        =  True
  pgresL@gsFillColor  = "grey55" ; "cyan1"      ;-- fill color
  pgresL@gsFillOpacityF         =  0.2         ;-- set opacity of polygon
  gon_1 = gsn_add_polygon(wks, plotsXYa(0,1), xxx1, yyy, pgresL)

  pgresL@gsFillColor  = "orange"      ;-- fill color
  gon_2 = gsn_add_polygon(wks, plotsXYa(0,1), xxx2, yyy, pgresL)

  pgresL@gsFillColor  = "Pink"      ;-- fill color
  gon_3 = gsn_add_polygon(wks, plotsXYa(0,1), xxx3, yyy, pgresL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plotsXYa!0="row"
plotsXYa!1="col"
plot1d = ndtooned(plotsXYa) 

;************************************************
; create panel
;************************************************
  resP = True
  resP@gsnPanelMainString = ""
  resP@gsnFrame       = False
  resP@gsnPanelBottom   = 0.08			 ; shrink panel plot by setting bottom edge of plot
  resP@gsnPanelLeft   = 0.005			 ; shrink panel plot by setting bottom edge of plot
  resP@gsnPanelLabelBar    = False                ; add common colorbar
  resP@gsnMaximize = True

  gsn_panel(wks,plot1d,(/5,2/),resP)             ; now draw as one plot
  delete(wks)

  system("convert -alpha off -background white -trim -density 900 " +\
          ofile+".eps " + ofile + ".png")
  system("rm " + outfile + ".eps")

 end
