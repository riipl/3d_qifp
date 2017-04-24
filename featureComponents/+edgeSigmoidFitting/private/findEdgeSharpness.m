function [ edgeSharpness ] = findEdgeSharpness(input)
%FINDEDGESHARPNESS Summary of this function goes here

%% Initialization
% Copying input parameters to local variables to avoid reuse
    intensityVOI = input.intensityVOI;
    segmentationVOI = input.segmentationVOI;
    infoVOI = input.infoVOI;
    edgeNormalLength = input.normalLength;
    numberOfNormals = input.numberOfNormals;
    numberOfSamplingPoints = input.numberOfSamplingPoints;
    internalParallelization = input.parallelization;
    
    
%% Create triangular mesh around VOI and find normals to each triangle
    
    % Find pixel spacing in millimeters in plane and between planes
    ySpacing = abs(infoVOI{1}.PixelSpacing(1));
    xSpacing = abs(infoVOI{1}.PixelSpacing(2));
    zSpacing = abs(infoVOI{1}.zResolution);

    % Create triangular mesh and reduce the number of triangles to
    % numberOfNormals
    [faces, verts] = ...
        reducepatch(isosurface(segmentationVOI, 0.5), numberOfNormals);
    
    % Scale the vertices of the triangles to reflect real-world coordinates
    % (the mass might not be isometric)
    verts = verts .* ...
        repmat([ySpacing, xSpacing, zSpacing], [size(verts,1), 1]);    
    
    % Calculate the centers and normals of each triangle
    triangRep = triangulation(faces,verts);
    normals = triangRep.faceNormal;
    centers = triangRep.incenter;
    
    % Separating Normals into 3 different variables to reduce information
    % copied during parallelization 
    normalsX = normals(:,1);
    normalsY = normals(:,2);
    normalsZ = normals(:,3);
    
%% Map original volume voxels to real-world coordinates
    
    % Scale coordinates to real-world values
    origSizes = size(segmentationVOI);
    Xm = (0:(origSizes(2)-1)).*xSpacing;
    Ym = (0:(origSizes(1)-1)).*ySpacing;
    Zm = (0:(origSizes(3)-1)).*zSpacing;
    
    % Generate combination of coordinates to later use with interpolation
    [X, Y, Z] = meshgrid(Xm, Ym, Zm);
    
%% Process each normal

    % Variable to keep track how many normals failed the fitting
    discarded = 0;
    
    % Array to store each sigmoid parameter
    params = [];
    
    % Copy the image to all CPUs to reduce communication during
    % parallelization
    
    % If internal paralellizing lets copy it to all cores to reduce 
    %  process intercommunication
    if internalParallelization 
        c = parallel.pool.Constant(intensityVOI);
    else
        c.Value = intensityVOI;
    end
    
    % TODO: Make this a function so I can use parfor or not. 
    for i = 1:size(normals,1) 
                
        % Find the angle for the normal
        [theta, rho, ~] = cart2sph(normalsX(i), normalsY(i), normalsZ(i));
        
        % Calculate initial point for intensity sampling
        [tmpx, tmpy, tmpz] = (sph2cart(theta, rho, edgeNormalLength));
        initPoints = ([tmpx tmpy tmpz] + centers(i,:));
        
        % Calculate end point for intensity sampling
        [tmpx, tmpy, tmpz] = (sph2cart(theta, rho, -edgeNormalLength));
        endPoints  = ([tmpx tmpy tmpz] + centers(i,:));
        
        % Interpolate intensity values along the normal
        try
            pixelValues = interp3(X, Y, Z, c.Value, ...
                linspace(initPoints(1),endPoints(1),numberOfSamplingPoints)',...
                linspace(initPoints(2),endPoints(2),numberOfSamplingPoints)',...
                linspace(initPoints(3),endPoints(3),numberOfSamplingPoints)',...
                'linear');
        catch
            warning('Not enough padding to interpolate normal');
            continue;
        end

        % Fit Sigmoid along the normal
        try
            tmpparams = fitSigmoid(pixelValues);
        catch
            warning(['Failed interpolating normal ' num2str(i)]);
            continue;
        end
        
        % Discard any sigmoid that failed its fitting
        % TODO: Revise this condition
        if (all(tmpparams < 0))
            discarded = discarded + 1;
            continue;
        end
        
        % Store sigmoid parameters
        params = [params; tmpparams];
    end
    
%% Output Processing
    % Eliminate the top and bottom 10% of the parameters.
    values = sort(params); 
    N = size(values, 1);
    limitedRangeParams = values( max(1,round(0.1 * N)) : round ( 0.9 * N ), : );

    % Calculate the percentage of normals that we failed fitting
    discardedPercentage = discarded ./ numberOfNormals;   
    
%% Store Values
    
    % The way we are going to output values is by creating a cell array
    % which each cell contains a structure "name" and "value". 
    
    % Store all sigmoid window parameters
    windowArray = limitedRangeParams(:,2);
    outputWindow = struct(...
        'name', 'window',...
        'value', windowArray ...
        );
    
    % Store all sigmoid scale parameters
    scaleArray = limitedRangeParams(:,3);
    outputScale = struct(...
        'name', 'scale',...
        'value', scaleArray ...
        );
    
    % Store the number of edges discarded.
    outputDiscarded = struct(...
        'name', 'discarded',...
        'value', discardedPercentage ...
    );

    % Store all outputs in the outputmebmer of the structure
    edgeSharpness = {outputWindow,outputScale, outputDiscarded};
end

