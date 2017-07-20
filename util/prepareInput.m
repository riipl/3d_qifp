function configurationStruct = prepareInput(inputArray, internalStruct, featureStruct, excludeInternal)
%prepareInput prepares a configuration structure to be passed to a feature
%
% Description: Features in the QIFP describe what inputs they are expecting
%   in their configuration file. prepareInput receives the cell array and
%   creates a structure following the description. If a config value is
%   required and it does not have a default value, prepareInput errors out.
%
% Input:
%   inputArray: 1-dimensional cell array containing multiple fields
%               describing inputs the QIFP feature module is expecting
%
%   internalStruct: Structure containing values generated internally by the
%                   QIFP
%
%   featureStruct: [optional] Structure containing configuration values for  
%                  this feature set by the user when setting the
%                  pipeline
%
%   excludeInternal: [optional] defaults to false. Return a configuration 
%                    array without any internal fields. Useful to store
%                    any running parameters. 
%
% Output:
%   configurationStruct: Structure ready to be passed as an input
%                       to a QIFP feature module containing all values
%                       specified by the inputArray and extracted from both
%                       the internal and feature structures.

%% Initialization
    % We only accept between 2 and 3 arguments as input. If featureStruct
    % is missing we initialize it to an empty struct
    narginchk(2,4);
    if nargin < 3
        featureStruct = struct();
    end
    if nargin < 4
        excludeInternal = false;
    end
    
    % Initialize our output variable
    configurationStruct = struct();
    
%% Create input structure
    % Iterate through all the input descriptions
    nInputs = numel(inputArray);
    for iInput = 1:nInputs
        input = inputArray{iInput};
        inputName = input.name;
        
        % Check if the input value is internal or from the feature
        % configuration file
        if isfield(input, 'internal') && input.internal
            if excludeInternal
                continue;
            end
            valueStruct = internalStruct;
        else
            valueStruct = featureStruct;
        end
        
        % Check if the field exists, and assign it to configuration
        % structure
        if isfield(valueStruct, inputName)
            configurationStruct.(inputName) = valueStruct.(inputName);
            
        % If the field doesn't exist check if there's a default value
        elseif isfield(input, 'default')
            configurationStruct.(inputName) = input.default;
        
        % If the field doesn't exist and doesn't have a default value check
        % if it's required. If it is then error out.
        elseif isfield(input, 'required') && input.required
            error(['The field ' inputName ' is required by this feature'...
                   ' and has not been defined']);
        end 
    end


end

