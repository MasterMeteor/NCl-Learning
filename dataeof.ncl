; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/shapefile_utils.ncl"
; 这些文件会自动加载
; 在这个程序中主要将青藏高原土壤湿度的夏季分布图
; by XinLiu 2019/4/3

begin
;-----------地图路径-----------------
  Dir       = "/cygdrive/D/data/DBATP/";地图路径
  shp_fname = systemfunc("cd "+Dir+"; ls *.shp");列出制定目标下所有的.shp文件
  Dirout    = "/cygdrive/D/data/EOF/"
 ;----------读取夏季数据----------------
 fils       = systemfunc("ls year/*.nc")
 printVarSummary(fils)   ; full path to files
 f          = addfiles(fils, "r")
 ListSetType(f,"cat")
 printVarSummary(f)

 ;----------读取文件当中的土壤湿度数据----------------
 soi        = f[:]->soi_avg
  printVarSummary(soi)

;-----单位转换-----
 soi1       = soi(0,:,:)/18
 soi2       = soi(1,:,:)/27
 soi3       = soi(2,:,:)/46
 soi4       = soi(3,:,:)/75
 soi5       = soi(4,:,:)/123
 soi6       = soi(5,:,:)/204
 soi7       = soi(6,:,:)/336
 ;soi8 = soi(7,:,:)/
 printVarSummary(soi1)
 printVarSummary(soi3)

 ;-----不同层次求平均----  
 ;swy=(soi1*1.8+soi2*2.7+soi3*4.6)/9.1   ;0-10cm平均土壤湿度
 swy=(soi3*4.6+soi4*7.5+soi5*12.3+soi6*20.4)/40.23    ;10-50cm平均土壤湿度
 copy_VarCoords(soi(0,:,:),swy)
 printVarSummary(swy)

neof   = 1

;*******************************************
;  EOF 
;*******************************************
  X = swy(lat|:,lon|:)              ; Space x Time

  optEof = True
  eof    = eofunc_Wrap( X, neof, optEof)
  eof_ts = eofunc_ts_Wrap( X, eof, False)

  printVarSummary(eof)
  printVarSummary(eof_ts)

