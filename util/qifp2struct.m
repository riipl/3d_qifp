function configStruct = qifpFormat(configFile, separator)
%QIFPFORMAT Summary of this function goes here
%   Detailed explanation goes here

%% Load configuration file
    tmpStruct = ini2struct(configFile);
    
if nargin < 2 
    separator = '0x7C';
end

%% Convert them into titles and members
    titles = fieldnames(tmpStruct);
    nTitles = numel(titles);
    configStruct = struct();
    for iTitle = 1:nTitles
        title = titles{iTitle};
        parts = strsplit(title, separator);
        nParts = numel(parts);
        if nParts > 1
            if strcmp(parts{1}, 'global')
                parts{1} = 'xGlobal';
            end
            if ~isfield(configStruct, parts{1})
                % For compatibility with the ini2struct.
                configStruct.(parts{1}) = struct();
            end
            configStruct.(parts{1}).(parts{2}) = tmpStruct.(title);
        else
            configStruct.(parts{1}) = tmpStruct.(title);
        end
    end
end

