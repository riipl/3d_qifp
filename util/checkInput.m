function inputStructure = checkInput(inputArray, functionInputs)
%checkInput checks a configuration structure passed to a feature to check
%for correctness
%
% Description: Features in the QIFP describe what inputs they are expecting
%   in their configuration file. checkInput receives the cell array and
%   and the features inputs and checks that all the required features are
%   present, if not it chooses the defaults
%
% Input:
%   inputArray: 1-dimensional cell array containing multiple fields
%               describing inputs the QIFP feature module is expecting
%
%   functionInputs: Structure containing the input values of the function
%
% Output:
%   inputStructure: Structure with valid input values to be used by the
%                   feature function
%%
    
    % Initialize our output variable
    inputStructure = Struct();
    
    % Iterate through all the input descriptions
    nInputs = numel(inputArray);
    for iInput = 1:nInputs
        input = inputArray{iInput};
        inputName = input.name;
        
        % Check if the field exists, and assign it to configuration
        % structure
        if isfield(inputs, inputName)
            inputStructure.(inputName) = functionInputs.(inputName);
            
        % If the field doesn't exist check if there's a default value
        elseif isfield(input, 'default')
            inputStructure.(inputName) = input.default;
        
        % If the field doesn't exist and doesn't have a default value check
        % if it's required. If it is then error out.
        elseif isfield(input, 'required') && input.required
            error(['The field ' inputName ' is required by this feature'...
                   ' and has not been defined']);
        end 
    end
end

