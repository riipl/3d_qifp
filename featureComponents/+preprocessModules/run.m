function [ out ] = run( inputs )
%RUN Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);
    
    %% Extract intensity values
    preProcessingModules = inputs.preprocessingToRun;
    separator = inputs.separator;
    
    %% Return intensity values
    out.output = { ... 
        struct(...
        'name', 'modules',...
        'value', strjoin(preProcessingModules,separator) ...
        ) ...
    };
end

