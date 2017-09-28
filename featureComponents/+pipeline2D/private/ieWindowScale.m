function res = ieWindowScale(x, a, b)

% 1. crop data in between a and b
% 2. scale values to be [0, 1]
%
% example: ieWindowScale(I, 840, 1240)

x = double(x);
x(x<a) = a;
x(x>b) = b;
res = ieScale(x, 0, 1);


