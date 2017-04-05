function [ OsegVOI, nRegions ] = maximumConnected(segVOI, connectivity)
% maximumConnected Summary of this function goes here
%   Detailed explanation goes here

%% Find the biggest connected region
    OsegVOI = segVOI;

    % Find all connected regions
    bw = bwconncomp(OsegVOI, connectivity);
    vsize = zeros(size(bw.PixelIdxList));
    
    nRegions = numel(bw.PixelIdxList);
    
    % Find the volume of each region
    for pil = 1:numel(bw.PixelIdxList);
        vsize(pil) = numel(bw.PixelIdxList{pil});
    end
    [~, sortI] = max(vsize);

    % Get the largest region by eliminating the mask everywhere else
    for tti = 1:numel(bw.PixelIdxList);
        if tti == sortI 
            continue;
        end
    
    OsegVOI(bw.PixelIdxList{tti}) = 0;
    end
end

