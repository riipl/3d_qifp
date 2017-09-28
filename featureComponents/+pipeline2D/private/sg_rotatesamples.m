%SG_ROTATESAMPLES
%
%   m = sg_rotatesamples(matr,rot,n)
%
% Rotates samples in sample matrix for rotation invariance. 
%
%   matr  - Sample matrix, either two or three dimensional
%   rot   - Rotation. How many steps the responses are rotated.
%           Usually values [0,n-1] should be used but any
%           integer value, also negative values, will work.
%   n     - Number of orientations in the sample matrix
%
% See also: SG_RESP2SAMPLEMATRIX, SG_SCALESAMPLES
%
% Authors: 
%   Jarmo Ilonen, 2004
%
% $Name: V_1_0_0 $ $Id: sg_rotatesamples.m,v 1.3 2005-10-12 14:27:31 ilonen Exp $

function feh=sg_rotatesamples(matr,rot,norient)

dim=ndims(matr);

ntotal=size(matr,dim);

if mod(ntotal,norient)~=0
  error('sg_rotatesamples:invalid_matrix','Invalid number of orientations');
end,

ind=0:ntotal-1; % indexes
find=floor(ind/norient); % frequencies

rind=mod(ind,norient)-rot;  % orientations and the shift

new_ind=find*norient+mod(rind,norient); % new indexes after rotation

% the indexes that "wrap" and are complex conjugates of the current values
wrap_ind=new_ind( mod(rind,norient*2) >= norient )+1;

if dim==2
  feh(:,new_ind+1)=matr; 

  feh(:,wrap_ind)=conj(feh(:,wrap_ind));

end;

if dim==3
  feh(:,:,new_ind+1)=matr;
  feh(:,:,wrap_ind)=conj(feh(:,:,wrap_ind));
end;

