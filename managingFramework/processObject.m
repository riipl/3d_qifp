function [featureCache, featureConfig] = processObject(globalState, ...
    globalFeatureConfig, inputState, globalPreprocessingConfig, ...
    globalOutputState, uidToProcess)
%PROCESSOBJECT Summary of this function goes here
%   Detailed explanation goes here
    logger('INFO', ['Processing object with UID ' uidToProcess]);

    localState = globalState;
    localState.processingUid = uidToProcess;
    localInputState = combineStructures(localState, inputState);
    %% Input Stage 
    logger('INFO', ['Starting input stage']);
    
    try
        inputData = inputStageLoad(localInputState, globalState.inputComponentName);
    catch
        logger('WARN', ['Could not load object with UID ' uidToProcess]);
        featureCache = {};
        featureConfig = {};
        return;
    end
    
    localState = combineStructures(localState, inputData);

    logger('INFO', ['Finishing input stage']);

    %% Pre-processing Stage
    logger('INFO', ['Starting Preprocessing stage']);

    localPreprocessingState = localState;
    
    for iPreprocessing = 1:globalState.nPreprocessing
        preprocessingComponent = globalState.preprocessingToRun{iPreprocessing};
        
        % Load Configuration 
        localPreprocessingConfigFunction = str2func([preprocessingComponent '.configuration']);
        localPreprocessingConfig = localPreprocessingConfigFunction();
        
        % Prepare input initialization parameters
        preparedPreprocessingConfig = ...
            prepareInput(localPreprocessingConfig.inputArray, ...
                        localPreprocessingState, globalPreprocessingConfig.(preprocessingComponent));
        
        % Check if there's a final function to call
        preprocessingName = findConfigValue(localPreprocessingConfig.configArray, ...
            'functionToRun');
        if isnan(preprocessingName)
            continue
        end
        logger('INFO', ['Calling Preprocessing component ' preprocessingComponent]);
        
        preprocessingFunction = str2func([preprocessingComponent '.' preprocessingName]);
        
        % Call the preprocessing function
        preprocessingOutput = preprocessingFunction(preparedPreprocessingConfig);        
        
        % Replace engine data with preprocessing output
        nPreprocessingOutputs = numel(preprocessingOutput);
        for iPreprocessingOutput = 1:nPreprocessingOutputs 
            localPreprocessingOutput = preprocessingOutput{iPreprocessingOutput};
            if (size(localPreprocessingOutput,1) > 1)
                nLocalPreprocessingOutput.name = localPreprocessingOutput(1).name;
                nLocalPreprocessingOutput.value = {localPreprocessingOutput.value};
                localPreprocessingOutput = nLocalPreprocessingOutput;
            end
            localPreprocessingState.(localPreprocessingOutput.name) = ...
                localPreprocessingOutput.value;
            localState.(localPreprocessingOutput.name) = ...
                localPreprocessingOutput.value;
        end
    end

    logger('INFO', ['Finishing Preprocessing stage']);

    %% Feature Computation Stage 
    logger('INFO', ['Starting Feature Computation stage']);
    % Initialize storage variables
    featureComputationOutput = struct();
    featureComputationConfigurations = struct();
    featureComponentName = cell(globalState.nFeatures,1);
    featureRootName = cell(globalState.nFeatures,1);
    featureResults = cell(globalState.nFeatures,1);
    featureConfigurations = cell(globalState.nFeatures,1);
    
    % Compute each feature in parallel 
    if strcmp(globalState.parallelMode, 'feature')
        logger('INFO', ['Running Feature Computation in Parallel Mode']);
        p = gcp();
        fResults = parallel.FevalFuture;
        for iFeature = 1:globalState.nFeatures
            featureComponent = globalState.featuresToCompute{iFeature};
            fResults(iFeature) = parfeval(p, @featureStageCompute, 3, ...
                globalFeatureConfig, localState, featureComponent);
            logger('INFO', ['Queued Feature ' featureComponent ' in position ' num2str(iFeature)]);

        end
        for iFeature = 1:globalState.nFeatures
            [cFeature,localFeatureResults, localFeatureComponentName, ...
                localFeatureRootName, localFeatureConfiguration] = ...
                fetchNext(fResults);
            logger('INFO', ['Received values from feature in queue position ' num2str(iFeature)]);
            java.lang.System.gc()
            featureResults{cFeature} = localFeatureResults;
            featureComponentName{cFeature} = localFeatureComponentName;
            featureRootName{cFeature} = localFeatureRootName;
            featureConfigurations{cFeature} = localFeatureConfiguration;
        end
    % Compute each feature serially   
    else
        for iFeature = 1:globalState.nFeatures
            featureComponent = globalState.featuresToCompute{iFeature};

            [localFeatureResults, localFeatureComponentName, ...
                localFeatureRootName, localFeatureConfiguration] = ...
                featureStageCompute(globalFeatureConfig, ...
                localState, featureComponent);
            featureResults{iFeature} = localFeatureResults;
            featureComponentName{iFeature} = localFeatureComponentName;
            featureRootName{iFeature} = localFeatureRootName;
            featureConfigurations{iFeature} = localFeatureConfiguration;
        end
    end
    
    % Compile results into a structure
    for iFeature = 1:globalState.nFeatures
        featureComputationOutput.(featureComponentName{iFeature}). ...
            (featureRootName{iFeature}) = featureResults{iFeature};
        featureComputationConfigurations.(featureComponentName{iFeature}). ...
            (featureRootName{iFeature}) = featureConfigurations{iFeature};
    end
    
    featureComputationOutput.uid = localState.processingUid;
    featureCache = featureComputationOutput;
    featureConfig = featureComputationConfigurations;
    localState.output = featureComputationOutput;
    localState.outputConfiguration = featureComputationConfigurations;
    
    logger('INFO', ['Finishing Feature Computation stage']);

    %% Output Stage
    logger('INFO', ['Starting Output stage']);

    % Run each output component that has each turned on
    localOutputState = localState;

    for iOutput = 1:globalState.nOutputs
        outputComponent = globalState.outputToRun{iOutput};
        
        % Load Configuration 
        localOutputConfigFunction = str2func([outputComponent '.configuration']);
        localOutputConfig = localOutputConfigFunction();
        
        % Prepare input initialization parameters
        preparedOutputConfig = ...
            prepareInput(localOutputConfig.inputArray, ...
                        localOutputState, globalOutputState.(outputComponent));
        
        % Check if we should run this algorithm at the end
        if ~isfield(preparedOutputConfig, 'each') || ~preparedOutputConfig.each
            continue;
        end
        
        % Check if there's a final function to call
        outputFunctionName = findConfigValue(localOutputConfig.configArray, ...
            'functionToEachOutput');
        if isnan(outputFunctionName)
            continue
        end
        logger('INFO', ['Calling output component ' outputComponent]);
        
        outputFunction = str2func([outputComponent '.' outputFunctionName]);
        
        % Call the output function
        try
            outputFunction(preparedOutputConfig);
        catch
            logger('ERROR', ['Was not able to run output component: ' outputComponent]);
        end
    end    
    logger('INFO', ['Finishing Output stage']);
    logger('INFO', ['Finished Processing the Object with UID: ' uidToProcess]);
end

