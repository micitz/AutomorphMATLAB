% This script adds a few more metrics to the data extracted from the
% profiles. 
%
% Michael Itzkin, 5/24/2020
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
currentNumber = 1;
years = 1998;
for yy = 1:length(years)
    for ss = 1:length(correctSections) 
        clc
        
        % Print out the section in progress
        totalSections = length(correctSections) * length(years);
        fprintf('Current Section: Bogue %s - %s (%s Percent Complete)',...
            correctSections(ss), num2str(years(yy)),...
            num2str((currentNumber / totalSections) * 100))
        
        % Set paths
        genPath = sprintf('Bogue %s%s%s%s',...
            correctSections(ss), filesep, num2str(years(yy)), filesep);
        profilesFname = sprintf('%sProfiles for Bogue %s %s.mat',...
            genPath, correctSections(ss), num2str(years(yy)));
        xValuesFname = sprintf('%sX Values For Bogue %s %s.mat',...
            genPath, correctSections(ss), num2str(years(yy)));
        morphoFname = sprintf('%sMorphometrics for Bogue %s %s.csv',...
            genPath, correctSections(ss), num2str(years(yy)));
        
        % Load profiles and morphometrics
        load(profilesFname)
        load(xValuesFname)
        morpho = readmatrix(morphoFname);
        
        % Copy the unmodified morphometrics in case there is an issue
        dlmwrite(sprintf('%sMorphometrics for Bogue %s %s Original.csv',...
            genPath, correctSections(ss), num2str(years(yy))), morpho,...
            'delimiter', ',', 'precision', 10)
        
        % Loop through the profiles
        [numProfiles, numMetrics] = size(morpho);
        
        % Loop through the profiles to set metrics that
        % need to be done one profile at a time
        for pp = 1:numProfiles
            
            profile = profiles(:, pp, 3);
            xMHW = morpho(pp, 2);
            yMHW = morpho(pp, 3);
            mhwIndex = nanmax(find(abs(profile - 0.34) == nanmin(abs(profile - 0.34))));
            xFenceToe = morpho(pp, 4);
            yFenceToe = morpho(pp, 5);
            fenceToeIndex = find(x_values == xFenceToe);
            xToe = morpho(pp, 12);
            yToe = morpho(pp, 13);
            toeIndex = find(x_values == xToe);
            xHeel = morpho(pp, 16);
            yHeel = morpho(pp, 17);
            heelIndex = find(x_values == xHeel);
            xTwoMeter = morpho(pp, 72);
            yTwoMeter = morpho(pp, 73);
            twoMeterIndex = find(x_values == xTwoMeter);
            
            naturalVolume = morpho(pp, 50);
            
            % Re-calculate the total dune volume as the total
            % volume between the natural dune heel and either
            % the natural or (if present) fenced dune toe. As
            % opposed to just adding the natural and fenced dune
            % volumes together
            if ~isempty(heelIndex)
                morpho(pp, 52) = totalDuneVolume(x_values,yFenceToe, yHeel,...
                    heelIndex, fenceToeIndex, naturalVolume, profile); 
            end
            
            % Add the average profile elevation
            morpho(pp, 91) = nanmean(profile);
            
            % Calculate the foreshore volume between the
            % natural or fenced dune toe and MHW
            morpho(pp, 92) = foreshoreVolume(x_values, profile,...
                fenceToeIndex, toeIndex, mhwIndex);
            
            % Calculate the subaerial profile volume
            xComponent = x_values(profile >= 0);
            yComponent = profile(profile >= 0);
            morpho(pp, 93) = abs(trapz(xComponent, yComponent));
            
            % Calculate the profile volume below 0m. Take the
            % absolute value since this comes out negative
            xComponent = x_values(profile < 0);
            yComponent = profile(profile < 0);
            if length(yComponent) < 2
                morpho(pp, 94) = NaN;
            else
                morpho(pp, 94) = abs(trapz(xComponent, yComponent));
            end
            
            % Calculate the profile volume between MHW and the 2m contour
            morpho(pp, 95) = twoMeterVolume(x_values, profile,...
                yTwoMeter, yMHW);
            
        end
        
        % Save the corrected morpho matrix
        saveMorpho(genPath, correctSections(ss), years(yy), morpho)
        currentNumber = currentNumber + 1;
        
    end
end

function fVolume = foreshoreVolume(x, profile, fenceToeIndex, toeIndex, mhwIndex)
    % Calculate the volume between MHW and the most seaward
    % toe location (fenced or natural)
    
    % Set the toe position to use
    if isempty(fenceToeIndex)
        useToe = toeIndex;
    else
        useToe = fenceToeIndex;
    end
    
    % Make a copy of the profile with the space between the toe
    % and MHW set to the MHW elevation
    profileCopy = profile;
    profileCopy(useToe:mhwIndex) = profile(mhwIndex);
    
    % Integrate over the profile and the fake profile
    profileVolume = trapz(x, profile);
    copyVolume = trapz(x, profileCopy);
    
    % Subtract the copyVolume from profileVolume
    % to get the foreshore volume
    fVolume = abs(profileVolume - copyVolume);

end

function saveMorpho(genPath, section, year, morpho)
    % Save a .csv file with the morphometrics. Include
    % a header in the file
    
    % Set the header
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
            '2010 Beach Volume', 'Wet Beach Volume', 'Dry Beach Volume',...
            'Mean Island Elevation', 'Foreshore Volume', 'Subaerial Volume',...
            'Subaqueous Volume', '2m Volume'};
        morphoSaveName = sprintf('%sMorphometrics for Bogue %s %s.csv',...
            genPath, section, num2str(year));
        
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
            morpho,...
            '-append',...
            'Delimiter', ',',...
            'Precision', 9)

end

function tmVolume = twoMeterVolume(x, profile, yTwoMeter, yMHW)
    % Calculate the volume between MHW and the most seaward
    % toe location (fenced or natural)
    
    % Make a copy of the profile with the height cut off at 2m
    twoMeterProfile = profile;
    twoMeterProfile(twoMeterProfile > yTwoMeter) = yTwoMeter;
    
    % Make a copy of the profile with the height cut off at MHW
    mhwProfile = profile;
    mhwProfile(mhwProfile > yMHW) = yMHW;
    
    % Integrate over the profiles
    sub2mVolume = trapz(x, twoMeterProfile);
    subMHWVolume = trapz(x, mhwProfile);
    
    % Subtract the copyVolume from profileVolume
    % to get the foreshore volume
    tmVolume = abs(sub2mVolume - subMHWVolume);

end