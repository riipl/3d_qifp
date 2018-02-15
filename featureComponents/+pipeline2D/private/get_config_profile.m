function config = get_config_profile( type )
%   loadDICOM               => how to normalize
%   s_getCTWindow           => c_low, c_high
%   getImageFeature         => hist bin size
%   getEdgeFeatureVector    => edge inside-outside

%  about edge sharpness range: [x0 W S I0]
%   x0: 10 pixel on both side, 20 pixels, interpolate 4x, 80 values
%       try to keep the center between 35 and 45
%    W: this is distance in pixel for 30% to 70% (50% is center)
%    S: should change accord to histogram bin range
%   I0: should change accord to histogram bin range

switch type
    case 'liver'
        config.name = 'liver';
        
        config.load_dicom_method = 'nop'; % do nothing
        
        config.display.c_low = 840;
        config.display.c_high = 1240;
        
        config.features.hist.bin_l = 1074; % 50 HU - 200 HU
        config.features.hist.bin_h = 1224;
        config.features.hist.F1_THRESH = 1100;
        config.features.hist.NUM_BINS = 9;
        
        % [x0 W S I0], see notes in the header
%         config.features.edge.curMin = [35.0     1.4     38    1040];
%         config.features.edge.curMax = [45.0      45     97    1102];
        config.features.edge.curMin = [35.0     1.4     38   config.features.hist.bin_l];
        config.features.edge.curMax = [45.0      45     97   config.features.hist.bin_h];
    case 'lung'
        config.name = 'lung';
        
        config.load_dicom_method = 'nop'; % do nothing
        
        config.display.c_low = -426;
        config.display.c_high = 1074;
        
        config.features.hist.bin_l = 240;   % -800 HU - 200 HU
        config.features.hist.bin_h = 1224;
        config.features.hist.F1_THRESH = 618;
        config.features.hist.NUM_BINS = 9;
        
        % [x0 W S I0], see notes in the header
        config.features.edge.curMin = [35.0    0.05   -2097   config.features.hist.bin_l];
        config.features.edge.curMax = [45.0     100    2097   config.features.hist.bin_h];
    case 'bone'
        config.name = 'bone';
        
        config.load_dicom_method = 'normalize'; % do nothing
        
        config.display.c_low = 0;
        config.display.c_high = 4096;
        
        config.features.hist.F1_THRESH = 15000;
        config.features.hist.bin_l = 1200;
        config.features.hist.bin_h = 3600;
        config.features.hist.NUM_BINS = 9;
        
        % [x0 W S I0], see notes in the header
        config.features.edge.curMin = [35.0    0.05   -100    config.features.hist.bin_l];
        config.features.edge.curMax = [45.0      30    100    config.features.hist.bin_h];
    case 'brain'
        config.name = 'brain';
        
        config.load_dicom_method = 'nop'; % do nothing
        
        config.display.c_low = 0;
        config.display.c_high = 800;
        
        config.features.hist.F1_THRESH = 20;
        config.features.hist.bin_l = 0;
        config.features.hist.bin_h = 40;
        config.features.hist.NUM_BINS = 9;
        
        % [x0 W S I0], see notes in the header
        config.features.edge.curMin = [35.0    0.05   -100   config.features.hist.bin_l];
        config.features.edge.curMax = [45.0      30    100   config.features.hist.bin_h];
    case 'breast'
        config.name = 'breast';
        
        config.load_dicom_method = 'nop'; % do nothing
        
        config.display.c_low = 0;
        config.display.c_high = 4096;
        
        config.features.hist.bin_l = 0;
        config.features.hist.bin_h = 4096;
        config.features.hist.F1_THRESH = (config.features.hist.bin_l + config.features.hist.bin_h)/2;
        config.features.hist.NUM_BINS = 9;
        
        % [x0 W S I0], see notes in the header
        config.features.edge.curMin = [35.0    0.05   -2048   config.features.hist.bin_l];
        config.features.edge.curMax = [45.0      30    2048   config.features.hist.bin_h];
    case 'rats'
        config.name = 'rats';
        
        config.load_dicom_method = 'nop'; % do nothing
        
        config.display.c_low = 0;
        config.display.c_high = 40;
        
        config.features.hist.bin_l = 0;
        config.features.hist.bin_h = 40;
        config.features.hist.F1_THRESH = 20;
        config.features.hist.NUM_BINS = 20;
        
        % [x0 W S I0], see notes in the header
        config.features.edge.curMin = [35.0    0.05   -100   config.features.hist.bin_l];
        config.features.edge.curMax = [45.0      30    100   config.features.hist.bin_h];
    case 'knee'
        config.name = 'knee';
        
        config.load_dicom_method = 'nop'; % do nothing
        
        config.display.c_low = 0;
        config.display.c_high = 12000; % 16384
        
        config.features.hist.bin_l = 1200;
        config.features.hist.bin_h = 12000;
        config.features.hist.F1_THRESH = (config.features.hist.bin_l + config.features.hist.bin_h)/2;
        config.features.hist.NUM_BINS = 9;
        
        % [x0 W S I0], see notes in the header
        config.features.edge.curMin = [35.0    0.05   -8192    config.features.hist.bin_l];
        config.features.edge.curMax = [45.0      30    8192    config.features.hist.bin_h];
    case 'tcia-phantom'
        config.name = 'tcia-phantom';
        
        config.load_dicom_method = 'nop'; % do nothing
        
        config.display.c_low = 0;
        config.display.c_high = 450; % 16384
        
        config.features.hist.bin_l = 0;
        config.features.hist.bin_h = 450;
        config.features.hist.F1_THRESH = (config.features.hist.bin_l + config.features.hist.bin_h)/2;
        config.features.hist.NUM_BINS = 32;
        
        % [x0 W S I0], see notes in the header
        config.features.edge.curMin = [35.0    0.05   -8192    config.features.hist.bin_l];
        config.features.edge.curMax = [45.0      30    8192    config.features.hist.bin_h];
    otherwise
        config.name = 'null';
end
