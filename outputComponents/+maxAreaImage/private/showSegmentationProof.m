function segmentationProof = showSegmentationProof(volumeVOI, segVOI, window)
%showSegmentationProof gets a volume and a DSO and returns an image showing
%the axial, coronal and sagittal cuts of the largest cross-sections.

%Axial cross-section
tmpBiggest = sum(sum(segVOI, 1), 2);
tmpBiggest = squeeze(tmpBiggest);
[~, I] = sort(tmpBiggest, 1 ,'descend');
axialCrossSection = normalizeImageRange(volumeVOI(:,:,I(1)), window(1), window(2));
axialCrossSectionMask = segVOI(:,:,I(1));
axialCrossSectionBoundary = returnImageBoundary(axialCrossSection, axialCrossSectionMask);

%Coronal cross-section
tmpBiggest = sum(sum(segVOI, 2), 3);
tmpBiggest = squeeze(tmpBiggest);
[~, I] = sort(tmpBiggest, 1 ,'descend');
coronalCrossSection = normalizeImageRange(rot90(squeeze(volumeVOI(I(1),:,:))), window(1), window(2));
coronalCrossSectionMask = rot90(squeeze(segVOI(I(1),:,:)));
coronalCrossSectionBoundary = returnImageBoundary(coronalCrossSection, coronalCrossSectionMask);

%Sagittal cross-section
tmpBiggest = sum(sum(segVOI, 3), 1);
tmpBiggest = squeeze(tmpBiggest');
[~, I] = sort(tmpBiggest, 1 ,'descend');
sagittalCrossSection  = normalizeImageRange(rot90(squeeze(volumeVOI(:,I(1),:))), window(1), window(2));
sagittalCrossSectionMask = rot90(squeeze(segVOI(:,I(1),:)));
sagittalCrossSectionBoundary = returnImageBoundary(sagittalCrossSection, sagittalCrossSectionMask);

segmentationProof = createImageCollage({axialCrossSectionBoundary, ... 
    coronalCrossSectionBoundary, sagittalCrossSectionBoundary}, [0, 10]);

end

