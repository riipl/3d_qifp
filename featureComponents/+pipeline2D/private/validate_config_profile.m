function valid = validate_config_profile(config, OSD)

%
% example 1:
%     validate_config_profile(get_config_profile('liver'),1)
%
% example 2:
%     x.name='failed example'
%     x.load_dicom_method='nop'
%     x.display= 2
%     validate_config_profile(x,1)
%
% TODO: print edge curMin/curMax

if ~exist('OSD', 'var'), OSD = 0; end

if ~isfield(config, 'name')
    error('Invalid config profile: no "name"');
end

if OSD
    fprintf('Using config profile: %s\n',config.name);
end

if strcmp(config.name, 'null')==1
    return;
end

fields = {'config.load_dicom_method', ...
    'config.display.c_low', ...
    'config.display.c_high', ...
    'config.features.hist.bin_l', ...
    'config.features.hist.bin_h', ...
    'config.features.hist.F1_THRESH', ...
    'config.features.hist.NUM_BINS', ...
    'config.features.edge.curMin', ...
    'config.features.edge.curMax', ...
    };

for i = 1:length(fields)
    words = regexp(fields{i}, '\.', 'split');
    if length(words)<2
        continue
    end
    prefix = [];
    for j = 2:length(words)
        if j>2
            prefix = [prefix '.'];
        end
        prefix = [prefix words{j-1}];
        if eval(sprintf('isfield(%s,''%s'')', prefix, words{j})) == 0
            error('Invalid config profile: no "%s" in "%s"', words{j}, prefix)
        end
    end
end

if OSD
    for i = 2:length(fields)-2
        eval(sprintf('fprintf(''    %%s: %%4.0f\\n'',''%s'', %s);', fields{i}, fields{i}));
    end
end

valid = 1;
