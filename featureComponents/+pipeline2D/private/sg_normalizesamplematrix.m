%SG_NORMALIZESAMPLEMATRIX
%
%   m = sg_normalizesamplematrix(m)
%
% Normalizes sample matrix for illumination invariance. Each sample 
% (Gabor responses for one point in all frequencies and rotations) is
% normalized so that norm(sample)==1.
%
% See also: SG_RESP2SAMPLEMATRIX
%
% Authors: 
%   Jarmo Ilonen, 2004
%
% $Name: V_1_0_0 $ $Id: sg_normalizesamplematrix.m,v 1.2 2005-10-12 14:29:45 ilonen Exp $

function meh=sg_normalizesamplematrix(meh)

n=size(meh);

featlen=n(end);

if length(n)==3
  meh=(1./repmat(sqrt(sum(abs(meh).^2,3)),[1,1,featlen])).*meh;
  return;
end;


if length(n)==2
  meh=(1./repmat(sqrt(sum(abs(meh).^2,2)),[1,featlen])).*meh;
  return;
end;

error('Could not decipher response structure');


