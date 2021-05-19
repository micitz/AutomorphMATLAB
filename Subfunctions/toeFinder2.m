% This script locates the toe on the profile using a third order
% polynomial fit between the dune crest and MHW (Mull and Ruggiero, 2014)
%
% Michael Itzkin, 3/13/2019
%------------------------------------------------------------------------%

% Isolate the area between the crest and MHW or the berm
if exist('berm_index')
    x = x_values(crest_index:berm_index)';
    y = profiles(crest_index:berm_index, k, 3);
else
    x = x_values(crest_index:mhw_index)';
    y = profiles(crest_index:mhw_index, k, 3);
end

% Fit a third order polynomial to the values
fit = polyfit(x, y, 3);
fitEval = polyval(fit, x);

% Subtract the fit from the profile section. Find the minimum
% point on the dterended line and set it as the toe index
detrended = y - fitEval;
detrendMin = nanmin(detrended);
detrendMinIdx = find(detrended == detrendMin);
toe_index = crest_index + detrendMinIdx;

hold on
plot(x, y)
plot(x, fitEval)
plot(x, detrended)
scatter(x(detrendMinIdx), y(detrendMinIdx))

% Set the appropriate locations
[x_toe, y_toe, local_x_toe, local_y_toe, toe_lon, toe_lat] =...
    set_locations(x_values, local_x_values, profiles, toe_index, k, sp_loc);