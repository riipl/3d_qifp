function [internalState, loaderGlobalConfig, loaderInitializerConfig] = ...
    inputStageInitialization(internalState, inputComponent)

    logger('INFO', ['Initializing Input Stage']);
    logger('INFO', ['Input Component: ' inputComponent]);

    % Load Configuration 
    loaderConfigFunction = str2func([inputComponent '.configuration']);
    loaderConfig = loaderConfigFunction();

    % Prepare input initialization parameters
    loaderInitializerConfig = ...
        prepareInput(loaderConfig.inputInitializeArray, ...
                        internalState, internalState);

    loaderInitializerFunctionName = findConfigValue(loaderConfig.configArray, ... 
                                                    'functionToInitialize');
    
    % Function to call for initialization
    loaderInitializerFunction = str2func([inputComponent '.' ...
                                               loaderInitializerFunctionName]);

    % Initialization Output
    inputInitializeOutput = loaderInitializerFunction(loaderInitializerConfig);

    internalState = combineStructures(internalState, ... 
        inputInitializeOutput);
    
    % Return Initializator global config
    loaderGlobalConfig = loaderConfig.configArray;
    logger('INFO', ['Input Stage Initialization Complete']);
end