function out = analyzeTrialExample(comb, varargin)
% Photometry dynamics and licks recorded from an example mouse during a 
% bandit task session. 
% - For plotting, each row depicts the baselined sensor signal of a trial.
% - t = 0 reflect trial start time as determined by mouse center poke.
% - red dots reflect trial end time, aka final correct lick / "hit".
%
% out = analyzeTrialExample(comb)
% out = analyzeTrialExample(comb, win)
% 
% NOTE: must run most recent bonsai behavior extraction code, which
% includes new variables beh.trialStart and beh.trialEnd.
%
% INPUTS
%   'comb': SINGLE RECORDING from combined data structure
%   'win': window, in seconds, for analysis. Eg, [-1 5]
%
% OUTPUTS
%   'out': structure with saved outputs, for plotting with script
%       'plotTrialsColormap.m'
%
% Anya Krok, December 2025

%% INPUTS
switch nargin
    case 2
        win = varargin{1};
    case 1
        win = [-1 5]; % in seconds
end
win_base = [win(1)-1 win(1)]; % for baseline adjusting photometry signal
    % default is 1 second window preceding window for analysis
bin_peth = 0.05; % bin width, in seconds, for aligning licks to events

%% Pull relevant data
signal  = comb.FP; 
Fs      = comb.Fs; 
beh     = comb.beh;

%% Behavioral events
% NOTE: CONSIDER CHANGING TO beh.lightOn for future
event = beh.lickStartHitTrial; % alignment to mouse self-initiation of rewarded trial

hitLatency = (beh.hits - event)./Fs; % latency between event and Hit
if all(hitLatency == 0); hitLatency(:) = nan; end 

%% Analysis: extract all licks for rewarded trials
nTrials = size(beh.lastAct,1);   % number of trials
nHits   = length(beh.hits);      % number of rewarded trials
idxHits = find(beh.lastAct.lastAct == "Hit"); % index rewarded trials

% for some recordings with photometry, trial start may coincide with start
% of photometry and thus 1st trial will remain NaN due to no photometry
% frames being documented prior to trial start time
if isnan(beh.trialStart(1))
    beh.trialStart(1) = 1;  % adjustment for above
end

hitLicks = cell(nHits,2); % initialize variable
for n = 1:nHits
    try
        idxSort = find((beh.lickRight > beh.trialStart(idxHits(n))) ...
                & (beh.lickRight < beh.trialEnd(idxHits(n)))); % licks R
        hitLicks{n,1} = beh.lickRight(idxSort);
    catch
        hitLicks{n,1} = nan;
    end
    try
        idxSort = find((beh.lickLeft > beh.trialStart(idxHits(n))) ...
                & (beh.lickRight < beh.trialEnd(idxHits(n)))); % licks L
        hitLicks{n,2} = beh.lickRight(idxSort);
    catch
        hitLicks{n,2} = nan;
    end
end

%% Initiate variables for storing data
evLicks = cell(1,2); % store values, licks to event
evPhoto = cell(1,2); % store values, photometry to event
evPhotoZ = evPhoto; % z-scored

%% Align licks to events
pethSide = cell(1,2); 
for s = 1:2
    pethSide{s} = nan(-1 + length(win(1):bin_peth:win(2)),nHits); % nans
    for n = 1:nHits
        if ~isnan(hitLicks{n,s})
            % extract peri-event histogram, aligning licks to event
            peth = getClusterPETH(hitLicks{n,s}./Fs, event(n)./Fs, bin_peth, win);
            pethSide{s}(:,n) = peth.cts{1}; % store values
        end
    end
    pethSide{s}(pethSide{s} > 1) = 1; % all lick bins set to 1
end

% index for R vs L ports w.r.t. rewarded trials 
idxSide = cell(1,2);
idxSide{1} = find(ismember(idxHits, find(beh.lastAct.lastLick == "LickRight")));
idxSide{2} = find(ismember(idxHits, find(beh.lastAct.lastLick == "LickLeft")));

% Align licks to behavioral event
for s = 1:2
    nSide = length(idxSide{s}); % number of trials for this port
    pethMat = pethSide{s}; % extract from stored values
    pethMat = pethMat(:,idxSide{s}); % restrict to R or L side ports
    evLicks{s} = pethMat; % store values
end

%% Align photometry signals to behavioral event
for b = 1:2
    [sta, time_sta, staZ] = getSTA(signal{b}, event./Fs, Fs, win);
    sta_base = getSTA(signal{b}, event./Fs, Fs, win_base);
    sta = sta - nanmean(sta_base,1);
    evPhoto{b} = sta; % store values
    evPhotoZ{b} = staZ; 
end

%% store
a = 1; 
out = struct;
out(a).mouse = comb.mouse;
out(a).date  = comb.date;
out(a).win   = win;
out(a).evLicks  = evLicks;
out(a).evPhoto  = evPhoto;
out(a).evPhotoZ = evPhotoZ;
out(a).timePeth = peth.time;
out(a).timeSta  = time_sta;
out(a).hitLat   = hitLatency;
out(a).idxSide  = idxSide;
out(a).lblSide  = {'lick R','lick L'};
out(a).lblPhoto = comb.FPnames; 