% This script determines shoreline change rates and uncertainties. It is
% similar to Automorph but it only uses pre-defined endpoint years and uses
% methods akin to those described by Hapke et al (2011)
%
% This could be integrated into Automorph but for now it only will work
% after you've ran Automorph (for the years you want to analyze)
%
% Michael Itzkin, 2/8/2019
%------------------------------------------------------------------------%
close all
clear all
clc

%% Inputs to set up calculations
% Set the location of the state plane coordinates. Check the "sp_proj"
% function in the Subfunctions folder for details
sp_loc = 'north carolina';

% Set the years of analysis
years = {'1997', '1998', '1999', '2000', '2004', '2005',...
    '2010', '2011', '2014', '2016'};

% Set the MHW level
MHW = 0.34;

% First load all the excel files to be used. Store the Excel files in the 
% "Excel files" folder. Automorph Shorelines will make any other folder
% as it goes
addpath('Subfunctions')

% Create an empty array to loop into
header = {'1997 CI', '1998 CI', '1999 CI', '2000 CI', '2004 CI', '2005 CI',...
    '2010 CI', '2011 CI', '2014 CI', '2016CI'};
data = NaN(38455, length(header));

%% This loop sets up the shoreline positions for each profile. Each row
% is a profile. The first n columns correspond to the cross-shore position
% of the shoreline for the n years being analyzed
for yr = 1:length(years)
    
    % Set the current year
    year = years{yr};
    
    % Maintain a counter that counts profiles across sections and resets
    % to 1 every time the year changes
    profileCounter = 1;
    
    % Loop through the sections of Bogue data and calculate
    % shorelines into a master array
    for section = 'A':'Z'
        
        % Load the profiles for the current year/section
        [xValues, profiles] = dataLoad(section, year);
        
        % Loop through the profiles in the sections
        for pp = 1:length(profiles(1,:))
            
            % Isolate the values within 0.5m of MHW
            [xx, yy] = mhwRange(MHW, profiles(:,pp), xValues);
            
            if ~isempty(xx)
                % Fit a linear regression through XX,YY
                mdl = fitlm(xx, yy);
                m = mdl.Coefficients.Estimate(2);
                b = mdl.Coefficients.Estimate(1);
                
                % Find the confidence interval error
                ci = coefCI(mdl, 0.05);
                ciError = (ci(2, 2) - ci(2, 1)) / 2;
                
            else
                ciError = NaN;
            end
            
            data(profileCounter, yr) = ciError;
            profileCounter = profileCounter + 1;
            
        end
        
    end
    
end

%% Save a .csv file with the data in it
saveName = sprintf('..%s..%sSand Fences%sData%sShoreline Confidence Intervals.csv',...
    filesep, filesep, filesep, filesep);
csvwriteh(saveName, data, header)

%% Subfunctions

function [xValues, profiles] = dataLoad(sec, year)
    % Load the x-values and profiles for the given year and
    % section of Bogue Banks
    %
    % sec: letter corresponding to the section of Bogue Banks
    % year: year being analyzed
    
    % Set paths to the data
    xPath = sprintf('Bogue %s%s%s%sX Values for Bogue %s %s.mat',...
        sec, filesep, year, filesep, sec, year);
    profilesPath = sprintf('Bogue %s%s%s%sProfiles for Bogue %s %s.mat',...
        sec, filesep, year, filesep, sec, year);

    % Load the x-values
    xValues = load(xPath);
    xValues = xValues.x_values;
    
    % Load the profiles
    profiles = load(profilesPath);
    profiles = profiles.profiles(:,:,3);

end

function [xx, yy] = mhwRange(mhw, prof, xvals)
    % Isolate the portion of the profile within 0.5m
    % of the accepted MHW elevation
    %
    % mhw: accepted MHW elevation
    % prof: elevation data
    % xvals: cross-shore data

    mhwRangeHi = mhw + 0.5;
    mhwRangeLo = mhw - 0.5;
    yy = prof;
    xx = xvals(prof >= mhwRangeLo & prof <= mhwRangeHi);
    yy = yy(yy >= mhwRangeLo & yy <= mhwRangeHi);

end

function up = positionUncertainty(x, y, xMHW, mdl, m, year)
    % Calculate the positional uncertainty
    %
    % x: cross-shore positions
    % y: elevations
    % xMHW: cross-shore mhw position from the regression
    % mdl: linear regression model
    % m: beach slope
    % year: year of data
    
    % Find the first source of uncertainty from the
    % regression confidence intervals
    ci = coefCI(mdl, 0.05);
    ciError = sqrt((ci(2,1)^2) + (ci(2,2)^2));
    
    % The second source of uncertainty comes from
    % the vertical error in the LiDAR data being used
    % and the beach slope
    if strcmp(year, '1997')
        vErr = 0.15;
    elseif strcmp(year, '2010')
        vErr = 0.15;
    elseif strcmp(year, '2016')
        vErr = 0.19;
    end
    vErr = vErr * m;
    
    % The third source of uncertainty comes from the difference
    % between where the regression model places MHW and where
    % the shoreline occurs. 
    obsDiff = abs(y - 0.34);
    obsInd = find(obsDiff == nanmin(obsDiff));
    xObs = x(obsInd);
    extrapErr = abs(xObs - xMHW);
    
    % Calculate the error. Some profiles return more than one
    % value here so we will choose the maximum
    up = nanmax(sqrt((ciError.^2) + (vErr.^2) + (extrapErr.^2)));
    
end

function [r, u] = rate(data, col1, col2, yr0, yr1)
    % Calculate the rate of change and associated uncertainty
    %
    % data: array of shoreline positions and uncertainties
    % col1: column of shoreline positions for the first year
    % col2: column of shoreline positions for the second year
    % yr0: first year
    % yr1: second year
    
    % Calcluate the timespan
    dt = yr1 - yr0;
    
    % Calculate the rate
    r = (data(:, col2) - data(:, col1)) ./ dt;
    
    % Calculate the uncertainty
    u = sqrt((data(:, col1+1).^2) + (data(:, col2+1).^2)) / dt;

end

function csvwriteh( filename, data, header )
    % CVSWRITEH write matrix to a csv file with header
    % CVSWRITEH( FILENAME, DATA, HEADER )
    % function to write a csvfile with a header
    % input parameters:
    %   FILENAME: filename for csv output file
    %   DATA:     matrix with data for csv file
    %   HEADER:   cell array with names per column
    %
    % SOURCE: https://www.nesono.com/node/415

    % check parameters
    % filename parameter
    if exist( 'filename', 'var' )
        if ~ischar( filename )
            error('filename not char')
        end
    else
        error('filename does not exists')
    end
    % data parameter
    if exist( 'data', 'var' )
        if ~isnumeric( data )
            error('data not numeric')
        end
    else
        error('data does not exist')
    end
    % header parameter
    if exist( 'header', 'var' )
        if ~iscellstr( header )
            error('header no cell str')
        end
    else
        error('header does not exist')
    end

    % check dimensions of data and header
    [drow dcol] = size (data);
    [hrow hcol] = size (header);
    if hcol ~= dcol
        error( 'header not of same length as data (columns)' )
    end

    % open file
    outid = fopen (filename, 'w+');

    % write header
    for idx = 1:hcol
        fprintf (outid, '%s', header{idx});
        if idx ~= hcol
            fprintf (outid, ',');
        else
            fprintf (outid, '\n' );
        end
    end
    % close file
    fclose(outid);

    % write data
    dlmwrite (filename, data, '-append' );
end