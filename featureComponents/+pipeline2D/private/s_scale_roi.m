function [x, y] = s_scale_roi( x, y, THRESH )

% we try to scale x by N times if the span of x is less than THRESH

spanx = max(x) - min(x);
spany = max(y) - min(y);

if spanx < spany
    N = THRESH / spany;
else
    N = THRESH / spanx;
end

x = ((x-spanx/2) * N + spanx/2);
y = ((y-spany/2) * N + spany/2);

return;
