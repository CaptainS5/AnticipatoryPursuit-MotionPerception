function [  ] = newSaccade( source,b,trial,pPos,pVel )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dustments=source.UserData;
newOnset=changeOnset(trial,pPos,pVel,'xg');
newOffset=changeOnset(trial,pPos,pVel,'xr');
% dustments.addedXOnsets=[];
% dustments.addedXOffsets=[];
if newOnset~=-999 && newOffset~=-999
    dustments.addedXOnsets(end+1)=newOnset;
    dustments.addedXOffsets(end+1)=newOffset;
    source.UserData=dustments;
end

   %% FOR PURSUIT PLOT (must recompute pursuit and plot it tafter changing saccades)
%    delete(pPur)
%    delete(pRej)
%    pursuit=adjustPursuit(trial,dustments);
%    pur=trial.eyeDX_filt;
%    pur(~pursuit.pursuitClean)=NaN;
%    pPur=plot(pur,'g','LineWidth',2);
%    pRej=plot(pursuit.rejects,'r','LineWidth',2);

end

