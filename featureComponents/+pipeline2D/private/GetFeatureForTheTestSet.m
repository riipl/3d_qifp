function [features, startPos, featureList] = GetFeatureForTheTestSet(lesionUIDs,DB, WEIGH_FEATURE_INDIV, FILENAME_PREFIX)
%
% Return Value:
%   features : N-D super feature vector (all FV concatenated tegother)
%   startPos : the start position of each feature vector
%   featureList : name of each feature
%
% Last modified: 11-23-2009
%

if ~exist('WEIGH_FEATURE_INDIV', 'var'), WEIGH_FEATURE_INDIV = 0; end
if ~exist('FILENAME_PREFIX', 'var'), FILENAME_PREFIX = ''; end


N = length(lesionUIDs);
if WEIGH_FEATURE_INDIV
    featureFileName = [FILENAME_PREFIX 'features_WFI_' num2str(N) '.mat'];
else
    featureFileName = [FILENAME_PREFIX 'features' num2str(N) '.mat'];
end

% calculate current hash
tmp = char(lesionUIDs);
current_hash = hash(tmp, 'md5');

if exist(featureFileName,'file') == 2
    load(featureFileName, 'features', 'lesionUIDs_hash', 'startPos', 'featureList', 'fv_name');
    % check lesionUIDs hash with the one saved
    if strcmp(current_hash, lesionUIDs_hash)
        % we return if the hash agrees
        fprintf('- Feature file ''%s'' found. Feature extraction skipped.\n', featureFileName)
        return;
    end
end

features = [];
for i = 1 : length(lesionUIDs)
    lesion = get(DB.lesions,lesionUIDs{i});

    [res startPos featureList] = GetFeatureOneLesion(lesion, 0, WEIGH_FEATURE_INDIV);
    
    if (size(features,1)>0 && size(res,1) ~= size(features,1))
        disp('error in feature size')
        [features] = [features zeros(size(features,1), 1)];
    else
        [features] = [features res];
    end
end
lesionUIDs_hash = current_hash;
[~,~, fv_name] = GetFeatureOneLesion(lesion, 0, 1);
fv_name = fv_name';
featureList = featureList';
save(featureFileName, 'features', 'lesionUIDs_hash', 'startPos', 'featureList', 'fv_name');

return;