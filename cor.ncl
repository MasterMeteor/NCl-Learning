;*************************************************
; corel_3.ncl
;
; Concepts illustrated:
;   - Calculating a two-dimensional correlation in time
;   - Reordering an array
;   - Copying attributes from one variable to another
;   - Copying coordinate arrays from one variable to another
;   - Removing the end boxes in a labelbar
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
begin
;************************************************
; open file and read in variable
;***********************************************
;选定青藏高原研究区域
lon1 = 75
lon2 = 105
lat1 = 25
lat2 = 40

;中国东部降水数据
; lon3 = 75
; lon4 = 140
; lat3 = 18
; lat4 = 55

;读取土壤湿度数据并处理

fils5        = systemfunc("ls chun/*05.001.nc")
 printVarSummary(fils5)   ; full path to files
f5           = addfiles(fils5, "r")
 ListSetType(f5,"join")
 printVarSummary(f5)
h2o          = f5[:]->SOIL_M_GDS0_DBLY
 printVarSummary(h2o)
h2o!0        = "time"
h2o!1        = "lat"
h2o!2        = "lon"

swy          = new((/33,10,150,360/), float)
swy(:,0,:,:) = (h2o(:,9,:,:)*0.0175+h2o(:,8,:,:)*0.0276+h2o(:,7,:,:)*0.0455)/0.0906              ;0-10cm
swy(:,1,:,:) = (h2o(:,6,:,:)*0.075+h2o(:,5,:,:)*0.1236+h2o(:,4,:,:)*0.2038)/0.4024               ;10-50cm
swy(:,2,:,:) = (h2o(:,3,:,:)*0.336+h2o(:,2,:,:)*0.5539)/0.8899                                    ;50-138cm
 copy_VarCoords(h2o(:,0:2,:,:), swy)
 printVarSummary(swy)

sm1          = dim_rmvmean_n_Wrap(swy(:,0,:,:), 0)

  copy_VarCoords(h2o(:,0,:,:), sm1)
sm1!0        = "time"
sm1!1        = "lat"
sm1!2        = "lon"
  printVarSummary(sm1)
indatsm      = sm1(:,{lat1:lat2},{lon1:lon2})
  printVarSummary(indatsm)

in2        = addfile("/cygdrive/d/data/rain/pre_0.25_Jun.nc","r")
rain       = in2->pre(1:33,:,:)
   printVarSummary(rain)
pre_stdr   = dim_standardize_n(rain,0,0)
pre_stdr!0 = "time"
pre_stdr!1 = "lat"
pre_stdr!2 = "lon"
 copy_VarCoords(rain,pre_stdr)
 printVarSummary(pre_stdr)
;indatpre   = pre_stdr(:,{lat3:lat4},{lon3:lon4})
 ;printVarSummary(indatpre)

 ;************************************************
; reorder to get time as right most dimension
;***********************************************

ts1        = indatsm(lat|:,lon|:,time|:)
ts2        = pre_stdr(lat|:,lon|:,time|:)
  printVarSummary(ts1)
  printVarSummary(ts2)

; ************************************************
; calculate cross correlations
; ************************************************
  maxlag = 2                                    ; set lag
; note, the max lag should not be more than N/4
  
  ccr = esccr(ts1,ts2,maxlag)                   ; calc cross correlations
  ; n    = dimsizes(ts1)                ; n=11
  ; t = r*sqrt((n-2)/(1-r^2))
  ; print(t)


; copy meta data and coordinate variables using contributed functions
  copy_VarAtts(ts1, ccr)                    
  copy_VarCoords_1(ts2,ccr)

    printVarSummary(ccr)

  ccr1 = ccr(0,0,:,:,:)
    copy_VarCoords_1(ts2,ccr1)


;************************************************
; plot the correlations
;************************************************
Dirout                    = "/cygdrive/D/data/cor/"
wks                       = gsn_open_wks("png",Dirout+"Maycore0-10cmJun")             ; send graphics to PNG file pre_0.25_Jul.nc
 
res                       = True                ; make plot mods

res@gsnMaximize           = True           ; maximize plot in frame
res@gsnDraw               = False
res@gsnFrame              = False

res@cnFillOn              = True                ; turn on color
res@cnFillPalette         = "BlWhRe"            ; set color map

res@cnLinesOn             = False               ; turn off contour lines
res@cnLevelSelectionMode  = "ManualLevels"      ; manually set cn levels
res@cnMinLevelValF        = -1.                 ; min level
res@cnMaxLevelValF        = 1.                 ; max level
res@cnLevelSpacingF       = .1                  ; contour level spacing

res@cnLabelBarEndStyle    = "ExcludeOuterBoxes" ; remove the two end boxes from the labelbar
res@pmLabelBarWidthF      = 0.8

res@mpOutlineOn = True

res@mpOutlineBoundarySets = "National"
res@mpGeophysicalLineColor = "black"
res@mpGeophysicalLineThicknessF = 2.0
res@mpDataBaseVersion = "MediumRes"

; res@mpOutlineOn           = True
; res@mpOutlineSpecifiers   = (/"China"/)

; res@mpOutlineDrawOrder    = "PostDraw";这个是我作图需要的顺序，你可以改。
; res@mpOutlineBoundarySets = "NoBoundaries";

; cnres           = True
; cnres@china     = True       ;draw china map or not
; cnres@river     = True       ;draw changjiang&huanghe or not
; cnres@province  = True       ;draw province boundary or not
; cnres@nanhai    = True       ;draw nanhai or not 
; cnres@diqu      = False       ; draw diqujie or no


res@gsnAddCyclic          = False
res@cnFillDrawOrder       = "Draw"
res@mpMinLonF             = 100;70               ; set min lon
res@mpMaxLonF             = 140;110               ; set max lon
res@mpMinLatF             = 15.1;24               ; set min lat
res@mpMaxLatF             = 55 ;45               ; set max lat
res@tmXTOn                = False           ;turns off the top tick marks
res@tmYLMinorOn           = False           ;Turns off minor tick marks

res@tmXBValues            = (/100.,105.,110.,115.,120.,125.,130.,135.,140./);/)
res@tmXBLabels            = (/"100E","105E","110E","115E","120E","125E","130E","135E","140E"/);/)
res@tmYLValues            = (/15.1,20.,25.,30.,35.,40.,45.,50.,55./)
res@tmYLLabels            = (/"15N", "20N","25N","30N","35N","40N","45N","50N","55N"/)

lag                       = 0
res@tiMainString          = "Correlations at lag "+lag
plot                      = gsn_csm_contour_map(wks,ccr1(:,:,lag),res)

; dir                    = "China/"
; fiename                = "diquJie_polyline.shp"
; lnres                  = True
; lnres@gsLineColor      = "black"
; lnres@gsLineThicknessF = 3.0
; poly_mask0             = gsn_add_shapefile_polylines(wks,plot,dir+fiename,lnres)
; ************************************************
 cnres           = True
 cnres@china     = True       ;draw china map or not
 cnres@river     = True       ;draw changjiang&huanghe or not
 cnres@province  = True       ;draw province boundary or not
 cnres@nanhai    = True       ;draw nanhai or not 
 cnres@diqu      = False       ; draw diqujie or not

 chinamap = add_china_map(wks,plot,cnres)
;>============================================================<

draw(plot)
frame(wks)
   ;  draw(plot)
   ; frame(wks)
end