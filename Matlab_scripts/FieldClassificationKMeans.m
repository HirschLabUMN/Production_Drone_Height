

%% Section 1 - Run each time. Need to change date (mmddyyyy) and fro each date the field (GC1, GC2, NC, or WiDiv)

% FieldClassificationKMeans.m
% Input: orthomosaic of desired planting after lcipping

clear;

date = '06042020NEW'; %ChNGE
planting = 'widivNEW'; %GC1/GC2/NC/WiDiv

file = strcat('QGIS Layers/', date, '/', date, '_geotiff_', planting, '.tif');

[ortho_geo, R] = geotiffread (file); %// type uint8
ortho_subset = ortho_geo(:,:,1:3);

% Classify each field image into plant(1) and background(0)

% Separating plants from soil using K-means clustering 
% K-Means clustering algorithm [24] is an unsupervised clustering algorithm that classifies the input data points into multiple classes based on their inherent distance from each other.
% https://www.mathworks.com/help/images/examples/color-based-segmentation-using-k-means-clustering.html
he = ortho_subset;
cform = makecform('srgb2lab'); % Convert Image from RGB Color Space to L*a*b* Color Space
lab_he = applycform(he,cform);

ab = double(lab_he(:,:,2:3)); % Classify the Colors in 'a*b*' Space Using K-Means Clustering
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

nColors = 6; %number of clusters desired
rng default;
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3); % repeat the clustering 3 times to avoid local minima

figure; imshow(ortho_subset,[]);


%% Rerun Each Time you change values below
Ikm = reshape(cluster_idx,nrows,ncols); % Label Every Pixel in the Image Using the Results from KMEANS
 imshow(Ikm,[]);



%% Change value of 0 or 1 based on backgorund (0) and plant (1) categories. Consider running each one with a "1" and all others as "zero" to determine what they are
Ikm(find(Ikm == 1)) = 0; %black 
Ikm(find(Ikm == 2)) = 1; %dark grey 
Ikm(find(Ikm == 3)) = 0; %light grey 
Ikm(find(Ikm == 4)) = 1; %white
Ikm(find(Ikm == 5)) = 0;

 imshow(Ikm,[]); % show mask

ortho_subset_appl = bsxfun(@times, ortho_subset, uint8(Ikm)); %create mask and apply to orthomosaic
 imshow(ortho_subset_appl); %show applied mask

%% save mask to desired folder
fileIkm = strcat('Data Analysis/Segmentation/', date, '_mask_', planting , '.mat'); 
save(fileIkm, 'Ikm');
