function [ referenceTextOutput ] = generateReferencesFromCell( allConfig )
%GENERATEREFERENCESFROMCELL Summary of this function goes here
%   Detailed explanation goes here

fieldsAllConfig = fieldnames(allConfig);
    nFields = numel(fieldsAllConfig);
    referenceTextOutput = {};
    
    % Go component by component
    for iField = 1:nFields
        componentName = fieldsAllConfig{iField};
        componentConfig = allConfig.(componentName);
        localReference = findConfigValue(componentConfig, 'reference');
        
        % If component doesn't have a reference then skip the component
        if (numel(localReference) == 0) || ...
                (~iscell(localReference) && ~isstruct(localReference) &&...
                isnan(localReference)) 
            continue
        end
        
        % Go through all references and compile their text
        nReferences = numel(localReference);
        for iReference = 1:nReferences
            % Create a bibtex entry for a particular reference
            referenceName = [componentName  num2str(iReference)];
            
            % If there's only one reference then its not a cell.
            if nReferences > 1 
                reference = localReference{iReference};
            else
                reference = localReference;
            end
            
            % Create text and append it to the cell string
            referenceText = ...
                generateBibtexFromReference(referenceName, reference);
            referenceTextOutput = [referenceTextOutput; referenceText];
        end
    end
end

