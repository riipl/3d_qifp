function [ out ] = extractInfo( volumeInfo, prefix )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% If prefix is not set then make it an empty string
if (nargin < 2)
    prefix = '';
else
    prefix = [prefix '.'];
end

%Go across all fields and save the ones that are not a structure.
fields = fieldnames(volumeInfo);
output  = {};
nFields = numel(fields);
for iField = 1:nFields
    fieldName = fields{iField};
    if isstruct(volumeInfo.(fieldName))
        continue
    end
    if ((numel(volumeInfo.(fieldName)) > 1) && ~ischar(volumeInfo.(fieldName)))
        continue
    end
    % If it is a string then add a ' at the beginning.
    if ischar(volumeInfo.(fieldName))
        fieldValue = char(['''' volumeInfo.(fieldName)]);
        fieldValue = strrep(fieldValue,',','');
        fieldValue = strrep(fieldValue,'\n','');
        fieldValue = strtrim(fieldValue);
    else
        fieldValue = volumeInfo.(fieldName);
    end
        
    localOutput =   struct(...
            'name', [prefix fieldName],...
            'value', fieldValue ...
            );         
    output = [output, localOutput];
end

out = output;

end

