function log(level, message)
%LOG Summary of this function goes here
%   Detailed explanation goes here
% global errorLevel

    time = datestr(datetime);
    pid = num2str(feature('getpid'));
    labId = num2str(labindex);
    level = upper(level);

    logFormat = '[%s][%s][pid=%s][labId=%s] %s\n';
    fprintf(logFormat, time, level, pid, labId, message);

end

