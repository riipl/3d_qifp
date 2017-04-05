function [inputData, inputLoaderConfig] = ...
    inputStageLoad(internalState, inputComponent)    

    % Load Configuration 
    loaderConfigFunction = str2func([inputComponent '.configuration']);
    loaderConfig = loaderConfigFunction();

    % Prepare input initialization parameters
    inputLoaderConfig = ...
        prepareInput(loaderConfig.inputLoadArray, ...
                        internalState, internalState);

    % Find the function name to call 
    inputLoaderFunctionName = findConfigValue(loaderConfig.configArray, ... 
                                                    'functionToLoad');
    inputLoaderFunction = str2func([inputComponent '.' ...
        inputLoaderFunctionName]);

    logger('INFO', ['Calling input component ' inputComponent]);
    
    % Call function
    inputData = inputLoaderFunction(inputLoaderConfig);
end