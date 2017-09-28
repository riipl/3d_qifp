function node = GetXMLChildPath(node,path)
for i = 1 : length(path)
    n = GetXMLChild(node,path{i});
    if ~isempty(n)
        node = n;
    end
end