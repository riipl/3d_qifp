function [output_labels, output_values] = glcm(image, distance, customConfig)
%GLCM Summary of this function goes here
    offsets = [0,1;
               -1,1;
               -1,0;
               -1,-1];
    offset = offsets .* distance;
    
    if (isfield(customConfig, 'glcmMinAndMaxIntensity') && ...
            ~isempty(customConfig.glcmMinAndMaxIntensity))
        grayLimitsStr = strsplit(customConfig.glcmMinAndMaxIntensity, ',');
        grayLimits = cellfun(@str2num, grayLimitsStr);
    else
        grayLimits = [];
    end
    
    if (isfield(customConfig, 'glcmNumLevels') && ...
            ~isempty(customConfig.glcmNumLevels))
        glcmNumLevels = customConfig.glcmNumLevels;
    else
        glcmNumLevels = 8;
    end
    
    
    if (isfield(customConfig, 'glcmSymmetric') && ...
            ~isempty(customConfig.glcmSymmetric))
        glcmSymmetric = customConfig.glcmSymmetric;
    else
        glcmSymmetric = false;
    end
    
    glcm_m = graycomatrix(uint16(image),'Offset',offset, ...
        'GrayLimits',grayLimits, 'NumLevels', glcmNumLevels, ...
        'Symmetric', glcmSymmetric);
    
    z = GLCM_Features4(glcm_m,0);

original_labels = {
    'Autocorrelation';
    'Contrast';
    'Correlation-matlab';
    'Correlation: [1-2]';
    'Cluster Prominence';
    'Cluster Shade';
    'Dissimilarity';
    'Energy-matlab';
    'Entropy';
    'Homogeneity-matlab';
    'Homogeneity';
    'Maximum probability';
    'Sum of squares-Variance';
    'Sum average';
    'Sum variance';
    'Sum entropy';
    'Difference variance';
    'Difference entropy';
    'Information measure of correlation1';
    'Information measure of correlation2';
    'Inverse difference normalized (INN)';
    'Inverse difference moment normalized'
    };

% mean
mean_labels = cell(size(original_labels));
for iLabels = 1:size(original_labels,1)
    prefix = 'mean-';
    postfix = ['-distance_', num2str(distance)];
    mean_labels{iLabels} = [prefix, original_labels{iLabels}, postfix];  
end
mean_values = structfun(@(x) mean(x(~isnan(x))), z, 'Uniform', 0);
mean_values = struct2array(mean_values)';
mean_skip = find(isnan(mean_values));
mean_labels(mean_skip) = [];
mean_values(mean_skip) = [];


%std
std_labels = cell(size(original_labels));
for iLabels = 1:size(original_labels,1)
    prefix = 'std-';
    postfix = ['-distance_', num2str(distance)];
    std_labels{iLabels} = [prefix, original_labels{iLabels}, postfix];  
end
std_values = structfun(@(x) std(x(~isnan(x))), z, 'Uniform', 0);
std_values = struct2array(std_values)';
std_skip = find(isnan(std_values));
std_labels(std_skip) = [];
std_values(std_skip) = [];

%min
min_labels = cell(size(original_labels));
for iLabels = 1:size(original_labels,1)
    prefix = 'min-';
    postfix = ['-distance_', num2str(distance)];
    min_labels{iLabels} = [prefix, original_labels{iLabels}, postfix];  
end
min_values = structfun(@(x) min(x(~isnan(x))), z, 'Uniform', 0);
min_values = struct2array(min_values)';
min_skip = find(isnan(min_values));
min_labels(min_skip) = [];
min_values(min_skip) = [];



%max
max_labels = cell(size(original_labels));
for iLabels = 1:size(original_labels,1)
    prefix = 'max-';
    postfix = ['-distance_', num2str(distance)];
    max_labels{iLabels} = [prefix, original_labels{iLabels}, postfix];  
end
max_values = structfun(@(x) max(x(~isnan(x))), z, 'Uniform', 0);
max_values = struct2array(max_values)';
max_skip = find(isnan(max_values));
max_labels(max_skip) = [];
max_values(max_skip) = [];


output_labels = [mean_labels; std_labels; min_labels; max_labels];  
output_values = [mean_values; std_values; min_values; max_values]; 

end

