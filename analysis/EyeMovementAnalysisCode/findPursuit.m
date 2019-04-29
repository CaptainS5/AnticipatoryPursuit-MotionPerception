% FUNCTION to find pursuit onset by detecting direction change in x/y
% pursuit traces; requires changeDetect.m, evalPWL.m, and ms2frames.m

% history
% ancient past  MS created SOCCHANGE probably in C
% 23-02-09      MS checked and corrected SOCCHANGE
% 07-2012       JE edited socchange.m
% 05-2014       JF edited and renamed function to findPursuit.m
% 13-07-2018    JF commented to make the script more accecable for future
%               VPOM students
% for questions email jolande.fooken@rwth-aachen.de
% 23-04-2019    XW added steady-state onset using the same method
% for questions email xiuyunwu5@gmail.com

%
% input: trial --> structure containing relevant current trial information
% output: pursuit --> structure containing info about pursuit onset

function [pursuit] = findPursuit(trial)

anticipatoryPeriod = ms2frames(300); % when should we start looking for pursuit onset
pursuitSearchEnd = 200; % this means we stop searching for pursuit onset n ms after stimulus onset
% x-value: TIME
if trial.stim_onset > anticipatoryPeriod
    startTime = trial.stim_onset-anticipatoryPeriod;
    % we want to make sure the end point is before the catch up saccade
    if ~isempty(trial.saccades.onsetsDuring)
        endTime = min([trial.stim_onset+ms2frames(pursuitSearchEnd) trial.saccades.onsetsDuring(1)]);
    else
        endTime = trial.stim_onset+ms2frames(pursuitSearchEnd);
    end
else
    startTime = trial.stim_onset-(trial.stim_onset-1);
    if ~isempty(trial.saccades.onsetsDuring)
        endTime = min([trial.stim_onset-1+ms2frames(pursuitSearchEnd) trial.saccades.onsetsDuring(1)]);
    else
        endTime = trial.stim_onset-1+ms2frames(pursuitSearchEnd);
    end
end

% this is basically saying there is no pursuit
if endTime-startTime < 10
    pursuit.onset = NaN;
    pursuit.onsetSteadyState = NaN;
