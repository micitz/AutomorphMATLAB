% This script attempts to filter out buildings from older (pre-2010)
% profiles that may have a dune obscured by a building
%
% Michael Itzkin, 3/27/2019
%-----------------------------------------------------------------------%

% Calculate the difference between the current profile and the 2010
% equivalent of the profile
profileDifference = profiles2010(:, k, 3) - profiles(:, k ,3);

% Calculate the average difference between the current year and
% 2010 as well as two standard deviations
meanDiff = nanmean(profileDifference);
stdDiff =  0.50 * nanstd(profileDifference);

loDiff = meanDiff - stdDiff;
hiDiff = meanDiff + stdDiff;

% Find where the difference profile goes below the loDiff. Add in a 
% "3 index" buffer on each end
possibleBuildingsIdx = find(profileDifference <= loDiff & abs(profileDifference) > 2);

% Add the differences to the current profile
profiles(possibleBuildingsIdx, k, 3) =...
    profiles(possibleBuildingsIdx, k, 3) + profileDifference(possibleBuildingsIdx);
