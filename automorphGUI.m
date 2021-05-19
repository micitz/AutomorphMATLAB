% This script runs a GUI based program that allows you to review Automorph
% output and make adjustments to various features
%
% Michael Itzkin, 4/11/2019
%------------------------------------------------------------------------%
close all
clear all
clc

opengl('hardware')

addpath('Subfunctions')
sp_loc = 'north carolina';

% Enter a letter for the section and a number for the year
% you want to review
section = 'Z';
year = 1998;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
% Set the following to a "1" to clear the berms. It is easier to
% fix berms by adding them in if most profiles don't have a berm
clearBerms = 0;
printNans = 0;
                              
% Set general paths to the data
genPath = sprintf('Bogue %s%s%s%s',...
    section, filesep, num2str(year), filesep);
gen1997Path = sprintf('Bogue %s%s1997%s',...
    section, filesep, filesep);
gen2010Path = sprintf('Bogue %s%s2010%s',...
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

% Copy the unmodified morphometrics in case there is an issue
dlmwrite(sprintf('%sMorphometrics for Bogue %s %s Original.csv',...
    genPath, section, num2str(year)), useMorpho,...
    'delimiter', ',', 'precision', 10)

% Load the morphometrics for 1997
morpho1997 = csvread(sprintf('%sMorphometrics for Bogue %s 1997.csv',...
    gen1997Path, section), 1, 0);

% Load the morphometrics for 2010
morpho2010 = csvread(sprintf('%sMorphometrics for Bogue %s 2010.csv',...
    gen2010Path, section), 1, 0);

% Load the profiles for 2010
useY2010 = load(sprintf('%sProfiles for Bogue %s 2010.mat',...
    gen2010Path, section));
profiles2010 = useY2010.profiles;

x_values2010 = load(sprintf('%sX Values for Bogue %s 2010.mat',...
    gen2010Path, section));
x_values2010 = x_values2010.x_values';

localUseX2010 = load(sprintf('%sLocal X Values for Bogue %s 2010.mat',...
    gen2010Path, section));
localUseX2010 = localUseX2010.local_x_values;

% For fenced years, load the morphometrics for the previous year. The
% fenced dune morphometrics have been extended to profiles where there
% aren't any fences and those same profiles will need to be "fenced" going
% forwards
if year == 1998
    previousPath = sprintf('Bogue %s%s1997%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 1997.csv', previousPath, section), 1, 0);
elseif year == 1999
    previousPath = sprintf('Bogue %s%s1998%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 1998.csv', previousPath, section), 1, 0);
elseif year == 2000
    previousPath = sprintf('Bogue %s%s1999%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 1999.csv', previousPath, section), 1, 0);
elseif year == 2004
    previousPath = sprintf('Bogue %s%s2000%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 2000.csv', previousPath, section), 1, 0);
elseif year == 2005
    previousPath = sprintf('Bogue %s%s2004%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 2004.csv', previousPath, section), 1, 0);
elseif year == 2010
    previousPath = sprintf('Bogue %s%s2005%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 2005.csv', previousPath, section), 1, 0);
    
    % If you are working on 2010 load the 2005 profiles for the overlay
    gen2005Path = sprintf('Bogue %s%s2005%s',...
    section, filesep, filesep);
    x_values2005 = load(sprintf('%sX Values for Bogue %s 2005.mat',...
        gen2005Path, section));
    x_values2005 = x_values2005.x_values';
    localUseX2005 = load(sprintf('%sLocal X Values for Bogue %s 2005.mat',...
        gen2005Path, section));
    localUseX2005 = localUseX2005.local_x_values;
    useY2005 = load(sprintf('%sProfiles for Bogue %s 2005.mat',...
        gen2005Path, section));
    profiles2005 = useY2005.profiles;
    
elseif year == 2011
    previousPath = sprintf('Bogue %s%s2010%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 2010.csv', previousPath, section), 1, 0);
elseif year == 2014
    previousPath = sprintf('Bogue %s%s2011%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 2011.csv', previousPath, section), 1, 0);
elseif year == 2016
    previousPath = sprintf('Bogue %s%s2014%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 2014.csv', previousPath, section), 1, 0);
else
    previousPath = sprintf('Bogue %s%s2010%s', section, filesep, filesep);
    previousMorpho = csvread(sprintf('%sMorphometrics for Bogue %s 2010.csv', previousPath, section), 1, 0);
end

% Enter the GUI
location = sprintf('Bogue %s ', section);
if year == 2010
    profileReview(location, num2str(year), x_values, local_x_values,...
        profiles, profiles2005, genPath, useMorpho, morpho1997,...
        previousMorpho, section, clearBerms, printNans)
else
    profileReview(location, num2str(year), x_values, local_x_values,...
        profiles, profiles2010, genPath, useMorpho, morpho1997,...
        previousMorpho, section, clearBerms, printNans)
end