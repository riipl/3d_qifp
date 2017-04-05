function finalOutput( inputs )
%FINALRUN Summary of this function goes here
%   Detailed explanation goes here
    
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
    outputFinalName = inputs.outputFinalName;
    outputExtension = inputs.outputExtension;
    fileName = fullfile(outputRoot, outputFolder, ...
        [outputRootName '.' outputFinalName '.' outputExtension]);
    
   cell2csv(fileName, results, ',', 2017);
end

