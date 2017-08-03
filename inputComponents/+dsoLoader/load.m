function [ outputStructure ] = load( inputs )
%LOAD Summary of this function goes here
%   Detailed explanation goes here

    DcmSegmentationObjectPatientInfoTable = inputs.DcmSegmentationObjectPatientInfoTable;
    toString = @(var) evalc(['disp(var)']);
    try
        outputStructure  = load_volume(inputs);
    catch E
        dsoUid = inputs.processingUid;
        infoDSO = DcmSegmentationObjectPatientInfoTable(dsoUid);
        fprintf(2,'--------------------\n')
        fprintf(2,'ERROR PROCESSING:\n')
        infoDSO.dso_uid = dsoUid;
        fprintf(2,[toString(infoDSO)]);
        fprintf(2,'--------------------\n')
        rethrow(E);
    end

end

