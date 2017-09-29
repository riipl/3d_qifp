% SimpleGabor Toolbox - Simple (Multiresolution) Gabor feature
% extraction
%
% Version 1.0
%
% Feature extraction interface
%   sg_version               - Version string for SimpleGabor toolbox
%   sg_createfilterbank      - Creates Gabor filter bank 
%   sg_filterwithbank        - Gabor filtering with filterbank
%   sg_resp2samplematrix     - Convert response structure to matrix
%   sg_normalizesamplematrix - Normalises the sample matrix (see [2] for usage)
%   sg_rotatesamples         - Rotates sample matrix (see [2] for usage)
%   sg_scalesamples          - Scales sample matrix (see [2] for usage)
%
% Internal interface (some used in verbose mode)
%   sg_createfilterf2.m      - Creates a 2-d Gabor filter in the frequency domain
%   sg_plotfilters2          - Displays Gabor filter bank
%   sg_solvefilterparams     - Solve Gabor filter parameters (see [1])
%   getargs                  - Parse variable argument list into a struct
%
% Special features
%   sg_filterwithbank2       - Gabor filtering with filterbank
%                              (only effective size responses) 
%
% Demos
%   sg_demo01                - A simple demo presenting Gabor feature
%                              computation
%
% References:
%   [1] Ilonen, J., Kamarainen, J.-K., Kälviäinen, H., Efficient
%   Computation of Gabor Features, Research Report 100,
%   Lappeenranta University of Technology, Department of
%   Information Technology, 2005.
%   [2] Ilonen, J., Kamarainen, J.-K., Paalanen, P., Hamouz, M.,
%   Kittler, J., Kälviäinen, H., Image feature localization by
%   multiple hypothesis testing of Gabor features, IEEE
%   Transactions on Image Processing 2008.
%
% Authors:
%    Jarmo Ilonen <Jarmo.Ilonen@lut.fi> 2004
%    Joni Kamarainen <Joni.Kamarainen@lut.fi> 2007
%
% Note:
%   For 1-D filtering you may use the depricated Gabor toolbox at:
%   http://www.it.lut.fi/project/gabor/downloads/src/gabortb/
%   The toolbox can be used also with 2-D signals, but it is
%   computationally much slower than this (see [1])!
%
% Copyright:
%
%   The GMMBayes Toolbox is Copyright (C) 2003, 2004, 2005, 2006,
%   2007, 2008 by Jarmo Ilonen and Joni Kamarainen.
%
%   The software package is free software; you can redistribute it
%   and/or modify it under terms of GNU General Public License as
%   published by the Free Software Foundation; either version 2 of
%   the license, or any later version. For more details see licenses
%   at http://www.gnu.org
%
%   The software package is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%   See the GNU General Public License for more details.
%
%   As stated in the GNU General Public License it is not possible to
%   include this software library or even parts of it in a proprietary
%   program without written permission from the owners of the copyright.
%   If you wish to obtain such permission, you can reach us by mail:
%
%      Department of Information Processing
%      Lappeenranta University of Technology
%      P.O. Box 20 FIN-53851 Lappeenranta
%      FINLAND
%
%  and by e-mail:
%
%      jarmo.ilonen@lut.fi
%      joni.kamarainen@lut.fi
%
%  Please, if you find any bugs contact authors.
%
%  Project home page: http://www.it.lut.fi/project/simplegabor/
%
%   $Name: V_1_0_0 $ $Revision: 1.1 $  $Date: 2007-11-23 08:53:11 $
%
