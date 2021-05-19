% This script locates the position of the fenced dune crest. It first
% checks that there is a fence on the profile before continuing. It then
% assigns the general, local, and lat/lon position of the fenced dune crest
%
% Michael Itzkin, 3/28/2018
%-------------------------------------------------------------------------%
clear y_fence_crest
    
% Locate peaks in the profile and filter out any below 2m
[fencePks, fenceLocs] = findpeaks(profiles(crest_index+1:fence_index+10,k,3));
fenceLocs = fenceLocs(fencePks > 2);
fencePks = fencePks(fencePks > 2);

% If there are no peaks between the crest and the fence
% then assign NaNs
if isempty(fencePks)
    x_fence_crest = NaN;
    y_fence_crest = NaN;
    local_x_fence_crest = NaN;
    local_y_fence_crest = NaN;
    fence_crest_lon = NaN;
    fence_crest_lat = NaN; 
else

    % Sort the peaks based on their distance
    % from the fence
    fenceLocsDistances = abs(x_values(fenceLocs) - x_values(fence_index));
    [sortedDistances, sortedIdx] = sort(fenceLocsDistances);
    fenceLocs = fenceLocs(sortedIdx);
    fencePks = fencePks(sortedIdx);
    fence_crest_index = fenceLocs(end);

    % Set the appropriate locations
    [x_fence_crest, y_fence_crest, local_x_fence_crest,...
        local_y_fence_crest, fence_crest_lon, fence_crest_lat] =...
        set_locations(x_values, local_x_values, profiles,...
        fence_crest_index, k, sp_loc);

end

% If no fence then assign NaN values
if ~exist('x_fence_crest')
    x_fence_crest = NaN;
    y_fence_crest = NaN;
    local_x_fence_crest = NaN;
    local_y_fence_crest = NaN;
    fence_crest_lon = NaN;
    fence_crest_lat = NaN;   
end

