%%
% make synthesized shape by composing coarse/fine levels
% modified for liver lesions

% clear all; close all;

cd('d:/Sandy/LesionRetrieval')

addpath([pwd '/supporting_routines']);
addpath([pwd '/supporting_routines/shape']);
addpath([pwd '/supporting_routines/gabor']);
addpath([pwd '/supporting_routines/gabor/simplegabortb-v1.0.0']);
addpath([pwd '/supporting_routines/cvx']);
addpath([pwd '/supporting_routines/cvx/builtins']);
addpath([pwd '/supporting_routines/cvx/commands']);
addpath([pwd '/supporting_routines/cvx/functions']);
addpath([pwd '/supporting_routines/cvx/lib']);
addpath([pwd '/supporting_routines/cvx/structures']);
addpath([pwd '/supporting_routines/cbatten-sw-cbxplot']);
addpath([pwd '/GUI']);

cd('d:/Sandy/LesionRetrieval/supporting_routines/')

SHAPE_FOLDER = './shape/';
addpath(['d:/Sandy/matlab_common/pwmetric']);

addpath('..\');

%%
%
% make synthesized shape by composing coarse/fine levels
% modified for liver lesions

% clear all; close all;

cd('d:/Sandy/LesionRetrieval')

addpath([pwd '/supporting_routines']);
addpath([pwd '/supporting_routines/shape']);
addpath([pwd '/supporting_routines/gabor']);
addpath([pwd '/supporting_routines/gabor/simplegabortb-v1.0.0']);
addpath([pwd '/supporting_routines/cvx']);
addpath([pwd '/supporting_routines/cvx/builtins']);
addpath([pwd '/supporting_routines/cvx/commands']);
addpath([pwd '/supporting_routines/cvx/functions']);
addpath([pwd '/supporting_routines/cvx/lib']);
addpath([pwd '/supporting_routines/cvx/structures']);
addpath([pwd '/supporting_routines/cbatten-sw-cbxplot']);
addpath([pwd '/GUI']);

cd('d:/Sandy/LesionRetrieval/supporting_routines/')

SHAPE_FOLDER = './shape/';
addpath(['d:/Sandy/matlab_common/pwmetric']);

addpath('..\');

% construct the lesion
MajorAxis = 25;
AR = 2.5;
AC_AMP = MajorAxis * 10/100;
NUM_ROI = 80;
FREQ = 8;
ROTATION = pi;

tmp_lesion = s_synthesize_lesion(MajorAxis, AR, AC_AMP, FREQ, NUM_ROI, ROTATION);

% show the lesion, rds, laii
% tmp_lesion = lesion{34};
img = double(tmp_lesion.cimg);
subplot(221); drawLesion(tmp_lesion, 5,0,0,0,1);
subplot(222); drawLesion(tmp_lesion, 6);
% subplot(223); drawLesion(tmp_lesion, 7);

% % take the shape apart
% blur = fspecial('gaussian',75*[1 1], 2);
% img = conv2(double(img), blur, 'same');
% subplot(223); imshow(img,[]);

%%
OSD = 0;

MajorAxis = 40;

NUM_ROI = 80;
AR_RANGE = [1 1.6];
AC_AMP_RANGE = linspace(1, 5, 2);   % 1,5,2
FREQ_RANGE = linspace(1, 4, 4);     % 1,2,3,4

Scale_RANGE = [1.5 2 2.5];
ROTATION_RANGE = [0 45 60 90];         % in degrees

% select the orientation/scale
Scale_RANGE = Scale_RANGE([1 ]);
ROTATION_RANGE = ROTATION_RANGE([1 ]);

fprintf('%d AR, %d Amp, %d Freq [%d scales, %d orientations]\n',length(AR_RANGE), length(AC_AMP_RANGE), length(FREQ_RANGE), length(Scale_RANGE), length(ROTATION_RANGE));
TOTAL_NUM = length(AR_RANGE) * length(FREQ_RANGE) * length(AC_AMP_RANGE) * length(ROTATION_RANGE) * length(Scale_RANGE);
TOTAL_BASE_NUM = length(AR_RANGE) * length(FREQ_RANGE) * length(AC_AMP_RANGE);
[h, w] = ieGetSubplotArrange(TOTAL_NUM);

clear DB;
DB.lesions = hashtable;
clf;

% loop on Scale, Orientation, AR, Freq, Amp
lesionUIDs = {};
i = 1;
ADD_FEATURE_AR = 0;
if 1
    for Scale = Scale_RANGE
        for ROTATION = ROTATION_RANGE
            for AR = AR_RANGE
                for AC_AMP = AC_AMP_RANGE
                    for FREQ = FREQ_RANGE
                        tmp_lesion = s_synthesize_lesion(MajorAxis, AR, AC_AMP, FREQ, NUM_ROI, ROTATION);
                        tmp_lesion.roix = tmp_lesion.roix * Scale;
                        tmp_lesion.roiy = tmp_lesion.roiy * Scale;
                        
                        img = double(tmp_lesion.cimg);
                        if TOTAL_NUM < 30
                            subplot(w,h,i); drawLesion(tmp_lesion, 5,0,0,0,1);
                            tmp = b_shape_distribution(tmp_lesion.roix, tmp_lesion.roiy);
                            plot(1:length(tmp), tmp);
                            if OSD
                                tmp = axis;
                                text((tmp(1)+tmp(2))/2, (tmp(3)+tmp(4))/2, ...
                                    [num2str(i) char(10) ...
                                    mat2str([AR AC_AMP FREQ])...
                                    ]);
                            end
                        end
                        
%                         lesion{i} = tmp_lesion;
%                         lesionUIDs{i} = lesion{i}.uid;
                        i = i + 1;
                    end
                end
            end
        end
    end
else
    load([SHAPE_FOLDER 'sim_db_16_AxisRatio_convhull.mat']) 
end
% subplotspace('vertical',-17);
% subplotspace('horizontal',-20);
%%
lesion = tmp_lesion;

% subplot(223); hist(tmp);