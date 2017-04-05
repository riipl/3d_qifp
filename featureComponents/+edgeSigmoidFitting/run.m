function [ out ] = run( inputs )

%RUN Summary of this function goes here
%   Detailed explanation goes here
    featureRootName = inputs.featureRootName;
    out = struct('featureRootName', featureRootName);
    out.output = findEdgeSharpness(inputs);
   
end

