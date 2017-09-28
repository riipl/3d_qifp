function [res, startPos, featureList] = AppendFeatureList(new_fv, fv_name, res, startPos, featureList)

% 
% add the elements in new_fv into res one by one, instead of as a group
% 
% Input:
%     new_fv      : a feature vector
%     fv_name     : feature notation, could be a vector of string.
% 
% Output:
%     res         : current final feature vector
%     startPos
%     featureList

if (length(new_fv) == 1)
    % there's only one element
    startPos = [startPos; length(res)+1];
    featureList{length(featureList)+1} = fv_name;
    res = [res; new_fv];
    return;
end

% the feature vector has more than 1 element
for ii = 1:length(new_fv)
    startPos = [startPos; length(res)+1];
    if ~iscell(fv_name)
        featureList{length(featureList)+1} = [fv_name '-' num2str(ii)];
    else
        featureList{length(featureList)+1} = fv_name{ii};
    end
    res = [res; new_fv(ii)];
end





