%Getting Average Plant Height per Plot Estimates 
% 1. Extracting Plots from DEM and DSM and subtracting DEM-DSM to get pixel height from ground for plot
% 2. Binning Plot to get all height points for 20 bins
% 3. Extracting 97th percentile height value from each bin
% 4. Using average of middle 12 bins and trimming 2 outlier bins to get avg height for plot


function [means] = AvgPHTwGroundBins_GroundDiff_v3 (date_g, date, planting, bins, binsy, plotnum)

% date_g = '05182021newAgisoft';
% date = '06022021newAgisoft';
% planting = 'manual';
% bins = 20;
% binsy = 20;
% plotnum = 1;


% read ground DEM {DSM} file
file_g = strcat('QGIS_Layers/', date_g, '/', date_g, '_geotiffDEM', '.tif');
[DSM] = geotiffread(file_g(:,:,1)); %// type uint8
DSM = im2double(DSM(:,:,1));

% read field DEM file
file = strcat('QGIS_Layers/', date, '/', date, '_geotiffDEM', '.tif');
[DEM] = geotiffread(file(:,:,1)); %// type uint8
DEM = im2double(DEM(:,:,1));


%% read plot boundary shapefile for DEM date of interest
shapefile = strcat('QGIS_Layers/', date, '/Plots_', planting,'.shp');
roi = shaperead(shapefile);
mapshow(roi);

R = geotiffinfo(file); 
[x,y] = pixcenters(R); 
[X,Y] = meshgrid(x,y); % Convert x,y arrays to grid: 

clearvars shapefile R x y;

R_g = geotiffinfo(file_g); 
[x_g,y_g] = pixcenters(R_g); 
[X_g,Y_g] = meshgrid(x_g,y_g); % Convert x,y arrays to grid: 

clearvars shapefile R_g x_g y_g;

grid = zeros(binsy, bins);
means =  zeros(length(roi), 1);

%% Extracting plot
for plot = 1:length(roi)
    [DSMplot] = PHT_PlotSubset_v2 (DSM, roi, plot, X_g, Y_g); % Extracting plot from ground DEM
    [DEMplot] = PHT_PlotSubset_v2 (DEM, roi, plot, X, Y); % Extracting plot from field DEM
    
    % If statement for base station
    if strcmp(planting,'BaseStation')
        base_height = prctile(DEMplot,97,'all'); % assign the base height to the 97th percentile of that date
        ground_height = prctile(DSMplot,3,'all'); % assign the ground height to the 3rd percentile of that date
        actual_base = base_height - ground_height;
    else
        % Divide DSM plot into grid
        M = bins + 1 ; N = binsy + 1 ; %subsetting in the x direction to a set number of points equidistant; not subsetting in y or z direction
        rows_g = length(DSMplot(:,1));
        columns_g = length(DSMplot(1,:));
        x2_g = linspace(1, columns_g , M) ;
        y2_g = linspace(1, rows_g, N) ;
    
        [X2_g,Y2_g] = meshgrid(x2_g,y2_g);
    
        % Divide DEM plot into grid
        rows = length(DEMplot(:,1));
        columns = length(DEMplot(1,:));
        x2 = linspace(1, columns , M) ;
        y2 = linspace(1, rows, N) ;
    
        [X2,Y2] = meshgrid(x2,y2);
    
        for j = 1:M -1
            for r = 1:N - 1
        
            % extracting average DSM bin height from grid segments to get ground height value for bin
            A_g = [X2_g(r,j) Y2_g(r,j)] ;
            B_g = [X2_g(r+1,j+1) Y2_g(r+1,j+1)] ;
        
            xmin_g = A_g(1);
            ymin_g = A_g(2);
            xmax_g = B_g(1);
            ymax_g = B_g(2);
            zmin_g = 0;
            zmax_g = inf;
        
            leftColumn_g = xmin_g;
            rightColumn_g = xmax_g;
            topLine_g = ymin_g;
            bottomLine_g = ymax_g;
            width_g = rightColumn_g - leftColumn_g;
            height_g = bottomLine_g - topLine_g;
        
            DSMplot_bin = imcrop(DSMplot, [leftColumn_g, topLine_g, width_g, height_g]); %cropping plot bin
            DSMplot_bin_sub = DSMplot_bin(DSMplot_bin > 0);
            groundHeight =  prctile(DSMplot_bin_sub(:,1), 50); %getting ground heigth value from bin as 50th percentile of DSM
        
        
            % extracting average DEM bin height from grid segments to get plant height value for bin
            A = [X2(r,j) Y2(r,j)] ;
            B = [X2(r+1,j+1) Y2(r+1,j+1)] ;
        
            xmin = A(1);
            ymin = A(2);
            xmax = B(1);
            ymax = B(2);
            zmin = 0;
            zmax = inf;
        
            leftColumn = xmin;
            rightColumn = xmax;
            topLine = ymin;
            bottomLine = ymax;
            width = rightColumn - leftColumn;
            height = bottomLine - topLine;
        
            % Subtracting the DSM average plot-bin value     
            DEMplot_bin = imcrop(DEMplot, [leftColumn, topLine, width, height]); %cropping plot bin
            DEMplot_bin_sub = DEMplot_bin(DEMplot_bin > 0);
            DEMdiff_bin = DEMplot_bin_sub - groundHeight;
        
            grid(r, j) =  (prctile(DEMdiff_bin(:,1), 95));
            means(plot, 1) = mean(grid, 'All');
        
            end
        
        end
        
    end
    
    clearvars x2 y2 X2 Y2 DEMplot DEMplot_bin grid_g j A B DEMplot_sub DEMdiff_bin;

%% Export data
path = 'Data_Analysis/Height/Plots/';
if strcmp(planting,'BaseStation')
    dlmwrite( strcat(path, 'PlotMeans95Perc_', date, '_', planting, "_plot", "_xdim", num2str(bins), "_ydim", num2str(binsy), '.txt'), actual_base, 'delimiter', '\t');
else
    dlmwrite( strcat(path, 'PlotMeans95Perc_', date, '_', planting, "_plot", "_xdim", num2str(bins), "_ydim", num2str(binsy), '.txt'), means, 'delimiter', '\t');
end

end
