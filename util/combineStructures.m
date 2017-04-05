function [combinedStructure] = combineStructures( structure1, structure2 )
%COMBINESTRUCTURES Summary of this function goes here
%   Detailed explanation goes here
    if isempty(structure2)
        structure2Names = [];
    else
        structure2Names = fieldnames(structure2);
    end
    combinedStructure = structure1;
    for i = 1:size(structure2Names,1)
        combinedStructure.(structure2Names{i}) = ...
            structure2.(structure2Names{i});
    end
end

