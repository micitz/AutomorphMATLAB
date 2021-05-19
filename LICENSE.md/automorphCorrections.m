% This script allows you to automatically correct morphometrics on profiles.
% Use it to correct profiles that were analyzed incorrectly. This script
% assumes that everything has already been analyzed and .m files exist
%
% Some manual adjustment may still be needed afterwards!
%
% Michael Itzkin, 3/20/2019
%------------------------------------------------------------------------%
close all
clear all
clc


addpath('Subfunctions')
sp_loc = 'north carolina';

% Identify the sections that need corrections. The X sections will
% have to be done separately
% Check the settings in the crest finder before running!
correctSections = 'A':'Z';

% Loop through the years
years = [1997, 1998, 1999, 2000, 2004, 2005, 2010, 2011,...
    2014, 2016, 2017, 2018];
for yy = 12
    for ss = 1:length(correctSections)        
        clc
        
        location = sprintf('Bogue %s ', correctSections(ss));
        year = num2str(years(yy));
        lastYear = num2str(years(yy - 1));
        
        % Turn fences off before 2010
        if years(yy) < 2010 || strcmp(correctSections(ss), 'Z')
            fenced = 0;
        else
            fenced = 1;
            fence_finder
        end
        
        % Set a general path
        genPath = sprintf('Bogue %s%s%s%s',...
            correctSections(ss), filesep, num2str(years(yy)), filesep);
        gen1997Path = sprintf('Bogue %s%s1997%s',...
            correctSections(ss), filesep, filesep);
        gen2010Path = sprintf('Bogue %s%s2010%s',...
            correctSections(ss), filesep, filesep);
        genPrevPath = sprintf('Bogue %s%s%s%s',...
            correctSections(ss), filesep, lastYear, filesep);
   
        % Load the profiles for the current year
        useY = load(sprintf('%sProfiles for Bogue %s %s.mat',...
            genPath, correctSections(ss), num2str(years(yy))));
        profiles = useY.profiles;
        
        x_values = load(sprintf('%sX Values for Bogue %s %s.mat',...
            genPath, correctSections(ss), num2str(years(yy))));
        x_values = x_values.x_values';
        
        localUseX = load(sprintf('%sLocal X Values for Bogue %s %s.mat',...
            genPath, correctSections(ss), num2str(years(yy))));
        localUseX = localUseX.local_x_values;
        
        useMorpho = csvread(sprintf('%sMorphometrics for Bogue %s %s.csv',...
            genPath, correctSections(ss), num2str(years(yy))), 1, 0);
        
        % Copy the unmodified morphometrics in case there is an issue
        dlmwrite(sprintf('%sMorphometrics for Bogue %s %s Original.csv',...
            genPath, correctSections(ss), num2str(years(yy))), useMorpho,...
            'delimiter', ',', 'precision', 10)
        
        % Load the morphometrics for 1997
        morpho1997 = csvread(sprintf('%sMorphometrics for Bogue %s 1997.csv',...
            gen1997Path, correctSections(ss)), 1, 0);
        
        % Load the morphometrics for 2010
        morpho2010 = csvread(sprintf('%sMorphometrics for Bogue %s 2010.csv',...
            gen2010Path, correctSections(ss)), 1, 0);
        
        % Load the morphometrics for the previous year
        original_data = csvread(sprintf('%sMorphometrics for Bogue %s %s.csv',...
            genPrevPath, correctSections(ss), lastYear), 1, 0);
        
        % Load the profiles for 2010
        useY2010 = load(sprintf('%sProfiles for Bogue %s 2010.mat',...
            gen2010Path, correctSections(ss)));
        profiles2010 = useY2010.profiles;
        
        x_values2010 = load(sprintf('%sX Values for Bogue %s 2010.mat',...
            gen2010Path, correctSections(ss)));
        x_values2010 = x_values2010.x_values';
        
        localUseX2010 = load(sprintf('%sLocal X Values for Bogue %s 2010.mat',...
            gen2010Path, correctSections(ss)));
        localUseX2010 = localUseX2010.local_x_values;
        
        % Set useMorpho to all NaNs
        [rows, cols] = size(useMorpho);
        useMorpho = NaN(rows, 88);
        
        % Fill missing values
        profiles = fillmissing(profiles,...
            'linear', 2,...
            'EndValues', 'nearest');
        
        % Loop through the profiles to correct
        for pass = 1
            for k = 1:(length(morpho1997(:,1)))

                fprintf('Current Profile: Bogue %s %s, Profile %s (Pass %s)\n',...
                    correctSections(ss), num2str(years(yy)), num2str(k), num2str(pass))
                
                % Profile number in column 1
                useMorpho(k, 1) = k;
                
                % If the year is earlier than 2010, mask out any possible
                % buildings obscuring the profile. Only run if the tallest
                % point in the profile is greater than 8m since there might
                % just be a lot of variation and no building
