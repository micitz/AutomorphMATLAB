% This script makes a DEM of the full island
% 
% Michael Itzkin, 11/6/2019
%----------------------------------------------------------------------%
close all
clear all
clc

close all
clear all
clc

addpath('Subfunctions')
dDEM = 0;

% Enter a letter for the section and a number for the year
% you want to review
sections = 'A':'Z';
year = 1999;

% Set matrices to loop into
fullProfiles = [];
fullMorpho = [];

% Loop through the sections
for ii = 1:length(sections)

    % Set the section
    section = sections(ii);
    
    % Set general paths to the data
    genPath = sprintf('Bogue %s%s%s%s',...
        section, filesep, num2str(year), filesep);
    
    % Load the profiles for the current section
    useY = load(sprintf('%sProfiles for Bogue %s %s.mat',...
        genPath, section, num2str(year)));
    profiles = useY.profiles;
    fullProfiles = [fullProfiles, profiles(1:501, :, :)];

    x_values = load(sprintf('%sX Values for Bogue %s %s.mat',...
        genPath, section, num2str(year)));
    x_values = x_values.x_values';

    localUseX = load(sprintf('%sLocal X Values for Bogue %s %s.mat',...
        genPath, section, num2str(year)));
    local_x_values = localUseX.local_x_values;
    
    % Load the morphometrics for the current section
    useMorpho = csvread(sprintf('%sMorphometrics for Bogue %s %s.csv',...
        genPath, section, num2str(year)), 1, 0);
    fullMorpho = [fullMorpho; useMorpho];

end