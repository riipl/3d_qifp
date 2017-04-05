function [ OsegVOI ] = topologyPreservation(segVOI, radius, ...
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

     % Closing
     OsegVOI = imclose(segVOI, nhood);
end

