% This script unpopulates the Excel Files folder with all the Excel
% files for Bogue Banks.
%
% Michael Itzkin, 5/29/2018
%-----------------------------------------------------------------------%
close all
clear all
clc

% All the Bogue files are alphabetical, store the alphabet
alphabet = 'A':'Z';

% All files go to the Excel Files folder, set that as the destination
source = 'Excel Files';

% Set a cell of years to loop through
years = {'1997', '1998', '1999', '2000', '2004', '2005',...
    '2010', '2011', '2014', '2016'};

% Loop through the files
for letter = 1:length(alphabet)
    
    % Loop through the years and move files. Check for existence first
    % since the particular year and location being worked on might already
    % be in Excel Files
    for yr = 1:length(years)
        
        % Set the destination
        destination = sprintf('Bogue %s%s%s%sBogue %s %s.xlsx',...
            alphabet(letter), filesep, years{yr}, filesep,...
            alphabet(letter), years{yr});
        
        year_fname = sprintf('%s%sBogue %s %s.xlsx',...
            source, filesep, alphabet(letter), years{yr});
        if exist(year_fname)
            movefile(year_fname, destination, 'f');
        end
    end
    
    %If there is a fences file, move it
    fences_fname = sprintf('Excel Files%sBogue %s Fences.xlsx',...
        filesep, alphabet(letter));
    fences_destination = sprintf('Bogue %s%sBogue %s Fences.xlsx',...
            alphabet(letter), filesep, alphabet(letter));
    if exist(fences_fname)
        movefile(fences_fname, fences_destination, 'f');
    end 
      
end