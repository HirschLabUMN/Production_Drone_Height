%% RGB Value Extraction
% inputs: date, planting
% prior: create classification mask using FieldClassificationKMeans.m
% Functions needed: Ortho_PlotSubset_FromField_Classified_RGB.m


function [PlantRatio] = RGB_Values (date, planting)

% date = '06182020';
% planting = 'WholeField'; %GC1/GC2/NC/WiDiv

file = strcat('QGIS_Layers/', date, '/', date, '_geotiff_', planting, '.tif');
shapefile = strcat('QGIS_Layers/', date, '/Plots_', planting, '.shp');
roi = shaperead(shapefile);

fileIkm = strcat('Data_Analysis/Segmentation/', date, '_mask_', planting, '.mat');
IkmFile = matfile(fileIkm);
Ikm2 = IkmFile.Ikm;
%imshow(Ikm2,[]);
 
PlantRatio = zeros(length(roi), 3);

for plot = 1:length(roi);
 
    [ortho_plotR,ortho_plotG,ortho_plotB] = Ortho_PlotSubset_FromField_Classified_RGB(file, shapefile, plot, Ikm2);
 
    % average red, green, and blue values for the plot
    redvalue = mean(nonzeros(ortho_plotR),'all');
    greenvalue = mean(nonzeros(ortho_plotG),'all');
    bluevalue = mean(nonzeros(ortho_plotB),'all');
    
    % add to PlantRatio
    PlantRatio(plot,1) = redvalue;
    PlantRatio(plot,2) = greenvalue;
    PlantRatio(plot,3) = bluevalue;
    
 end
 
dlmwrite( strcat('Data_Analysis/RGB_Values/', 'RGB_', date, '_', planting, '.txt'), PlantRatio, 'delimiter', '\t');

end
