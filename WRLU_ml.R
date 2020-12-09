#Required Packages
library(keras)
library(tidyr)
library(ggplot2)

#Path to full training set and path to a subset
train_image_files_path <- "C:/Users/Temo/Desktop/onee/"
valid_image_files_path <- "C:/Users/Temo/Desktop/onee_l/"


#Only two categories here, a polygon only has one field, or a polygon has two or more fields
Field_cat <- c("one", "two")
output_n <- length(Field_cat)
#Set up resolution, can go higher but much slower
img_width <- 240
img_height <- 240
target_size <- c(img_width, img_height)

# RGB = 3 channels, in this case I converted everything to a single band. Imagnet requires 3 so it is used.
channels <- 3

#Rescale images and rotate to increase training dataset
train_data_gen = image_data_generator(
  rescale = 1/255,rotation_range=90)

#bring in images. I have seen other ways to bring in the images that are faster, maybe experiment with in the future
train_image_array_gen <- flow_images_from_directory(train_image_files_path, 
                                                    train_data_gen,
                                                    shuffle = TRUE,
                                                    target_size = target_size,
                                                    batch_size = 20,
                                                    class_mode = "categorical",
                                                    classes = Field_cat,
                                                    seed = 42)
valid_image_array_gen <- flow_images_from_directory(valid_image_files_path , 
                                                    train_data_gen,
                                                    shuffle = TRUE,
                                                    target_size = target_size,
                                                    batch_size = 10,
                                                    class_mode = "categorical",
                                                    classes = Field_cat,
                                                    seed = 42)
cat("Number of images per class:")
table(factor(train_image_array_gen$classes))

field_classes_indices <- train_image_array_gen$class_indices
# number of training samples
train_samples <- train_image_array_gen$n
# number of validation samples
valid_samples <- valid_image_array_gen$n

# define batch size and number of epochs
batch_size <- 20
epochs <- 15
# Bring in pre-trained model, same resolution as training data
b_model <-application_inception_v3(include_top = FALSE,weights = "imagenet",input_shape = c(240,240,3))

# add layers to model
predictions<-b_model$output %>%
  layer_flatten() %>%
  layer_dense(128) %>%
  layer_activation("relu") %>%
  layer_dropout(0.2) %>%
  layer_dense(output_n) %>% 
  layer_activation("softmax")
# apply layers to model
model<-keras_model(inputs=b_model$input,outputs=predictions)

# compile
model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = optimizer_rmsprop(lr = 0.0001),
  metrics = "accuracy"
)
# Run model
hist <- model %>% fit_generator(
  # training data
  train_image_array_gen,
  
  # epochs
  steps_per_epoch = as.integer(train_samples / batch_size), 
  epochs = epochs, 
  
  # validation data
  validation_data = valid_image_array_gen,
  validation_steps = as.integer(valid_samples / batch_size),
  
  # print progress
  verbose = 2,
  callbacks = list(
    # save best model after every epoch
    callback_model_checkpoint("C:/Users/Temo/Documents/Work/WRLU102220_1.h5", save_best_only = TRUE),
    # only needed for visualising with TensorBoard
    callback_tensorboard(log_dir = "C:/Users/Temo/Documents/Work/logs")
  )
)
plot(hist)
###########################
#Load in wanted model to apply to full dataset
model<-load_model_hdf5("C:/Users/Temo/Documents/Work/WRLU102220_1.h5")#WRLU102020_1.h5-good
#This includes all of the extracted imagry from each polygon within our dataset, different than the training
valid_image_files_path <- "C:/Users/Temo/Documents/Work/lu_pics/"
#blank out data generator
ig<-image_data_generator()
#We are applying the model to each individual picture, make abtch size 1 and turn off shiffle
test_image_array_gen <- flow_images_from_directory(valid_image_files_path , 
                                                    train_data_gen,
                                                   target_size = target_size,
                                                   shuffle = FALSE,
                                                   class_mode = "categorical",
                                                   batch_size  = 1)
#Can be useful to understand output, get each filename
fn<-test_image_array_gen$filenames 
#reset before applying, I read this is important however I noticed no difference
test_image_array_gen$reset()

#apply model to make predictions to data. I saw no peformance gain by adding workers (cores)
predictions4 <- model %>% predict_generator(test_image_array_gen,steps=191934,workers = 2)#191934

#Output pridictions to either of the two categories because we have two, we can understand it by either column and 0 or 1
p4<-as.data.frame(ifelse(predictions4 > 0.5, 1, 0))
#Merge the file names to the prediction dataframe
nrp2<-cbind(p4,fn)
#reorder data by the filename
p4$V3<-seq.int(nrow(p3))
colnames(p3)<-c("id","ML")
#####Packages required to join the odels predictions back to the spatial polgons
require(sf)
require(raster)
#read in polygons
lu<-st_read("C:/Users/Temo/Documents/Work/ML5.shp")
#making a column to join by file name
lu$rn1<-paste("WRLU",lu$id,sep="")
rn1<-sub(".*U","",fn)
rn1<-sub(".png.*","",rn1)
rn1<-paste("WRLU",rn1,sep="")
rn1<-as.data.frame(rn1)
rn1$match<-p4$V2
#merge model prediction output to sahpefile
lu<-merge(lu,rn1,by="rn1")
#save shapefile
st_write(lu,"C:/Users/Temo/Documents/Work/ML6.shp")
####


