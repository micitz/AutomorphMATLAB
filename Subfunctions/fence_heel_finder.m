% This script locates the position of the fenced dune heel. It first
% checks that there is a fenced dune crest on the profile before
% continuing. It then assigns the general, local, and lat/lon 
% position of the fenced dune heel
%
% Michael Itzkin, 3/29/2018
%-------------------------------------------------------------------------%

% Set the fence heel flag to 0. It will get reset to a 1 if there is a
% fenced dune heel
fence_heel_flag = 0;

if exist('fence_crest_index')
    % Only run if there is a fenced dune crest on the profile
    
    % fence_heel_index = fence_crest_index;
    % while profiles(fence_heel_index - 1, k, 3) < profiles(fence_heel_index, k, 3)
    %    fence_heel_index = fence_heel_index - 1
    % end
    
    fenceHeelSection = profiles(crest_index:fence_crest_index, k, 3);
    [fenceHeelPoint, fenceHeelPointIdx] = nanmin(fenceHeelSection);
    fence_heel_index = crest_index + fenceHeelPointIdx;
    
    if ~exist('fence_heel_index') || isempty(fence_heel_index)
        % If there is no fenced dune heel, then set it to NaN
        x_fence_heel = NaN;
        y_fence_heel = NaN;
        local_x_fence_heel = NaN;
        local_y_fence_heel = NaN;
        fence_heel_lon = NaN;
        fence_heel_lat = NaN; 
    else
        
        fence_heel_index = nanmin(fence_heel_index);
        
        % Set the fenced dune heel
        [x_fence_heel, y_fence_heel, local_x_fence_heel,...
            local_y_fence_heel, fence_heel_lon, fence_heel_lat] =...
            set_locations(x_values, local_x_values, profiles,...
            fence_heel_index, k, sp_loc);
        
        % Set the fenced dune toe equal to the fenced dune heel
        x_toe = x_fence_heel;
        y_toe = y_fence_heel;
        local_x_toe = local_x_fence_heel;
        local_y_toe = local_y_fence_heel;
        toe_lon = fence_heel_lon;
        toe_lat = fence_heel_lat;
        
%         fence_heel_flag = 1;
    end
    
else
    
    % Set all the locations to NaN
    x_fence_heel = NaN;
    y_fence_heel = NaN;
    local_x_fence_heel = NaN;
    local_y_fence_heel = NaN;
    fence_heel_lon = NaN;
    fence_heel_lat = NaN;  
    
end

if exist('fence_heel_index')
    % Set the fenced dune toe equal to the fenced dune heel
    x_toe = x_fence_heel;
    y_toe = y_fence_heel;
    local_x_toe = local_x_fence_heel;
    local_y_toe = local_y_fence_heel;
    toe_lon = fence_heel_lon;
    toe_lat = fence_heel_lat;
end