% This script locates the natural dune crest on the profile using the mean
% and standard deviation of the natural dune crest position on profiles
% with a fenced dune crest
%
% Michael Itzkin, 4/10/2019
%------------------------------------------------------------------------%
clear crest_index lowPoint

backshore_drop = 0.6;
buffer_pct = 0.10;

meanXCrestFenced = nanmean(useMorpho(~isnan(useMorpho(:,8)),14));
stdXCrestFenced = nanstd(useMorpho(~isnan(useMorpho(:,8)),14));
max_lim = meanXCrestFenced - (2.0 * stdXCrestFenced);

% Find peaks in the profile. Remove any that are lower than 2m or greater
% than 12m
[pks, locs] = findpeaks(profiles(:,k,3));
locs = locs(pks > 2.5 & pks < 12);
pks = pks(pks > 2.5 & pks < 12);
pks = pks(x_values(locs) > max_lim);
locs = locs(x_values(locs) > max_lim);
locs = flip(locs);
pks = flip(pks);

if isempty(pks)    
crest_index = find(profiles(:,k,3) == nanmax(profiles(:,k,3)));    
else
[crest_index, lowPoint] =...
    peakLoop(pks, locs, k, profiles, backshore_drop, 0);    
if crest_index == 1000000
    [crest_index, lowPoint] = peakLoop(pks, locs, k, profiles, 0, 0);
    if crest_index == 1000000
        crest_index = find(profiles(:,k,3) == nanmax(profiles(:,k,3)));
    end
end

bufferLocs = locs(locs > crest_index & locs < fence_crest_index);
bufferPeaks = pks(locs > crest_index & locs < fence_crest_index);
bufferLocs =...
    bufferLocs((bufferPeaks < profiles(crest_index,k,3)) &...
    (bufferPeaks >= (profiles(crest_index,k,3) * (1 - buffer_pct))));
while ~isempty(bufferLocs)
    crest_index = bufferLocs(end);
    bufferLocs = locs(locs > crest_index);
    bufferPeaks = pks(locs > crest_index);
    bufferLocs =...
        bufferLocs((bufferPeaks < profiles(crest_index,k,3)) &...
                   (bufferPeaks >= profiles(crest_index,k,3) * (1 - buffer_pct)));
end
    
end
if ~exist('crest_index')
    crest_index = find(profiles(:,k,3) == nanmax(profiles(:,k,3)));
end

    
% Set the appropriate locations
[x_crest, y_crest, local_x_crest, local_y_crest, crest_lon, crest_lat] =...
    set_locations(x_values, local_x_values, profiles, crest_index, k, sp_loc);


function [crest_index, lowPoint] = peakLoop(pks, locs, k, profiles, threshold, fenceFlag)
    % Loop through the peaks to determine where the crest
    % is located on the profile
    
    crest_index = 1000000;
    lowPoint = 1000000;
    
    if fenceFlag == 1
        
        % Loop through the peaks
        for pp = 1:length(pks)

            % Identify the current peak and the height of the next
            % landward peak that is taller
            currPeak = pks(pp);
            currPeakLoc = locs(pks == currPeak);
            nextPeaks = pks(pks > currPeak);
            if ~isempty(nextPeaks) && length(pks) > 1
                nextPeak = nextPeaks(1);
                nextPeakLoc = locs(pks == nextPeak);
            else
                nextPeak = profiles(1, k, 3);
                nextPeakLoc = 1;
            end

            % Find the lowest point between the current peak and the next peak
            lowPoint = nanmin(profiles(nextPeakLoc:currPeakLoc, k, 3));

            % If the difference between the current peak and the low point
            % is in agreement with the backshore drop then set it as the crest
            if (currPeak - lowPoint) >= threshold
                crest_index = currPeakLoc;
                break
            else
                crest_index = 1000000;
            end


        end
        
    else
    
        % Loop through the peaks
        for pp = 1:length(pks)-1

            % Identify the current peak and the height of the next
            % landward peak that is taller
            currPeak = pks(pp);
            currPeakLoc = locs(pks == currPeak);
            nextPeaks = pks(pks > currPeak);
            if ~isempty(nextPeaks) && length(pks) > 1
                nextPeak = nextPeaks(1);
                nextPeakLoc = locs(pks == nextPeak);
            else
                nextPeak = profiles(1, k, 3);
                nextPeakLoc = 1;
            end

            % Find the lowest point between the current peak and the next peak
            lowPoint = nanmin(profiles(nextPeakLoc:currPeakLoc, k, 3));

            % If the difference between the current peak and the low point
            % is in agreement with the backshore drop then set it as the crest
            if (currPeak - lowPoint) >= threshold
                crest_index = currPeakLoc;
                break
            else
                crest_index = 1000000;
            end


        end
        
    end
    crest_index = crest_index(1);
end