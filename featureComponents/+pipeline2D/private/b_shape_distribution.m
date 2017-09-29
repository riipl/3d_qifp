function res = b_shape_distribution(tmpx, tmpy)

if length(tmpx) < 100
    [tmpx tmpy] = s_spline_interpolate(tmpx, tmpy);
end

tmp = [];
N = length(tmpx);
for i = 1 : round(N/100) : N
    for j = 1 : round(N/100) : N
        tmp = [tmp (tmpx(i)-tmpx(j)).^2 + (tmpy(i)-tmpy(j)).^2];
    end
end

tmp = tmp * 500/mean(tmp);
% res = tmp;
% disp(mean(tmp));
res = hist(tmp, linspace(0, 2000, 20));

% [c,l] = wavedec(res',3,'haar');
% res = c(l(1)+l(2));