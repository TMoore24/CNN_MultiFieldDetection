require(rgdal)
require(raster)
require(gdalUtils)
require(sf)
require(doParallel)
require(ggplot2)
require(RStoolbox)

Beaver<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Beaver_RGB.tif')
BoxElder<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_BoxElder_RGB.tif')
Carbon<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Carbon_RGB.tif')
Cache<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Cache_RGB.tif')
Daggett<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Daggett_RGB_1.tif')
Davis<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Davis_RGB.tif')
Duchesne<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Duchesne_RGB.tif')
Emery<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Emery_RGB.tif')
Garfield<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Garfield_RGB.tif')
Grand<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Grand_RGB.tif')
Iron<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Iron_RGB_1.tif')
Juab<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Juab_RGB.tif')
Kane<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Kane_RGB.tif')
Millard<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Millard_RGB.tif')
Morgan<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Morgan_RGB_1.tif')
Piute<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Piute_RGB_1.tif')
SaltLake<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_SaltLake_RG_1.tif')
SanJuan<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_SanJuan_RGB.tif')
Sanpete<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Sanpete_RGB.tif')
Sevier<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Sevier_RGB.tif')
Summit<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Summit_RGB_1.tif')
Tooele<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Tooele_RGB.tif')
Uintah<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Uintah_RGB.tif')
Utah<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Utah_RGB.tif')
Wasatch<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Wasatch_RGB.tif')
Washington<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Washington_RGB.tif')
Wayne<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Wayne_RGB_1.tif')
Weber<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/NAIP2018_Weber_RGB.tif')
Rich<-brick('C:/Users/Temo/Documents/ArcGIS/Projects/WRLU_2019_ML/Rich_RGB_1.tif')

#3.404544e+04 to big?
#3.4e+03
WRLU<-st_transform(st_read("C:/Users/Temo/Documents/Work/Landuse2020/Landuse2020.gdb",layer="PLSS_IRc"),crs=st_crs(Rich))
WRLU<-subset(WRLU,WRLU$STATE=='Utah')
WRLU$County<-gsub(" ", "", WRLU$COUNTY, fixed = TRUE)
WRLU$id<-seq.int(nrow(WRLU))
#####parralel between counties
####How do I want to choose the proper NAIP to use?
####Ignore ripairan, water?, and urban, any more?

#load all of the tifs in and crop from the pasted value of the basin yo uare in?

#writeRaster(pic, filename = name, datatype = 'INT1U') this will make a real color tif
###will take around 16 hours to run
Sys.time()
for (i in 1:nrow(WRLU)){
  poly<-WRLU[i,]
  dd<-poly$id
  naip<-crop(get(as.character(poly$County)),poly)
  pic<-mask(naip,poly)
  name<-paste0(paste0("C:/Users/Temo/Documents/Work/Landuse2020/ML_irr/irr/irr",dd),".tif")
  writeRaster(pic,name,datatype = 'INT1U')
}
Sys.time()

#### convert tifs to png
for (i in 112345:248106){
  ras<-raster(paste(test_image_array_gen$directory,test_image_array_gen$filenames[i], sep=''))
  name<-paste(test_image_array_gen$directory,test_image_array_gen$filenames[i], sep='')
  name<-gsub("tif","png",name)
  png(name)
  plot(ras,axes = FALSE,box=FALSE,legend=FALSE)
  dev.off()
}
####if not in two folder put on one folder?
valid_image_files_path2 <-"C:/Users/Temo/Desktop/onee/"
test_image_array_gen2 <- flow_images_from_directory(valid_image_files_path2 , 
                                                    train_data_gen,
                                                    target_size = target_size,
                                                    shuffle = FALSE,
                                                    class_mode = "categorical",
                                                    batch_size  = 1)

name1<-test_image_array_gen2$filenames
ra
ras<-raster(paste(test_image_array_gen$directory,test_image_array_gen$filenames[i], sep=''))
