## MATLAB Scripts Readme

AvgPHTwGroundBins_GroundDiff_v3.m is the MATLAB script used for plant height extraction using 97th percentile from the data flight date as top of plant and 3rd percentile from the ground flight as ground value. Formatted as a function with date_g (ground flight date), date (data flight date), planting (either manual or WholeField for plots where manual measurements were collected or the whole field), bins (number of bins across x axis within the plot boundary), binsy (number of bins across y axis within the plot boundary), and plotnum as inputs. 

FieldClassificationKMeans.m is the MATLAB script used to identify plant vs background material using k means clustering. Background material is then masked out before red, green, and blue values are extracted for each plot from the orthomosaic. Formatted with date (data flight) and planting (manual or WholeField) as inputs. nColors is changed based on the number of clusters desired and the value for each cluster is then changed to a 0 or 1 based on whether it is background or plant material. The output of this file is used in RGB_Values.m.

RGB_Values.m is the MATLAB script used for extracting average red, green, and blue values from the data flights. Formatted as a function with date (data flight date), and planting either manual or WholeField for plots where manual measurements were collected or the whole field). Uses orthomosaics, plot boundary .shp files, and mask output from FieldClassificationKMeans.m . 

Ortho_PlotSubset_FromField_Classified_RGB.m is referenced within RGB_Values.m and is never used independently. Subsets the orhomosaic to the given plot and extracts all red, green, and blue values. 

PHT_PlotSubset_v2.m is referenced within AvgPHTwGroundBins_GroundDiff_v3.m and is never used independently. This script creates a mask and clips the geotiff to the roi of the plot.

Using_AvgPHTGroundBins_GroundDiff_v3.m and Using_RGB_Values.m are scripts used to run the functions AvgPHTGroundBins_GroundDiff_v3.m and RGB_Values.m for each date of interest. 