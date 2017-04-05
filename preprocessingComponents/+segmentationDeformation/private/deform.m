function [ OsegVOI ] = deform(segVOI, operation, radius, ...
    xSpacing, ySpacing, zSpacing)
%DEFORM Summary of this function goes here
%   Detailed explanation goes here

%% Create structural element
     % Resolution
     xLimit = radius / xSpacing; 
     yLimit = radius / ySpacing;
     zLimit = radius / zSpacing;
    
     % Create coordinates in the space
     [xx,yy,zz] = ndgrid(-xLimit:xSpacing:xLimit, ...
         -yLimit:ySpacing:yLimit, ...
         -zLimit:zSpacing:zLimit);

     % Structure Element
     nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= radius;

     % Dilation or Erosion
     if (strcmp(operation, 'dilate'))
        OsegVOI = imdilate(segVOI, nhood);
     elseif (strcmp(operation, 'erode'))
        OsegVOI = imerode(segVOI, nhood);
     else
        OsegVOI = segVOI;
     end
end

