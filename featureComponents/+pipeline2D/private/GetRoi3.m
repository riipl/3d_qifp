function [poly SOPInstanceUID uid chs observations patientName patientAge patientGender] = GetRoi3(xmlName)
% 
% To obtain patient age, demography info 2011-12-06
% 
xmlDoc = parseXML(xmlName);

% ROI
xml_filter{1} = 'geometricShapeCollection';
xml_filter{2} = 'GeometricShape';
xml_filter{3} = 'spatialCoordinateCollection';
xml_filter{4} = 'SpatialCoordinate';
% UID
uid = ParseDoc(xmlDoc, xml_filter, 'imageReferenceUID', 1);
uid = uid{1};

x = ParseDoc(xmlDoc, xml_filter, 'x', 0);
y = ParseDoc(xmlDoc, xml_filter, 'y', 0);
if 1
    idx = ParseDoc(xmlDoc, xml_filter, 'coordinateIndex', 0);
    [~, idx] = sort(idx);    % 2009-08-18
end
poly.x = x(idx);                 % 2009-08-18
poly.y = y(idx);                 % 2009-08-18

%% SOPInstanceUID (associated DICOM uid)
clear xml_filter;
xml_filter{1} = 'imageReferenceCollection';
xml_filter{2} = 'ImageReference';
xml_filter{3} = 'study';
xml_filter{4} = 'Study';
xml_filter{5} = 'series';
xml_filter{6} = 'Series';
xml_filter{7} = 'imageCollection';
xml_filter{8} = 'Image';
SOPInstanceUID = ParseDoc(xmlDoc, xml_filter, 'sopInstanceUID', 1);
if ~isempty(SOPInstanceUID)
    SOPInstanceUID = SOPInstanceUID{1};
end

%% CHS
clear xml_filter;
xml_filter{1} = 'imagingObservationCollection';
xml_filter{2} = 'ImagingObservation';
xml_filter{3} = 'imagingObservationCharacteristicCollection';
xml_filter{4} = 'ImagingObservationCharacteristic';
chs = ParseDoc(xmlDoc, xml_filter, 'codeMeaning', 1);
%% Obervations
clear xml_filter;
xml_filter{1} = 'imagingObservationCollection';
xml_filter{2} = 'ImagingObservation';
observations = ParseDoc(xmlDoc, xml_filter, 'codeMeaning', 1);

%% patientName
clear xml_filter;
xml_filter{1} = 'patient';
xml_filter{2} = 'Patient';
patientName = ParseDoc(xmlDoc, xml_filter, 'name', 1);
patientName = patientName{1};
tmp = ParseDoc(xmlDoc, xml_filter, 'birthDate', 1);
if iscell(tmp)
    tmp = tmp{1};
end
if isempty(tmp)
    patientAge = 0;
else
    patientAge = 2011-str2double(tmp(1:4));
end
tmp = ParseDoc(xmlDoc, xml_filter, 'sex', 1);
patientGender = tmp{1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

function val = ParseDoc(xmlDoc, xml_filter, propertyName, isString)
node{1}=xmlDoc;
res = GetXMLChildPath(node,xml_filter);
if ~isString
    val = [];
else
    val = cell(0);
end
for i = 1 : length(res)
    for j = 1 : length(res{i}.Attributes)
        if strcmp(res{i}.Attributes(j).Name,propertyName)
            tmp = res{i}.Attributes(j).Value;
            if ~isString
                tmp = str2num(tmp);
                val = [val; tmp];
            else
                val{length(val)+1} = tmp;
            end
        end
    end
end