function runPipeline(config)
%% Initialize Managing Framework
    %% Add Paths
    addpath('util');
    addpath('managingFramework');
    addpath('inputComponents');
    addpath('preprocessingComponents');
    addpath('featureComponents');
    addpath('outputComponents');

    %% Global Stage
    globalState = config.xGlobal;
    globalState.allConfig = struct();
    
    %% Input Stage initialization
    % Create the internal input stage state
    globalState.inputComponentName = config.input.component;
    
    inputState = combineStructures(globalState, config.input);
    inputState = combineStructures(inputState, ...
        config.(globalState.inputComponentName));
    [inputState, inputConfig, ~] = ...
        inputStageInitialization(inputState, globalState.inputComponentName);
    
    % Load global input component configuration
    globalState.allConfig.(globalState.inputComponentName) = inputConfig;
    
    % Save to a separate variable to save keystrokes:
    uidToProcess = inputState.uidToProcess;
    
    % Check if we are supposed to resume a run
    if (isfield(globalState, 'resume'))
        if (globalState.resume == 1)
            % Name of the resume file
            resumeFileName = fullfile(config.output.outputRoot, '.resume');
            % Check if the file exists if not create it
            if(exist(resumeFileName, 'file') == 2)
                % Load the file, and then remove all uidAlreadyProcessed.
                logger('INFO', 'Resume file found');
                logger('WARNING', ...
                    'Final output components might give incomplete results');
                resumeStruct = load(resumeFileName, '-mat', 'processedUid');
                processedUid = resumeStruct.processedUid;
                logger('INFO', ['Objects already processed ' ...
                    num2str(numel(processedUid))]);
                uidToProcess = setdiff(uidToProcess, processedUid, ...
                    'stable');
            else
                processedUid = {};
            end
        end
    end

    % Number of cases to be processed
    numUid = numel(uidToProcess);
    logger('INFO', ['Objects to process: ' num2str(numUid)]);
    
    %% PreProcessing Stage Initialization
    logger('INFO', ['Initializing Preprocessing Stage']);
    
    % Get the name of the modules that will be executed:
    if (isfield(config, 'preprocessing'))
        preprocessingToRunStr = config.preprocessing.components;
        preprocessingToRun = strtrim(strsplit(preprocessingToRunStr, ','));
        globalState.preprocessingToRun =  preprocessingToRun;
    else
        preprocessingToRunStr = '';
        config.preprocessing = struct();
        preprocessingToRun = {};
        globalState.preprocessingToRun =  preprocessingToRun;
    end
    logger('INFO', ['Preprocessing Components: ' preprocessingToRunStr]);
    
    
    % Extract the configuration file settings from each module
    globalPreprocessingConfig = struct();
    globalState.nPreprocessing = numel(preprocessingToRun);
    preprocessingState = combineStructures(globalState, config.preprocessing);
    for iPreprocessing = 1:globalState.nPreprocessing
        logger('INFO', ['Initializing Feature Component: ' ...
            preprocessingToRun{iPreprocessing}]);
        if isfield(config, preprocessingToRun{iPreprocessing})
            globalPreprocessingConfig.(preprocessingToRun{iPreprocessing}) = ...
                combineStructures(preprocessingState, ...
                config.(preprocessingToRun{iPreprocessing}));
        else
            globalPreprocessingConfig.(preprocessingToRun{iPreprocessing}) = ...
                preprocessingState;
        end
        
        % Load global feature configuration
        preprocessConfigFunction = str2func([preprocessingToRun{iPreprocessing} '.configuration']);
        preprocessConfig = preprocessConfigFunction();
        globalState.allConfig.(preprocessingToRun{iPreprocessing}) = ...
            preprocessConfig.configArray;
    end    
    
    logger('INFO', ...
        ['Preprocessing Stage Initialization Complete']);

    
    %% Feature Computation Stage Initialization
    logger('INFO', ['Initializing Feature Compute Stage']);
    
    % Get the name of the modules that will be executed:
    featuresToComputeStr = config.featureComputation.components;
    logger('INFO', ['Feature Components: ' featuresToComputeStr]);
    
    featuresToCompute = strtrim(strsplit(featuresToComputeStr, ','));
    globalState.featuresToCompute = featuresToCompute;
    
    % Extract the configuration file settings from each module
    globalFeatureConfig = struct();
    globalState.nFeatures = numel(featuresToCompute);
    featureState = combineStructures(globalState, config.featureComputation);
    for iFeature = 1:globalState.nFeatures
        logger('INFO', ['Initializing Feature Component: ' ...
            featuresToCompute{iFeature}]);
        if isfield(config, featuresToCompute{iFeature})
            globalFeatureConfig.(featuresToCompute{iFeature}) = ...
                combineStructures(featureState, ...
                config.(featuresToCompute{iFeature}));
        else
            globalFeatureConfig.(featuresToCompute{iFeature}) = ...
                featureState;
        end
        
        % Load global feature configuration
        featureConfigFunction = str2func([featuresToCompute{iFeature} '.configuration']);
        featureConfig = featureConfigFunction();
        globalState.allConfig.(featuresToCompute{iFeature}) = ...
            featureConfig.configArray;
    end
    
    % Store all feature results for output
    featureCache = cell(numUid,1);
    featureConfig = cell(numUid,1);
    
    logger('INFO', ['Feature Computation Stage Initialization Complete']);


    %% Output Initialization
    logger('INFO', ['Initializing Output Stage']);
    % Get the name of the modules that will be executed:
    outputsToRunStr = config.output.components;
    logger('INFO', ['Output components: ' outputsToRunStr]);
    
    outputsToRun = strtrim(strsplit(outputsToRunStr, ','));
    globalState.outputToRun = outputsToRun;
    
    % Extract the configuration file settings from each module
    globalState.nOutputs = numel(outputsToRun);
    outputState = combineStructures(globalState, config.output);
    for iOutput = 1:globalState.nOutputs
        logger('INFO', ['Initializing Output Component: ' ...
            outputsToRun{iOutput}]);
        if isfield(config, outputsToRun{iOutput})
            globalOutputState.(outputsToRun{iOutput}) = ...
                combineStructures(outputState, ...
                config.(outputsToRun{iOutput}));
        else
            globalOutputState.(outputsToRun{iOutput}) = ...
                outputState;
        end
        
        % Load global outputs configuration
        outputConfigFunction = str2func([outputsToRun{iOutput} ...
            '.configuration']);
        outputConfig = outputConfigFunction();
        globalState.allConfig.(outputsToRun{iOutput}) = ...
            outputConfig.configArray;
    end
    
    logger('INFO', ['Output Stage Initialization Complete']);

    
