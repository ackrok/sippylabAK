function out = analyzeFP_STA(varargin)
% Analyze photometry signal to align to behavioral events
%
% out = analyzeFP_STA(comb)
% out = analyzeFP_STA(comb, win, base)
%
% INPUTS
% 'comb' - structure with data from multiple recordings, created using 
%           script "extractComb"
% 'win'  - window for STA analysis, default is [-1 2] seconds
% 'base' - window for baselining, default is [-2 -1]
%
% OUTPUTS
% 'out' - structure with behavior performance metrics
%   - out(a).mouse   - mouse ID
%   - out(a).date    - all recording dates
%   - out(a).sta - table with STA data
%       - table columns are behavioral events that are aligned to
%       - example: out(A).sta.('hits'){B, C} is a matrix, where number
%           of columns is number of events, A is unique mouse ID, B is
%           index of recording date, and C is index of photometry signal.
%   - out(a).time - time vector for plotting STA
%
% Note: to extract table headers, use headers = T.Properties.VariableNames
%
% Written by Anne Krok, Dec 2025
%

% Default inputs
try
    switch nargin
    case 1
        comb = varargin{1};
        win = [-1 2]; % STA window, in seconds
        winBase = [-2 -1]; % baseline window, in seconds
    case 3
        comb = varargin{1};
        win = varargin{2}; % Update STA window if provided
        winBase = varargin{3}; % Update baseline window if provided
    end
catch
    error('ERROR: check your inputs. See documentation < help analyzeFP_STA >');
end

%% Initialize output variable
out = struct;

opts = fieldnames(comb(1).beh); % options are all behavioral events names
lbls = {'hits','miss','error','lickStartTrial','lickStartHitTrial'}; % hard-coded which behavioral events to process

uniMouse = unique({comb.mouse}); %  unique mouse IDs from the input structure

% Loop through each unique mouse ID to calculate performance metrics
for thisMouse = 1:length(uniMouse)
    % Loop through each recording for each unique mouse ID
    match = find(strcmp({comb.mouse},uniMouse{thisMouse}));

    out(thisMouse).mouse = uniMouse{thisMouse}; % STORE
    out(thisMouse).recs  = {comb(match).date}; % STORE
    C = cell(length(match), 2, length(lbls)); % Initiate cell array
    % #rows is #recordings for unique mouse ID
    % #columns is #photometry signals
    % #pages is #behavioral events
    C2 = cell(2, length(lbls)); % Initiate cell array for averaged data

    for a = 1:length(match)
        FP  = comb(match(a)).FP; % Photometry signal(s)
        nFP = length(comb(match(a)).FPnames); % Number of phototometry signals
        beh = comb(match(a)).beh; % Behavioral data for one recording
        beh.error = sort([beh.error; beh.noHold]);
        Fs  = comb(match(a)).Fs; % Sampling frequency
        mouse = comb(match(a)).mouse; date = comb(match(a)).date; % Store to be able to check in case of errors

        % Loop through each behavioral events
        for pickEv = 1:length(lbls)
            % Extract event times based on label
            ev = getfield(beh, opts{strcmp(opts, lbls{pickEv})});
            ev = ev./Fs; % convert to seconds

            % Loop through each photometry signal
            for thisFP = 1:nFP
                signal = FP{thisFP}; 
                [sta, time] = getSTA(signal, ev, Fs, win);
                base        = getSTA(signal, ev, Fs, winBase);
                base = nanmean(base,1); % average across entire baseline window to create vector of length(nHits)
                staAdj = sta - base; % subtract baseline

                C{a, thisFP, pickEv} = staAdj; % STORE
                C2{thisFP, pickEv}(:,a) = nanmean(staAdj,2); % STORE

            end
        end
    end

    T = table();
    for p = 1:size(C,3)
        T.(lbls{p}) = C(:,:,p);
    end
    out(thisMouse).sta = T;
    out(thisMouse).time = time;
    out(thisMouse).nFP = nFP; out(thisMouse).FPnames = comb(1).FPnames;
end

