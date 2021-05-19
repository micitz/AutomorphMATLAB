% This script locates the natural dune crest on the profile. It then store
% the location as a local value, general value, and lat/lon. It uses the
% crest definition from Mull and Ruggiero (2014) where the crest must have
% a backshore drop of 0.6m
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%
clear crest_index

% Find peaks in the profile. Filter out for a threshold based on whether or
% not sand fences are present. Choose a higher threshold for sand fenced
% profiles in order to ensure that the fenced dune is not selected. Remove
% any peaks above 10m to nsure that houses are not selected
[pks, locs] = findpeaks(profiles(:,k,3));
locs = locs(pks < 10);
pks = pks(pks < 10);
new_pks_inds = find(pks > crest_threshold);
threshold_pks = pks(new_pks_inds);
threshold_locs = locs(new_pks_inds);
    

% If there are no peaks, just pick the higherst point in profile
if isempty(locs)
    
    crest_index = find(profiles(:,k,3) == nanmax(profiles(:,k,3)));
    ignore_slope_threshold = 1;
    
else
    
    ignore_slope_threshold = 1;
    
    % Loop through each peak in the profile. Start at the peak and work
    % landward to see the decrease. If the drop exceeds the
    % backshore_drop than stop the loop and set the peak as the crest
    for peak = length(threshold_pks):-1:1
        
        if peak == 1
            ignore_slope_threshold = 1;
        else
            ignore_slope_threshold = 0;
        end
        
        look_index = threshold_locs(peak)-1;
        while (profiles(look_index,k,3) <= profiles(threshold_locs(peak),k,3))...
                && (look_index-1 > 0) && profiles(look_index,k,3) > MHW
            
            % Calculate the vertical distance between the current
            % look_index and the peak
            drop = abs(profiles(threshold_locs(peak),k,3)-profiles(look_index,k,3));

            if drop >= backshore_drop
                % If the drop exceeds the backshore_drop than set the
                % current peak location as the crest_index and break the
                % while loop
                crest_index = threshold_locs(peak);
                
                % The indexes and peak locations increase seawards if the next seaward
                % peak is reasonably close in elevation the to the crest than it should
                % be set as the crest instead of what the crest will be set as at this
                % point. Set a buffer and see if any of the peaks seaward of the
                % current crest are greater than or equal to the buffer elevation. If
                % so, set that as the crest. Set the buffer in the main script
                crest_loc_index = find(crest_index==locs); % Find which loc is the crest
                buffer = pks(crest_loc_index) * (1-buffer_pct); % Set the buffer
                if ~(crest_loc_index == length(locs)) % If the current loc is not the most seaward
                    while (crest_loc_index+1 <= length(locs))
                        % While the next loc is not out of index
                        if pks(crest_loc_index+1) >= buffer
                            % If the next seaward peak is greater than the buffer
                            crest_index = locs(crest_loc_index + 1); % Make the crest the next seaward peak
                            buffer = pks(crest_loc_index) * (1-buffer_pct); % Reset the buffer
                            crest_loc_index = crest_loc_index + 1; % Increment the loc
                        else
                            crest_loc_index = crest_loc_index + 1; % Increment the loc
                        end
                    end
                end
                
                break
            end

            look_index = look_index - 1;

        end

        if exist('crest_index')
            % If the crest_index has been set than break out of the for
            % loop
            break
        end

    end
    
end

if ~exist('crest_index')
    crest_index = find(profiles(:,k,3) == nanmax(profiles(:,k,3)));
    ignore_slope_threshold = 1;
end

crest_index = nanmin(crest_index);

% Set the appropriate locations
[x_crest, y_crest, local_x_crest, local_y_crest, crest_lon, crest_lat] =...
    set_locations(x_values, local_x_values, profiles, crest_index, k, sp_loc);

% Dynamically update the crest_threshold value as profiles are analyzed.
% Store the values in a matrix with a row for each pass (2) and a column
% for each profile
if (k == 1) && (pass == 1)
    crest_threshold = nanmean([crest_threshold, y_crest]);
elseif pass == 1
    crest_threshold = nanmean([all_thresholds(1,1:k-1), y_crest]);
elseif (k == 1) && (pass == 2)
    crest_threshold = nanmean([all_thresholds(1,:), y_crest]);
elseif pass == 2
    crest_threshold = nanmean([all_thresholds(1,:), all_thresholds(2,1:k-1), y_crest]);
end
all_thresholds(pass, k) = crest_threshold;