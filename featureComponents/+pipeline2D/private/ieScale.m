function res = ieScale(x, a, b)
% scale values in x to be between (a, b)
%
% example: ieScale(src, MIN, MAX)

x = double(x);
res = a + (x - min(x(:))) / (max(x(:)) - min(x(:))) * (b-a);

return 