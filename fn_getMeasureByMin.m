function resultbymin = fn_getMeasureByMin(minutesbaseline, minutespost, nbframes1min, trace, measurement)
    % Returns one value per minute for either 'mean' or 'AUC'
    % Input:
    %   - minutesbaseline, minutespost: durations before and after event
    %   - nbframes1min: number of frames per minute
    %   - trace: 1D signal vector (single rat)
    %   - measurement: 'mean' or 'AUC'
    %
    % Output:
    %   - resultbymin: 1 x (minutesbaseline + minutespost) vector
    
    totalMinutes = minutesbaseline + minutespost;
    resultbymin = zeros(1, totalMinutes);  % preallocate

    % Reshape signal into matrix of [frames per min x minutes]
    totalFramesNeeded = totalMinutes * nbframes1min;
    if length(trace) < totalFramesNeeded
        warning('Trace is shorter than expected (%d frames). Filling remaining minutes with NaNs.', totalFramesNeeded);
        trace(end+1:totalFramesNeeded) = NaN; % pad with NaN
    end

    reshapedTrace = reshape(trace(1:totalMinutes*nbframes1min), nbframes1min, totalMinutes);

    switch lower(measurement)
        case 'mean'
            resultbymin = mean(reshapedTrace, 1, 'omitnan');
        case 'auc'
            resultbymin = trapz(reshapedTrace, 1);
        otherwise
            error('Unknown measurement type: %s. Use ''mean'' or ''AUC''.', measurement);
    end
end