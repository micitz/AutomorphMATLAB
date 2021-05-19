% This script locates the natural dune heel and sets the general, local,
% and lat/lon locations of the heel. It looks for the lowest point behind
% the crest that also satisfies the backshore drop. 
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%

% Move the heel down to a low
heel_index = crest_index;
while(heel_index-1 > 1)
   if profiles(heel_index-1,k,3) < profiles(heel_index,k,3)
       heel_index = heel_index-1;
   else
       break
   end 
end
    
heel_index = nanmin(heel_index);

% Set all the appropriate locations
[x_heel, y_heel, local_x_heel, local_y_heel, heel_lon, heel_lat] =...
    set_locations(x_values, local_x_values, profiles, heel_index, k, sp_loc);