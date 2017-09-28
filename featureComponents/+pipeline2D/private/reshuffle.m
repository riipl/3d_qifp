function out = reshuffle(in, index)

for i = 1:length(index)
    out{i} = in{index(i)};
end