% This script plots all the profiles as overlays to visualize changes to
% the profiles over time. Do not run this script until all the profiles
% have been analyzed or it will not run properly
%
% Michael Itzkin, 5/23/2018
%------------------------------------------------------------------------%
tic;
close all
clear all
clc

% Load all the current folders into a struct.
files = dir();

% Set a matrix of colors equal to the number of years
colors = jet(10);

% Loop over all the folders, only consider those which are for Bogue.
% Checking for bytes==0 prevents the loop from trying to open
% "Bogue_Profile_Overlays.m" as a folder
for i = 1:length(files)
    if length(files(i).name) > 5 &&...
            strcmp(files(i).name(1:5), 'Bogue') &&...
            files(i).bytes == 0
        
        loc = files(i).name;
        
        % Set the filenames
        x_values_fname = sprintf('%s%s2010%sX Values for %s 2010.mat',...
            loc, filesep, filesep, loc);
        profiles_1997_fname = sprintf('%s%s1997%sProfiles for %s 1997.mat',...
            loc, filesep, filesep, loc);
        profiles_1998_fname = sprintf('%s%s1998%sProfiles for %s 1998.mat',...
            loc, filesep, filesep, loc);
        profiles_1999_fname = sprintf('%s%s1999%sProfiles for %s 1999.mat',...
            loc, filesep, filesep, loc);
        profiles_2000_fname = sprintf('%s%s2000%sProfiles for %s 2000.mat',...
            loc, filesep, filesep, loc);
        profiles_2004_fname = sprintf('%s%s2004%sProfiles for %s 2004.mat',...
            loc, filesep, filesep, loc);
        profiles_2005_fname = sprintf('%s%s2005%sProfiles for %s 2005.mat',...
            loc, filesep, filesep, loc);
        profiles_2010_fname = sprintf('%s%s2010%sProfiles for %s 2010.mat',...
            loc, filesep, filesep, loc);
        profiles_2011_fname = sprintf('%s%s2011%sProfiles for %s 2011.mat',...
            loc, filesep, filesep, loc);
        profiles_2014_fname = sprintf('%s%s2014%sProfiles for %s 2014.mat',...
            loc, filesep, filesep, loc);
        profiles_2016_fname = sprintf('%s%s2016%sProfiles for %s 2016.mat',...
            loc, filesep, filesep, loc);
        
        % Load the data.
        x_values = load(x_values_fname);
        profiles_1997 = load(profiles_1997_fname);
        profiles_1998 = load(profiles_1998_fname);
        profiles_1999 = load(profiles_1999_fname);
        profiles_2000 = load(profiles_2000_fname);
        profiles_2004 = load(profiles_2004_fname);
        profiles_2005 = load(profiles_2005_fname);
        profiles_2010 = load(profiles_2010_fname);
        profiles_2011 = load(profiles_2011_fname);
        profiles_2014 = load(profiles_2014_fname);
        profiles_2016 = load(profiles_2016_fname);
        
        x = x_values.x_values;
        profiles_1997 = profiles_1997.profiles;
        profiles_1998 = profiles_1998.profiles;
        profiles_1999 = profiles_1999.profiles;
        profiles_2000 = profiles_2000.profiles;
        profiles_2004 = profiles_2004.profiles;
        profiles_2005 = profiles_2005.profiles;
        profiles_2010 = profiles_2010.profiles;
        profiles_2011 = profiles_2011.profiles;
        profiles_2014 = profiles_2014.profiles;
        profiles_2016 = profiles_2016.profiles;
        
        % Make a directory to store figures in
        new_folder = sprintf('%s%sProfile Overlays',...
            loc, filesep);
        mkdir(new_folder)
        
        % Loop through the profiles and make the figures
        for k = 1:length(profiles_2010(:,:,3))
            
            Title = sprintf('%s (Profile %d)', loc, k);
            Figure = figure('name', Title, 'Visible', 'Off');
            
            box on
            grid on
            hold on
            
            a = plot(x, profiles_1997(:,k,3),...
                'color', colors(1,:),...
                'LineWidth', 2,...
                'DisplayName', '1997');
            b = plot(x, profiles_1998(:,k,3),...
                'color', colors(2,:),...
                'LineWidth', 2,...
                'DisplayName', '1998');
            c = plot(x, profiles_1999(:,k,3),...
                'color', colors(3,:),...
                'LineWidth', 2,...
                'DisplayName', '1999');
            d = plot(x, profiles_2000(:,k,3),...
                'color', colors(4,:),...
                'LineWidth', 2,...
                'DisplayName', '2000');
            e = plot(x, profiles_2004(:,k,3),...
                'color', colors(5,:),...
                'LineWidth', 2,...
                'DisplayName', '2004');
            f = plot(x, profiles_2005(:,k,3),...
                'color', colors(6,:),...
                'LineWidth', 2,...
                'DisplayName', '2005');
            g = plot(x, profiles_2010(:,k,3),...
                'color', colors(7,:),...
                'LineWidth', 2,...
                'DisplayName', '2010');
            h = plot(x, profiles_2011(:,k,3),...
                'color', colors(8,:),...
                'LineWidth', 2,...
                'DisplayName', '2011');
            i = plot(x, profiles_2014(:,k,3),...
                'color', colors(9,:),...
                'LineWidth', 2,...
                'DisplayName', '2014');
            j = plot(x, profiles_2016(:,k,3),...
                'color', colors(10,:),...
                'LineWidth', 2,...
                'DisplayName', '2016');
            k = line([x(1) x(end)], [0.34 0.34],...
                'color', 'k',...
                'LineWidth', 2,...
                'LineStyle', '--',...
                'DisplayName', 'MHW');
            
            ylim([0 12])
            
            xlabel('Cross Shore Distance (m)')
            ylabel('Elevation (m NAVD88)')
            title(Title)
            legend([a b c d e f g h i j], 'Location', 'northeast')
            set(gca, 'XDir', 'reverse')
            
            save_title = sprintf('%s%s%s.png', new_folder, filesep, Title);
            saveas(Figure, save_title, 'png')
            close()
            
        end
        
    end
end

toc;
sec = rem(toc,60);
min = floor(toc/60);
hr = floor(min/60);
min = min - (hr*60);
fprintf('The program completed in %d hour(s), %d minute(s), and %.2f seconds\n',...
    hr, min, round(sec))