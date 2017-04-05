function [ bibtex ] = generateBibtexFromReference(name, referenceEntry)
%GENERATEBIB Summary of this function goes here
%   Detailed explanation goes here

    % Assign variables for easy access later.
    entry = referenceEntry;
    entryName = name;
    entryType = entry.type;
    entryFields = entry.fields;
    entryFieldNames = fieldnames(entry.fields);
    nEntryField = numel(entryFieldNames);
    
    % Replace map
    originalChars = {'{', '"', '$'};
    destChars = {'\{', '\"', '\$'};
    
    % Reserve the space for the bibtex entry and input the first and last
    % row
    referenceRows = cell(nEntryField+2,1);
    headerRow = ['@' entryType '{' entryName ','];
    referenceRows{1} = headerRow;
    referenceRows{end} = '}';
    
    % Go line by line adding it to the bibtex entry
    for iEntryField = 1:nEntryField
        localFieldName = entryFieldNames{iEntryField};
        localFieldValue = entryFields.(localFieldName);
        for iReplace = 1:numel(originalChars)
            localFieldValue = strrep(localFieldValue, ...
                originalChars{iReplace}, destChars{iReplace});
        end
        line = [localFieldName ' = {' localFieldValue '},'];
        referenceRows{iEntryField + 1} =  line;
    end

    % Assign Output
    bibtex = referenceRows;

end

