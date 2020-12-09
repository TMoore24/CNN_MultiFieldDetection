# CNN_MultiFieldDetection
Loop through spatial polygons to extract high resolution imagery of agricultural fields. Identify polygons that contain more than one field and need to be redrawn. 

The primary data for this model are Utah Division of Water Resources Water-Related Landuse data. The data are stored as spatial ploygons and attempt to represent agricultural fields in a given year. As the USDA Naitional Agricultural Imagry Program (NAIP) releases new imagry of the state, the polygons must be redrawn to better represnt fields and different crops or irrigation practices whithin the field. To do this individuals would pan across the state at 1:24,000 feet and manually decide which polgyons needed to be modified. Below is an example of such a view.
![alt tag](https://github.com/TMoore24/CNN_MultiFieldDetection/blob/main/ML_fig1.png)
Maybe we would select the following fields and decide these polygons should be reworked. The goal of this model is to take the majority of this panning process out and already know which polygons are good canidates to be redrawn.
![alt tag](https://github.com/TMoore24/CNN_MultiFieldDetection/blob/main/ML_fig2.png)
To do this, we use R to loop through each polygon, extract the 2018 NAIP imagry as a single band PNG. Maintaining 3 bands and real colors could be beneficail for other models, but this speeds the process up and maintains the general patterns we want the model to find. We went through the images manually to train the model deciding whether an images was a single field or represented mutiple fields. As seen below.
![alt tag](https://github.com/TMoore24/CNN_MultiFieldDetection/blob/main/ML_fig3.png)
We then use Keras to implment a CNN image classification model through tensorflow. We begin to see the model level off at 10 epochs, however the 15th epoch yields the best results.
![alt tag](https://github.com/TMoore24/CNN_MultiFieldDetection/blob/main/ML_fig4.png)
We can apply this model to each extracted image and rejoin the results of the model to the shapefile. Once this is done we can quickly go through each polygon the model suggests linework for and decide whether we would like to modify it or not. Below we can see an area and the suggested changes from the model. 
![alt tag](https://github.com/TMoore24/CNN_MultiFieldDetection/blob/main/ML_fig5.png)
