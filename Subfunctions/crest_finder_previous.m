% This script locates the natural dune crest by identifying the location of
% the previous year's natural dune crest
%
% Michael Itzkin, 11/6/2019
%------------------------------------------------------------------------%
clear crest_index lowPoint

% Identify the cross-shore position of the crest from the previous year
previousCrestIndex = find(x_values == original_data(k, 14));
previousXCrest = x_values(previousCrestIndex);

% Find peaks in the current profile
[pks, locs] = findpeaks(profiles(:, k, 3));


if isempty(pks) || isempty(previousXCrest)   
    
    % Find the highest point on the profile if the previous crest is a NaN
    crest_index = find(profiles(:,k,3) == nanmax(profiles(:,k,3)));    
else

    % Find the peak closest to the previous peak
    newLocs = abs(locs - previousCrestIndex);
    locsIndex= find(newLocs == nanmin(newLocs));
    crest_index = locs(locsIndex);
    crest_index = nanmax(crest_index);
    
end

if ~exist('crest_index')
    crest_index = find(profiles(:,k,3) == nanmax(profiles(:,k,3)));
    crest_index = nanmax(crest_index);
end

    
% Set the appropriate locations
[x_crest, y_crest, local_x_crest, local_y_crest, crest_lon, crest_lat] =...
    set_locations(x_values, local_x_values, profiles, crest_index, k, sp_loc);

