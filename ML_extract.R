require(rgdal)
require(raster)
require(gdalUtils)
require(sf)
require(doParallel)
require(ggplot2)
require(RStoolbox)

#Depending on whether you woant 1 band or 3 band use brick-3band, or raster-1band
#Bring in each county NAIP, this could be whithin the extraction loop but it seems faster to do it at once
Beaver<-brick('Path/NAIP2018_Beaver_RGB.tif')
BoxElder<-brick('Path/NAIP2018_BoxElder_RGB.tif')
Carbon<-brick('Path/NAIP2018_Carbon_RGB.tif')
Cache<-brick('Path/NAIP2018_Cache_RGB.tif')
Daggett<-brick('Path/NAIP2018_Daggett_RGB_1.tif')
Davis<-brick('Path/NAIP2018_Davis_RGB.tif')
Duchesne<-brick('Path/NAIP2018_Duchesne_RGB.tif')
Emery<-brick('Path/NAIP2018_Emery_RGB.tif')
Garfield<-brick('Path/NAIP2018_Garfield_RGB.tif')
Grand<-brick('Path/NAIP2018_Grand_RGB.tif')
Iron<-brick('PathL/NAIP2018_Iron_RGB_1.tif')
Juab<-brick('Path/NAIP2018_Juab_RGB.tif')
Kane<-brick('Path/NAIP2018_Kane_RGB.tif')
Millard<-brick('Path/NAIP2018_Millard_RGB.tif')
Morgan<-brick('Path/NAIP2018_Morgan_RGB_1.tif')
Piute<-brick('Path/NAIP2018_Piute_RGB_1.tif')
SaltLake<-brick('Path/NAIP2018_SaltLake_RG_1.tif')
SanJuan<-brick('Path/NAIP2018_SanJuan_RGB.tif')
Sanpete<-brick('Path/NAIP2018_Sanpete_RGB.tif')
Sevier<-brick('Path/NAIP2018_Sevier_RGB.tif')
Summit<-brick('Path/NAIP2018_Summit_RGB_1.tif')
Tooele<-brick('Path/NAIP2018_Tooele_RGB.tif')
Uintah<-brick('Path/NAIP2018_Uintah_RGB.tif')
Utah<-brick('Path/NAIP2018_Utah_RGB.tif')
Wasatch<-brick('Path/NAIP2018_Wasatch_RGB.tif')
Washington<-brick('Path/NAIP2018_Washington_RGB.tif')
Wayne<-brick('Path/NAIP2018_Wayne_RGB_1.tif')
Weber<-brick('Path/NAIP2018_Weber_RGB.tif')
Rich<-brick('Path/Rich_RGB_1.tif')

#Bring in WRLU data
WRLU<-st_transform(st_read("Path to Landuse",layer="PLSS_IRc"))
#The model does not handle non agricultural areas, remove
WRLU<-subset(WRLU,!WRLU$Description%in%c("Urban","Water","Riparian","Sewage Lagoon")&WRLU$State=="Utah")
# There are not many ploygons this big, however I remove them to save time and will manually check these giant areas
WRLU<-subset(WRLU,WRLU$Acres<3.404544e+03)
#match the raster variable name format
WRLU$County<-gsub(" ", "", WRLU$COUNTY, fixed = TRUE)
WRLU$id<-seq.int(nrow(WRLU))
#Loop through each polygon, crop the NAIP, then mask by polygon. Save with name than can be joined to data later
Sys.time()
for (i in 1:nrow(WRLU)){
  poly<-WRLU[i,]
  dd<-poly$id
  naip<-crop(get(as.character(poly$County)),poly)
  pic<-mask(naip,poly)
  name<-paste0(paste0("Path to output and name/irr",dd),".tif")
  writeRaster(pic,name,datatype = 'INT1U')
}
Sys.time()

#### I decided to share how to extract 3 band tifs rather than 1 band PNGs. Below yo ucan convert, or modify the above code by removing writeraster and using png, plot, and dev.off
#for (i in 1:nrow(WRLU)){
#  ras<-raster(paste(test_image_array_gen$directory,test_image_array_gen$filenames[i], sep=''))
#  name<-paste(test_image_array_gen$directory,test_image_array_gen$filenames[i], sep='')
#  name<-gsub("tif","png",name)
#  png(name)
#  plot(ras,axes = FALSE,box=FALSE,legend=FALSE)
#  dev.off()
#}

