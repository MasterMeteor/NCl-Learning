load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"

begin

 ;Dir       = "DBATP/";地图路径
 ;shp_fname = systemfunc("cd "+Dir+"; ls *.shp");列出制定目标下所有的.shp文件
 ;fils3 = systemfunc("ls /vol6/home/fgz/dingxu/CESM/cesm1_2_2/archiev/CRU_V7_new/lnd/hist/chun/CRU_V7_new.clm2.h0.*3.nc")
 ;printVarSummary(fils3)   ; full path to files
 ;f3 = addfiles(fils3, "r")
 ;ListSetType(f3,"cat")
 ;printVarSummary(f3)
 ;h2o3 = f3[:]->H2OSOI
 ;printVarSummary(h2o3)

 ;fils4 = systemfunc("ls /vol6/home/fgz/dingxu/CESM/cesm1_2_2/archiev/CRU_V7_new/lnd/hist/chun/CRU_V7_new.clm2.h0.*4.nc")
 ;printVarSummary(fils4)   ; full path to files
 ;f4 = addfiles(fils4, "r")
 ;ListSetType(f4,"cat")
 ;printVarSummary(f4)
 ;h2o4 = f4[:]->H2OSOI
 ;printVarSummary(h2o4)

 fils5 = systemfunc("ls season/*chun.nc")
 printVarSummary(fils5)   ; full path to files
 f5 = addfiles(fils5, "r")
 ListSetType(f5,"join")
 printVarSummary(f5)
 h2o = f5[:]->SOIL_M_GDS0_DBLY
 printVarSummary(h2o)

; h2o = month_to_annual(h21, 0)  ; prc_annual_total(20) 
;  printVarSummary(h2o)

 ;h2o = (h2o3+h2o4+h2o5)/3.0
 ;h2o!0="time"
 ;h2o!1="levgrnd"
 ;h2o!2="lat"                              
 ;h2o!3="lon"
 ;printVarSummary(h2o)
  swy = new((/36,10,150,360/), float)
 swy(:,0,:,:)=(h2o(:,9,:,:)*0.0175+h2o(:,8,:,:)*0.0276+h2o(:,7,:,:)*0.0455)/0.0906              ;0-10cm
 swy(:,1,:,:)=(h2o(:,6,:,:)*0.075+h2o(:,5,:,:)*0.1236+h2o(:,4,:,:)*0.2038)/0.4024               ;10-50cm
 swy(:,2,:,:)=(h2o(:,3,:,:)*0.336+h2o(:,2,:,:)*0.5539)/0.8899                                    ;50-138cm
 copy_VarCoords(h2o(:,0:2,:,:), swy)
 printVarSummary(swy)

  sm1 = dim_rmvmean_n_Wrap(swy(:,0,:,:), 0)
  copy_VarCoords(h2o(:,0,:,:), sm1)
  printVarSummary(sm1)
  dims = dimsizes(sm1)
  year = ispan(1981, 1981+dims(0)-1, 1)
  ;jisuan quanzhong
  w = sqrt(cos(0.01745329*sm1&g0_lat_0))
  wp = sm1 * conform(sm1, w, 1)
  copy_VarCoords(sm1, wp)
  printVarSummary(wp)
  optEOF = True      
  optEOF@jopt = 0  
  
; =================================================================
; Reorder (lat,lon,time) the *weighted* input data
; Access the area of interest via coordinate subscripting
; =================================================================
  x     = wp({g0_lat_0|:},{g0_lon_1|:},ncl_join|:)
  neof =4
  eof      = eofunc_Wrap(x, neof, optEOF)      ;EOF fenjie
  eof = smth9_Wrap(eof,0.5,0.5, True)

;jisuan shijianxulie biaozhunhua==========
  eof_ts   = eofunc_ts_Wrap (x, eof, False)
  eof_ts = dim_standardize_n(eof_ts, 1, 1)
  printVarSummary( eof )                         ; examine EOF variables
  printVarSummary( eof_ts )
  ; dimxw  = dimsizes( x )
  ; mln    = dimxw(1)
  ; sumWgt = mln*sum( clat({lat|latS:latN}) )
  ; eof_ts = eof_ts/sumWg

;   ;north--------------------------
  prinfo = True
  ntim = dims(0)
  sig_pcv = eofunc_north(eof@pcvar, ntim, prinfo)

;   ;;;NETcdf wenjian
;   ;path_out = "sm1-PC1-"+dims(0)+"yr.nc"
;   ;system("rm -f"+path_out)
;   ;ncdf = addfile(path_out, "c")

  eof_ts!1 = "year"
  eof_ts&year = ispan(1981, 2016, 1)
;   ;ncdf->EOF1 = eof_ts(0,:)
;   ;保存时间序列，后面分析使用
;   opt = True
;   filename = "eof_ts-pre-1981-2016.txt"
;   write_matrix(eof_ts, ny+"f7.2", opt)
;   pcvar = eof@pcvar
;   prinfo = True

