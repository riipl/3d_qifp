function [ fieldValue ] = findConfigValue(configArray, fieldName)
%FINDCONFIGVALUE Summary of this function goes here
%   Detailed explanation goes here

    fieldValue = NaN;
     % Iterate through all the input descriptions
    nInputs = numel(configArray);
    for iInput = 1:nInputs
        config = configArray{iInput};
        configName = config.name;
        if strcmp(configName, fieldName)
            localValues = {config.value};
            if numel(localValues) ~= 1
                fieldValue = localValues;    
            else
                fieldValue = config.value;
            end
            return
        end
    end
end

