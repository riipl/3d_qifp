function output( inputs )
%OUTPUT Summary of this function goes here
%   Detailed explanation goes here
%% Fix output so we can reuse the code (embed it in a cell structure
    inputs.output = {inputs.output};
    inputs.outputConfiguration = {inputs.outputConfiguration};

%% Calculate Results
    results = generateCell(inputs);
    
%% Check if we have to transpose
    if inputs.transpose
        results = results';
    end
    
%% Write it to disk
    outputRoot = inputs.outputRoot;
    outputFolder = inputs.outputFolder;
    outputRootName = inputs.outputRootName;
    outputUidName = inputs.processingUid;
    outputExtension = inputs.outputExtension;
    fileName = fullfile(outputRoot, outputFolder, ...
        [outputRootName '.' outputUidName '.' outputExtension]);
    
   cell2csv(fileName, results, ',', 2017);

end

