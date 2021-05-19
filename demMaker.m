% This script makes a 3D DEM of the study area
%
% Michael Itzkin, 4/15/2019
%-----------------------------------------------------------------------%
close all
clear all
clc

addpath('Subfunctions')
dDEM = 0;   % 0 = Normal DEM; 1 = 2016 - Year; 2 = Year - 1997

% Enter a letter for the section and a number for the year
% you want to review
section = 'U';
year = 2018;

% Set general paths to the data
genPath = sprintf('Bogue %s%s%s%s',...
    section, filesep, num2str(year), filesep);
gen1997Path = sprintf('Bogue %s%s1997%s',...
    section, filesep, filesep);
gen2010Path = sprintf('Bogue %s%s2010%s',...
    section, filesep, filesep);
gen2018Path = sprintf('Bogue %s%s2018%s',...
    section, filesep, filesep);

% Load the profiles for the current year
useY = load(sprintf('%sProfiles for Bogue %s %s.mat',...
    genPath, section, num2str(year)));
profiles = useY.profiles;

x_values = load(sprintf('%sX Values for Bogue %s %s.mat',...
    genPath, section, num2str(year)));
x_values = x_values.x_values';

localUseX = load(sprintf('%sLocal X Values for Bogue %s %s.mat',...
    genPath, section, num2str(year)));
local_x_values = localUseX.local_x_values;

useMorpho = csvread(sprintf('%sMorphometrics for Bogue %s %s.csv',...
    genPath, section, num2str(year)), 1, 0);

% Load the profiles for 2018
useY2018 = load(sprintf('%sProfiles for Bogue %s %s.mat',...
    gen2018Path, section, num2str(2018)));
profiles2018 = useY2018.profiles;

x_values2018 = load(sprintf('%sX Values for Bogue %s %s.mat',...
    gen2018Path, section, num2str(2018)));
x_values2018 = x_values2018.x_values';

localUseX2018 = load(sprintf('%sLocal X Values for Bogue %s %s.mat',...
    gen2018Path, section, num2str(2018)));
local_x_values2018 = localUseX2018.local_x_values;

useMorpho2018 = csvread(sprintf('%sMorphometrics for Bogue %s %s.csv',...
    gen2018Path, section, num2str(2018)), 1, 0);

% Load the profiles for 1997
useY1997 = load(sprintf('%sProfiles for Bogue %s %s.mat',...
    gen1997Path, section, num2str(1997)));
profiles1997 = useY1997.profiles;

x_values1997 = load(sprintf('%sX Values for Bogue %s %s.mat',...
    gen1997Path, section, num2str(1997)));
x_values1997 = x_values1997.x_values';

localUseX1997 = load(sprintf('%sLocal X Values for Bogue %s %s.mat',...
    gen1997Path, section, num2str(1997)));
local_x_values1997 = localUseX1997.local_x_values;

useMorpho1997 = csvread(sprintf('%sMorphometrics for Bogue %s %s.csv',...
    gen1997Path, section, num2str(1997)), 1, 0);

%% Plot a 3D DEM of the selected year with morphometrics

if dDEM == 1
    difference = (profiles2018(:,:,3) - profiles(:,:,3));

    hold on
    surf(1:length(profiles(:,:,3)), x_values, difference, 'EdgeColor', 'none')
    zlimits = [nanmin(difference) nanmax(difference)];
    colormap(bluewhitered);
    colorbar;
elseif dDEM == 2
    difference = (profiles(:,:,3) - profiles1997(:,:,3));

    hold on
    surf(1:length(profiles(:,:,3)), x_values, difference, 'EdgeColor', 'none')
    zlimits = [nanmin(difference) nanmax(difference)];
    colormap(bluewhitered);
    colorbar;
else
    hold on
    surf(1:length(profiles(:,:,3)), x_values, profiles(:,:,3), 'EdgeColor', 'none')
    zlimits = [nanmin(profiles(:,:,3)) nanmax(profiles(:,:,3))];
    demcmap(zlimits);
    colorbar;
end

% Plot the MHW contour
plot3(1:length(profiles(:,:,3)), useMorpho(:,2), useMorpho(:,3),...
    'Color', 'y',...
    'LineWidth', 2)

% Plot the berm
scatter3(1:length(profiles(:,:,3)), useMorpho(:,60), useMorpho(:,61),...
    'MarkerFaceColor', 'c',...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

% Plot the 2m contour
plot3(1:length(profiles(:,:,3)), useMorpho(:,72), useMorpho(:,73),...
    'Color', [0.25, 0.80, 0.60],...
    'LineWidth', 2)

% Plot the natural dune toe
scatter3(1:length(profiles(:,:,3)), useMorpho(:,12), useMorpho(:,13),...
    'MarkerFaceColor', 'b',...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

% Plot the natural dune crest
scatter3(1:length(profiles(:,:,3)), useMorpho(:,14), useMorpho(:,15),...
    'MarkerFaceColor', 'm',...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

% Plot the natural dune heel
scatter3(1:length(profiles(:,:,3)), useMorpho(:,16), useMorpho(:,17),...
    'MarkerFaceColor', 'g',...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

% Plot the fence dune toe
scatter3(1:length(profiles(:,:,3)), useMorpho(:,6), useMorpho(:,7),...
    'MarkerFaceColor', 'r',...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

% Plot the fenced dune toe
scatter3(1:length(profiles(:,:,3)), useMorpho(:,4), useMorpho(:,5),...
    'MarkerFaceColor', [0.55 0.57 0.67],...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

% Plot the fenced dune crest
scatter3(1:length(profiles(:,:,3)), useMorpho(:,8), useMorpho(:,9),...
    'MarkerFaceColor', [0.91, 0.41, 0.17],...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

% Plot the fenced dune heel
scatter3(1:length(profiles(:,:,3)), useMorpho(:,10), useMorpho(:,11),...
    'MarkerFaceColor', [0.50, 0.00, 0.90],...
    'MarkerEdgeColor', 'k',...
    'LineWidth', 2)

view([0 90])
zlim([-1 12])





