%SG_SCALESAMPLES
%
%   m = sg_scalesamples(matr,sc,m,n)
%
% Scales samples in sample matrix for scale invariance. Returns responses for
% nf frequencies (frequencies [r:nf+r] from the original sample matrix).
%
%   matr  - Sample matrix, either two or three dimensional
%   sc    - Scaling, how many steps the frequencies are shifted.
%           Extra frequencies must be specified with 
%           sg_createfilter(), and the value must be
%           [0,extra_freq].
%   m     - Number of usable frequencies in the sample matrix
%   n     - Number of orientations in the sample matrix
%
% See also: SG_RESP2SAMPLEMATRIX, SG_ROTATESAMPLES
%
% Authors: 
%   Jarmo Ilonen, 2004
%
% $Name: V_1_0_0 $ $Id: sg_scalesamples.m,v 1.4 2005-10-12 14:29:03 ilonen Exp $

function feh=sg_scalesamples(matr,sc,nf,norient)

dim=ndims(matr);

ntotal=size(matr,dim);

if mod(ntotal,norient)~=0
  error('sg_scalesamples:invalid_matrix','Invalid number of orientations');
end,

favail=ntotal/norient;

if nf+sc>favail~=0
  error('sg_scalesamples:invalid_matrix','Not enough frequencies available');
end,


ind=1:(nf*norient);
orig_ind=ind + sc*norient;

if dim==2
  feh=matr(:,orig_ind); 

end;

if dim==3
  feh=matr(:,:,orig_ind);
end;