;   *******************************************
;  plots
; *******************************************
  wks                      = gsn_open_wks("png",Dirout+"eof")         ; send graphics to PNG file

  ;plot                     = new(neof,graphic)                ; create graphic array
     gsn_define_colormap(wks,"MPL_RdYlBu")        ; BlueDarkRed18
                                          ; only needed if paneling
  ;res                      = True
  ;res@gsnDraw              = False        ; don't draw yet
  ;res@gsnFrame             = False        ; don't advance frame yet
  ;res@gsnAddCyclic         = False        ; data not cyclic
  ;res@cnFillPalette        = "posneg_1"   ; choose colormap
 
  ; res@mpCenterLonF       = 180.         ; defailt is 0 [GM]
  ; res@mpMinLatF          = min(x&lat)
  ; res@mpMaxLatF          = max(x&lat)
  ; res@mpMinLonF          = min(x&lon)
  ; res@mpMaxLonF          = max(x&lon)
  ; res@mpFillDrawOrder    = "PostDraw"

  ;res@cnFillOn             = True         ; turn on color fill
  ;res@cnLinesOn            = True         ; True is default
  ;res@lbLabelBarOn         = False        ; turn off individual lb's
                                          ; set symmetric plot min/max
  ; symMinMaxPlt(eof, 16, False, res); contributed.ncl

    res                        = True     ; plot mods desired

  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpOutlineOn            = False
  res@cnFillOn               = True     ; turn on color fill
  res@cnLinesOn              = False    ; turn off contour lines
  res@cnLineLabelsOn         = False    ; turn off contour line labels
  res@lbLabelBarOn           = True     ;open the labelbar
  res@lbBoxLinesOn           = True
  res@cnSmoothingOn          = True
  res@cnSmoothingTensionF    = True
  res@gsnSpreadColors        = True

  res@cnFillColors         = (/7,17,27,33,49,65,70,81,90,97,107,109,112,115,118,120,125,127,128,129/)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0.06
  res@cnMaxLevelValF       = 0.40
  res@cnLevelSpacingF      = 0.02

  res@gsnAddCyclic         = False
  res@cnFillDrawOrder      = "Draw"
  res@mpMinLonF            = 75               ; set min lon
  res@mpMaxLonF            = 105               ; set max lon
  res@mpMinLatF            = 25               ; set min lat
  res@mpMaxLatF            = 40               ; set max lat
  res@tmXBValues           = (/75.,80.,85.,90.,95.,100.,105./);,120.,130.,140/)
  res@tmXBLabels           = (/"75E","80E","85E","90E","95E","100E","105E"/)
  res@tmYLValues           = (/25.,30.,35.,40./)        ;,50.,55/)     ;(/15.,
  res@tmYLLabels           = (/"25N","30N","35N","40N"/)       ;,"50N","55N"/)  ;(/"15N",
  res@tmXTOn               = False           ;turns off the top tick marks
  res@tmYLMinorOn          = False           ;Turns off minor tick marks


; panel plot only resources
  ; resP                     = True         ; modify the panel plot
  ; resP@gsnMaximize         = True         ; large format
  ; resP@gsnPanelLabelBar    = True         ; add common colorbar

  ; res@gsnPanelMainString  = "EOF"
  ;do n                    = 0,neof-1
  ;res@gsnLeftString        = "EOF 1"
  ;res@gsnRightString       = sprintf("%5.1f", eof@pcvar) +"%"
  plots1                   = gsn_csm_contour_map(wks,eof(:,:),res)
   ;end do
 ; gsn_panel(wks,plot,(/neof,1/),resP)     ; draw all 'neof' as one plot

;*******************************************
; time series (principal component) plot
;*******************************************
;   eof_ts@long_name = "Amplitude"

;   rts           = True
;   rts@gsnDraw   = False       ; don't draw yet
;   rts@gsnFrame  = False       ; don't advance frame yet
;  ;rts@gsnScale  = True        ; force text scaling               

; ; these four resources allow the user to stretch the plot size, and
; ; decide exactly where on the page to draw it.

;   rts@vpHeightF = 0.40        ; Changes the aspect ratio
;   rts@vpWidthF  = 0.85
;   rts@vpXF      = 0.10        ; change start locations
;   rts@vpYF      = 0.75        ; the plot

;   rts@gsnYRefLine           = 0.              ; reference line   
;   rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
;   rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; ; panel plot only resources
;   rtsP                     = True             ; modify the panel plot
;   rtsP@gsnMaximize         = True             ; large format
      
;   resP@gsnPanelMainString  = "EOF"
;   do n=0,neof-1
;      rts@gsnLeftString  = "EOF "+(n+1)
;      rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
;      plot(n) = gsn_csm_xy (wks,x&time,eof_ts(n,:),rts)
;   end do
;   gsn_panel(wks,plot,(/neof,1/),rtsP)        ; draw all 'neof' as one plot

;-----添加高原轮廓线------
   lnres  = True
   lnres@gsLineColor      = "black"
   lnres@gsLineThicknessF = 6.0 
   poly_mask0 = gsn_add_shapefile_polylines(wks,plots1,Dir+shp_fname(1),lnres)

   draw(plots1)
   frame(wks)


end



;  ;-------------绘图设置-----------------
;  res = True     ; plot mods desired
;  wks = gsn_open_wks("ps", Dirout+"1980-2016 moisture(10-50cm)")  ; send graphics to PNG file
;  gsn_define_colormap(wks,"MPL_RdYlBu")        ; BlueDarkRed18
     
;   res@gsnMaximize            = True
;   res@gsnDraw                = False
;   res@gsnFrame               = False
;   res@mpOutlineOn            = False
;   res@cnFillOn               = True     ; turn on color fill
;   res@cnLinesOn              = False    ; turn off contour lines
;   res@cnLineLabelsOn         = False    ; turn off contour line labels
;   res@lbLabelBarOn           = True     ;open the labelbar
;   res@lbBoxLinesOn           = True
;   res@cnSmoothingOn          = True
;   res@cnSmoothingTensionF    = True
;   res@gsnSpreadColors        = True
  
;   res@cnFillColors           = (/7,17,27,33,49,65,70,81,90,97,107,109,112,115,118,120,125,127,128,129/)
;   res@cnLevelSelectionMode   = "ManualLevels"
;   res@cnMinLevelValF         = 0.06
;   res@cnMaxLevelValF         = 0.40
;   res@cnLevelSpacingF        = 0.02

;   res@gsnAddCyclic           = False
;   res@cnFillDrawOrder        = "Draw"
;   res@mpMinLonF              = 75               ; set min lon
;   res@mpMaxLonF              = 105               ; set max lon
;   res@mpMinLatF              = 25               ; set min lat
;   res@mpMaxLatF              = 40               ; set max lat
;   res@tmXBValues             = (/75.,80.,85.,90.,95.,100.,105./);,120.,130.,140/)
;   res@tmXBLabels             = (/"75E","80E","85E","90E","95E","100E","105E"/)
;   res@tmYLValues             = (/25.,30.,35.,40./)        ;,50.,55/)     ;(/15.,
;   res@tmYLLabels             = (/"25N","30N","35N","40N"/)       ;,"50N","55N"/)  ;(/"15N",
;   res@tmXTOn                 = False           ;turns off the top tick marks
;   res@tmYLMinorOn            = False           ;Turns off minor tick marks


;   res@tiMainString           = "Tibet moisture(10_50cm)"
;   res@tiMainFontHeightF      = 0.025
  
;   res@mpDataBaseVersion      = "MediumRes"
;   res@mpLandFillColor        = "white"
;   res@mpInlandWaterFillColor = "white"
;   res@mpOceanFillColor       = "white"
;   res@gsnLeftString          = "(a)"
;   res@gsnRightString         = "m~S~3~N~/m~S~3~N~"
  
;   plots1                     = gsn_csm_contour_map(wks,swy,res)
   
; ;-----添加高原轮廓线------
;    lnres  = True
;    lnres@gsLineColor      = "black"
;    lnres@gsLineThicknessF = 6.0 
;    poly_mask0 = gsn_add_shapefile_polylines(wks,plots1,Dir+shp_fname(1),lnres)

;    draw(plots1)
;    frame(wks)

;  end