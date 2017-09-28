function [uid phase diagno] = s_returnLesionPhaseDiag(lesion, OSD)

if ~exist('OSD','var'), OSD = 0; end;   % default no console interaction

tmp = lesion.observations;

if OSD
    fprintf('   AIM_ID : %s\n', lesion.uid);
end
uid = lesion.uid;
phase = '';
diagno = '';
for ii = 1:length(tmp)
    switch tmp{ii}
        case {'hepatocellular carcinoma' , ...
                'focal nodular hyperplasia', ...
                'cyst','metastasis','hemangioma', ...
                'abscess','laceration', 'fat deposition'}
            if OSD
                fprintf('   Diagno : %s\n', tmp{ii});
            end
            diagno = tmp{ii};
    end
    if ~isempty(strfind(tmp{ii}, 'phase'))
        if OSD
            fprintf('   Phase  : %s\n', tmp{ii});
        end
        phase = tmp{ii};
    end
end

switch diagno
    case 'hepatocellular carcinoma'
        diagno = 'HCC';
    case 'focal nodular hyperplasia'
        diagno = 'focal nodular';
end

