function out = analyzeBeh_2AFC(comb)
% Analyze behavioral performance across multiple recordings across multiple
% unique mouse IDs, for two-alternate forced choice task in Sippy lab.
%
% out = analyzeBeh_2AFC(comb)
%
% INPUTS
% 'comb' - structure with data from multiple recordings, created using 
%           script "extractComb"
%
% OUTPUTS
% 'out' - structure with behavior performance metrics
%   - out(a).mouse   - mouse ID
%   - out(a).date    - all recording dates
%   - out(a).lastAct - last action taken by mouse for each trial
%   - out(a).lickHit - matrix with licks aligned to each rewarded trial
%           - default to use bin width 0.1 sec, window [-1 1] sec
%   - out(a).hitTime - time to 1st and last rewarded trial, in seconds
%   - out(a).iri     - cell array with inter-reward intervals, in seconds
%
% Note: to extract table headers, use headers = T.Properties.VariableNames

% Written by Anne Krok, Dec 2025

% Initialize output structure
out = struct;

% Input variables
lickBin = 0.1; % bin width for PETH, in seconds
lickWin = [-1 1]; % window for PETH, in seconds

% Extract unique mouse IDs from the input structure
uniMouse = unique({comb.mouse});

% Loop through each unique mouse ID to calculate performance metrics
for thisMouse = 1:length(uniMouse)
    % Loop through each recording for each unique mouse ID
    match = find(strcmp({comb.mouse},uniMouse{thisMouse}));

    % Initiate outcomes variables
    trialOutcome = nan(length(match),5);
    trialOutcomes = {'hit R','hit L','miss','error','other'};
    lickHit = cell(length(match),2); 
    lickHitLbl = {'lick R','lick L'};
    lickHitTime = [];
    hitTime = nan(length(match),2);
    hitTimeLbl = {'1st reward','last reward'};
    iri = cell(length(match),1);

    for a = 1:length(match)
        beh = comb(match(a)).beh; % Behavioral data for one recording
        Fs = comb(match(a)).Fs; % Sampling frequency
        mouse = comb(match(a)).mouse; date = comb(match(a)).date; % Store to be able to check in case of errors

        % Loop through each trial to first identify outcome
        % Possible outcomes: Hit, with either LickRight or LickLeft being
        % second to last event, also Miss, IncorrectAction (error/noHold)
        lastAct = [beh.lastAct.lastAct]; % Last action for each trial
        side = [beh.lastAct.lastLick]; % Second to last action for each trial
        side = side(lastAct == 'Hit');
        trialOutcome(a, 1) = length(find(side == "LickRight"));
        trialOutcome(a, 2) = length(find(side == "LickLeft"));
        % counts = countcats(lastAct); % count occurence of categorical array elements by category
        % names = categories(lastAct); % returns possible names for categories
        trialOutcome(a, 3) = length(find(lastAct == 'Miss'));
        trialOutcome(a, 4) = length(find(lastAct == 'IncorrectAction'));
        trialOutcome(a, 5) = length(lastAct) - sum(trialOutcome(a,1:4));
    
        % Generate matrix of licks aligned to rewarded Hit trials
        pethR = getClusterPETH(beh.lickRight./Fs, beh.hits./Fs, lickBin, lickWin);
        pethL = getClusterPETH(beh.lickLeft./Fs,  beh.hits./Fs, lickBin, lickWin);
        lickHit{a, 1} = pethR.cts{1}; % Store lick data for right trials
        lickHit{a, 2} = pethL.cts{1};  % Store lick data for left trials
    
        % Extract timing of 1st and last rewards
        hitTime(a,1) = beh.hits(1)/Fs; % time to 1st reward, in seconds
        hitTime(a,2) = beh.hits(end)/Fs; % time to last reward, in seconds

        % Inter-reward intervals
        iri{a} = diff(beh.hits./Fs); % inter-hit intervals, in seconds
        iri{a} = [beh.hits(1)/Fs; iri{a}]; % add delay to 1st reward
    end
   
    % Load into output structure
    out(thisMouse).mouse = uniMouse{thisMouse};
    out(thisMouse).date = {comb(match).date};
    out(thisMouse).lastAct = array2table(trialOutcome, ...
        'VariableNames', trialOutcomes);
    out(thisMouse).lickHit = array2table(lickHit, ...
        'VariableNames', lickHitLbl);
    out(thisMouse).lickHit_time = pethR.time; % Extract time vector from PETH
    out(thisMouse).hitTime = array2table(hitTime, ...
        'VariableNames', hitTimeLbl);
    out(thisMouse).iri = iri;

end
   
end
    
