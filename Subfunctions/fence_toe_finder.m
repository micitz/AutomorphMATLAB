% This script locates the position of the fenced dune toe. It first
% checks that there is a fenced dune crest on the profile before
% continuing. It then assigns the general, local, and lat/lon 
% position of the fenced dune toe
%
% Michael Itzkin, 4/4/2018
% Modified 4/22/2020: Calculate from MHW to Fhigh if index is 1
%-------------------------------------------------------------------------%

if exist('fence_crest_index') && ~isnan(x_fence_crest)
    
    % Make a copy of the current profile, and then replace the part between MHW
    % and the fenced dune crest with a straight line
    profile_copy = profiles(:,k,3);

    linear_component = linspace(y_fence_crest, y_twoMeter,...
                length(fence_crest_index:twoMeter_index));
    profile_copy(fence_crest_index:twoMeter_index) = linear_component;

    % Subtract the profile_copy from the profile and take the absolute values.
    % Then identify where the greatest value is and set it as the fenced dune
    % toe index
    dists = profile_copy - profiles(:,k,3);
    fence_toe_index = find(dists == nanmax(dists));

    fence_toe_index = nanmin(fence_toe_index);
    
    % Set the appropriate locations
    [x_fence_toe, y_fence_toe, local_x_fence_toe, local_y_fence_toe,...
        fence_toe_lon, fence_toe_lat] = set_locations(x_values,...
        local_x_values, profiles, fence_toe_index, k, sp_loc);
end

% Recalculate the fenced dune toe position if the fenced dune
% toe is placed at the end of the profile
if exist('fence_toe_index') && (fence_toe_index == 1)
    
    % Recalculate the stretched sheet from MHW
    linear_component = linspace(y_fence_crest, y_mhw,...
                length(fence_crest_index:mhw_index));
    profile_copy(fence_crest_index:mhw_index) = linear_component;
    
    
    % Subtract the profile_copy from the profile and take the absolute values.
    % Then identify where the greatest value is and set it as the fenced dune
    % toe index
    dists = profile_copy - profiles(:,k,3);
    fence_toe_index = find(dists == nanmax(dists));

    fence_toe_index = nanmin(fence_toe_index);
    
    % Set the appropriate locations
    [x_fence_toe, y_fence_toe, local_x_fence_toe, local_y_fence_toe,...
        fence_toe_lon, fence_toe_lat] = set_locations(x_values,...
        local_x_values, profiles, fence_toe_index, k, sp_loc);
    
end