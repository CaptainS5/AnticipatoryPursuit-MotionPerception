% adjustments.oldXOnsets=trial.saccades.X.onsets;
% adjustments.newXOnsets=trial.saccades.X.onsets; %temporarily save the new onsets as the old, to be overwritten with adjustments
% adjustments.thresh=saccadeThreshold;
pVel=subplot(2,2,2);
pPos=subplot(2,2,1);

% clicks = clicks + 1;
% trialCounter = max([clicks currentTrial]);
% 
% if currentTrial>size(adjustedSacs,2) || isempty(adjustedSacs{currentTrial}) ...
%         || buttons.previous.Value
%        % if we have not been to this trial yet onsets= those from analyzeTrial
%     currentOnsets=struct('currentTrial',currentTrial,'oldXOnsets',trial.saccades.X.onsets,'newXOnsets',trial.saccades.X.onsets);
% else % we take the result of last time we saw this trial, so we either keep it the same or overwrite it
%     currentOnsets=adjustedSacs{currentTrial};
%     changed=adjustedSacs{currentTrial}.newXOnsets(adjustedSacs{currentTrial}.oldXOnsets~=adjustedSacs{currentTrial}.newXOnsets);
%     
%     plot(pVel,changed,trial.eyeDX_filt(changed),'xr', 'MarkerSize',8);
%     plot(pPos,changed,trial.eyeX_filt(changed),'xr', 'MarkerSize',8);
% 
%     plot(pVel,adjustedSacs{currentTrial}.addedXOnsets,trial.eyeDX_filt(changed),'c*', 'MarkerSize',8);
%     plot(pPos,adjustedSacs{currentTrial}.addedXOffsets,trial.eyeX_filt(changed),'c*', 'MarkerSize',8);
%     
% end
currentOnsets.XOffsets=trial.saccades.X.offsets;
addedOnsets=struct('addedXOnsets',[],'addedXOffsets',[]);

% bg = uibuttongroup( 'Visible','on',...
%                   'Position',[.6 .4 .4 .1],...
%                   'UserData',currentOnsets,...
%                   'SelectionChangedFcn',{@bselection,trial,pPos,pVel});

% n=length(trial.saccades.X.onsets);              
% a(n+1)= uicontrol(bg,'Style',...
%                   'radiobutton',...
%                   'String','none',...
%                   'Position',[10+40*n 8 50 50],...
%                   'HandleVisibility','off');
buttons.new = uicontrol(fig,'string','New Saccade','Position',[1035,480,100,30],...
    'UserData',addedOnsets,...
    'callback',{@newSaccade,trial,pPos,pVel});
% buttons.new = uicontrol(fig,'string','New Saccade','Position',[865,350,100,30],...
%     'UserData',addedOnsets,...
%     'callback',{@newSaccade,trial,pPos,pVel});

if buttons.new.Value
    currentOnsets=adjustedSacs{currentTrial};
    changed=adjustedSacs{currentTrial}.newXOnsets(adjustedSacs{currentTrial}.oldXOnsets~=adjustedSacs{currentTrial}.newXOnsets);
    plot(pVel,changed,trial.eyeDX_filt(changed),'xr', 'MarkerSize',8);
    plot(pPos,changed,trial.eyeX_filt(changed),'xr', 'MarkerSize',8);
    plot(pVel,adjustedSacs{currentTrial}.addedXOnsets,trial.eyeDX_filt(changed),'c*', 'MarkerSize',8);
    plot(pPos,adjustedSacs{currentTrial}.addedXOffsets,trial.eyeX_filt(changed),'c*', 'MarkerSize',8);
end

% buttons.save = uicontrol(fig,'string','Save Adjustments','Position',[0,180,140,30],...
%     'callback','cd(currentSubjectPath); save adjustments adjustedSacs; cd(analysisPath)');
              
              

% for i=1:n
%     name=num2str(i);
%     a(i)= uicontrol(bg,'Style',...
%                   'radiobutton',...
%                   'String',name,...
%                   'Position',[10+40*(i-1) 8 30 50],...
%                   'HandleVisibility','off');
% end



