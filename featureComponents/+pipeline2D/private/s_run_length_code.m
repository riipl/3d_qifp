function [val cnt] = s_run_length_code(tmp)

tmp = int16(tmp(:));
tmp = sort(tmp);
x = [1; diff(tmp)];
val = tmp(x>0);
cnt = int16(diff([0; find(x>0)]));