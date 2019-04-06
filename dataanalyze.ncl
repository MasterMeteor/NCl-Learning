; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/shapefile_utils.ncl"

begin
;数据路径
;Dir              = "/cygdrive/D/data/DBATP/"
Dirout            = "/cygdrive/D/data/year/"

;shp_fname        = systemfunc("cd "+Dir+"; ls *.shp");列出制定目标下所有的.shp文件
 
fils              = systemfunc("ls newdata/GLDAS_CLM10_M.A201*.001.grb.SUB.nc4")
 printVarSummary(fils)   ; full path to files
f                 = addfiles(fils, "r")
 ListSetType(f,"cat")
 printVarSummary(f)
 ;-----读取数据-----
soi               = f[ : ]->SoilMoist
 printVarSummary(soi)
soi_ave           = dim_avg_n_Wrap(soi,0)
soi_ave!0         = "levgrnd"
soi_ave!1         = "lat"
soi_ave!2         = "lon"
 printVarSummary(soi_ave)

 ;-----创建一个新的nc文件读取数据-----
; filsput           = "2010-2016.nc"
; system("/bin/rm -f " + filsput)
; filsput1          = addfile(Dirout+filsput,"c" )

; filsput1->soi_avg = soi_ave


 end