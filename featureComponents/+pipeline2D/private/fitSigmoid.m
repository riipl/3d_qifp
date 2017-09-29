function params = fitSigmoid(pixelValues)

% if pixelValues(1) > pixelValues(end)
%    pixelValues = pixelValues * -1;
% end

%params: 1 x 4: 
% p(1) : x0
% p(2) : W
% p(3) : S
% p(4) : I0


f = @(p,x) p(4) + p(3) ./ (1 + exp(-(x-p(1))/p(2)));


args = statset('MaxIter', 300, 'TolFun', 1e-8, 'TolX', 1e-8, ...
    'Display', 'off', 'DerivStep', eps^(1/3), 'FunValCheck', ...
    'on', 'Robust', 'on', 'WgtFun', 'bisquare');

params = zeros(1, 4);

N = length(pixelValues);
x = 1:N;
values = sort(pixelValues);

%use 10th and 90th percentile as a robust rough guess for min and max values
maxVal = values(round(N * 0.9));
minVal = values(round(N * 0.1));

%     maxVal = max(pixelValues);
%     minVal = min(pixelValues);

guess = [ N/2.0   5   maxVal-minVal  minVal];

try
    params = nlinfit(x', pixelValues, f, guess, args);
catch me
    disp(['NLINFIT failed on ' mat2str(pixelValues) ]);
    params = [-1 -1 -1 -1];
end


end