function lesion = GetRoi(xmlName, OSD)
%
% modified for LUNG NODULES 2010-05-24
% [poly SOPInstanceUID AIM_UID chs observations patientName]
%
if ~exist('OSD', 'var'), OSD = 0;  end;
%xmlDoc = parseXML(xmlName);
aim_file = aim_tools.load_aim_from_file(xmlName);

try
    % ROI
    %xml_filter{1} = 'geometricShapeCollection';
    %xml_filter{2} = 'GeometricShape';
    %xml_filter{3} = 'spatialCoordinateCollection';
    %xml_filter{4} = 'SpatialCoordinate';
    % UID
    %uid = ParseDoc(xmlDoc, xml_filter, 'imageReferenceUID', 1);
    %lesion.uid = uid{1};
    %lesion.uid = char(aim_file.getImageAnnotations().get(0).getMarkupEntityCollection.get(0).getImageReferenceUid.getRoot());
    lesion.uid = char(aim_file.getImageReferenceCollection.getImageReferenceList.get(0).getImageStudy.getImageSeries.getImageCollection.getImageList.get(0).getSopInstanceUID);
    coordinates = aim_tools.get_control_point_array_from_aim(aim_file);
    x = coordinates.x;
    y = coordinates.y;
    lesion.roi.x = x;
    lesion.roi.y = y;
    %x = ParseDoc(xmlDoc, xml_filter, 'x', 0);
    %y = ParseDoc(xmlDoc, xml_filter, 'y', 0);
    %if 1
    %    idx = ParseDoc(xmlDoc, xml_filter, 'coordinateIndex', 0);
    %    [~, idx] = sort(idx);    % 2009-08-18
    %end
    
    % Check what kind of shape it is
    %roi_shape_type = ParseDoc(xmlDoc, xml_filter(1:2), 'xsi:type', 1);
    %switch(lower(roi_shape_type{1}))
    %    case 'circle'
    %        centerX = x(1);
    %        centerY = y(1);
    %        radius = sqrt((x(2) - x(1)).^2 + (y(2) - y(1)).^2);
%             angles = 0:0.1:2*pi;
%             lesion.roi.x = (cos(angles(1:(end-1)))*radius + centerX)';
%             lesion.roi.y = (sin(angles(1:(end-1)))*radius + centerY)';
%             
%         otherwise %polygons
%             lesion.roi.x = x(idx);                 % 2009-08-18
%             lesion.roi.y = y(idx);                 % 2009-08-18           
%     end 
    

    
    
    %% UID (of the lesion, not the DICOM uid)
%     lesion.AIM_UID = strtrim(char(aim_file.getUniqueIdentifier.getRoot));
      lesion.AIM_UID = strtrim(char(aim_file.getUniqueIdentifier));
%     for i = 1 : length(xmlDoc.Attributes)
%         if strcmp(xmlDoc.Attributes(i).Name,'uniqueIdentifier') || strcmp(xmlDoc.Attributes(i).Name,'uid')
%             lesion.AIM_UID = xmlDoc.Attributes(i).Value;
%         end
%     end
    
    %% SOPInstanceUID (associated DICOM uid)
%     clear xml_filter;
%     xml_filter{1} = 'imageReferenceCollection';
%     xml_filter{2} = 'ImageReference';
%     xml_filter{3} = 'study';
%     xml_filter{4} = 'Study';
%     xml_filter{5} = 'series';
%     xml_filter{6} = 'Series';
%     xml_filter{7} = 'imageCollection';
%     xml_filter{8} = 'Image';
%     SOPInstanceUID = ParseDoc(xmlDoc, xml_filter, 'sopInstanceUID', 1);
%     if isempty(SOPInstanceUID)
%         xml_filter{1} = 'imageReferenceCollection';
%         xml_filter{2} = 'ImageReference';
%         xml_filter{3} = 'imageStudy';
%         xml_filter{4} = 'ImageStudy';
%         xml_filter{5} = 'imageSeries';
%         xml_filter{6} = 'ImageSeries';
%         xml_filter{7} = 'imageCollection';
%         xml_filter{8} = 'Image';
%         SOPInstanceUID = ParseDoc(xmlDoc, xml_filter, 'sopInstanceUID', 1);
%     end
%     if isempty(SOPInstanceUID)
%         % this is for old liver lesions
%         clear xml_filter;
%         xml_filter{1} = 'imageReferenceCollection';
%         xml_filter{2} = 'ImageReference';
%         xml_filter{3} = 'Study';
%         xml_filter{4} = 'Series';
%         xml_filter{5} = 'imageCollection';
%         xml_filter{6} = 'Image';
%         SOPInstanceUID = ParseDoc(xmlDoc, xml_filter, 'SOPInstanceUID', 1);
%     end
%     if isempty(SOPInstanceUID)
%         if OSD, disp(['Could not locate SOPInstanceUID']); end
%     end
%     lesion.SOPInstanceUID = SOPInstanceUID{1};
%       lesion.SOPInstanceUID = strtrim(char(aim_file.getImageAnnotations().get(0).getImageReferenceEntityCollection.get(0).getImageStudy.getImageSeries.getImageCollection.get(0).getSopInstanceUid.getRoot()));
lesion.SOPInstanceUID = strtrim(char(aim_file.getImageReferenceCollection.getImageReferenceList.get(0).getImageStudy.getImageSeries.getImageCollection.getImageList.get(0).getSopInstanceUID));
      
    %% CHS
