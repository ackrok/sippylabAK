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

%%
statetransTS = table2array(statetrans(:,1));

%% Hit
compTS = statetransTS((statetrans.Id=='Hit')); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.hits = TS;

%% Miss
compTS = statetransTS((statetrans.Id=='Miss')); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.miss = TS;

%% LickRight
compTS = statetransTS((statetrans.Id=='LickRight')); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.lickRight = TS;

%% LickLeft
compTS = statetransTS((statetrans.Id=='LickLeft')); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.lickLeft = TS;

%% LickCenter
compTS = statetransTS((statetrans.Id=='LickCenter')); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.lickCenter = TS;

%% LickCenter -- mouse initiates trial
trials = unique(statetrans.Trial); % Identify row index for first LickCenter for each unique Trial
rowsLickCenter_trialStart = nan(size(trials));
for ii = 1:numel(trials)
    rows = find(statetrans.Trial == trials(ii));
    k = find(statetrans.Id(rows) == "LickCenter", 1, 'first');
    if ~isempty(k)
        rowsLickCenter_trialStart(ii) = rows(k);
    end
end
compTS = statetransTS(rowsLickCenter_trialStart); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.lickStartTrial = TS;

%% LickCenter -- precedes each Hit
rowsHit = find(statetrans.Id == 'Hit'); % row numbers of Hits
rowsLickCenter_preHit = nan(numel(rowsHit),1);       % store preceding LickCenter (NaN if none)
for k = 1:numel(rowsHit)
    r = rowsHit(k);
    if r > 1
        idx = find(statetrans.Id(1:r-1) == 'LickCenter', 1, 'last');
        if ~isempty(idx)
            rowsLickCenter_preHit(k) = idx;
        end
    end
end
compTS = statetransTS(rowsLickCenter_preHit); % only select time stamps for LickCenter that precedes a Hit
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.lickStartHitTrial = TS;
beh.rewLatency = beh.hits - beh.lickStartHitTrial;

%% Timeout
compTS = statetransTS((statetrans.Id=='Timeout')); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
beh.error = TS;

%% IncorrectAction
compTS = statetransTS((statetrans.Id=='IncorrectAction')); 
TS = firstFrameBeforeEventIndex(compTS, data.acq.time{1});
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

