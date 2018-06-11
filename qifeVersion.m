function [version] = qifeVersion()
    version = struct();
    version.gitBranch=NaN;
    version.gitHash=NaN;
    version.dockerTag=NaN;
    version.buildDate=NaN;
    version.runDate=datestr(now, 'yyyymmddHHMMSS');