%% Prepare Paralellization 


%% Managing Framework Processing
    sequentialUidList = 1:numUid;
    % Object Parallel
    if strcmp(globalState.parallelMode, 'object')
        sequentialUidList = [];
        logger('INFO', ['Starting the run in Object Parallel Mode']);
        delete(gcp('nocreate'))
        parpool('SpmdEnabled',false);
        p = gcp();
        oResults = parallel.FevalFuture;
        for iUid = 1:numUid
            localUid = uidToProcess{iUid};
            logger('INFO', ['Queued UID ' localUid ' in position ' num2str(iUid)]);
            oResults(iUid) = parfeval(p, @processObject, 2, ...
                globalState, globalFeatureConfig, inputState, ...
                globalPreprocessingConfig, globalOutputState, localUid);
        end
        for iUid = 1:numUid
            try
                [oUid,localFeatureCache, localFeatureConfig] = fetchNext(oResults);
                disp(oResults(oUid).Diary);
                logger('INFO', ['Received values from queue position ' num2str(oUid)]);
                featureCache{oUid} = localFeatureCache;
                featureConfig{oUid} = localFeatureConfig;
                %Add the processed case into processedUIDs and save it to the
                %output directory
                if (isfield(globalState, 'resume'))
                    if (globalState.resume == 1)
                        processedUid{end+1} = uidToProcess{oUid};
                        save(resumeFileName, '-mat', 'processedUid')
                    end
                end
            catch
                % Error processing this object. Lets schedule it so it is
                % run sequentially
                logger('WARNING', ['Could not process: ', num2str(oUid), ' in parallel adding it to sequential']);
                sequentialUidList = [sequentialUidList oUid];
                disp(oResults(oUid).Diary);    
            end
        end
    end
    
    % Sequential
    if numel(sequentialUidList) > 0
        logger('INFO', ['Starting the run in Sequential Mode']);
        for iUid = 1:numUid
            localUid = uidToProcess{iUid};
            [featureCache{iUid}, featureConfig{iUid}] = processObject(globalState, globalFeatureConfig, ...
                inputState, globalPreprocessingConfig,  globalOutputState, localUid);
            if (isfield(globalState, 'resume'))
                if (globalState.resume == 1)
                    processedUid{end+1} = localUid;
                    save(resumeFileName, '-mat', 'processedUid')
                end
            end
        end
    end
%% Final Output Stage
    logger('INFO', ['Starting the final output stage']);
    % Run each output component that has final turned on
    finalOutputState = globalState;
    finalOutputState.output = featureCache;
    finalOutputState.outputConfiguration = featureConfig;
    
    for iOutput = 1:globalState.nOutputs
        outputComponent = globalState.outputToRun{iOutput};
        
        % Load Configuration 
        localOutputConfigFunction = str2func([outputComponent '.configuration']);
        localOutputConfig = localOutputConfigFunction();
        
        % Check if there's a final function to call
        outputFunctionName = findConfigValue(localOutputConfig.configArray, ...
            'functionToFinalOutput');
        if isnan(outputFunctionName)
            continue
        end
        
        % Prepare input initialization parameters
        preparedOutputConfig = ...
            prepareInput(localOutputConfig.inputArray, ...
                        finalOutputState, globalOutputState.(outputComponent));
        
        % Check if we should run this algorithm at the end
        if ~isfield(preparedOutputConfig, 'final') || ~preparedOutputConfig.final
            continue;
        end
        
        logger('INFO', ['Running Output Component: ' outputComponent]);
        
        outputFunction = str2func([outputComponent '.' outputFunctionName]);
        
        % Call the output function
        outputFunction(preparedOutputConfig);
    end
    
    % We finished, lets delete the resume file.
    if (isfield(globalState, 'resume'))
        if (globalState.resume == 1)
            delete(resumeFileName);
        end
    end
    
    logger('INFO', ['Finishing the final output stage']);
    logger('INFO', ['Quantitative Image Feature Engine complete']);
end
