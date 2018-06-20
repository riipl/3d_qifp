function output( inputs )
%OUTPUT Summary of this function goes here
%   Detailed explanation goes here

    %% Initialization 
    segVOI = inputs.segmentationVOI;
    segInfo = inputs.segmentationInfo;

    
    %% Prepare segmentation for output
    origY = segInfo.segmentationOrigin(1);
    origX = segInfo.segmentationOrigin(2);
    origZ = segInfo.segmentationOrigin(3);
    rows = segInfo.Rows;
    columns = segInfo.Columns;
    tmpVOI = false(rows,columns,size(segVOI,3));
    tmpVOI(origY:(origY+size(segVOI,1)-1), ...
    origX:(origX+size(segVOI,2)-1), ...
    origZ:(origZ+size(segVOI,3)-1)) = segVOI;
    segVOIDimensional(:,:,1,:) =  tmpVOI;
    %% Prepare information for output
    % Add information where the DSO was created
    manufacturerModelName = [];
    separator  = '';
    if inputs.includeOriginalManufacturerModelName
        manufacturerModelName = segInfo.ManufacturerModelName;
        separator = ' ';
    end
    
    if numel(inputs.manufacturerModelName)
        segInfo.ManufacturerModelName = [manufacturerModelName ...
            separator inputs.manufacturerModelName];
    end
    
    % Add Information about the Series description
    seriesDescription = [];
    separator  = '';
    if inputs.includeOriginalSeriesDescription
        seriesDescription = segInfo.SeriesDescription;
        separator = ' ';
    end
    
    if numel(inputs.seriesDescription)
        seriesDescription = [seriesDescription separator ...
            inputs.seriesDescription];
    end
    
    if numel(inputs.addDerivedInSeriesDescription)
        seriesDescription = [seriesDescription separator ...
            inputs.derivedFromPrefix ' '...
            inputs.processingUid];
    end
    segInfo.SeriesDescription = seriesDescription;
    
    %% Save the image to disk
    outputRoot = inputs.outputRoot;
    outputFolder = inputs.outputFolder;
    outputRootName = inputs.outputRootName;
    outputUidName = inputs.processingUid;
    outputExtension = inputs.outputExtension;
    c = fullfile(outputRoot, outputFolder, ...
        [outputRootName '.' outputUidName '.' outputExtension]);

    dicomwrite(uint8(segVOIDimensional), c, segInfo, 'CreateMode', 'copy')
end

