load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;load "$NCARG_ROOT/lib/ncarg/nclscripts/shapefile_utils.ncl"

begin
 Dir       = "/cygdrive/D/data/DBATP/"
 shp_fname = systemfunc("cd "+Dir+"; ls *.shp");列出制定目标下所有的.shp文件
 
 fils      = systemfunc("ls newdata/GLDAS_CLM10_M.A20*.nc4")
 printVarSummary(fils)   ; full path to files
 f         = addfiles(fils, "r")
 ListSetType(f,"cat")
 printVarSummary(f)
 ;-----读取数据-----
 soi = f[:]->SoilMoist
 printVarSummary(soi)
 soi_ave = dim_avg_n_Wrap(soi,0)
 soi_ave!0="levgrnd"
 soi_ave!1="lat"                              
 soi_ave!2="lon"
 printVarSummary(soi_ave)
 ;-----单位转换-----
 soi1=soi_ave(0,:,:)/18
 soi2=soi_ave(1,:,:)/27
 soi3=soi_ave(2,:,:)/46
 soi4=soi_ave(3,:,:)/75
 soi5=soi_ave(4,:,:)/123
 soi6=soi_ave(5,:,:)/204
 soi7=soi_ave(6,:,:)/336
 printVarSummary(soi1)
 printVarSummary(soi3)
 ;-----不同层次求平均----  1
 ;swy=(soi1*1.8+soi2*2.7+soi3*4.6)/9.1   ;0-10cm平均土壤湿度
 swy=(soi3*4.6+soi4*7.5+soi5*12.3+soi6*20.4)/40.23    ;10-50cm平均土壤湿度
 copy_VarCoords(soi_ave(0,:,:),swy)
 printVarSummary(swy)


  res                        = True     ; plot mods desired
  wks                        = gsn_open_wks("png", "2000-2010 GLDAS_6-8_50cm")  ; send graphics to PNG file
   gsn_define_colormap(wks,"MPL_RdYlBu")        ; BlueDarkRed18
     
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
  
  res@cnFillColors           = (/7,17,27,33,49,65,70,81,90,97,107,109,112,115,118,120,125,127,128,129/)
  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF         = 0.06
  res@cnMaxLevelValF         = 0.40
  res@cnLevelSpacingF        = 0.02

  res@gsnAddCyclic           = False
  res@cnFillDrawOrder        = "Draw"
  res@mpMinLonF              = 75               ; set min lon
  res@mpMaxLonF              = 105               ; set max lon
  res@mpMinLatF              = 25               ; set min lat
  res@mpMaxLatF              = 40               ; set max lat
  res@tmXBValues             = (/75.,80.,85.,90.,95.,100.,105./);,120.,130.,140/)
  res@tmXBLabels             = (/"75E","80E","85E","90E","95E","100E","105E"/)
  res@tmYLValues             = (/25.,30.,35.,40./)        ;,50.,55/)     ;(/15.,
  res@tmYLLabels             = (/"25N","30N","35N","40N"/)       ;,"50N","55N"/)  ;(/"15N",
  res@tmXTOn                 = False           ;turns off the top tick marks
  res@tmYLMinorOn            = False           ;Turns off minor tick marks


  res@tiMainString           = "Tibet moisture(10_50cm)"
  res@tiMainFontHeightF      = 0.025
  
  res@mpDataBaseVersion      = "MediumRes"
  res@mpLandFillColor        = "white"
  res@mpInlandWaterFillColor = "white"
  res@mpOceanFillColor       = "white"
  res@gsnLeftString          = "(a)"
  res@gsnRightString         = "m~S~3~N~/m~S~3~N~"
  
  plots1                     = gsn_csm_contour_map(wks,swy,res)
   
;-----添加高原轮廓线------
   lnres  = True
   lnres@gsLineColor      = "black"
   lnres@gsLineThicknessF = 6.0 
   poly_mask0 = gsn_add_shapefile_polylines(wks,plots1,Dir+shp_fname(1),lnres)

   draw(plots1)
   frame(wks)

 end