; printMinMax(eof,True)
;============================================================
Dirout="/cygdrive/f/last/glads/eof/"
  wks = gsn_open_wks("png",Dirout+"chun_eof_year_0-10")         ; send graphics to PNG file
  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
    gsn_define_colormap(wks,"BlueRed");BlueRed
; EOF patterns

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnAddCyclic         = False        ; plotted dataa are not cyclic


  ; res@pmTickMarkDisplayMode = "Always"

   res@lbBoxLinesOn     =False
  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
 res@cnLineLabelsOn       = False       ; True is default

   res@gsnSpreadColors =True        ;反转labelbar------
   res@gsnSpreadColorStart  =-1
   res@gsnSpreadColorEnd  =2
  ;res@cnFillColors          = (/7,17,27,37,47,57,67,85,95,105,110,115,119,125,127,129/) ;

 ;res@cnLineLabelDensityF = 0.01
 res@cnLineThicknessF = 1.2
  res@lbLabelBarOn         = False        ; turn off individual lb's
  res@cnLineLabelFormat = "@^sg"
  res@gsnContourNegLineDashPattern= 11
  res@gsnContourPosLineDashPattern= 0
  res@gsnContourZeroLineThicknessF = 1.4

    res@cnLevelSelectionMode  ="ManualLevels"; "ExplicitLevels"   ; set manual contour levels
   ;res@cnLevels             = (/-0.005,-0.003,-0.001,0,-0.001,0.003,0.005/)
   res@cnExplicitLabelBarLabelsOn = True
   ;res@lbLabelStrings       = (/"-0.015","-0.008","-0.004","-0.002","0","0.001","0.002","0.003","0.004"/)
   res@cnLineLabelPlacementMode = "Constant"
   ;res@cnLineLabelDensityF= 10
   res@cnMinLevelValF        =  -0.008          ; set min contour level
   res@cnMaxLevelValF        =   0.008         ; set max contour level
   res@cnLevelSpacingF       =   0.001          ; set contour interval

  ;set map to be regional
   res@gsnAddCyclic        = False
   res@cnFillDrawOrder     = "Draw"
   res@mpMinLonF            =72.1;70               ; set min lon
   res@mpMaxLonF            =105;110               ; set max lon
   res@mpMinLatF            =25.1;24               ; set min lat
   res@mpMaxLatF            =40 ;45               ; set max lat
   res@tmXTOn               =False           ;turns off the top tick marks
   res@tmYLMinorOn          =False           ;Turns off minor tick marks 

   res@tmXBValues           = (/72.1,75.1,80.,85.,90.,95.,100.,105.,110./);/)
   res@tmXBLabels           = (/"70E","75E","80E","85E","90E","95E","100E","105E","110E"/);/)
   res@tmYLValues           = (/25.1,30.,35.,40./)  
   res@tmYLLabels           = (/"25N", "30N","35N","40N"/)  
  

  res@tmXBLabelFontHeightF = 0.02
  res@tmYLLabelFontHeightF = 0.02

  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
   ;resP@cnLevelSelectionMode  = "ManualLevels"   ; set manual contour levels
   ;resP@cnMinLevelValF        =  -0.01           ; set min contour level
   ;resP@cnMaxLevelValF        =   0.01          ; set max contour level
   ;resP@cnLevelSpacingF       =   0.005           ; set contour interval

  yStrt                    = 1981
  yLast                    = 2016
 ; resP@txString            = season+": "+yStrt+"-"+yLast

;*******************************************
; first plot
;*******************************************
  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n)=gsn_csm_contour_map(wks,eof(n,:,:),res);_ce
     shp_filename ="DBATP/DBATP_Line.shp"  ;"$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/"
     cnres                       = True
     cnres@gsLineThicknessF      = 5.0
     cnres@gsLineColor           = "black"
     plotshp = gsn_add_shapefile_polylines(wks,plot,shp_filename,cnres)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
; EOF time series  [bar form]

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               
  rts@tmXBMode        = "Manual"   
  rts@tmYLMode        = "Manual"  
; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot

   rts@tmXBValues           = (/1981.,1986.,1991.,1996.,2001.,2006.,2011.,2016./);/)
   rts@tmXBLabels           = (/"1981","1986","1991","1996","2001","2006","2011","2016"/);/)
   ;rts@tmYLValues           = (/-3.,-2.,-1.,0.,1.,2.,3./)  
  ; rts@tmYLLabels           = (/"-3","-2","-1","0","1","2","3"/)  
  rts@tmXBLabelFontHeightF = 0.02
  rts@tmYLLabelFontHeightF = 0.02

  rts@trYMaxF   =3
  rts@trYMinF   =-3

  rts@tiYAxisString = " "                    ; y-axis label      

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnXYBarChart         = True            ; create bar chart
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
  ;rtsP@txString             = season+": "+yStrt+"-"+yLast

  ;year = yyyymm/100

; create individual plots
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,eof_ts&year,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)     ; now draw as one plot
  print(sig_pcv)
end

