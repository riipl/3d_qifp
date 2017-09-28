function res = tileToSize(img,h,w)
[hi wi]=size(img);
hn = ceil(h/hi);
wn = ceil(w/wi);
res = repmat(img,hn,wn);
res = res(1:h,1:w);