%                 meanDEM = nanmean(nanmean(profiles(:, :, 3)));
%                 stdDEM = nanstd(nanstd(profiles(:, :, 3)));
%                 thresh = meanDEM;
%                 if (nanmax(profiles(:, k, 3)) >= thresh) &&...
%                         (years(yy) < 2010) &&...
%                         ~strcmp(correctSections(ss), 'Z')
%                     ghostProfile = profiles(:, k, 3);
%                     buildingMask
%                 end
                
                % Apply a loess smoothing filter
                profiles(:, k, 3) = loess(profiles(:, k, 3), x_values, x_values, 5); 

                % Calculate the average Dhigh positions to add in a reference
                % line to help decide where to place the crest
                meanXCrest = nanmean(useMorpho(:, 14));
                stdXCrest = nanstd(useMorpho(:, 14));
                meanYCrest = nanmean(useMorpho(:, 15));
                stdYCrest = nanstd(useMorpho(:, 15));

                % Select MHW. This one is automated since it 
                % is just finding a contour and is always accurate
                MHW = 0.34;
                mhw_finder
                useMorpho(k,2) = x_mhw;
                useMorpho(k,3) = y_mhw;
                useMorpho(k, 18) = local_x_mhw;
                useMorpho(k, 19) = local_y_mhw;
                useMorpho(k, 34) = mhw_lon;
                useMorpho(k, 35) = mhw_lat;

                % Select the 2m contour. This one is automated since it 
                % is just finding a contour and is always accurate
                % Find the closest point on the profile to MHW
                twoMeter_index = mhw_index;
                while (twoMeter_index - 1) > 0
                    if profiles(twoMeter_index - 1, k, 3) > 2 &&...
                            profiles(twoMeter_index, k ,3) < 2
                        break
                    else
                        twoMeter_index = twoMeter_index - 1;
                    end
                end
                [x_twoMeter, y_twoMeter, local_x_twoMeter, local_y_twoMeter, twoMeter_lon, twoMeter_lat] =...
                    set_locations(x_values, local_x_values, profiles,...
                    twoMeter_index, k, sp_loc);
                useMorpho(k,72) = x_twoMeter;
                useMorpho(k,73) = y_twoMeter;
                useMorpho(k, 74) = local_x_twoMeter;
                useMorpho(k, 75) = local_y_twoMeter;
                useMorpho(k, 76) = twoMeter_lon;
                useMorpho(k, 77) = twoMeter_lat;

                % Select the dune crest
                if pass == 1
                    % crest_finder_mull_ruggiero_2014_corrections
                    crest_finder_previous
                    useMorpho(k,14) = x_crest;
                    useMorpho(k,15) = y_crest;
                    useMorpho(k, 30) = local_x_crest;
                    useMorpho(k, 31) = local_y_crest;
                    useMorpho(k, 46) = crest_lon;
                    useMorpho(k, 47) = crest_lat;
                elseif pass == 2
                    crest_finder_fence_adjust
                    useMorpho(k,14) = x_crest;
                    useMorpho(k,15) = y_crest;
                    useMorpho(k, 30) = local_x_crest;
                    useMorpho(k, 31) = local_y_crest;
                    useMorpho(k, 46) = crest_lon;
                    useMorpho(k, 47) = crest_lat;
                end

                % Select the dune toe
                toe_finder_corrections
                useMorpho(k,12) = x_toe;
                useMorpho(k,13) = y_toe;
                useMorpho(k, 28) = local_x_toe;
                useMorpho(k, 29) = local_y_toe;
                useMorpho(k, 44) = toe_lon;
                useMorpho(k, 45) = toe_lat;          

                % Select the berm
                berm_finder
                useMorpho(k,60) = x_berm;
                useMorpho(k,61) = y_berm;
                useMorpho(k, 62) = local_x_berm;
                useMorpho(k, 63) = local_y_berm;
                useMorpho(k, 64) = berm_lon;
                useMorpho(k, 65) = berm_lat;
                
                % Try a new toe using the berm if the old toe did
                % not work
                if useMorpho(k, 12) == x_values(1)
                    toe_finder_corrections
                    useMorpho(k,12) = x_toe;
                    useMorpho(k,13) = y_toe;
                    useMorpho(k, 28) = local_x_toe;
                    useMorpho(k, 29) = local_y_toe;
                    useMorpho(k, 44) = toe_lon;
                    useMorpho(k, 45) = toe_lat;    
                end

                % Select the dune heel
                heel_finder2
                useMorpho(k,16) = x_heel;
                useMorpho(k,17) = y_heel;
                useMorpho(k, 32) = local_x_heel;
                useMorpho(k, 33) = local_y_heel;
                useMorpho(k, 48) = heel_lon;
                useMorpho(k, 49) = heel_lat;
                
                % Set the crest to be the tallest point
                % between the toe and the heel
                if toe_index >= heel_index
                    lookIdx = heel_index:toe_index;
                    crest_index_max = find(profiles(lookIdx, k, 3) == nanmax(profiles(lookIdx, k, 3)));
                    crest_index_max = crest_index_max + heel_index;
                else
                    lookIdx = toe_index:toe_index;
                    crest_index_max = find(profiles(lookIdx, k, 3) == nanmax(profiles(lookIdx, k, 3)));
                    crest_index_max = crest_index_max + toe_index;
                end
                if ~isempty(crest_index_max)
                    [x_crest, y_crest, local_x_crest, local_y_crest,...
                        crest_lon, crest_lat] =...
                        set_locations(x_values, local_x_values, profiles,...
                        crest_index_max, k, sp_loc);
                    useMorpho(k,14) = x_crest;
                    useMorpho(k,15) = y_crest;
                    useMorpho(k, 30) = local_x_crest;
                    useMorpho(k, 31) = local_y_crest;
                    useMorpho(k, 46) = crest_lon;
                    useMorpho(k, 47) = crest_lat;
                    
                    crest_index = crest_index_max;
                end

                % Calculate the natural dune volume
                natural_dune_volume_finder
                useMorpho(k, 50) = natural_dune_volume;

                % If a fence exists and is seaward of
                % the natural dune crest, run extra methods
                if fenced 
                    
                    fenceCounter = 1;
                    
                    % Find the fence location
                    fence_locator
                    useMorpho(k, 6) = x_fence;
                    useMorpho(k, 7) = y_fence;
                    useMorpho(k, 22) = local_x_fence;
                    useMorpho(k, 23) = local_y_fence;
                    useMorpho(k, 38) = fence_lon;
                    useMorpho(k, 39) = fence_lat;
                    
                    if exist('fence_index') && fence_index >= crest_index
                        
                        % Find the fenced dune crest
                        fence_crest_finder
                        useMorpho(k, 8) = x_fence_crest;
                        useMorpho(k, 9) = y_fence_crest;
                        useMorpho(k, 24) = local_x_fence_crest;
                        useMorpho(k, 25) = local_y_fence_crest;
                        useMorpho(k, 40) = fence_crest_lon;
                        useMorpho(k, 41) = fence_crest_lat;
                        
                        % Find the fenced dune heel
                        if isnan(useMorpho(k, 9))
                            useMorpho(k, [10, 11, 26, 27, 42, 43]) = NaN;
                        else
                            fence_heel_finder
                            useMorpho(k, 10) = x_fence_heel;
                            useMorpho(k, 11) = y_fence_heel;
                            useMorpho(k, 26) = local_x_fence_heel;
                            useMorpho(k, 27) = local_y_fence_heel;
                            useMorpho(k, 42) = fence_heel_lon;
                            useMorpho(k, 43) = fence_heel_lat;
                        end
                        
                        % Find the fenced dune toe
                        fence_toe_finder
                        if exist('x_fence_toe')
                            useMorpho(k, 4) = x_fence_toe;
                            useMorpho(k, 5) = y_fence_toe;
                            useMorpho(k, 20) = local_x_fence_toe;
                            useMorpho(k, 21) = local_y_fence_toe;
                            useMorpho(k, 36) = fence_toe_lon;
                            useMorpho(k, 37) = fence_toe_lat;
                        end 
                        
                    end
                    
                end
                
                % Calculate the fenced dune volume
                fenced_dune_volume_finder
                if exist('fenced_dune_volume')
                    useMorpho(k, 51) = fenced_dune_volume;
                else
                    useMorpho(k, 51) = NaN;
                end

                % Calculate the total dune volume
                if isnan(useMorpho(k, 51))
                    useMorpho(k, 52) = useMorpho(k, 50);
                else
                    useMorpho(k, 52) = useMorpho(k, 50) + useMorpho(k, 51);
                end

                % Calculate the beach width
                beach_width_finder
                useMorpho(k, 53) = beach_width;

                % Calculate the position of the 1997 Dhigh
                if years(yy) == 1997
                    useMorpho(k, 54) = y_crest;
                    useMorpho(k, 55) = crest_index;
                else
                    crestIndex1997 = morpho1997(k, 55);
                    useMorpho(k, 54) = profiles(crestIndex1997, k, 3);
                    useMorpho(k, 55) = morpho1997(k, 55);
                end
                
                % Calculate the position of the 2010 Dhigh
                if years(yy) == 2010
                    useMorpho(k, 81) = y_crest;
                    useMorpho(k, 82) = crest_index;
                elseif years(yy) > 2010
                    crestIndex2010 = morpho2010(k, 82);
                    useMorpho(k, 81) = profiles(crestIndex2010, k, 3);
                    useMorpho(k, 82) = morpho2010(k, 55);
                elseif years(yy) < 2010
                    useMorpho(k, 81) = NaN;
                    useMorpho(k, 82) = NaN;
                end
                
                % Calculate the position of the 2010 Fhigh
                if exist('fence_crest_index') &&...
                        years(yy) == 2010
                    useMorpho(k, 56) = profiles(fence_crest_index, k, 3);
                    useMorpho(k, 57) = fence_crest_index;
                elseif years(yy) > 2010 && ~isnan(morpho2010(k, 55))
                    fCrestIndex2010 = morpho2010(k, 55);
                    useMorpho(k, 56) = profiles(fCrestIndex2010, k, 3);
                    useMorpho(k, 57) = morpho2010(k, 57);
                else
                    useMorpho(k, 56) = NaN;
                    useMorpho(k, 57) = NaN;
                end

                % Calculate the volume contained within the 1997
                % dune position
                if years(yy) == 1997
                    idxToe1997 = toe_index;
                    idxHeel1997 = heel_index;
                    useMorpho(k, 66) = idxToe1997;
                    useMorpho(k, 67) = idxHeel1997;
                else
                    idxToe1997 = morpho1997(k, 66);
                    idxHeel1997 = morpho1997(k, 67);
                    useMorpho(k, 66) = idxToe1997;
                    useMorpho(k, 67) = idxHeel1997;
                end
                if idxHeel1997 == idxToe1997
                    useMorpho(k, 68) = NaN;
                else
                    useMorpho(k, 68) =...
                        abs(trapz(x_values(idxHeel1997:idxToe1997),...
                        profiles(idxHeel1997:idxToe1997, k, 3)));
                end
                
                % Calculate the volume contained within the
                % 2010 dune position
                if years(yy) == 2010
                    idxToe2010 = toe_index;
                    idxHeel2010 = heel_index;
                    useMorpho(k, 83) = idxToe2010;
                    useMorpho(k, 84) = idxHeel2010;
                elseif years(yy) > 2010
                    idxToe2010 = morpho2010(k, 83);
                    idxHeel2010 = morpho2010(k, 84);
                    useMorpho(k, 83) = idxToe2010;
                    useMorpho(k, 84) = idxHeel2010;
                end
                if years(yy) >= 2010
                    if idxHeel2010 == idxToe2010
                        useMorpho(k, 85) = NaN;
                    else
                        useMorpho(k, 85) =...
                            abs(trapz(x_values(idxHeel2010:idxToe2010),...
                            profiles(idxHeel2010:idxToe2010, k, 3)));
                    end
                end
                
                % Calculate the volume contained within the 2010
                % fenced dune position
                if exist('fence_toe_index') && exist('fence_heel_index') && years(yy) == 2010
                    idxFenceToe2010= fence_toe_index;
                    idxFenceHeel2010 = fence_heel_index;
                    useMorpho(k, 78) = idxFenceToe2010;
                    useMorpho(k, 79) = idxFenceHeel2010;
                elseif years(yy) > 2010 &&...
                        ~isnan(morpho2010(k, 78)) &&...
                        ~isnan(morpho2010(k, 79))
                    idxFenceToe2010 = morpho2010(k, 78);
                    idxFenceHeel2010 = morpho2010(k, 79);
                    useMorpho(k, 78) = idxFenceToe2010;
                    useMorpho(k, 79) = idxFenceHeel2010;
                else
                    useMorpho(k, 78) = NaN;
                    useMorpho(k, 79) = NaN;
                end
                if exist('idxFenceHeel2010') && exist('idxFenceToe2010')
                    if idxFenceHeel2010 == idxFenceToe2010
                        useMorpho(k, 80) = NaN;
                    else
                        useMorpho(k, 80) =...
                            abs(trapz(x_values(idxFenceHeel2010:idxFenceToe2010),...
                            profiles(idxFenceHeel2010:idxFenceToe2010, k, 3)));
                    end
                end
                
                % Calculate the volume contained within
                % the 1997 beach position
                if years(yy) == 1997
                    idxToe1997 = toe_index;
                    idxMHW1997 = mhw_index;
                    useMorpho(k, 69) = idxToe1997;
                    useMorpho(k, 70) = idxMHW1997;
                else
                    idxToe1997 = morpho1997(k, 69);
                    idxMHW1997 = morpho1997(k, 70);
                    useMorpho(k, 69) = idxToe1997;
                    useMorpho(k, 70) = idxMHW1997;
                end
                if idxMHW1997 == idxToe1997
                    useMorpho(k, 71) = NaN;
                elseif idxMHW1997 > idxToe1997
                    useMorpho(k, 71) =...
                    abs(trapz(x_values(idxToe1997:idxMHW1997),...
                    profiles(idxToe1997:idxMHW1997, k, 3)));
                else
                    useMorpho(k, 71) =...
                    abs(trapz(x_values(idxMHW1997:idxToe1997),...
                    profiles(idxMHW1997:idxToe1997, k, 3)));
                end
                
                % Calculate the volume contained within
                % the 2010 beach position
                if years(yy) == 2010
                    idxToe2010 = toe_index;
                    idxMHW2010 = mhw_index;
                    useMorpho(k, 86) = idxToe2010;
                    useMorpho(k, 87) = idxMHW2010;
                else
                    idxToe2010 = morpho2010(k, 86);
                    idxMHW2010 = morpho2010(k, 87);
                    useMorpho(k, 86) = idxToe2010;
                    useMorpho(k, 87) = idxMHW2010;
                end
                if years(yy) >= 2010
                    if idxMHW2010 == idxToe2010
                        useMorpho(k, 88) = NaN;
                    elseif idxMHW2010 > idxToe2010
                        useMorpho(k, 88) =...
                        abs(trapz(x_values(idxToe2010:idxMHW2010),...
                        profiles(idxToe2010:idxMHW2010, k, 3)));
                    else
                        useMorpho(k, 88) =...
                        abs(trapz(x_values(idxMHW2010:idxToe2010),...
                        profiles(idxMHW2010:idxToe2010, k, 3)));
                    end
                end
                
                % Calculate the beach slope and the foreshore slope
                beach_slope_finder
                useMorpho(k, 58) = beach_slope;
                useMorpho(k, 59) = foreshore_slope;

                % Re-plot the profile
                profile_plotter
                
                % Clear variables that update with every profile
                % NOTE: Fenced dune crest index is not cleared!!!
                clear beach_slope beach_width berm_index berm_lat...
                    berm_line berm_locs berm_lon berm_pks berm_profile...
                    crest_index crest_lat crest_lon dists foreshore_slope...
                    heel_index heel_lat heel_lon high_dists high_elevation...
                    high_elevation_index idxHeel1997 idxMHW1997 idxToe1997...
                    integral_line integral_profile ix linear_component...
                    local_x_berm local_x_crest local_x_heel local_x_mhw...
                    local_x_toe local_y_berm local_y_crest local_y_heel...
                    local_y_mhw local_y_toe low_dists low_elevation...
                    low_elevation_index mhw_index mhw_lat mhw_lon...
                    profile_copy regress_range toe_index toe_lat toe_lon...
                    x_berm x_crest x_heel x_mhw x_toe y_berm y_crest...
                    y_heel y_mhw y_toe ghostProfile x_fence y_fence...
                    x_fence_toe y_fence_toe x_fence_crest y_fence_crest...
                    x_fence_heel y_fence_heel local_x_fence local_y_fence...
                    local_x_fence_toe local_y_fence_toe local_x_fence_crest...
                    local_y_fence_crest local_x_fence_heel local_y_fence_heel...
                    fence_lon fence_lat fence_toe_lon fence_toe_lat...
                    fence_crest_lon fence_crest_lat fence_heel_lon...
                    fence_heel_lat fence_index fence_toe_index...
                    fence_heel_index fenced_dune_volume idxToe1997...
                    idxHeel1997 idxToe1997 idxFenceToe2010...
                    fCrestIndex2010 idxFenceHeel2010
            end 
        end
        
        % Re-plot the overview map
        morpho_table = useMorpho;
        morpho_2d_plotter
        
        % Save the corrected morpho matrix
        morphoHeader = {'Profile No.', 'x_mhw', 'y_mhw', 'x_fence_toe',...
            'y_fence_toe', 'x_fence', 'y_fence', 'x_fence_crest', 'y_fence_crest',...
            'x_fence_heel', 'y_fence_heel', 'x_toe', 'y_toe', 'x_crest', 'y_crest',...
            'x_heel', 'y_heel', 'local_x_mhw', 'local_y_mhw', 'local_x_fence_toe',...
            'local_y_fence_toe', 'local_x_fence', 'local_y_fence',...
            'local_x_fence_crest', 'local_y_fence_crest', 'local_x_fence_heel',...
            'local_y_fence_heel', 'local_x_toe', 'local_y_toe', 'local_x_crest',...
            'local_y_crest', 'local_x_heel', 'local_y_heel', 'mhw_lon', 'mhw_lat',...
            'fence_toe_lon', 'fence_toe_lat', 'fence_lon', 'fence_lat',...
            'fence_crest_lon', 'fence_crest_lat', 'fence_heel_lon', 'fence_heel_lat',...
            'toe_lon', 'toe_lat', 'crest_lon', 'crest_lat', 'heel_lon', 'heel_lat'...
            'Natural Dune Volume', 'Fenced Dune Volume', 'Total Dune Volume',...
            'Beach Width', 'Start Crest Height', 'Start Crest Index',...
            'Start Fence Crest Height', 'Start Fence Crest Index', 'Beach Slope',...
            'Foreshore Slope', 'x_berm', 'y_berm', 'local_x_berm',...
            'local_y_berm', 'berm_lon', 'berm_lat',...
            'Start Toe Index', 'Start Heel Index', 'Start Dune Volume',...
            'Start Toe Index', 'Start MHW Index', 'Start Beach Volume'...
            'x_twoMeter', 'y_twoMeter', 'local_x_twoMeter',...
            'local_y_twoMeter', 'twoMeter_lon', 'twoMeter_lat',...
            'Start Fence Toe Index', 'Start Fence Heel Index',...
            'Start Fence Dune Volume', '2010 Crest Height',...
            '2010 Crest Index', '2010 Toe Index', '2010 Heel Index',...
            '2010 Natural Dune Volume', '2010 Toe Index', '2010 MHW Index',...
            '2010 Beach Volume'};
        morphoSaveName = sprintf('%sMorphometrics for Bogue %s %s.csv',...
            genPath, correctSections(ss), num2str(years(yy)));
        
        % Create the .csv file
        fid = fopen(morphoSaveName, 'w+'); 

        % write header
        for i = 1:length(morphoHeader)
            fprintf(fid, '%s', morphoHeader{i});
            if i ~= length(morphoHeader)
                fprintf(fid, ',');
            else
                fprintf(fid, '\n' );
            end
        end
        % close file
        fclose(fid);

        % Append the data to the .csv file which should now have a header in the
        % first row
        dlmwrite(morphoSaveName,...
            useMorpho,...
            '-append',...
            'Delimiter', ',',...
            'Precision', 9)
    
    % Combine the x, y, and z matrices into a 3D matrix and save it as a
    % .mat file for faster access
    profiles_fname = sprintf('%s%s%s%sProfiles for %s %s (No Buildings).mat',...
        location(1:end-1), filesep, year, filesep, location(1:end-1), year);
    save(profiles_fname, 'profiles', '-mat')
    
    % Save the profiles as a csv as well
    profiles_fname = sprintf('%s%s%s%sProfiles for %s %s (No Buildings).csv',...
        location(1:end-1), filesep, year, filesep, location(1:end-1), year);
    dlmwrite(profiles_fname, profiles(:, :, 3), 'delimiter', ',', 'Precision', 10)
    
        
    clear morpho1997 morpho2010 gen1997Path gen2010Path genPath...
        local_x_values localUseX location profiles save_name title...
        useMorpho useY x_values profiles_fname
        
    end
    
