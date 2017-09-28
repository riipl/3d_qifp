function res = s_getGS(GS, USE_BINNED_GS)
%
% returns actual or binned Gold Standard
%

if USE_BINNED_GS
    res = round(GS);
else
    res = GS;
end
    