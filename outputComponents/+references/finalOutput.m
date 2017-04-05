function finalOutput( inputs )
%FINALRUN Summary of this function goes here
%   Detailed explanation goes here
    
%% Extract all references and rewrite them as bibtex entries
    allConfig = inputs.allConfig;
    referenceText = generateReferencesFromCell(allConfig);
    
%% Write them to disk
    outputRoot = inputs.outputRoot;
    outputFolder = inputs.outputFolder;
    outputRootName = inputs.outputRootName;
    outputFinalName = inputs.outputFinalName;
    outputExtension = inputs.outputExtension;
    fileName = fullfile(outputRoot, outputFolder, ...
        [outputRootName '.' outputFinalName '.' outputExtension]);
    
   fileID = fopen(fileName,'w');
   fprintf(fileID,'%s\n',referenceText{:});
   fclose(fileID);

end