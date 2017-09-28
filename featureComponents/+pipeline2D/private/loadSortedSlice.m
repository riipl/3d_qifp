function [slice_locations files tmp] = loadSortedSlice(ROOT, OVERRIDE)

% only look at one-level, no recursion
if ~exist('OVERRIDE', 'var'), OVERRIDE = 0; end
allfiles = dir([ROOT '\*.*']);
files = {};
tmp = {};
slice_locations = [];

savedSortedSliced = [ROOT 'sortedSlices.mat'];
if OVERRIDE || exist(savedSortedSliced, 'file') ~= 2
    h = waitbar(0, 'Sorting slices...');
    ctr = 0;
    seriesList = [];
    acqList = [];
    for i = 1:length(allfiles)
        waitbar(i/length(allfiles), h,  sprintf('Sorting slices... (%d/%d) [%d series, %d acqs]', i,length(allfiles), length(seriesList), length(acqList)));
        fname = allfiles(i).name;
        tmpfn = [ROOT  fname];
        if exist(tmpfn, 'file')==2 && isdicom(tmpfn)
            x = dicominfo(tmpfn);
            if ~isfield(x, 'SliceLocation')
                x.SliceLocation = -8888;
            end
            ctr = ctr + 1;
            files(ctr).name = strrep(tmpfn,'\\','\');
            if isempty(x.AcquisitionNumber), x.AcquisitionNumber = 0; end
            
            slice_locations(ctr) = x.SeriesNumber*20000 + x.AcquisitionNumber*5000 + x.SliceLocation;
            seriesList = union(seriesList, x.SeriesNumber);
            acqList = union(acqList, x.AcquisitionNumber);
            tmp{ctr} = ['[' num2str(x.SeriesNumber) ',' num2str(x.AcquisitionNumber) '] ' fname];
        end
    end
    close(h);
    save(savedSortedSliced, 'slice_locations', 'files', 'tmp');
else
    load(savedSortedSliced);
end
% sort the list
[slice_locations ind] = sort(slice_locations', 'descend');
tmp = {tmp{ind}};
files = files(ind);