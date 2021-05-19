% This script locates the natural dune heel and sets the general, local,
% and lat/lon locations of the heel. It looks for the lowest point behind
% the crest that also satisfies the backshore drop. 
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%

% Subtract 0.6m from the crest elevation and then move landwards
% until that elevation is identified.
heelElevation = y_crest - 0.6;
heel_index = crest_index;
while (heel_index > 1) &&...
        (profiles(heel_index,k,3) > heelElevation) &&...
        (profiles(heel_index-1, k, 3) < (y_crest * 1.10))
    heel_index = heel_index - 1;
end

% Determine what to do next
if heel_index == 1
    
    % If the heel index is equal to 1, use a stretched sheet method
    % from 1 to the crest index
    profile_copy = profiles(:,k,3);
    linear_component = linspace(1, y_crest,...
        length(1:crest_index));
    profile_copy(1:crest_index) = linear_component;
    dists = profile_copy - profiles(:,k,3);
    heel_index = find(dists == nanmax(dists));
    while(heel_index-1 > 1)
       if profiles(heel_index-1,k,3) < profiles(heel_index,k,3)
           heel_index = heel_index-1;
       else
           break
       end 
    end
    heel_index = nanmin(heel_index);
else
    
    % Move the heel to a local minima
    while(heel_index-1 > 1)
       if profiles(heel_index-1,k,3) < profiles(heel_index,k,3)
           heel_index = heel_index - 1;
       else
           break
       end 
    end    
    
    while(heel_index + 1 < crest_index)
       if profiles(heel_index+1,k,3) < profiles(heel_index,k,3)
           heel_index = heel_index + 1;
       else
           break
       end 
    end    
end



% profile_copy = profiles(:,k,3);
% linear_component = linspace(profiles(heel_index,k,3), y_crest,...
%     length(heel_index:crest_index));
% profile_copy(heel_index:crest_index) = linear_component;
% dists = profile_copy - profiles(:,k,3);
% heel_index = find(dists == nanmax(dists));

if length(heel_index) > 1 || heel_index == 1 || heel_index == crest_index
    heel_finder
else
    
    % Set all the appropriate locations
    [x_heel, y_heel, local_x_heel, local_y_heel, heel_lon, heel_lat] =...
        set_locations(x_values, local_x_values, profiles, heel_index, k, sp_loc);
end