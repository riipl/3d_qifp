function [windowFilterResponseStruct, uniqueFilter, percentageCovered] = computeLawsFilters( intensityVOI, ...
    segmentationVOI, resolution, samplePoints, xSpacing, ySpacing, zSpacing)
%COMPUTELAWSFILTERS Summary of this function goes here
%   Detailed explanation goes here

%% Get all kernels for computation
filters = generateLawsFilters();

%% Get intensity windows to apply kernels on
spacing = [ySpacing, xSpacing, zSpacing];
[windows, percentageCovered] = createWindows(intensityVOI, ... 
    segmentationVOI, resolution, samplePoints, spacing); 

%% Generate Filter Responses
nWindows = size(windows, 4);
nFilters = size(filters,1);

windowFilterResponse = zeros(nWindows, nFilters);
filterNames = cell(nFilters,1);
filterIds = zeros(nFilters,1);
windowFilterResponseStruct = cell(nFilters,1);

% Extract names and ids from filters
for iFilter = 1:nFilters
    filterNames{iFilter} = filters{iFilter}.name;
    filterIds(iFilter) = filters{iFilter}.id;
end


% Apply filters to all windows
for iWindow = 1:nWindows
    window = windows(:,:,:,iWindow);
    windowFilterResponse(iWindow, :) = applyFiltersToWindow(window, filters);
end

% Format Output
for iFilter = 1:nFilters
    windowFilterResponseStruct{iFilter} = struct( ...
        'value', windowFilterResponse(:,iFilter), ...
        'name', ['resolution.' num2str(resolution) 'mm.' filterNames{iFilter}] ...
    );
end

% Combine features with same ID
uniqueIds = unique(filterIds);
nUniqueIds = numel(uniqueIds);
uniqueFilter = cell(nUniqueIds,1);
for iUniqueId = 1:nUniqueIds
    cId = uniqueIds(iUniqueId);
    filterMaskId = (filterIds == cId);
    filtersMasked = windowFilterResponse(:,filterMaskId);
    filtersNameMasked = filterNames(filterMaskId);
    uniqueFilter{iUniqueId} = struct( ...
        'value', filtersMasked(:), ...
        'name', ['resolution.' num2str(resolution) 'mm.aggregated.' filtersNameMasked{1}] ...
    );
end

end

%% BruteForce Window application
% Look into paralelizing this
function response = applyFiltersToWindow(window, filters)
    nFilters = numel(filters);
    response = nan(nFilters,1);
    for iFilter = 1:nFilters
        mResponse = window .* filters{iFilter}.filter;
        response(iFilter) = sum(mResponse(:));
    end
end