% function c_query_image(r_imgID)
% Last Modified: 11/16/2009

retrieve_s = -Dcombined;

SAVE_QUERY_IMG_RESULT = 0;

LESION_DISPLAY_MODE = 5;    % 5 - radial distance signal, 0 - paper quality

%%%%%%%%%%%%%%%%%%%%%%%%%
%
FIG_FOR_PAPER = 1;
%
%%%%%%%%%%%%%%%%%%%%%%%%%

NUM_K = 6;

TopK = length(im_RANGE);
TopK = 16;   % number of images to show

H = figure(545);clf;
tmp = get(H, 'Position');

nR = floor(sqrt(TopK));
nC = ceil(TopK / nR);
set(H, 'Position', [tmp(1) min(100, tmp(2))  740   721]);

for r_imgID = 59
    % ankit (old, gabor); H: 26, M:6 38% for fit in 3-column word
    % Ankit_30 (new): ovoid: 19, lobular: 13, ir: 29
    % H: 37, C:25, M:55
    % round: 79, ovoid: 80,6 lobular: 21
    % 72-lesion: ovoid: 34, lobular:42, round:12
    tmp = retrieve_s(r_imgID, :);
    tmp(r_imgID) = 5;  % WAS 5 here
    [tmp_b tmp_i] = sort(tmp, 'descend');

    for tt = 1 : TopK

        imgID = tmp_i(tt);

        if (0)
            % ROI only
            tsubplot(nR, nC, tt);
            tmp = lesion{imgID}.img;
            imgshow( tmp );

            [m n] = size(tmp);
            titleStr = [num2str(imgID) ':' lesion{imgID}.name ...    % lesion UID
                ' (' char(lesion{imgID}.type) ')' ...   % lesion type
                ' [' num2str(sum((tmp(:)>0))) ']' ...
                ' {' num2str(tmp_b(tt)) '}']; % lesion size
            if (tt == 1)
                if FIG_FOR_PAPER
                    titleStr = sprintf('%2.1f (%g)', tmp_b(tt), lesion{imgID}.type);
                else
                    titleStr = ['REF ' titleStr];
                end
            end
        else
            % ROI with context
%             subplot(nR, nC, tt);
%             tsubplot(nR, nC, tt, 'Spacing', 0.025, 'Box', 'inner');
tsubplot(nR, nC, tt);
            drawLesion(lesion{imgID}, LESION_DISPLAY_MODE);

            if FIG_FOR_PAPER
                % temporarily for paper
                tmp_b(2:end) = ieScale(tmp_b(2:end), 1,3);
                titleStr = sprintf('%2.2f (%g)', tmp_b(tt), gs(r_imgID, imgID));
            else
                titleStr = sprintf('%g (%c,%g) {%4.3f}', imgID  ...    % lesion UID
                    , lesion{imgID}.type ...   % lesion type
                    , gs(r_imgID, imgID) ...      % similarity score  
                    , tmp_b(tt)); % lesion size
            end
            
            if (tt == 1)
                if FIG_FOR_PAPER
                    titleStr = sprintf('QUERY', tmp_b(tt), lesion{imgID}.type);
                else
                    titleStr = ['REQ: ' num2str(imgID) '(' lesion{imgID}.type ')'];
                end
            end

            if (LESION_DISPLAY_MODE == 5)
                tmp = axis;
                text((tmp(1)+tmp(2))/2, (tmp(3)+tmp(4))/2, num2str(imgID),'HorizontalAlignment', 'Center', 'FontSize', 12);
                shapeStr = '';
                for ii =1:length(lesion{imgID}.ioc)
                    tmpStr = lesion{imgID}.ioc{ii}.codeMeaning;
                    tmpStrEnd = strfind(tmpStr, 'ly shaped');
                    if length(tmpStrEnd)>0
                        tmpStr = tmpStr(1:tmpStrEnd-1);
                    end
                    if length(strfind(tmpStr, 'polygonal'))>0
                        tmpStr = 'polyg';
                    end
                    if length(strfind(tmpStr, 'rectangular'))>0
                        tmpStr = 'rect';
                    end
                    shapeStr = [shapeStr ',' tmpStr];
                end
                shapeStr = shapeStr(2:end);
                titleStr = [ shapeStr];
                disp(titleStr)
%                 legend(titleStr)
            end
%             titleStr = '';
        end
        
        title(titleStr);
    end
    if SAVE_QUERY_IMG_RESULT == 1
        tmp_fname = sprintf('query\\=%g=%g_top-%g_%3.1f%%', ...
            nFiles, r_imgID, NUM_K, 100*mean(precision(r_imgID, 1:NUM_K)) );
        saveas(H, [tmp_fname '.jpg'], 'jpg');
%         print('-djpeg',[tmp_fname]);
        disp(['***** [Saved] ' tmp_fname ' *****'])
    end
end

if (LESION_DISPLAY_MODE == 0)
    s_format_fig('query', 'long', -2)
else
    s_format_fig('query', 'long', -2)
%     s_format_fig('ppt', 'full2',-5)
end

