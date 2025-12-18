function beh = extract2AFCdataAK(statetrans)
% Extract behavioral events from bonsai output table
% Task: 2AFC
%
% INPUT
% 'statetrans' - table made from StateTransitions.csv using function 
% statetrans = GetBonsai_Pho_StateTransitions_Celeste(filename.name);
%
% OUTPUT
% 'beh' - structure with extracted behavioral data
%
% Written by Anya Krok, Dec 2025


%% time stamps
compTime = [statetrans.TimeOfDay]./1e3; % computer time
compTime_0 = compTime - compTime(1);
elapTime = [statetrans.ElapsedTime]; % elapsed time on bonsai
elapTime_0 = elapTime - elapTime(1);

TS0 = elapTime_0(:); % use elapsed time **CAN CHANGE**

%% 
uni = unique(statetrans.Id); % identify unique behavioral event names
nTrial = max(statetrans.Trial)+1; % total number of trials

%% center port light on -- trial starts


%% center port lick -- mouse initiates trial
% Identify row index for first LickCenter for each unique Trial
trials = unique(statetrans.Trial);
lickCenterRows = nan(size(trials));
for i = 1:numel(trials)
    rows = find(statetrans.Trial == trials(i));
    k = find(statetrans.Id(rows) == "LickCenter", 1, 'first');
    if ~isempty(k)
        lickCenterRows(i) = rows(k);
    end
end
beh.lickStartTrial = TS0(lickCenterRows);

%% LICKS: all lick left and all lick rights
% Identify row indices for left and right licks
leftLickRows = statetrans.Id == 'LickLeft';
rightLickRows = statetrans.Id == 'LickRight';
centerLickRows = statetrans.Id == 'LickCenter';

beh.lickLeft = TS0(leftLickRows);
beh.lickRight = TS0(rightLickRows);
beh.lickCenter = TS0(centerLickRows);

%% HIT
hitRows = statetrans.Id == 'Hit'; % row numbers of Hits
% hitTrial = statetrans.Trial(hitRows)+1; % find the Trial # for Hits
% hitError = find(diff(sort(hitTrial)) == 0); % ensure that no overlappying Hits on the same trial

beh.hits = TS0(hitRows);

%% MISS
missRows = statetrans.Id == 'Miss'; % row numbers of Misses
% missTrial = statetrans.Trial(missRows)+1; % same for Misses
% missError = find(diff(sort(missTrial)) == 0); % ensure that no overlappying Misses on the same trial

beh.miss = TS0(missRows);

%% INCORRECT ACTION
incRows = statetrans.Id == 'IncorrectAction';
beh.incorrect = TS0(incRows);

%% ERROR
errorRows = statetrans.Id == 'Error';
beh.error = TS0(errorRows);

%% NO HOLD
noholdRows = statetrans.Id == 'NoHold';
beh.noHold = TS0(noholdRows);

%% TRIAL END ACTION
% Group trials and get unique trial ids
[G, trial] = findgroups(statetrans.Trial);

% For each group, take the last Id (last row within that trial)
lastAct = splitapply(@(ids) ids(end), statetrans.Id, G);   % categorical array, one per trial

% Take second to last Id (should be LickXXX)
secondLastAct = splitapply(@(ids) ids(end-1), statetrans.Id, G); % second to last action per trial
% s = string(secondLastAct); % convert to string vector
% maskNotLick = ~startsWith(s, "Lick") | isundefined(secondLastAct); % logical to identify which values do not start with Lick
% idx = find(maskNotLick); % any action non-Lick?

% Return result table
lastAct = table(trial, lastAct, secondLastAct,...
    'VariableNames', {'trial','lastAct','lastLick'});

beh.lastAct = lastAct;

end