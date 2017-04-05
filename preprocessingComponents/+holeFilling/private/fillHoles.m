function [ OsegVOI ] = fillHoles(segVOI)
% maximumConnected Summary of this function goes here
%   Detailed explanation goes here

%% Fill holes in the segmentation
    OsegVOI = imfill(logical(segVOI), 'holes');
    
end

