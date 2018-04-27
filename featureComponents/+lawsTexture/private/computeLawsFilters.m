function [windowFilterResponseStruct, uniqueFilter, percentageCovered] = computeLawsFilters( intensityVOI, ...
    segmentationVOI, resolution, samplePoints, xSpacing, ySpacing, zSpacing)
%COMPUTELAWSFILTERS Summary of this function goes here
%   Detailed explanation goes here

% Statistics name and functions
statisticFunctions = statistics();
nFunctions = numel(statisticFunctions);
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
windowFilterResponseStruct = cell(nFilters*nFunctions,1);

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
    for iFunction = 1:nFunctions
        statFunction = statisticFunctions{iFunction};
        statName = statFunction.name;
        statFunc = statFunction.function;        
        featureName = ['resolution.' num2str(resolution) 'mm.' filterNames{iFilter}, '.', statName];
        featureValue = statFunc(windowFilterResponse(:,iFilter));
        if isnan(featureValue)
            featureValue = [];
        end
        windowFilterResponseStruct{(iFilter-1)*nFunctions + iFunction} = struct( ...
            'value', featureValue, ...
            'name', featureName ...
        );
    end
end

% Combine features with same ID
uniqueIds = unique(filterIds);
nUniqueIds = numel(uniqueIds);
uniqueFilter = cell(nUniqueIds*nFunctions,1);
for iUniqueId = 1:nUniqueIds
    cId = uniqueIds(iUniqueId);
    filterMaskId = (filterIds == cId);
    filtersMasked = windowFilterResponse(:,filterMaskId);
    filtersNameMasked = filterNames(filterMaskId);
    
    for iFunction = 1:nFunctions
        statFunction = statisticFunctions{iFunction};
        statName = statFunction.name;
        statFunc = statFunction.function;                
        featureName = ['resolution.' num2str(resolution) 'mm.aggregated.' filtersNameMasked{1} '.', statName];
        featureValue = statFunc(filtersMasked(:));
        if isnan(featureValue)
            featureValue = [];
        end
        uniqueFilter{(iUniqueId-1)*nFunctions + iFunction} = struct( ...
            'value', featureValue, ...
            'name', featureName ...
        );
    end
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