%     clear xml_filter;
%     xml_filter{1} = 'imagingObservationCollection';
%     xml_filter{2} = 'ImagingObservation';
%     xml_filter{3} = 'imagingObservationCharacteristicCollection';
%     xml_filter{4} = 'ImagingObservationCharacteristic';
%     chsx = ParseDoc(xmlDoc, xml_filter, 'codeMeaning', 1);
%     chsx = strrep(chsx, '"', '');
%     chsx = strrep(chsx, ',', '');
%     chsx = strrep(chsx, '%', '');
%     lesion.chs = chsx;
      lesion.chs = [];
    %% Obervations
%     clear xml_filter;
%     xml_filter{1} = 'imagingObservationCollection';
%     xml_filter{2} = 'ImagingObservation';
%     chsy = ParseDoc(xmlDoc, xml_filter, 'codeMeaning', 1);
%     chsy = strrep(chsy, '"', '');
%     chsy = strrep(chsy, ',', '');
%     chsy = strrep(chsy, '%', '');
%     lesion.observations = chsy;
      lesion.chsy = [];
    %% lesionName
%     clear xml_filter;
%     xml_filter{1} = 'ImageAnnotation';
%     %xml_filter{2} = 'Person';
%     lesionName = ParseDoc(xmlDoc, xml_filter, 'name', 1);
%     if isempty(lesionName)
%        lesionName = '';
%     end
%     if ~isempty(lesionName)
%         lesion.lesionName = lesionName{1};
%     else
%         lesion.lesionName = '';
%     end    
%    lesion.lesionName = strtrim(char(aim_file.getImageAnnotations().get(0).getName().getValue()));
    lesion.lesionName = strtrim(char(aim_file.getName));

    %% lesionComment
%     clear xml_filter;
%     xml_filter{1} = 'ImageAnnotation';
%     %xml_filter{2} = 'Person';
%     lesionComment = ParseDoc(xmlDoc, xml_filter, 'comment', 1);
%     if isempty(lesionComment)
%        lesionComment = '';
%     end
%     if ~isempty(lesionComment)
%         lesion.lesionComment = lesionComment{1};
%         lesion.lesionComment = strrep(lesion.lesionComment, '"', '');
%         lesion.lesionComment = strrep(lesion.lesionComment, ',', '');
%         lesion.lesionComment = strrep(lesion.lesionComment, '%', '');
%     else
%         lesion.lesionComment = '';
%     end        
%     lesion.lesionComment = strtrim(char(aim_file.getImageAnnotations().get(0).getComment().getValue()));
    lesion.lesionComment = '';
    
    %% userName
%     clear xml_filter;
%     xml_filter{1} = 'user';
%     xml_filter{2} = 'User';
%     userName = ParseDoc(xmlDoc, xml_filter, 'name', 1);
%     if isempty(userName)
%        userName = '';
%     end
%     if ~isempty(userName)
%         lesion.userName = userName{1};
%     else
%         lesion.userName = '';
%     end
%     
%     lesion.userName = strtrim(char(aim_file.getUser().getLoginName.getValue()));
    lesion.userName = '';
    %% patientName
%     clear xml_filter;
%     xml_filter{1} = 'person';
%     xml_filter{2} = 'Person';
%     patientName = ParseDoc(xmlDoc, xml_filter, 'name', 1);
%     if isempty(patientName)
%        patientName = ParseDoc(xmlDoc, xml_filter, 'patientID', 1);
%     end
%     if ~isempty(patientName)
%         lesion.patientName = patientName{1};
%     else
%         lesion.patientName = '';
%     end
%     lesion.patientName = strtrim(char(aim_file.getPerson.getName.getValue()));
    lesion.patientName = strtrim(char(aim_file.getListPerson.get(0).getName));
    %% patientID
%     clear xml_filter;
%     xml_filter{1} = 'person';
%     xml_filter{2} = 'Person';
%     patientId = ParseDoc(xmlDoc, xml_filter, 'id', 1);
%     if isempty(patientId)
%        patientId = ParseDoc(xmlDoc, xml_filter, 'id', 1);
%     end
%     if ~isempty(patientId)
%         lesion.patientId = num2str(patientId{1});
%     else
%         lesion.patientId = '';
%     end    
    
%     lesion.patientId = strtrim(char(aim_file.getPerson.getId.getValue()));
    lesion.patientId = strtrim(char(aim_file.getListPerson.get(0).getId));
    lesion.valid = 1;
catch
    lesion.valid = 0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

% function val = ParseDoc(xmlDoc, xml_filter, propertyName, isString)
% node{1}=xmlDoc;
% res = GetXMLChildPath(node,xml_filter);
% if ~isString
%     val = [];
% else
%     val = cell(0);
% end
% for i = 1 : length(res)
%     for j = 1 : length(res{i}.Attributes)
%         if strcmp(res{i}.Attributes(j).Name,propertyName)
%             tmp = res{i}.Attributes(j).Value;
%             if ~isString
%                 tmp = str2num(tmp);
%                 val = [val; tmp];
%             else
%                 val{length(val)+1} = tmp;
%             end
%         end
%     end
% end