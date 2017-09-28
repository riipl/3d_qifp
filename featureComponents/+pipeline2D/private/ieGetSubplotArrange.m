function [h, w] = ieGetSubplotArrange(cnt,imageEachRow,imageEachCol)
%
% [nR, nC] = ieGetSubplotArrange(NUM_IMAGE, [imageEachRow], [imageEachCol])
%
%   set imageEachRow to 0 if you want to specify imageEachCol only.
%

if ~exist('imageEachRow','var') || imageEachRow == 0
    if exist('imageEachCol','var')
        h = imageEachCol;
        w = ceil(cnt/h);
    else
        h = floor(sqrt(cnt));
        w = ceil(cnt/h);
    end
else
    w = imageEachRow;
    h = ceil(cnt/w);
end