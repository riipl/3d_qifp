function [c_low c_high] = s_getCTWindow(ORGAN, I)

% usage:
%   1) imshow(I, s_getCTwindow('liver'))
% 
%   2) [c_low c_high] = s_getCTwindow('liver');


if ~exist('I', 'var'), scale = 0; end

% switch lower(ORGAN)
%     case 'liver'
%         c_low = 840; c_high = 1240;
%     case 'lung'
%         c_low = -426; c_high = 1074;
%     case 'brain'
%         c_low = 0; c_high = 800;
%     case 'breast'
%         c_low = 0; c_high = 4096;
%     case 'bone'
%         c_low = 0; c_high = 4096;
%     case 'knee'
%         c_low = 0; c_high = 12000; % 16384
%     otherwise
%         c_low = 0; c_high = 2048;
% end

config_profile = get_config_profile(ORGAN);
if strcmp(config_profile.name, 'null')==0
    c_low = config_profile.display.c_low;
    c_high = config_profile.display.c_high;
end

if nargout < 2
    c_low(2) = c_high;
end

return;