else
    time = startTime:endTime;
    fixationInterval = 550; % chose an interval before stimulus onset that
    % we will use as fixation window; needs to be at least 201 ms
    if trial.stim_onset > fixationInterval
        fix_x = mean(trial.eyeDX_filt(trial.stim_onset-ms2frames(fixationInterval):trial.stim_onset-ms2frames(fixationInterval-200)));
        fix_y = mean(trial.eyeDY_filt(trial.stim_onset-ms2frames(fixationInterval):trial.stim_onset-ms2frames(fixationInterval-200)));
    else
        fix_x = mean(trial.eyeDX_filt(trial.stim_onset-ms2frames(fixationInterval-100):trial.stim_onset-ms2frames(fixationInterval-300)));
        fix_y = mean(trial.eyeDY_filt(trial.stim_onset-ms2frames(fixationInterval-100):trial.stim_onset-ms2frames(fixationInterval-300)));
    end
    % 2. calculate 2D vector relative to fixation velocity
    dataxy_tmp = sqrt( (trial.eyeDX_filt-fix_x).^2 + (trial.eyeDY_filt-fix_y).^2 );
    XY = dataxy_tmp(time);
    % run changeDetect.m
    [cx,cy,ly,ry] = changeDetect(time,XY);
    pursuit.onsetTrue = round(cx); % the calculated onset after the gap
    % make sure it is visually-driven, the earliest from 50ms after
    % stimulus onset
    if pursuit.onsetTrue<(trial.stim_onset+ms2frames(50))
        pursuit.onset = trial.stim_onset+ms2frames(50);
    elseif pursuit.onsetTrue>(trial.stim_onset+ms2frames(200))
        pursuit.onset = trial.stim_onset+ms2frames(200);
    else
        pursuit.onset = pursuit.onsetTrue;
    end
    
    % this next part has been written by JF to make sure that the pursuit
    % onset is ligit (e.g. not in an undetected saccade or during a
    % fixation --> there was no pursuit at all
    mark = pursuit.onset;
    % in this first part we're getting the first saccade onset after the
    % stimulus starts moving to make sure that the pursuit onset is before
    if isempty(trial.saccades.onsetsDuring)
        on = NaN;
        off = NaN;
        idx = 0;
        idy = 0;
    else
        on = trial.saccades.onsetsDuring(1);
        off = trial.saccades.offsetsDuring(1);
        if isempty(trial.saccades.X.onsetsDuring)
            idx = 0;
            idy = find(trial.saccades.Y.onsetsDuring == trial.saccades.Y.onsetsDuring(1))-1;
        elseif isempty(trial.saccades.Y.onsetsDuring)
            idx = find(trial.saccades.X.onsetsDuring == trial.saccades.X.onsetsDuring(1))-1;
            idy = 0;
        else
            idx = find(trial.saccades.X.onsetsDuring == trial.saccades.X.onsetsDuring(1))-1;
            idy = find(trial.saccades.Y.onsetsDuring == trial.saccades.Y.onsetsDuring(1))-1;
        end
    end
    if idx == 0 && idy == 0
        earlyOn = NaN;
        earlyOff = NaN;
    elseif idx == 0 && idy > 0
        earlyOn = trial.saccades.Y.onsetsDuring(idy);
        earlyOff = trial.saccades.Y.offsetsDuring(idy);
    elseif idx > 0 && idy == 0
        earlyOn = trial.saccades.X.onsetsDuring(idx);
        earlyOff = trial.saccades.X.offsetsDuring(idx);
    elseif idx > 0 && idy > 0
        earlyOn = max([trial.saccades.X.onsetsDuring(idx) trial.saccades.Y.onsetsDuring(idy)]);
        earlyOff = max([trial.saccades.X.offsetsDuring(idx) trial.saccades.Y.offsetsDuring(idy)]);
    end
    if ~isempty(trial.saccades.onsetsDuring)
        endMark = min([(mark+240) trial.saccades.onsetsDuring(1)]); %indicates end of open loop phase
    else
        endMark = mark+240;
    end
    checkX = mean(trial.eyeDX_filt(mark:endMark));
    checkY = mean(trial.eyeDY_filt(mark:endMark));
    % first check, if the pursuit onset is inside the first saccade
    if mark >= on && mark <= off
        pursuit.onset = pursuit.onset + 50;
        pursuit.saccadeType = 1;
        % check if it is not inside the previous saccade that happens during
        % target onset
    elseif mark >= earlyOn && mark <= earlyOff ||...
            mark <= earlyOn
        pursuit.onset = earlyOff;
        pursuit.saccadeType = -1;
        if pursuit.onset < trial.stim_onset-280 || isnan(pursuit.onset)
            pursuit.onset = off;
            pursuit.saccadeType = -2;
        end
    elseif sqrt(((abs(trial.eyeDX_filt(mark))).^2+(abs(trial.eyeDY_filt(mark))).^2)) > 18
        pursuit.onset = pursuit.onset + 50;
        pursuit.saccadeType = -1;
        if pursuit.onset < trial.stim_onset-280 || isnan(pursuit.onset)
            pursuit.onset = pursuit.onset + 50;
            pursuit.saccadeType = -2;
        end
        % check if the pursuit onset is not just a fixation
    elseif ceil(sqrt(checkX.^2+checkY.^2)*10)/10 < 1.5
        pursuit.onset = endMark;
        pursuit.saccadeType = 2;
    else %everything fine
        pursuit.saccadeType = 0;
    end
    % just mark the pursuit onset types to later count what's going on
    if mark < trial.stim_onset
        pursuit.onsetType = -1;
    elseif mark == trial.stim_onset
        pursuit.onsetType = 0;
    else
        pursuit.onsetType = 1;
    end
    
    %%calculate the steady-state phase onset, using similar methods
    %%currently not reliable enough... need to check later
    startTime = pursuit.onset;
    endTime =  nanmin(pursuit.onset + ms2frames(250), trial.stim_offset - trial.timeWindow.excludeEndDuration); % open-loop phase not longer than a certain window
    if startTime>=trial.stim_offset - trial.timeWindow.excludeEndDuration - ms2frames(50) % if pursuit onset too late, ignore
        pursuit.onsetSteadyState = NaN;
    else
        time = startTime:endTime;
%         fixationInterval = 550; % chose an interval before stimulus onset that
%         % we will use as fixation window; needs to be at least 201 ms
%         if trial.stim_onset > fixationInterval
%             fix_x = mean(trial.eyeDX_filt(trial.stim_onset-ms2frames(fixationInterval):trial.stim_onset-ms2frames(fixationInterval-200)));
%             fix_y = mean(trial.eyeDY_filt(trial.stim_onset-ms2frames(fixationInterval):trial.stim_onset-ms2frames(fixationInterval-200)));
%         else
%             fix_x = mean(trial.eyeDX_filt(trial.stim_onset-ms2frames(fixationInterval-100):trial.stim_onset-ms2frames(fixationInterval-300)));
%             fix_y = mean(trial.eyeDY_filt(trial.stim_onset-ms2frames(fixationInterval-100):trial.stim_onset-ms2frames(fixationInterval-300)));
%         end
        % calculate 2D vector relative to fixation velocity
        dataxy_tmp = sqrt( (trial.DX_interpolSac-fix_x).^2 + (trial.DY_interpolSac-fix_y).^2 );
        XY = dataxy_tmp(time);
        % run changeDetect.m
        [cx,cy,ly,ry] = changeDetectRestricted(time,XY);
        pursuit.onsetSteadyState = round(cx);
        % if the steady state onset is during a saccade, move it
        % around the saccade
        if ~isempty(trial.saccades.onsetsDuring) && ~isempty(trial.saccades.offsetsDuring)
            onsetT = find(trial.saccades.onsetsDuring>=pursuit.onset & trial.saccades.onsetsDuring<pursuit.onsetSteadyState);
            offsetT = find(trial.saccades.offsetsDuring>pursuit.onsetSteadyState);
            if ~isempty(onsetT) && ~isempty(offsetT)
                if ~isempty(find(onsetT==offsetT(1))) && (trial.saccades.onsetsDuring(offsetT(1))-pursuit.onset)>140
                    pursuit.onsetSteadyState = trial.saccades.onsetsDuring(offsetT(1));
                else
                    pursuit.onsetSteadyState = trial.saccades.offsetsDuring(offsetT(1))+1;
                end
            end
        end
        
%         disp(num2str(pursuit.onsetSteadyState-pursuit.onset))
    end
end

end