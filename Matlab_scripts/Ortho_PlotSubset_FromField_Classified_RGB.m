%%%% Subsetting Geottif image to desired ROI
% file = field orthomosaic file
% shapefile = plot subset shapefile
% plot = plot number

function [ortho_plotR,ortho_plotG,ortho_plotB] = Ortho_PlotSubset_FromField_Classified(file, shapefile, plot, ClassificationMask)

[ortho_subset, R] = geotiffread(file);

% identify red values of image
ortho_subsetR = ortho_subset(:,:,1);

% identify green values of image
ortho_subsetG = ortho_subset(:,:,2);

% identify blue values of image
ortho_subsetB = ortho_subset(:,:,3);

% Read in GeoTIFF
R2 = geotiffinfo(file); 

[x,y] = pixcenters(R2); 

% Convert x,y arrays to grid: 
[X,Y] = meshgrid(x,y);
roi = shaperead(shapefile);

% Remove trailing nan from shapefile
rx = roi(plot).X(1:end-1);
ry = roi(plot).Y(1:end-1);

% Create Mask
mask_area = inpolygon(X,Y,rx,ry); 

%Apply mask to orthomosaic
ortho_subsetR = bsxfun(@times, uint8(ortho_subsetR), uint8(ClassificationMask)); 
ortho_subsetG = bsxfun(@times, uint8(ortho_subsetG), uint8(ClassificationMask)); 
ortho_subsetB = bsxfun(@times, uint8(ortho_subsetB), uint8(ClassificationMask)); 

ortho_plotR = bsxfun(@times, uint8(ortho_subsetR), uint8(mask_area));
ortho_plotG = bsxfun(@times, uint8(ortho_subsetG), uint8(mask_area));
ortho_plotB = bsxfun(@times, uint8(ortho_subsetB), uint8(mask_area));
%ortho_plot(find(ortho_plot > 1)) = 1;

% Get coordinates of the boundary of the freehand drawn region.
structBoundaries = bwboundaries(mask_area);
xy = structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.

% Now crop the image.
leftColumn = min(x);
rightColumn = max(x);
topLine = min(y);
bottomLine = max(y);
width = rightColumn - leftColumn;
height = bottomLine - topLine;
ortho_plotR = imcrop(ortho_plotR, [leftColumn, topLine, width, height]);
ortho_plotG = imcrop(ortho_plotG, [leftColumn, topLine, width, height]);
ortho_plotB = imcrop(ortho_plotB, [leftColumn, topLine, width, height]);
%ortho_plot = imcrop(ClassificationMask, [leftColumn, topLine, width, height]);

% Display cropped image.
%
%R    = ortho_plot(:, :, 1);
%G    = ortho_plot(:, :, 2);
%B    = ortho_plot(:, :, 3);

%mask2D = (0.0 < R) & ...  
 %        (0.0 < G) & ...
  %       (0.0 < B);
%
%ortho_plot   = cat(3, mask2D, mask2D, mask2D);
%RGB(ortho_plot) = 0;

%imshow(ortho_plot);

