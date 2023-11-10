    % V1 degraded
    ds_index = 1;
    detection_schemes(ds_index).name = 'Velocity of average firing rate peaks V degraded';
    detection_schemes(ds_index).method = 'avg_velocity_peaks';
    detection_schemes(ds_index).features = {'spikes'};

    % detection_schemes(ds_index).Features = {'Raster'};
    detection_schemes(ds_index).time_window = 80; %Average across 80 ms timewindow
%         detection_schemes(ds_index).min_peak_height_sigma = 1; %Default: 1. 0.4 for 210811 How many standard deviations the decision variable should be above its mean at least to detect a switch.
    detection_schemes(ds_index).min_peak_height_sigma = 0.4; %How many standard deviations the decision variable should be above its mean at least to detect a switch.
    detection_schemes(ds_index).min_peak_distance = 80; %The minimum distance between switches.
    detection_schemes(ds_index).b_standardize_units=true; %if true, we normalize each unit first before averaging
    detection_schemes(ds_index).b_use_only_selective=true; % (default true). if true, only use units that were significantly selective during training paradigm
    detection_schemes(ds_index).probe_indices_to_use = []; %Optional, pick which probe indices to use for detection. Default ([]) will use all probes.