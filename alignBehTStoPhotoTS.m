function [beh] = alignBehTStoPhotoTS(data, statetrans)
%
% When looping over each GoTS, it first finds all the photometry frames 
% that happen before the behavior event, and return the indices of those 
% frames ('FramesB4Evnt'); 
% then FirstFrameB4EvntIdx7 takes the last one (end)
%
% INPUT
% - 'data': structure with data
%       necessary variables to be included within 'data' structure are: 
%           - data.acq.time{1} or 'FrameTS': actual time (in ms) of each 
%               photometry frame recorded by the computer software clock
% - 'statetrans': table extracted from file ('*StateTransitions.csv') 
%       using GetBonsai_Pho_StateTransitions_Celeste function
%       >> filename=dir('*StateTransitions.csv');
%       >> statetrans=GetBonsai_Pho_StateTransitions_Celeste(filename.name);
%
% OUTPUT
% - 'TS': timestamp as index relative to photometry signal.
%       This is the frame in photometry signal that is
%       immediately BEFORE the behavioral event timestamp
%
% INTERIM OUTPUTS
% - 'GoTS': timestamps in computer software clock time of the desired
%       behavior event(s) from StateTransitions.csv table
%

StateTransTS=table2array(statetrans(:,1));

GoTS=StateTransTS((statetrans.Id=='Hit')); 
FirstFrameB4EvntIdx7 = []; c=1;
FramesTS = data.acq.time{1};
for i=1:length(GoTS)
    FramesB4Evnt = find(FramesTS<GoTS(i)); 
    if FramesB4Evnt > 0
        FirstFrameB4EvntIdx7(c) = FramesB4Evnt(end);
        c=c+1;
    else
        continue
    end
end
TS = FirstFrameB4EvntIdx7(:);
beh.hits = TS;

GoTS=StateTransTS((statetrans.Id=='Miss')); 
FirstFrameB4EvntIdx7 = []; c=1;
FramesTS = data.acq.time{1};
for i=1:length(GoTS)
    FramesB4Evnt = find(FramesTS<GoTS(i)); 
    if FramesB4Evnt > 0
        FirstFrameB4EvntIdx7(c) = FramesB4Evnt(end);
        c=c+1;
    else
        continue
    end
end
TS = FirstFrameB4EvntIdx7(:);
beh.miss = TS;

GoTS=StateTransTS((statetrans.Id=='LickCenter')); 
FirstFrameB4EvntIdx7 = []; c=1;
FramesTS = data.acq.time{1};
for i=1:length(GoTS)
    FramesB4Evnt = find(FramesTS<GoTS(i)); 
    if FramesB4Evnt > 0
        FirstFrameB4EvntIdx7(c) = FramesB4Evnt(end);
        c=c+1;
    else
        continue
    end
end
TS = FirstFrameB4EvntIdx7(:);
beh.lickCenter = TS;

GoTS=StateTransTS((statetrans.Id=='LickRight')); 
FirstFrameB4EvntIdx7 = []; c=1;
FramesTS = data.acq.time{1};
for i=1:length(GoTS)
    FramesB4Evnt = find(FramesTS<GoTS(i)); 
    if FramesB4Evnt > 0
        FirstFrameB4EvntIdx7(c) = FramesB4Evnt(end);
        c=c+1;
    else
        continue
    end
end
TS = FirstFrameB4EvntIdx7(:);
beh.lickRight = TS;

GoTS=StateTransTS((statetrans.Id=='Timeout')); 
FirstFrameB4EvntIdx7 = []; c=1;
FramesTS = data.acq.time{1};
for i=1:length(GoTS)
    FramesB4Evnt = find(FramesTS<GoTS(i)); 
    if FramesB4Evnt > 0
        FirstFrameB4EvntIdx7(c) = FramesB4Evnt(end);
        c=c+1;
    else
        continue
    end
end
TS = FirstFrameB4EvntIdx7(:);
beh.error = TS;

GoTS=StateTransTS((statetrans.Id=='IncorrectAction')); 
FirstFrameB4EvntIdx7 = []; c=1;
FramesTS = data.acq.time{1};
for i=1:length(GoTS)
    FramesB4Evnt = find(FramesTS<GoTS(i)); 
    if FramesB4Evnt > 0
        FirstFrameB4EvntIdx7(c) = FramesB4Evnt(end);
        c=c+1;
    else
        continue
    end
end
TS = FirstFrameB4EvntIdx7(:);
beh.noHold = TS;

% TStype=[ones(1,length(TS))];
% STClocal=1;
% FS=30;
% pre=5;
% post=5;
% for i= 1:length(TS)
% if TS(i) + post*FS < length(data.final.time{1}) & TS(i)-pre*FS+1>0   
%     GreenMatrix1(:,STClocal)=data.final.FP{1}(TS(i)-pre*FS+1:TS(i)+post*FS);
%     RedMatrix1(:,STClocal)=data.final.FP{2}(TS(i)-pre*FS+1:TS(i)+post*FS);
% 
%     TrialType1(STClocal)=TStype(i);
%     STClocal=STClocal+1;
% end
% end

