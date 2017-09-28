function res = GetXMLChild(node,name)
res=cell(0);
for i = 1 : length(node)
    for j = 1 : length(node{i}.Children)
        if strcmp(node{i}.Children(j).Name,name)
            res{length(res)+1} = node{i}.Children(j);
        end
    end
end