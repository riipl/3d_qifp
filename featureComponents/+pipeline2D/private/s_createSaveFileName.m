function fn = s_createSaveFileName(FV_MASK, lesionUIDs, USE_BINNED_GS, LESIONS_TO_EXCLUDE)
%
% [FILENAME] = 
%   s_createSaveFileName( FV_MASK, lesionUIDs, 
%                         [USE_BINNED_GS = 0], [LESIONS_TO_EXCLUDE=[]])

% Generate a filename string for:
%       different goldstandard (depends on lesionUIDs, USE_BINNED_GS)
%       different feature vector (FV_MASK)
%       lesions excluded from goldstandard
%
% Parameters:
%   lesionUIDs      : ORIGINAL (including non-excluding)
%   USE_BINNED_GS   : default is 0
%

if ~exist('LESIONS_TO_EXCLUDE', 'var')
    LESIONS_TO_EXCLUDE = []; 
else
    LESIONS_TO_EXCLUDE = sort(LESIONS_TO_EXCLUDE);
end
if ~exist('USE_BINNED_GS', 'var'), USE_BINNED_GS = 0; end

fn = ['DCombined_LOO_NDCG_' num2str(length(lesionUIDs))];
if length(LESIONS_TO_EXCLUDE) == 1
    fn = [fn '-[' mat2str(LESIONS_TO_EXCLUDE) ']'];
elseif ~isempty(LESIONS_TO_EXCLUDE)
    fn = [fn '-' mat2str(LESIONS_TO_EXCLUDE)];
end


fn = [fn '_FV(' char(FV_MASK+char('0')) ')'];
fn = [fn '_GS'];
if (USE_BINNED_GS)
    fn = [fn '_BINNED'];
end

fn = [fn '.mat'];