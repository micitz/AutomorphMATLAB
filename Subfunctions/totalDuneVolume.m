function totalDuneVolume = totalDuneVolume(exes, yFenceToe, yHeel, heelIndex,...
    fenceToeIndex, naturalVolume, profile) 
    % Calculate the total volume between the natural dune heel and
    % the most seaward toe (natural or fenced)

    % Check if the fenced dune toe exists
    if exist('yFenceToe') && ~isnan(yFenceToe)

        % Determine if the fenced dune toe or dune heel is lower in elevation.
        % A line must be fit across the bottom of the dune, the lower
        % feature will determine where to put the line
        if yHeel <= yFenceToe
            x = profile;
            x(heelIndex:fenceToeIndex) = yHeel;
        elseif yFenceToe < yHeel   
            x = profile;
            x(heelIndex:fenceToeIndex) = yFenceToe;
        end  

        % Calculate the area under the profile from the heel to toe
        integralProfile = trapz(exes, profile);

        % Calculate the area under the x vector created above from the heel to toe
        integralLine = trapz(exes, x);

        % Subtract the area below the line from the area below the profile to get
        % the natural dune volume
        totalDuneVolume = abs(integralProfile - integralLine);
        
    else
        totalDuneVolume = naturalVolume;
    end
end