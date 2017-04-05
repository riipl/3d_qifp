function params = fitSigmoid(pixelValues)
% fitSigmoid Fit a sigmoid to the sampled values
%
% Description: Fits a sigmoid defined by p(4) + p(3) ./ (1 + exp(-(x-p(1))/p(2)))
%               to the sampled values passed as input
%
% Input:
%   pixelValues: 1-dimensional array with sampled values 
%
% Output:
%   params: a 1x4 matrix holding parameter values of the sigmoid that 
%           fits the sigmoid to the passed sampled values.
%           p(1) : x0  = central point location
%           p(2) : W   = Window size
%           p(3) : S   = Scale Size
%           p(4) : I0  = Intensity Bias
%           If the fits fail it returns [-1 -1 -1 -1]
%           If the inside and outside values are really close then return
%           [-2, -2, -2, -2]


%% Initialize
% Sigmoid function
f = @(p,x) p(4) + p(3) ./ (1 + exp(-(x-p(1))/p(2)));

% Paramenters passed to the fitting algorithm
args = statset('MaxIter', 300, 'TolFun', 1e-8, 'TolX', 1e-8, ...
    'Display', 'off', 'DerivStep', eps^(1/3), 'FunValCheck', ...
    'on', 'Robust', 'on', 'WgtFun', 'bisquare');

% Initialize the parameter equation to 0
params = zeros(1, 4);

% Number of sample points
N = length(pixelValues);

% Sample points index
x = 1:N;

% Representative value inside and outside the VOI
insideVal = median(pixelValues(1:round(N/4)));
outsideVal = median(pixelValues(round(3*N/4):N));

%Initial parameters for the optimization paramenter
guess = [ N/2.0,   5,   outsideVal-insideVal, insideVal];

%% Error checking
% If values are too close to each other then fail
if (abs(insideVal - outsideVal) < 100)
    params = [-2 -2 -2 -2];    
    return;
end

%% Find parameters that match the sampled points
% We are capturing the fitting failures
w = warning ('off','all');
try
    params = nlinfit(x', pixelValues, f, guess, args);
catch me
    % If the fit fails return [-1, -1, -1, -1] and generate and error.
    disp(['NLINFIT failed on ' mat2str(pixelValues) ]);
    params = [-1 -1 -1 -1];
    error(me)
end
w = warning ('on','all');

end