end

function [x_crest, y_crest, local_x_crest, local_y_crest, crest_lon, crest_lat, crest_index] =...
    correctCrestFinder(meanXCrest, stdXCrest, meanYCrest, stdYCrest,...
    x_values, local_x_values, profiles, k, letter, sp_loc)
    % Use the mean and standard deviation of the crest positions to
    % pick a crest. This function will choose the talles peak within
    % mean+/-Sd range of the crests in the current section
    
    loRange = meanYCrest - stdYCrest;
    if loRange < 2.5
        loRange = 2.5;
    end
    
    % Set the range of values to look at
    if strcmp(letter, 'Z')
        loVals = meanXCrest + (1.5 * stdXCrest);
        hiVals = meanXCrest + (10 * stdXCrest);
    else
        loVals = meanXCrest - (1.5 * stdXCrest);
        hiVals = meanXCrest + (1.5 * stdXCrest);
    end
    
    % Set the actual indices to consider
    hiIdx = find(abs(x_values - loVals) == nanmin(abs(x_values - loVals)));
    loIdx = find(abs(x_values - hiVals) == nanmin(abs(x_values - hiVals)));
    
    % Find peaks in the search range
    [allPks, allLocs] = findpeaks(profiles(:, k, 3));
    
    if length(loIdx:hiIdx) >= 3
        [pks, locs] = findpeaks(profiles(loIdx:hiIdx, k, 3));
    end
    if exist('pks')
        if strcmp(letter, 'Z') && k < 300
            locs = locs(pks > 4 & pks < 12);
            pks = pks(pks > 4 & pks < 12);
            allLocs = allLocs(allPks > 4 & allPks < 12);
            allPks = allPks(allPks > 4 & allPks < 12);
        elseif strcmp(letter, 'Z') && k < 300
            locs = locs(pks > loRange & pks < 12);
            pks = pks(pks > loRange & pks < 12);
            allLocs = allLocs(allPks > loRange & allPks < 12);
            allPks = allPks(allPks > loRange & allPks < 12);
        end
    else
        if strcmp(letter, 'Z') && k < 300
            allLocs = allLocs(allPks > 4 & allPks < 12);
            allPks = allPks(allPks > 4 & allPks < 12);
        elseif strcmp(letter, 'Z') && k < 300
            allLocs = allLocs(allPks > loRange & allPks < 12);
            allPks = allPks(allPks > loRange & allPks < 12);
        end
    end
    if exist('pks') && length(pks) >= 1
        % If there are peaks, set the crest index to the index
        % of the most seaward peak
        crest_index_1 = locs(pks == nanmax(pks)) + loIdx - 1;
        crest_index_2 = locs(end) + loIdx - 1;       
        
        % Calculate the backshore drop of both potential crest indices
        crestIndices = [crest_index_1, crest_index_2];
        drops = [NaN, NaN];
        if crest_index_1 == crest_index_2
            crest_index = crest_index_1;
        else           
            for cc = 1:2
                idx = crestIndices(cc);
                while (idx > 1) && profiles(idx - 1, k, 3) < profiles(idx, k , 3)
                    idx = idx - 1;
                end
                drops(cc) = profiles(crestIndices(cc), k, 3) - profiles(idx, k, 3);
            end
            crest_index = crestIndices(drops == nanmax(drops));
        end
        
        % If the next landward peak is less than 5m away and taller, use it
        if (length(pks) > 1) &&...
                (abs(x_values(locs(end)) - x_values(locs(end - 1))) <= 5) &&...
                 pks(end - 1) >= pks(end)
            crest_index = locs(end - 1) + loIdx - 1;           
        end
        
        % Check that there aren't any taller peaks seaward outside
        % of the search range
        if any(allPks(allLocs > crest_index) > profiles(crest_index, k, 3))
            allLocs = allLocs(allLocs > crest_index & allPks > profiles(crest_index, k, 3));
            crest_index = allLocs(end);
        end
        
    else
        % Pick the talles point in the section
        [~, crest_index] = nanmax(profiles(loIdx:hiIdx, k, 3));
        
    end
    
    % If the crest_index is 1, find the tallest point and use it. This 
    % is the least preferred method but it is at least more reasonable
    if crest_index == 1
       [~, crest_index] = nanmax(profiles(:, k, 3)); 
    end
    
    % Set local locations and lat/lon
    [x_crest, y_crest, local_x_crest, local_y_crest, crest_lon, crest_lat] =...
        set_locations(x_values, local_x_values, profiles, crest_index, k, sp_loc);
        
end

function [x, y, local_x, local_y, lon, lat, index] = findNearest(ptX, ptY, x,...
    profiles, k, x_values, local_x_values, sp_loc)
    % Find the nearest point to the profile
    
    distances = sqrt((ptX - x).^2 + (ptY - profiles(:,k,3)).^2);
    [~, index] = nanmin(distances);  
    index = index(1);
    
    % Set local locations and lat/lon
    [x, y, local_x, local_y, lon, lat] =...
        set_locations(x_values, local_x_values, profiles, index, k, sp_loc);

end