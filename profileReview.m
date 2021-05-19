function profileReview(location, year, x_values, local_x_values,...
    profiles, profilesNext, genPath, useMorpho, morpho1997,...
    previousMorpho, section, clearBerms, printNans)
    % This is the main GUI function for automorphGUI
    %
    % Michael Itzkin, 4/11/2019
    
    % Fill missing values
    profiles = fillmissing(profiles, 'linear', 2, 'EndValues', 'nearest');
    
    % Smooth the profile
    for kk = 1:length(useMorpho(:,1))
        profiles(:, kk, 3) = loess(profiles(:, kk, 3), x_values, x_values, 5);
    end
    
    k = 1;  % Inititalize the first profile
    h = []; % Create an empty variable for the plot
    
    MHW = 0.34;
    
    if year >= 2010
        fenced =1;
    else
        fenced = 0;
    end
    
    % Calculate wet and dry beach volumes. Clear out any metrics
    % that correspond to a building that may have been picked as
    % a dune by mistake
    if length(useMorpho(1, :)) < 90
        useMorpho(:, 89:90) = NaN;
    end
    for kk = 1:length(useMorpho(:,1))
        
        % Find the MHW index
        mhw_index = nanmin(find_closest(profiles(:, kk,3), MHW));
        
        % Find the natural dune toe index
        toe_index = find(x_values == useMorpho(kk, 12));
        if isempty(toe_index)
            yToe = useMorpho(kk, 13);
            toe_index = nanmin(find_closest(profiles(:, kk, 3), yToe)); 
        end
        
        % Find the fenced dune toe index
        if year >= 2010
            if ~isnan(useMorpho(kk, 4))
                fence_toe_index = find(x_values == useMorpho(kk, 4));
            end
            if ~isnan(useMorpho(kk, 4)) && isempty(berm_index)
               fence_toe_index = nanmin(find_closest(profiles(:, kk, 3), useMorpho(kk, 5))); 
            end
            
            if ~isempty(fence_toe_index)
                toe_index = fence_toe_index;
            end
        end
        
        % Find the berm index
        if ~isnan(useMorpho(kk, 60))
            berm_index = find(x_values == useMorpho(kk, 60));
        end
        if ~isnan(useMorpho(kk, 61)) && isempty(berm_index)
           berm_index = nanmin(find_closest(profiles(:, kk, 3), useMorpho(kk, 61))); 
        end
        
        % Measure the wet beach volume
        if isnan(useMorpho(kk, 89))
            if ~isnan(useMorpho(kk, 60)) && ~isempty(berm_index) && (berm_index < mhw_index)
                wet_beach_volume =...
                    trapz(x_values(berm_index:mhw_index),...
                    profiles(berm_index:mhw_index, kk, 3));
                useMorpho(kk, 89) = abs(wet_beach_volume);
            elseif ~isnan(useMorpho(kk, 60)) && ~isempty(berm_index) && (berm_index > mhw_index)
                wet_beach_volume =...
                    trapz(x_values(mhw_index:berm_index),...
                    profiles(mhw_index:berm_index, kk, 3));
                useMorpho(kk, 89) = abs(wet_beach_volume);
            else
                useMorpho(kk, 89) = NaN;
            end
        end
        

        % Measure the dry beach volume
        if isnan(useMorpho(kk, 90))
            if ~isnan(useMorpho(kk, 60)) && ~isempty(berm_index) && ~isempty(toe_index) && (toe_index < berm_index)
                dry_beach_volume =...
                    trapz(x_values(toe_index:berm_index),...
                    profiles(toe_index:berm_index, kk, 3));
                useMorpho(kk, 90) = abs(dry_beach_volume);
            elseif ~isnan(useMorpho(kk, 60))&& ~isempty(berm_index)  && ~isempty(toe_index) && (toe_index > berm_index)
                dry_beach_volume =...
                    trapz(x_values(berm_index:toe_index),...
                    profiles(berm_index:toe_index, kk, 3));
                useMorpho(kk, 90) = abs(dry_beach_volume);
            else
                useMorpho(kk, 90) = NaN;
            end
        end
              
        % If y_crest is a NaN, clear out the natural dune metrics
        naturalDuneMetricColumns = [14, 15, 16, 17 30, 31, 32, 33, 46,...
            47, 48, 49, 50];
        if isnan(useMorpho(kk, 15))
            useMorpho(kk, naturalDuneMetricColumns) = NaN;
        end
        
    end
    
    % If clearBerms == 1, remove all the metrics dealing
    % with berms
    if clearBerms
        bermColumns = [60, 61, 62, 63, 64, 65, 89, 90];
        useMorpho(:, bermColumns) = NaN;
    end
    
    % Print any profiles with a NaN berm value
    if printNans
        nanColumns = isnan(useMorpho(:, 89)) | isnan(useMorpho(:, 90));
        useMorpho(nanColumns, 1)
    end
    
    
    % Create the GUI figure
    f = figure('Visible', 'off',...
        'color', [0.75 0.75 0.75],...
        'Position', [300 400 1000 1000]);
    
    % Create the axes for the plot
    axHan = axes('Units', 'Pixels',...
        'Position', [50 150 500 500],...
        'Parent', f);
    profileView
    
    % Create a "next" button under the plot, on the right
    nexth = uicontrol('Style', 'pushbutton',...
        'String', 'Next >>',...
        'Position', [450 50 100 50],...
        'Callback', @profileChange);
    
    
    % Create a "previous" button under the plot, on the left
    prevh = uicontrol('Style', 'pushbutton',...
        'String', '<< Previous',...
        'Position', [50 50 100 50],...
        'Callback', @profileChange);
    
    % Create a "skip to" box under the plot in the middle
    % between the "<< Previous" and "Next >>" buttons
    skiptexth = uicontrol('Style', 'pushbutton',...
        'String', 'Skip to Profile: ',...
        'Position', [200 50 100 50],...
        'Callback', @profileChange);
    skiph = uicontrol('Style', 'edit',...
        'Position', [300 50 100 50],...
        'Callback', @profileChange);
    
    % Create a column of "edit" buttons
    edith = uicontrol('Style', 'text',...
        'String', sprintf('\n Edit Feature: '),...
        'Position', [600 610 100 50]);
    bermEdith = uicontrol('Style', 'pushbutton',...
        'String', 'Berm',...
        'Position', [600 560 100 50],...
        'Callback', @profileEdit);
    toeEdith = uicontrol('Style', 'pushbutton',...
        'String', 'Toe',...
        'Position', [600 510 100 50],...
        'Callback', @profileEdit);
    crestEdith = uicontrol('Style', 'pushbutton',...
        'String', 'Crest',...
        'Position', [600 460 100 50],...
        'Callback', @profileEdit);
    heelEdith = uicontrol('Style', 'pushbutton',...
        'String', 'Heel',...
        'Position', [600 410 100 50],...
        'Callback', @profileEdit);
    fenceToeEdith = uicontrol('Style', 'pushbutton',...
        'String', 'Fenced Dune Toe',...
        'Position', [600 360 100 50],...
        'Callback', @profileEdit);
    fenceCrestEdith = uicontrol('Style', 'pushbutton',...
        'String', 'Fenced Dune Crest',...
        'Position', [600 310 100 50],...
        'Callback', @profileEdit);
    fenceHeelEdith = uicontrol('Style', 'pushbutton',...
        'String', 'Fenced Dune Heel',...
        'Position', [600 260 100 50],...
        'Callback', @profileEdit);
    
    % Create a column of "clear" buttons
    clearh = uicontrol('Style', 'text',...
        'String', sprintf('\n Clear Feature: '),...
        'Position', [725 610 100 50]);
    bermClearh = uicontrol('Style', 'pushbutton',...
        'String', 'Berm',...
        'Position', [725 560 100 50],...
        'Callback', @profileClear);
    toeClearh = uicontrol('Style', 'pushbutton',...
        'String', 'Toe',...
        'Position', [725 510 100 50],...
        'Callback', @profileClear);
    crestClearh = uicontrol('Style', 'pushbutton',...
        'String', 'Crest',...
        'Position', [725 460 100 50],...
        'Callback', @profileClear);
    heelClearh = uicontrol('Style', 'pushbutton',...
        'String', 'Heel',...
        'Position', [725 410 100 50],...
        'Callback', @profileClear);
    fenceToeClearh = uicontrol('Style', 'pushbutton',...
        'String', 'Fenced Dune Toe',...
        'Position', [725 360 100 50],...
        'Callback', @profileClear);
    fenceCrestClearh = uicontrol('Style', 'pushbutton',...
        'String', 'Fenced Dune Crest',...
        'Position', [725 310 100 50],...
        'Callback', @profileClear);
    fenceHeelClearh = uicontrol('Style', 'pushbutton',...
        'String', 'Fenced Dune Heel',...
        'Position', [725 260 100 50],...
        'Callback', @profileClear);

    % Create a button to save changes
    saveh = uicontrol('Style', 'pushbutton',...
        'String', 'Approve and Save',...
        'Position', [700 150 100 50],...
        'Callback', @saveMorpho);
    savetexth = uicontrol('Style', 'text',...
        'Visible', 'off',...
        'String', sprintf('\nFigure Saved Successfully!'),...
        'Position', [700 100 100 50]);
    
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    
    % Make the profileChange function
    function profileChange(hObject, eventdata)
        % Change the profile being worked on based
        % on the button pressed by the user
        
        % Change to the desired profile
        if hObject == nexth
            set(savetexth, 'Visible', 'off')
            cla
            k = k + 1;
            profileView
        elseif hObject == prevh
            set(savetexth, 'Visible', 'off')
            cla
            k = k - 1;
            profileView
        elseif hObject == skiph || hObject == skiptexth
            set(savetexth, 'Visible', 'off')
            cla
            hold on
            k = str2num(get(skiph, 'String'));
            profileView
        end       
    end
    
    % Make the profileEdit function
    function profileEdit(hObject, eventdata)
        % Change the location of a feature
        
        mhw_index = nanmin(find_closest(profiles(:,k,3), MHW));
        
        if hObject == bermEdith
            
            % Set the berm position
            set(savetexth, 'Visible', 'off')
            [ptX, ptY] = ginput(1);
            [x_berm, y_berm, local_x_berm, local_y_berm,...
                    berm_lon, berm_lat, berm_index] = findNearest(ptX,...
                    ptY, profiles, k, x_values, local_x_values);
            useMorpho(k,60) = x_berm;
            useMorpho(k,61) = y_berm;
            useMorpho(k, 62) = local_x_berm;
            useMorpho(k, 63) = local_y_berm;
            useMorpho(k, 64) = berm_lon;
            useMorpho(k, 65) = berm_lat;
            
            % Find the natural dune toe index
            toe_index = find(x_values == useMorpho(k, 12));
            if isempty(toe_index)
                yToe = useMorpho(k, 13);
                toe_index = nanmin(find_closest(profiles(:, k, 3), yToe)); 
            end

            % Find the fenced dune toe index
            if year >= 2010
                if ~isnan(useMorpho(k, 4))
                    fence_toe_index = find(x_values == useMorpho(k, 4));
                end
                if ~isnan(useMorpho(k, 4)) && isempty(berm_index)
                   fence_toe_index = nanmin(find_closest(profiles(:, k, 3), useMorpho(k, 5))); 
                end
            end
            
            % Measure the wet beach volume;
            if ~isnan(useMorpho(k, 60))
                berm_index = find(x_values == useMorpho(k, 60));
            end
            if ~isnan(useMorpho(k, 61)) && isempty(berm_index)
               berm_index = nanmin(find_closest(profiles(:, k, 3), useMorpho(k, 61))); 
            end
            if berm_index < mhw_index
                wet_beach_volume =...
                    trapz(x_values(berm_index:mhw_index),...
                    profiles(berm_index:mhw_index,k,3));
            else
                wet_beach_volume =...
                    trapz(x_values(mhw_index:berm_index),...
                    profiles(mhw_index:berm_index,k,3));
            end
            useMorpho(k, 89) = abs(wet_beach_volume);
            profileView

            % Measure the dry beach volume
            if exist('fence_toe_index') && ~isempty(fence_toe_index)
                use_index = fence_toe_index;
            else
                use_index = toe_index;
            end
            if use_index < berm_index
                dry_beach_volume =...
                    trapz(x_values(use_index:berm_index),...
                    profiles(use_index:berm_index,k,3));
            else
                dry_beach_volume =...
                    trapz(x_values(berm_index:use_index),...
                    profiles(berm_index:use_index,k,3));
            end
            useMorpho(k, 90) = abs(dry_beach_volume);
            profileView
                
            cla
            profileView
        elseif hObject == toeEdith
            set(savetexth, 'Visible', 'off')
            [ptX, ptY] = ginput(1);
            [x_toe, y_toe, local_x_toe, local_y_toe,...
                    toe_lon, toe_lat, toe_index] = findNearest(ptX,...
                    ptY, profiles, k, x_values, local_x_values);
            useMorpho(k,12) = x_toe;
            useMorpho(k,13) = y_toe;
            useMorpho(k, 28) = local_x_toe;
            useMorpho(k, 29) = local_y_toe;
            useMorpho(k, 44) = toe_lon;
            useMorpho(k, 45) = toe_lat;
            
            % Measure the dry beach volume
            if ~isnan(useMorpho(k, 60))
                berm_index = find(x_values == useMorpho(k, 60));
            end
            if ~isnan(useMorpho(k, 61)) && isempty(berm_index)
               berm_index = nanmin(find_closest(profiles(:, k, 3), useMorpho(k, 61))); 
            end
            if exist('fence_toe_index') && ~isempty(fence_toe_index)
                use_index = fence_toe_index;
            else
                use_index = toe_index;
            end
            if use_index < berm_index
                dry_beach_volume =...
                    trapz(x_values(use_index:berm_index),...
                    profiles(use_index:berm_index,k,3));
            else
                dry_beach_volume =...
                    trapz(x_values(berm_index:use_index),...
                    profiles(berm_index:use_index,k,3));
            end
            useMorpho(k, 90) = abs(dry_beach_volume);
            profileView
            
            cla
            profileView
            
        elseif hObject == crestEdith
            
            % Manually select the crest
            set(savetexth, 'Visible', 'off')
            [ptX, ptY] = ginput(1);
            [x_crest, y_crest, local_x_crest, local_y_crest,...
                    crest_lon, crest_lat, crest_index] = findNearest(ptX,...
                    ptY, profiles, k, x_values, local_x_values);
            useMorpho(k,14) = x_crest;
            useMorpho(k,15) = y_crest;
            useMorpho(k, 30) = local_x_crest;
            useMorpho(k, 31) = local_y_crest;
            useMorpho(k, 46) = crest_lon;
            useMorpho(k, 47) = crest_lat;
            
            % Adjust the heel
            heelElevation = y_crest - 0.6;
            heel_index = crest_index;
            while (heel_index > 1) &&...
                    (profiles(heel_index,k,3) > heelElevation) &&...
                    (profiles(heel_index-1, k, 3) < (y_crest * 1.10))
                heel_index = heel_index - 1;
            end
            if heel_index == 1
                profile_copy = profiles(:,k,3);
                linear_component = linspace(1, y_crest,...
                    length(1:crest_index));
                profile_copy(1:crest_index) = linear_component;
                dists = profile_copy - profiles(:,k,3);
                heel_index = find(dists == nanmax(dists));
                while(heel_index-1 > 1)
                   if profiles(heel_index-1,k,3) < profiles(heel_index,k,3)
                       heel_index = heel_index-1;
                   else
                       break
                   end 
                end
                heel_index = nanmin(heel_index);
            else
                while(heel_index-1 > 1)
                   if profiles(heel_index-1,k,3) < profiles(heel_index,k,3)
                       heel_index = heel_index - 1;
                   else
                       break
                   end 
                end    
                while(heel_index + 1 < crest_index)
                   if profiles(heel_index+1,k,3) < profiles(heel_index,k,3)
                       heel_index = heel_index + 1;
                   else
                       break
                   end 
                end    
            end

            heel_index = nanmin(heel_index);
            [x_heel, y_heel, local_x_heel, local_y_heel, heel_lon, heel_lat] =...
                set_locations(x_values, local_x_values, profiles, heel_index, k);
            useMorpho(k,16) = x_heel;
            useMorpho(k,17) = y_heel;
            useMorpho(k, 32) = local_x_heel;
            useMorpho(k, 33) = local_y_heel;
            useMorpho(k, 48) = heel_lon;
            useMorpho(k, 49) = heel_lat;
            cla
            profileView
        elseif hObject == heelEdith
            set(savetexth, 'Visible', 'off')
            [ptX, ptY] = ginput(1);
            [x_heel, y_heel, local_x_heel, local_y_heel,...
                    heel_lon, heel_lat, heel_index] = findNearest(ptX,...
                    ptY, profiles, k, x_values, local_x_values);
            useMorpho(k,16) = x_heel;
            useMorpho(k,17) = y_heel;
            useMorpho(k, 32) = local_x_heel;
            useMorpho(k, 33) = local_y_heel;
            useMorpho(k, 48) = heel_lon;
            useMorpho(k, 49) = heel_lat;
            cla
            profileView
        elseif hObject == fenceToeEdith
            set(savetexth, 'Visible', 'off')
            [ptX, ptY] = ginput(1);
            [x_fence_toe, y_fence_toe, local_x_fence_toe, local_y_fence_toe,...
                    fence_toe_lon, fence_toe_lat, fence_toe_index] = findNearest(ptX,...
                    ptY, profiles, k, x_values, local_x_values);
            useMorpho(k, 4) = x_fence_toe;
            useMorpho(k, 5) = y_fence_toe;
            useMorpho(k, 20) = local_x_fence_toe;
            useMorpho(k, 21) = local_y_fence_toe;
            useMorpho(k, 36) = fence_toe_lon;
            useMorpho(k, 37) = fence_toe_lat;
            
            % Measure the dry beach volume
            if ~isnan(useMorpho(k, 60))
                berm_index = find(x_values == useMorpho(k, 60));
            end
            if ~isnan(useMorpho(k, 61)) && isempty(berm_index)
               berm_index = nanmin(find_closest(profiles(:, k, 3), useMorpho(k, 61))); 
            end
            use_index = fence_toe_index;
            if use_index < berm_index
                dry_beach_volume =...
                    trapz(x_values(use_index:berm_index),...
                    profiles(use_index:berm_index,k,3));
            else
                dry_beach_volume =...
                    trapz(x_values(berm_index:use_index),...
                    profiles(berm_index:use_index,k,3));
            end
            useMorpho(k, 90) = abs(dry_beach_volume);
            profileView
         
            cla
            profileView
        elseif hObject == fenceCrestEdith
            set(savetexth, 'Visible', 'off')
            [ptX, ptY] = ginput(1);
            [x_fence_crest, y_fence_crest, local_x_fence_crest, local_y_fence_crest,...
                    fence_crest_lon, fence_crest_lat, fence_crest_index] = findNearest(ptX,...
                    ptY, profiles, k, x_values, local_x_values);
            useMorpho(k, 8) = x_fence_crest;
            useMorpho(k, 9) = y_fence_crest;
            useMorpho(k, 24) = local_x_fence_crest;
            useMorpho(k, 25) = local_y_fence_crest;
            useMorpho(k, 40) = fence_crest_lon;
            useMorpho(k, 41) = fence_crest_lat;
            
            % Adjust the fenced dune heel
            heelElevation = y_fence_crest;
            fence_heel_index = fence_crest_index;
            while (fence_heel_index > 1) &&...
                    (profiles(fence_heel_index,k,3) > heelElevation) &&...
                    (profiles(fence_heel_index-1, k, 3) < (y_fence_crest * 1.10))
                fence_heel_index = fence_heel_index - 1;
            end
            if fence_heel_index == 1
                profile_copy = profiles(:,k,3);
                linear_component = linspace(1, y_fence_crest,...
                    length(1:fence_crest_index));
                profile_copy(1:crest_index) = linear_component;
                dists = profile_copy - profiles(:,k,3);
                fence_heel_index = find(dists == nanmax(dists));
                while(fence_heel_index-1 > 1)
                   if profiles(fence_heel_index-1,k,3) < profiles(fence_heel_index,k,3)
                       fence_heel_index = fence_heel_index-1;
                   else
                       break
                   end 
                end
                fence_heel_index = nanmin(fence_heel_index);
            else
                while(fence_heel_index-1 > 1)
                   if profiles(fence_heel_index-1,k,3) < profiles(fence_heel_index,k,3)
                       fence_heel_index = fence_heel_index - 1;
                   else
                       break
                   end 
                end    
                while(fence_heel_index + 1 < fence_crest_index)
                   if profiles(fence_heel_index+1,k,3) < profiles(fence_heel_index,k,3)
                       fence_heel_index = fence_heel_index + 1;
                   else
                       break
                   end 
                end    
            end

            fence_heel_index = nanmin(fence_heel_index);
            [x_fence_heel, y_fence_heel, local_x_fence_heel,...
                local_y_fence_heel, fence_heel_lon, fence_heel_lat] =...
                set_locations(x_values, local_x_values, profiles, fence_heel_index, k);
            useMorpho(k,10) = x_fence_heel;
            useMorpho(k,11) = y_fence_heel;
            useMorpho(k, 26) = local_x_fence_heel;
            useMorpho(k, 27) = local_y_fence_heel;
            useMorpho(k, 42) = fence_heel_lon;
            useMorpho(k, 43) = fence_heel_lat;
            
            cla
            profileView
        elseif hObject == fenceHeelEdith
            set(savetexth, 'Visible', 'off')
            [ptX, ptY] = ginput(1);
            [x_fence_heel, y_fence_heel, local_x_fence_heel, local_y_fence_heel,...
                    fence_heel_lon, fence_heel_lat, fence_heel_index] = findNearest(ptX,...
                    ptY, profiles, k, x_values, local_x_values);
            useMorpho(k, 10) = x_fence_heel;
            useMorpho(k, 11) = y_fence_heel;
            useMorpho(k, 26) = local_x_fence_heel;
            useMorpho(k, 27) = local_y_fence_heel;
            useMorpho(k, 42) = fence_heel_lon;
            useMorpho(k, 43) = fence_heel_lat;
            cla
            profileView
        end
        
        % Calculate the natural dune volume
        if hObject == toeEdith || hObject == heelEdith || hObject == crestEdith
            heel_index = find(x_values == useMorpho(k,16));
            toe_index = find(x_values == useMorpho(k,12));
            if useMorpho(k,17) <= useMorpho(k,13)
                x = profiles(:,k,3);
                x(heel_index:toe_index) = useMorpho(k,17);
            elseif useMorpho(k,13) < useMorpho(k,17)    
                x = profiles(:,k,3)';
                x(heel_index:toe_index) = useMorpho(k,13);
            end  
            integral_profile = trapz(x_values, profiles(:,k,3));
            integral_line = trapz(x_values, x);
            natural_dune_volume = abs(integral_profile - integral_line);
            useMorpho(k, 50) = natural_dune_volume;
            profileView
        end
        
        % Calculate the fenced dune volume
        if hObject == fenceHeelEdith ||...
                hObject == fenceToeEdith ||...
                hObject == fenceCrestEdith
            fence_toe_index = find(x_values == useMorpho(k, 4));
            fence_heel_index = find(x_values == useMorpho(k, 10));
            if useMorpho(k, 11) <= useMorpho(k, 5)
                x = profiles(:,k,3);
                x(fence_heel_index:fence_toe_index) = useMorpho(k, 11);
            elseif useMorpho(k, 5) < useMorpho(k, 11)   
                x = profiles(:,k,3);
                x(fence_heel_index:fence_toe_index) = useMorpho(k, 5);
            end  
            integral_profile = trapz(x_values, profiles(:,k,3));
            integral_line = trapz(x_values, x);
            fenced_dune_volume = abs(integral_profile - integral_line);
            useMorpho(k, 51) = fenced_dune_volume;
            profileView
        end
        
        % Calculate the total dune volume
        if isnan(useMorpho(k, 51))
            useMorpho(k, 52) = useMorpho(k, 50);
            profileView
        else
            useMorpho(k, 52) = useMorpho(k, 50) + useMorpho(k, 51);
            profileView
        end
        
        % Calculate the dry beach volume
        if hObject == toeEdith || hObject == fenceToeEdith ||hObject == crestEdith
            berm_index = find(x_values == useMorpho(k,60));
            toe_index = find(x_values == useMorpho(k, 12));
            fence_toe_index = find(x_values == useMorpho(k, 4));
            if ~isempty(fence_toe_index) && ~isnan(fence_toe_index)
                use_index = fence_toe_index;
            else
                use_index = toe_index;
            end
            if (~isnan(berm_index)) && (~isempty(berm_index)) && (use_index < berm_index)
                dry_beach_volume =...
                    trapz(x_values(use_index:berm_index),...
                    profiles(use_index:berm_index,k,3));
            elseif (~isnan(berm_index)) && (~isempty(berm_index)) && (use_index >= berm_index)
                dry_beach_volume =...
                    trapz(x_values(berm_index:use_index),...
                    profiles(berm_index:use_index,k,3));
            end
            useMorpho(k, 90) = abs(dry_beach_volume);
        end
        
        % Calculate the beach width
        if hObject == fenceToeEdith
            beach_width = local_x_fence_toe - useMorpho(k, 18);
            useMorpho(k, 53) = beach_width;
            profileView
        elseif hObject == toeEdith
            beach_width = local_x_toe - useMorpho(k, 18);
            useMorpho(k, 53) = beach_width;
            profileView
        end
        
        % Calculate the position of the 1997 Dhigh
        if strcmp(year, '1997') && hObject == crestEdith
            useMorpho(k, 54) = y_crest;
            useMorpho(k, 55) = crest_index;
        end
        
        % Calculate the position of the 2010 Fhigh
        if strcmp(year, '2010') && hObject == fenceCrestEdith
            useMorpho(k, 56) = profiles(fence_crest_index, k, 3);
            useMorpho(k, 57) = fence_crest_index;
        end
        
        % Calculate the position of the 2010 Dhigh
        if strcmp(year, '2010') && hObject == crestEdith
            useMorpho(k, 81) = y_crest;
            useMorpho(k, 82) = crest_index;
        end
        
        % Calculate the volume contained within the 1997
        % dune position
        if strcmp(year, '1997')
            useMorpho(k, 66) = toe_index;
            useMorpho(k, 67) = heel_index;
            useMorpho(k, 68) =...
                        abs(trapz(...
                        x_values(useMorpho(k, 67):useMorpho(k, 66)),...
                        profiles(useMorpho(k, 67):useMorpho(k, 66), k, 3)));
        end
        
        % Calculate the volume contained within the
        % 2010 dune position
        if strcmp(year, '2010')
            useMorpho(k, 83) = toe_index;
            useMorpho(k, 84) = heel_index;
            useMorpho(k, 85) =...
                        abs(trapz(...
                        x_values(useMorpho(k, 84):useMorpho(k, 83)),...
                        profiles(useMorpho(k, 84):useMorpho(k, 83), k, 3)));
        end
        
        % Calculate the volume contained within the 2010
        % fenced dune position
        if strcmp(year, '2010') && (hObject == fenceToeEdith || hObject == fenceHeelEdith)
            useMorpho(k, 78) = fence_toe_index;
            useMorpho(k, 79) = fence_heel_index;
            useMorpho(k, 80) =...
                        abs(trapz(...
                        x_values(useMorpho(k, 79):useMorpho(k, 78)),...
                        profiles(useMorpho(k, 79):useMorpho(k, 78), k, 3)));
        end
        
        % Calculate the volume contained within
        % the 2010 beach position
        if strcmp(year, '2010') && hObject == toeEdith
            idxToe2010 = find(x_values == useMorpho(k, 12));
            idxMHW2010 = mhw_index;
            useMorpho(k, 86) = idxToe2010;
            useMorpho(k, 87) = idxMHW2010;
            
            if idxMHW2010 > idxToe2010
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
        if hObject == fenceToeEdith || hObject == toeEdith
            low_elevation = useMorpho(k, 3) - 0.5;
            high_elevation = useMorpho(k, 3) + 0.5;
            if nanmin(profiles(:,k,3)) < low_elevation
                low_dists = abs(profiles(:,k,3) - low_elevation);
                low_elevation_index = find(low_dists(mhw_index:length(x_values)) == nanmin(low_dists(mhw_index:length(x_values))));
                low_elevation_index = mhw_index + low_elevation_index;
                if low_elevation_index > length(x_values)
                    low_elevation_index = length(x_values);
                end
            else
                low_elevation_index = length(x_values);
            end
            high_dists = abs(profiles(:,k,3) - high_elevation);
            high_elevation_index = find(high_dists == nanmin(high_dists));
            regress_range = [high_elevation_index:low_elevation_index];
            if ~isempty(regress_range)
                beach_slope_regression = fitlm(x_values(regress_range),...
                    profiles(regress_range,k,3));
                beach_slope = beach_slope_regression.Coefficients{2,1};
            else
                beach_slope = NaN;
            end
            useMorpho(k, 58) = beach_slope;
            profileView
        end
        
        if hObject == fenceToeEdith
            useMorpho(k, 59) = (y_fence_toe - useMorpho(k, 3))/(x_fence_toe - useMorpho(k, 2));
            profileView
        elseif hObject == toeEdith
            useMorpho(k, 59) = (y_toe - useMorpho(k, 3))/(x_toe - useMorpho(k, 2));
            profileView
        end
        
    end
    
    % Make the profileClear function
    function profileClear(hObject, eventdata)
        % Change the location of a feature
        
        if hObject == bermClearh
            set(savetexth, 'Visible', 'off')
            useMorpho(k,60) = NaN;
            useMorpho(k,61) = NaN;
            useMorpho(k, 62) = NaN;
            useMorpho(k, 63) = NaN;
            useMorpho(k, 64) = NaN;
            useMorpho(k, 65) = NaN;
            useMorpho(k, 89) = NaN;
            useMorpho(k, 90) = NaN;
            cla
            profileView
        elseif hObject == toeClearh
            set(savetexth, 'Visible', 'off')
            useMorpho(k,12) = NaN;
            useMorpho(k,13) = NaN;
            useMorpho(k, 28) = NaN;
            useMorpho(k, 29) = NaN;
            useMorpho(k, 44) = NaN;
            useMorpho(k, 45) = NaN;
            cla
            profileView
        elseif hObject == crestClearh
            set(savetexth, 'Visible', 'off')
            useMorpho(k,14) = NaN;
            useMorpho(k,15) = NaN;
            useMorpho(k, 30) = NaN;
            useMorpho(k, 31) = NaN;
            useMorpho(k, 46) = NaN;
            useMorpho(k, 47) = NaN;
            
            % If y_crest is a NaN, clear out the natural dune metrics
            naturalDuneMetricColumns = [14, 15, 16, 17 30, 31, 32, 33, 46,...
                47, 48, 49, 50];
            useMorpho(k, naturalDuneMetricColumns) = NaN;
            
            cla
            profileView
        elseif hObject == heelClearh
            set(savetexth, 'Visible', 'off')
            useMorpho(k,16) = NaN;
            useMorpho(k,17) = NaN;
            useMorpho(k, 32) = NaN;
            useMorpho(k, 33) = NaN;
            useMorpho(k, 48) = NaN;
            useMorpho(k, 49) = NaN;
            
            % If y_crest is a NaN, clear out the natural dune metrics
            naturalDuneMetricColumns = [14, 15, 16, 17 30, 31, 32, 33, 46,...
                47, 48, 49, 50];
            if isnan(useMorpho(kk, 15))
                useMorpho(kk, naturalDuneMetricColumns) = NaN;
            end
            
            cla
            profileView
        elseif hObject == fenceToeClearh
            set(savetexth, 'Visible', 'off')
            useMorpho(k, 4) = NaN;
            useMorpho(k, 5) = NaN;
            useMorpho(k, 20) = NaN;
            useMorpho(k, 21) = NaN;
            useMorpho(k, 36) = NaN;
            useMorpho(k, 37) = NaN;
            useMorpho(k, 51) = NaN;
            useMorpho(k, 52) = useMorpho(k, 50);
            useMorpho(k, 56) = NaN;
            useMorpho(k, 57) = NaN;
            cla
            profileView
        elseif hObject == fenceCrestClearh
            set(savetexth, 'Visible', 'off')
            useMorpho(k, 8) = NaN;
            useMorpho(k, 9) = NaN;
            useMorpho(k, 24) = NaN;
            useMorpho(k, 25) = NaN;
            useMorpho(k, 40) = NaN;
            useMorpho(k, 41) = NaN;
            useMorpho(k, 51) = NaN;
            useMorpho(k, 52) = useMorpho(k, 50);
            useMorpho(k, 56) = NaN;
            useMorpho(k, 57) = NaN;
            cla
            profileView
        elseif hObject == fenceHeelClearh
            set(savetexth, 'Visible', 'off')
            useMorpho(k, 10) = NaN;
            useMorpho(k, 11) = NaN;
            useMorpho(k, 26) = NaN;
            useMorpho(k, 27) = NaN;
            useMorpho(k, 42) = NaN;
            useMorpho(k, 43) = NaN;
            useMorpho(k, 51) = NaN;
            useMorpho(k, 52) = useMorpho(k, 50);
            useMorpho(k, 56) = NaN;
            useMorpho(k, 57) = NaN;
            cla
            profileView
        end
    end

    % Make the saveMorpho function
    function saveMorpho(hObject, eventdata)
        % Save the changes to the profile
        
        if hObject == saveh || savetexth
        
            % Make a new plot
            profile_plotter

            % Re-plot the overview map
            morpho_table = useMorpho;
            sand = [0.93, 0.79, 0.69];
            water = [0.51, 0.90, 0.85];
            fence_toe_color = [0.55 0.57 0.67];
            fence_crest_color = [0.91, 0.41, 0.17];
            fence_heel_color = [0.50, 0.00, 0.90];

            Title = sprintf('2D View of %s %s', location(1:end-1), year);
            latlon_figure = figure('name', Title);

            hold on
            grid on
            box on

            scatter(morpho_table(:,34), morpho_table(:,35),...
                'MarkerFaceColor', 'y',...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'MHW')
            scatter(morpho_table(:,36), morpho_table(:,37),...
                'MarkerFaceColor', fence_toe_color,...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'Fenced Dune Toe')
            scatter(morpho_table(:,38), morpho_table(:,39),...
                'MarkerFaceColor', 'r',...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'Fence')
            scatter(morpho_table(:,40), morpho_table(:,41),...
                'MarkerFaceColor', fence_crest_color,...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'Fenced Dune Crest')
            scatter(morpho_table(:,44), morpho_table(:,45),...
                'MarkerFaceColor', 'b',...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'Toe')
            scatter(morpho_table(:,42), morpho_table(:,43),...
                'MarkerFaceColor', fence_heel_color,...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'Fenced Dune Heel')
            scatter(morpho_table(:,46), morpho_table(:,47),...
                'MarkerFaceColor', 'm',...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'Crest')
            scatter(morpho_table(:,48), morpho_table(:,49),...
                'MarkerFaceColor', 'g',...
                'MarkerEdgeColor', 'k',...
                'DisplayName', 'Heel')

            legend('Location', 'northeastoutside')

            set(gca, 'FontWeight', 'bold')
            xlabel('Longitude (^{o})')
            ylabel('Latitude (^{o})')
            title(Title)

            save_name = sprintf('%s%s%s%s%s.png', location(1:end-1), filesep, year, filesep, Title);
            saveas(latlon_figure, save_name, 'png')
            close()

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
                '2010 Beach Volume', 'Wet Beach Volume', 'Dry Beach Volume'};
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
                useMorpho,...
                '-append',...
                'Delimiter', ',',...
                'Precision', 9)

            set(savetexth, 'Visible', 'on')
        end
    end

    % Function to identify the nearest point on the profile
    % to where the user clicked in a feature
    function [x, y, local_x, local_y, lon, lat, index] =...
            findNearest(ptX, ptY,...
            profiles, k, x_values, local_x_values)
        
        % Find the nearest point to the profile

        distances = sqrt((ptX - x_values).^2 + (ptY - profiles(:,k,3)).^2);
        [~, index] = nanmin(distances);  
        index = index(1);

        % Set local locations and lat/lon
        [x, y, local_x, local_y, lon, lat] =...
            set_locations(x_values, local_x_values, profiles, index, k);

    end

    % Function to view the profile
    function profileView
        % Plot the profile
        hold(axHan, 'on')
        
        % Add a line 1m below the dune crest
        line([x_values(1) x_values(end)],...
            [useMorpho(k,15) - 0.6 useMorpho(k,15) - 0.6],...
            'Color', 'k',...
            'LineWidth', 2,...
            'Parent', axHan);
        
        % Add lines marking where the dunes were for the
        % last survey of the current profile
        line([previousMorpho(k, 12) previousMorpho(k, 12)],...
            [0 12],...
            'Color', 'b',...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        line([previousMorpho(k, 60) previousMorpho(k, 60)],...
            [0 12],...
            'Color', 'c',...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        line([previousMorpho(k, 14) previousMorpho(k, 14)],...
            [0 12],...
            'Color', 'm',...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        line([previousMorpho(k, 16) previousMorpho(k, 16)],...
            [0 12],...
            'Color', 'g',...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        line([previousMorpho(k, 6) previousMorpho(k, 6)],...
            [0 12],...
            'Color', 'r',...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        line([previousMorpho(k, 4) previousMorpho(k, 4)],...
            [0 12],...
            'Color', [0.55 0.57 0.67],...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        line([previousMorpho(k, 8) previousMorpho(k, 8)],...
            [0 12],...
            'Color', [0.91, 0.41, 0.17],...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        line([previousMorpho(k, 10) previousMorpho(k, 10)],...
            [0 12],...
            'Color', [0.50, 0.00, 0.90],...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        
        % Add lines marking where the dunes were for the
        % previous profile if the current profile is not #1
        if k > 1
            line([useMorpho(k-1, 12) useMorpho(k-1, 12)],...
                [0 12],...
                'Color', [0.00 0.00 0.50],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
            line([useMorpho(k-1, 60) useMorpho(k-1, 60)],...
                [0 12],...
                'Color', [0.00 0.50 0.50],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
            line([useMorpho(k-1, 14) useMorpho(k-1, 14)],...
                [0 12],...
                'Color', [0.50 0.00 0.50],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
            line([useMorpho(k-1, 16) useMorpho(k-1, 16)],...
                [0 12],...
                'Color', [0.00 0.50 0.00],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
            line([useMorpho(k-1, 6) useMorpho(k-1, 6)],...
                [0 12],...
                'Color', [0.50 0.00 0.00],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
            line([useMorpho(k-1, 4) useMorpho(k-1, 4)],...
                [0 12],...
                'Color', [0.55/2 0.57/2 0.67/2],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
            line([useMorpho(k-1, 8) useMorpho(k-1, 8)],...
                [0 12],...
                'Color', [0.91/2, 0.41/2, 0.17/2],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
            line([useMorpho(k-1, 10) useMorpho(k-1, 10)],...
                [0 12],...
                'Color', [0.25, 0.00, 0.45],...
                'LineStyle', '--',...
                'LineWidth', 2,...
                'Parent', axHan);
        end
        
        % Mark off the 1997 Dhigh position
        line([morpho1997(k,14) morpho1997(k,14)],...
            [0 12],...
            'Color', [0.75 0.75 0.75],...
            'LineStyle', '--',...
            'LineWidth', 2,...
            'Parent', axHan);
        
        % Plot and fill in the profile
        h = plot(x_values, profiles(:, k, 3),...
            'Color', 'k',...
            'LineWidth', 2,...
            'Parent', axHan);
        area([x_values(1) x_values(end)],...
            [0.34 0.34],...
            'FaceColor',[0.51, 0.90, 0.85],...
            'Parent', axHan);
        area(x_values, profiles(:, k, 3),...
            'FaceColor', [0.93, 0.79, 0.69],...
            'Parent', axHan);
        h2010 = plot(x_values, profilesNext(:, k, 3),...
            'Color', 'k',...
            'LineWidth', 2,...
            'LineStyle', '--',...
            'Parent', axHan);

        % Add MHW
        mhwPoint = scatter(useMorpho(k, 2), useMorpho(k, 3),...
            'MarkerFaceColor', 'y',...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'MHW',...
            'Parent', axHan);

        % Add the berm
        bermPoint = scatter(useMorpho(k, 60), useMorpho(k, 61),...
            'MarkerFaceColor', 'c',...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Berm',...
            'Parent', axHan);

        % Add the 2m contour
        twoMeterPoint = scatter(useMorpho(k, 72), useMorpho(k, 73),...
            'MarkerFaceColor', [0.25, 0.80, 0.60],...
            'MarkerEdgeColor', 'k',...
            'DisplayName', '2m Contour',...
            'Parent', axHan);

        % Add the natural dune toe
        toePoint = scatter(useMorpho(k, 12), useMorpho(k, 13),...
            'MarkerFaceColor', 'b',...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Toe',...
            'Parent', axHan);

        % Add the natural dune crest
        crestPoint = scatter(useMorpho(k, 14), useMorpho(k, 15),...
            'MarkerFaceColor', 'm',...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Crest',...
            'Parent', axHan);

        % Add the natural dune heel
        heelPoint = scatter(useMorpho(k, 16), useMorpho(k, 17),...
            'MarkerFaceColor', 'g',...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Heel',...
            'Parent', axHan);

        % Add the fence
        fencePoint = scatter(useMorpho(k, 6), useMorpho(k, 7),...
            'MarkerFaceColor', 'r',...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Fence',...
            'Parent', axHan);

        % Add the fenced dune toe
        fenceToePoint = scatter(useMorpho(k, 4), useMorpho(k, 5),...
            'MarkerFaceColor', [0.55 0.57 0.67],...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Fenced Dune Toe',...
            'Parent', axHan);

        % Add the fenced dune crest
        fenceCrestPoint = scatter(useMorpho(k, 8), useMorpho(k, 9),...
            'MarkerFaceColor', [0.91, 0.41, 0.17],...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Fenced Dune Crest',...
            'Parent', axHan);

        % Add the fenced dune heel
        fenceHeelPoint = scatter(useMorpho(k, 10), useMorpho(k, 11),...
            'MarkerFaceColor', [0.50, 0.00, 0.90],...
            'MarkerEdgeColor', 'k',...
            'DisplayName', 'Fenced Dune Heel',...
            'Parent', axHan);
        
        duneSlope = (useMorpho(:, 15) - useMorpho(:, 13)) ./...
            (useMorpho(:, 14) - useMorpho(:, 12));
        duneSlope = (atan(duneSlope) * 180) / pi;
        
        axHan.HitTest = 'off';
        axHan.XDir = 'reverse';
        axHan.Title.String = sprintf('%s%s, Profile %s of %s\nNatural Dune Volume: %.2f\nFenced Dune Volume: %.2f\nWet Beach Volume: %.2f (NaNs = %s)\nDry Beach Volume: %.2f (NaNs = %s)',...
            location,...
            num2str(year),...
            num2str(k),...
            num2str(length(profiles(1, :, 1))),...
            useMorpho(k, 50),...
            useMorpho(k, 51),...
            useMorpho(k, 89),...
            num2str(sum(isnan(useMorpho(:, 89)))),...
            useMorpho(k, 90),...
            num2str(sum(isnan(useMorpho(:, 90)))));
        axHan.YLim = [0 12];
        hold(axHan, 'off')
    end

    % Function to replot the profile and save the figure
    function profile_plotter()
        sand = [0.93, 0.79, 0.69];
        water = [0.51, 0.90, 0.85];
        twoMeter_color = [0.25, 0.80, 0.60];
        fence_toe_color = [0.55 0.57 0.67];
        fence_crest_color = [0.91, 0.41, 0.17];
        fence_heel_color = [0.50, 0.00, 0.90];

        Title = sprintf('%s %s (Profile %d)', location(1:end-1), year, k);
        profile_figure = figure('name', Title, 'Visible', 'Off');

        hold on
        grid on
        box on

        % Plot the profile and water colored in
        water_level = ones(1,length(local_x_values(:,k))) * MHW;
        area(local_x_values(:,k), water_level,...
            'EdgeColor', 'k',...
            'FaceColor', water,...
            'LineWidth', 1)
        area(local_x_values(:,k), profiles(:,k,3),...
            'EdgeColor', 'k',...
            'FaceColor', sand,...
            'LineWidth', 1)

        % Plot the ghost profile if it exists
        if exist('ghostProfile')
           plot(local_x_values(:,k), ghostProfile,...
               'Color', 'k',...
               'LineStyle', '--')
        end

        % These are the natural features that every profile will have
        p_mhw = scatter(useMorpho(k, 18), useMorpho(k, 19), 50,...
            'Marker', 's',...
            'MarkerFaceColor', 'yellow',...
            'MarkerEdgeColor', 'k',...
            'LineWidth', 1,...
            'DisplayName', 'MHW');
        p_twoMeter = scatter(useMorpho(k, 74), useMorpho(k, 75), 50,...
            'Marker', 's',...
            'MarkerFaceColor', twoMeter_color,...
            'MarkerEdgeColor', 'k',...
            'LineWidth', 1,...
            'DisplayName', '2m Contour');
        p_toe = scatter(useMorpho(k, 28), useMorpho(k, 29), 50,...
            'Marker', 's',...
            'MarkerFaceColor', 'blue',...
            'MarkerEdgeColor', 'k',...
            'LineWidth', 1,...
            'DisplayName', 'Toe');
        p_crest = scatter(useMorpho(k, 30), useMorpho(k, 31), 50,...
            'Marker', 's',...
            'MarkerFaceColor', 'magenta',...
            'MarkerEdgeColor', 'k',...
            'LineWidth', 1,...
            'DisplayName', 'Crest');
        p_heel = scatter(useMorpho(k, 32), useMorpho(k, 33), 50,...
            'Marker', 's',...
            'MarkerFaceColor', 'green',...
            'MarkerEdgeColor', 'k',...
            'LineWidth', 1,...
            'DisplayName', 'Heel');

        % Make an empty list to add fenced features too for the legend
        natural_features = [p_mhw, p_twoMeter, p_toe, p_crest, p_heel];
        fence_features = [];

        % Plot the fence if it exists on the profile and append it to the legend
        if fenced==1 && exist('local_x_fence') && ~isnan(local_x_fence)
            p_fence = scatter(useMorpho(k, 22), useMorpho(k, 23), 50,...
                'Marker', 's',...
                'MarkerFaceColor', 'red',...
                'MarkerEdgeColor', 'k',...
                'LineWidth', 1,...
                'DisplayName', 'fence');
            fence_features = [fence_features, p_fence];
        end

        % Plot the fenced dune crest if it exists on the profile
        % and append it to the legend
        if  ~isnan(useMorpho(k, 24)) && ~isnan(useMorpho(k, 25))
            p_fence_crest = scatter(useMorpho(k, 24), useMorpho(k, 25), 50,...
                'Marker', 's',...
                'MarkerFaceColor', fence_crest_color,...
                'MarkerEdgeColor', 'k',...
                'LineWidth', 1,...
                'DisplayName', 'Fenced Dune Crest');
            fence_features = [fence_features, p_fence_crest];
        end

        % Plot the fenced dune heel if it exists on the profile
        % and append it to the legend. Remove the natural dune toe from the legend
        if ~isnan(useMorpho(k, 26)) && ~isnan(useMorpho(k, 27))
            p_fence_heel = scatter(useMorpho(k, 26), useMorpho(k, 27), 50,...
                'Marker', 's',...
                'MarkerFaceColor', fence_heel_color,...
                'MarkerEdgeColor', 'k',...
                'LineWidth', 1,...
                'DisplayName', 'Fenced Dune Heel');
            fence_features = [fence_features, p_fence_heel];
            clear fence_heel_index
        end

        % Plot the fenced dune crest if it exists on the profile
        % and append it to the legend
        if ~isnan(useMorpho(k, 20)) && ~isnan(useMorpho(k, 21))
            p_fence_toe = scatter(useMorpho(k, 20), useMorpho(k, 21), 50,...
                'Marker', 's',...
                'MarkerFaceColor', fence_toe_color,...
                'MarkerEdgeColor', 'k',...
                'LineWidth', 1,...
                'DisplayName', 'Fenced Dune Toe');
            fence_features = [p_fence_toe, fence_features];
        end

        % Plot the berm if it exists on the profile
        % and append it to the legend
        if ~isnan(useMorpho(k, 62)) && ~isnan(useMorpho(k, 63))
            p_fence_toe = scatter(useMorpho(k, 62), useMorpho(k, 63), 50,...
                'Marker', 's',...
                'MarkerFaceColor', 'c',...
                'MarkerEdgeColor', 'k',...
                'LineWidth', 1,...
                'DisplayName', 'Berm');
            fence_features = [p_fence_toe, fence_features];
        end

        legend([natural_features, fence_features], 'Location', 'northeast')
        xlabel('Cross Shore Distance (m)')
        ylabel('Elevation (m NAVD88)')
        title(Title)

        xlim([nanmin(local_x_values(:,k)) nanmax(local_x_values(:,k))])
        ylim([0 12])
        set(gca, 'XDir', 'Reverse')

        save_name = sprintf('%s%s%s%sProfile Plots%s%s.png', location(1:end-1), filesep, year,...
            filesep, filesep, Title);
        saveas(profile_figure, save_name, 'png')
        close(profile_figure)
    end

    % Function to set locations on the profile
    function [gen_x, gen_y, local_x, local_y, lon, lat] =...
        set_locations(x_values, local_x_values, profiles, index, k)
        % This function takes the index of a feature and sets three coordinates for
        % it:
        % 1: The X and Y location using the normal x_values vector
        % 2: The local X and Y coordinates
        % 3: The longitude and latitude

        % Set the x_heel and y_heel location, which is the relative location on the
        % profile for heel. Also find the local x, y location to plot later
        [gen_x, gen_y] = set_x_y(x_values, profiles(:,:,3), index, k);
        [local_x, local_y] = set_x_y(local_x_values(:,k),...
            profiles(:,:,3), index, k);

        % Store the lat and lon location of heel
        [lon, lat] = lon_lat_finder('north carolina', profiles, index, k);

    end

    % Apply a loess filter
    function [yls,flag] = loess(y,t,tls,tau)

        yls = NaN*tls ;
        flag = 0*tls ;

        %  normalize t and tls by tau
        t = t/tau ;
        tls = tls/tau ;

        %  only apply loess smoother to times (tls) within the time range of the
        %  data (t)
        nn = find((tls>=min(t)).*(tls<=max(t))) ;

            for ii = 1:length(nn)
                idx = nn(ii) ;
                qn = (t-tls(idx)) ;
                mm = find(abs(qn)<=1) ;
                qn = qn(mm) ;
                ytmp = y(mm) ;
                ttmp = t(mm)-tls(idx) ;
                mm = find(~isnan(ttmp.*ytmp)) ;
                %  need at least three data points to do the regression
                if length(mm)>=3
                    ytmp = ytmp(mm) ;
                    ttmp = ttmp(mm) ;
                    qn = qn(mm) ;
                    wn = ((1 - abs(qn).^3).^3).^2 ;
                    W = diag(wn,0) ;
                    X = [ones(size(ttmp)) ttmp ttmp.^2] ;
                    M1 = X'*W*X ;
                    M2 = X'*W*ytmp ;
                    B = M1\M2 ;

                    yls(idx) = B(1) ;

                    %  if the solution is out of the range of the data used in the
                    %  regression, then flag that datapoint
                    if (B(1)<min(ytmp))||(B(1)>max(ytmp))
                        flag(idx) = 1 ;
                    end

                end
            end

    end

end