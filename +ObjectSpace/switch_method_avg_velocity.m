function detection_result = switch_method_avg_velocity(detection_scheme,training_timecourse,testing_timecourse)

        %Smooth
        training_timecourse_smoothed = smoothdata(training_timecourse',2,'movmean',detection_scheme.time_window);
        testing_timecourse_smoothed = smoothdata(testing_timecourse',2,'movmean',detection_scheme.time_window);
%         training_timecourse_smoothed = smooth(training_timecourse,detection_scheme.time_window,'moving');
%         testing_timecourse_smoothed = movmean(double(testing_timecourse'),detection_scheme.time_window,2);
        if detection_scheme.b_standardize_units
            training_timecourse_standardized = normalize_neurons(training_timecourse_smoothed,training_timecourse_smoothed,1,3);
            testing_timecourse_standardized = normalize_neurons(testing_timecourse_smoothed,training_timecourse_smoothed,1,3);
            training_timecourse_avg_across_units = nanmean(training_timecourse_standardized,1);
            testing_timecourse_avg_across_units = nanmean(testing_timecourse_standardized,1);
        else
            training_timecourse_avg_across_units = nanmean(training_timecourse,1);
            testing_timecourse_avg_across_units = nanmean(testing_timecourse,1);
        end
        training_velocity = [nan(1, detection_scheme.time_window), training_timecourse_avg_across_units(:,(1+1.5*detection_scheme.time_window):end - 0.5*detection_scheme.time_window) - training_timecourse_avg_across_units(:,(1+0.5*detection_scheme.time_window):(end-1.5*detection_scheme.time_window)), nan(1, detection_scheme.time_window)];
        testing_velocity = [nan(1, detection_scheme.time_window), testing_timecourse_avg_across_units(:,(1+1.5*detection_scheme.time_window):end - 0.5*detection_scheme.time_window) - testing_timecourse_avg_across_units(:,(1+0.5*detection_scheme.time_window):(end-1.5*detection_scheme.time_window)), nan(1, detection_scheme.time_window)];
        sigma = nanstd(training_velocity);
        if isfield(detection_scheme,'min_peak_height')
            min_peak_height = detection_scheme.min_peak_height;
        else
            min_peak_height = nanmean(training_velocity) + detection_scheme.min_peak_height_sigma * sigma;
        end
        
        [pks, switch_times] = findpeaks(testing_velocity,'MinPeakHeight',min_peak_height,'MinPeakDistance',detection_scheme.min_peak_distance);
        detection_result.switch_times = switch_times;
        detection_result.decision_variable = testing_velocity;
