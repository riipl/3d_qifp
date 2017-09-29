function [res k]=s_unique(x)

if size(x,2) ~= 2, x = x'; end

% if size(x,2) ~= 2, x = x'; end

d1 = [0; 1-diff(x(:,1))];  % same
d2 = [0; 1-diff(x(:,2))];
k = ~(d1&d2);
res(:,1) = x(k,1);
res(:,2) = x(k,2);

