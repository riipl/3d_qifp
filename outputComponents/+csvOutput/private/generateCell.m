function [ outCell ] = generateCell( input )
%GENERATECSV Summary of this function goes here
%   Detailed explanation goes here

%% Initialization
    % Copying input parameters to local variables to avoid reuse
    outputsArray = input.output;
    nCases = numel(outputsArray);
    nameList = containers.Map();

    % Statistics name and functions
    statisticFunctions = statistics();
    
%% Save one column for the UID
    row = 1;
    nameList('uid') = struct('row', row);
    row = row + 1;
    
%% Find all features names across all cases
    %Go across all cases
    for iCase = 1:nCases
        outputArray = outputsArray{iCase};
        if isempty(outputArray)
            continue;
        end
        % All components run for a particular case
        componentNames = fieldnames(outputArray);
        nComponentName = numel(componentNames);
        for iComponentName = 1:nComponentName
            % Name of a particular feature component
            componentName = componentNames{iComponentName};
            
            % If its the uid then skip it, we created that before
            if strcmp(componentName, 'uid')
                continue
            end
            
            outputComponent = outputsArray{iCase}.(componentName);
            % Allow rootnames in case we ran the same feature with
            % different paraemters
            rootNames = fieldnames(outputComponent);
            nrootNames = numel(rootNames);
            
            % If there was only one run of the component use the rootname
            if(nrootNames > 1)
                prefix = [componentName '.'];
            else
                prefix = '';
            end
            
            % Go across all outputs
            for irootNames = 1:nrootNames
                rootName = rootNames{irootNames};
                outputs =  outputComponent.(rootName);
                nOutputs = numel(outputs);
                
                for iOutput = 1:nOutputs
                    output = outputs{iOutput};
                    
                    outputName = output.name;
                    % If value is singular or a string then just add 
                    % the prefix and rootname
                    if (numel(output.value) == 1) || ischar(output.value)
                        featureName = [prefix, rootName, '.', outputName];
                        % If the key is already there then do not add it
                        if ~isKey(nameList, featureName)
                            nameList(featureName) = struct('row', row, ...
                                    'componentName', componentName);
                            row = row + 1;
                        end
                        
                    % If it has more than one value then generate names
                    % with all the possible statistics
                    elseif (numel(output.value) > 1)
                        nFunctions = numel(statisticFunctions);
                        for iFunction = 1:nFunctions
                            statFunction = statisticFunctions{iFunction};
                            statName = statFunction.name;
                            featureName = [prefix, rootName, '.', ...
                                outputName, '.', statName];
                            % If the key is already there then do not add it
                            if ~isKey(nameList, featureName)
                                nameList(featureName) = struct('row', row, ...
                                    'componentName', componentName);
                                row = row + 1;
                            end
                        end
                    end
                end
            end
        end
    end
    
%% Create the results cell:
% Each feature in a row, aech uid in a column
nFeatures = numel(nameList.keys);
results = cell(nFeatures, nCases);

    for iCase = 1:nCases
        outputArray = outputsArray{iCase};
        if isempty(outputArray)
            continue;
        end
        % All components run for a particular case
        componentNames = fieldnames(outputArray);
        nComponentName = numel(componentNames);
        for iComponentName = 1:nComponentName
            % Name of a particular feature component
            componentName = componentNames{iComponentName};
            
            % If its the uid then skip it, we created that before
            if strcmp(componentName, 'uid')
                results{nameList('uid').row, iCase} = ...
                    outputsArray{iCase}.(componentName);
                continue
            end
            
            outputComponent = outputsArray{iCase}.(componentName);
            % Allow rootnames in case we ran the same feature with
            % different paraemters
            rootNames = fieldnames(outputComponent);
            nrootNames = numel(rootNames);
            
            % If there was only one run of the component use the rootname
            if(nrootNames > 1)
                prefix = [componentName '.'];
            else
                prefix = '';
            end
            
            % Go across all outputs
            for irootNames = 1:nrootNames
                rootName = rootNames{irootNames};
                outputs =  outputComponent.(rootName);
                nOutputs = numel(outputs);
                
                for iOutput = 1:nOutputs
                    output = outputs{iOutput};
                    
                    outputName = output.name;
                    % If value is singular or a string then just add 
                    % the prefix and rootname
                    if (numel(output.value) == 1) || ischar(output.value)
                        featureName = [prefix, rootName, '.', outputName];
                        % If the key is already there then do not add it
                        results{nameList(featureName).row, iCase} = output.value;
                    % If it has more than one value then generate names
                    % with all the possible statistics
                    elseif (numel(output.value) > 1)
                        nFunctions = numel(statisticFunctions);
                        for iFunction = 1:nFunctions
                            statFunction = statisticFunctions{iFunction};
                            statName = statFunction.name;
                            statFunc = statFunction.function;
                            featureName = [prefix, rootName, '.', ...
                                outputName, '.', statName];
                            % If the key is already there then do not add it
                            if ~isnan(statFunc(output.value(:)))
                                results{nameList(featureName).row, iCase} = statFunc(output.value(:));
                            else
                                results{nameList(featureName).row, iCase} = [];
                            end
                        end
                    end
                end
            end
        end
    end
    
    %% Create label columns
    resultsLabel = cell(nFeatures, 1);
    featureNames = nameList.keys;

    for iFeature = 1:nFeatures
        featureInfo = nameList(featureNames{iFeature});
        featureName = featureNames{iFeature};
        featureRow  = featureInfo.row;
        resultsLabel{featureRow} = featureName;
    end

    %% Concatenate Labels with data
    outCell = [resultsLabel, results];
end

