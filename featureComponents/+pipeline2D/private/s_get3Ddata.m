function [I3 x3 Ires seq] = s_get3Ddata(DCM_FILENAME, LESION_ROI, NUM_3D, OSD, EXPORT, DCM_FOLDER, EXPORT_FOLDER)

% DICOM FILE


% get 3D volume centered at the lesion level
% see b_get_all_3d.m

if ~exist('NUM_3D','var'), NUM_3D = 5; end;
if ~exist('OSD','var'), OSD = 0; end;
if ~exist('EXPORT','var'), EXPORT = 0; end;
if ~exist('DCM_FOLDER','var'), DCM_FOLDER = ''; end;
if ~exist('EXPORT_FOLDER','var'), EXPORT_FOLDER = ''; end;

SHOW_ALL_SLICES = 0;
if OSD || nargout>2, SHOW_ALL_SLICES = 1; end

if NUM_3D > 15, OSD = 0; SHOW_ALL_SLICES = 0; end

c_low = 840; c_high = 1240;
%     case 'lung'
c_low = -426; c_high = 1074;

MARGIN = 75;
IM_SPAN = -MARGIN:MARGIN;


% if EXPORT
%     EXPORT_FOLDER = ['d:\Sandy\segmentation\_3d_slices\c' num2str(CASE) 't' num2str(TIME)];
%     if exist(EXPORT_FOLDER, 'dir') ~= 7
%         mkdir(EXPORT_FOLDER);
%     else
%         dos(['del /q ' EXPORT_FOLDER '\*']);
%     end
% end

if NUM_3D == 1 && EXPORT
    dos(['copy /y "' lymphnode.DCMFullPath '" ' EXPORT_FOLDER '\ > tmp_copy_output.txt']);
    return
end

fname = DCM_FILENAME;

tmp = find(DCM_FILENAME == '\');
ROOT = DCM_FILENAME(1:tmp(end));

[slice_locations files] = loadSortedSlice(ROOT);
% files are sorted in the order of slice_locations
for j = 1:length(files)
    if ~isempty(findstr(fname, files(j).name))
        thisSliceIndex = j;
    end
end

% take the cropped 3D volume
roi = LESION_ROI;
[roi.x roi.y] = s_spline_interpolate(roi.x, roi.y);
cx = round( (max(roi.x(:))+min(roi.x(:))) /2 );
cy = round( (max(roi.y(:))+min(roi.y(:))) /2 );
I3 = zeros(length(IM_SPAN));
if SHOW_ALL_SLICES, Ires = []; end


slice_range = thisSliceIndex-round(NUM_3D/2)+ [1:NUM_3D];
if min(slice_range)<1
    offset = -min(slice_range) + 1;
    slice_range = slice_range + offset;
    fprintf('- ROI is in slice %d, instead of %d :(\n', round(NUM_3D/2)-offset, round(NUM_3D/2) );
end

tmp = dicominfo(DCM_FILENAME);
SN = tmp.SeriesNumber;
AN = tmp.AcquisitionNumber;
ctr = 0;

actual_slice_number = [];
for j = 1:NUM_3D
    I = double(dicomread( files(slice_range(j)).name ));
    tmp = dicominfo( files(slice_range(j)).name );
    if (SN==tmp.SeriesNumber && (isempty(AN) || AN == tmp.AcquisitionNumber))
        ctr = ctr + 1;
        %     files(slice_range(j)).name
        I3(:,:,j) = I(round(cy)+IM_SPAN, round(cx)+IM_SPAN) + (tmp.RescaleIntercept + 1024);
        actual_slice_number = [actual_slice_number slice_range(j)];
        
        if SHOW_ALL_SLICES, Ires = [Ires I3(:,:,j)]; end
        if EXPORT
            new_fileName = strrep(files(slice_range(j)).name, DCM_FOLDER, EXPORT_FOLDER);
            tmp = find(new_fileName=='\');
            tmp = new_fileName(1 : tmp(end)-1);
            tmp(tmp=='/') = '\';
            if ~exist (tmp, 'dir')
                dos(['md "' tmp '"']);
            end
            dos(['copy /y "' files(slice_range(j)).name '" "' new_fileName '" > tmp_copy_output.txt']);
        end
    end
end
tmp = find(actual_slice_number==thisSliceIndex);
seq = [1:length(actual_slice_number)] - tmp;

if ctr~=NUM_3D 
    disp(['- ' num2str(ctr) ' slices instead of ' num2str(NUM_3D)]);
end

x3 = ieWindowScale(I3, c_low, c_high);

if OSD && SHOW_ALL_SLICES
    figure;
    imshow(Ires, [c_low c_high]);
end
