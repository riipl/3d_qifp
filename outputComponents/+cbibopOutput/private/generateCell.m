function [ outCell ] = generateCell( input )
%GENERATECSV Summary of this function goes here
%   Detailed explanation goes here

%% Initialization
    % Copying input parameters to local variables to avoid reuse
    outputsArray = input.output;
    outputsConfigurationArray = input.outputConfiguration;
    
    nCases = numel(outputsArray);
    nameList = containers.Map();

    % Statistics name and functions
    statisticFunctions = statistics();
    
%% Save one row for the UID
    row = 1;
    if input.showUid
        nameList('uid') = struct('row', row);
        row = row + 1;
    end
    
%% Find all features names across all cases
    %Go across all cases
    for iCase = 1:nCases
        outputArray = outputsArray{iCase};
        outputConfigurationArray = outputsConfigurationArray{iCase};
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
            
            componentConfiguration = ...
                outputConfigurationArray.(componentNames{iComponentName});
    
            
            outputComponent = outputsArray{iCase}.(componentName);
            % Allow rootnames in case we ran the same feature with
            % different parameters
            rootNames = fieldnames(outputComponent);
            nrootNames = numel(rootNames);
            
            % If there was only one run of the component use the rootname
            if(nrootNames > 1)
                prefix = [componentName '.'];
            else
                prefix = '';
            end
            
            rootPrefix = prefix;
            % Go across all outputs
            for irootNames = 1:nrootNames
                rootName = rootNames{irootNames};
                outputs =  outputComponent.(rootName);
                outputConfiguration =  componentConfiguration.(rootName);
                
                % Add settings as features in the CSV 
                if input.featureConfiguration
                    settingNames = fieldnames(outputConfiguration);
                    nSettings = numel(settingNames);
                    settingStruct = cell(1, nSettings);
                    for iSetting = 1:nSettings
                        settingStruct{iSetting} = struct( ...
                            'name', [input.featureConfigurationPrefix ... 
                            input.featureConfigurationSeparator settingNames{iSetting}], ...
                            'value', outputConfiguration.(settingNames{iSetting}) ...
                        );
                    end
                    outputs = [settingStruct, outputs];
                end
            
                nOutputs = numel(outputs);
                % Check if we are prepending Category Names, if so append 
                % category name using defined separator
                categoryName = '';
                if input.categoryNames
                    if isfield(outputConfiguration, 'category')
                        categoryName = outputConfiguration.category;
                    else
                        categoryName = input.undefinedCategory;
                    end
                end
                
                
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
                                    'componentName', componentName, ...
                                    'categoryName', categoryName);
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
                                    'componentName', componentName, ...
                                    'categoryName', categoryName);
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
        outputConfigurationArray = outputsConfigurationArray{iCase};
        
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
                if input.showUid
                    results{nameList('uid').row, iCase} = ...
                        outputsArray{iCase}.(componentName);
                end
                continue
            end
                       
            componentConfiguration = ...
                outputConfigurationArray.(componentNames{iComponentName});
                       
            
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
            
            rootPrefix = prefix;
            % Go across all outputs
            for irootNames = 1:nrootNames
                rootName = rootNames{irootNames};
                outputs =  outputComponent.(rootName);
                outputConfiguration =  componentConfiguration.(rootName);
                
                % Add settings as features in the CSV 
                if input.featureConfiguration
                    settingNames = fieldnames(outputConfiguration);
                    nSettings = numel(settingNames);
                    settingStruct = cell(1, nSettings);
                    for iSetting = 1:nSettings
                        settingStruct{iSetting} = struct( ...
                            'name', [input.featureConfigurationPrefix ... 
                            input.featureConfigurationSeparator settingNames{iSetting}], ...
                            'value', outputConfiguration.(settingNames{iSetting}) ...
                        );
                    end
                    outputs = [settingStruct, outputs];
                end
                
                nOutputs = numel(outputs);
                % Check if we are prepending Category Names, if so append 
                % category name using defined separator
                if input.categoryNames
                    if isfield(outputConfiguration, 'category')
                        categoryName = outputConfiguration.category;
                    else
                        categoryName = input.undefinedCategory;
                    end
                end
                
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
    
    %% Create category column
    if input.categoryNames
        categoryLabel = cell(nFeatures, 1);
        featureNames = nameList.keys;

        for iFeature = 1:nFeatures
            featureInfo = nameList(featureNames{iFeature});
            featureRow  = featureInfo.row;
            if isfield(featureInfo, 'categoryName')
                featureCategory  = featureInfo.categoryName;
            else
                featureCategory  = '';
            end
            categoryLabel{featureRow} = featureCategory;
        end    
    end

    %% Concatenate Labels with data
    outCell = [resultsLabel, results];
    
    if input.categoryNames
        outCell = [categoryLabel, outCell];
    end
    
    if (input.sort)
        uidRow = outCell(1,:);
        restSorted = sortrows(outCell(2:end,:),1);
        sortedOutCell = vertcat(uidRow, restSorted);
        outCell = sortedOutCell;
    end
    
end

