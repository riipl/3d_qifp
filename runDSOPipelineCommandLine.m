 function runDSOPipelineCommandLine( dsoDirPath,...
    outputDirPath, configFilePath, qifpFormat)
%RUNPIPELINECOMMANDLINE Summary of this function goes here
%   Detailed explanation goes here
addpath('util');
logger('INFO', 'Starting to run the DSO Pipeline from the Command Line');

if (nargin < 3)
    configFilePath = 'config.ini';
    logger('INFO', ['Using ' configFilePath ' as config file']);
end


if (nargin < 4)
    qifpFormat = false;
    logger('INFO', ['Using INI configuration format']);
end

dicomSeriesDirPath = dsoDirPath;

%% Load configuration
    if ~qifpFormat
        config = ini2struct(configFilePath);
    else
        config = qifp2struct(configFilePath);
    end
    
    % Change configuration to force DSO loading
    % and overwrite paths for locations of DSO and Series
    if ~isfield(config, 'input')
        config.input = struct();
    end
    config.input.component = 'dsoLoader';
    config.input.inputRoot = '';
   
    if ~isfield(config, 'dsoLoader')
        config.dsoLoader = struct();
    end
    
    config.dsoLoader.dicomFolder=dicomSeriesDirPath;
    config.dsoLoader.dsoFolder=dsoDirPath;
    logger('INFO', ['Setting Dicom Series Folder: ' dicomSeriesDirPath]);
    logger('INFO', ['Setting DSO Folder: ' dicomSeriesDirPath]);

    % Change output
    if ~isfield(config, 'output')
        config.output = struct();
    end

    config.output.outputRoot = outputDirPath;

    % Set QIFE version for the run.
    qifeVersion;
    config.versionQIFE = struct();
    config.versionQIFE.gitBranch = gitBranch;
    config.versionQIFE.gitHash = gitHash;
    config.versionQIFE.dockerTag = dockerTag;
    config.versionQIFE.buildDate = buildDate;
    config.versionQIFE.runDate = runDate;
    config.featureComputation.components = ...
        [config.featureComputation.components ',versionQIFE'];

    runPipeline(config)

end

