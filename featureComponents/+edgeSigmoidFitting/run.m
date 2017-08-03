function [ out ] = run( inputs )

%RUN Summary of this function goes here
%   Detailed explanation goes here
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);
    try
        out.output = findEdgeSharpness(inputs);
    catch
        out.output = {};
    end
end

