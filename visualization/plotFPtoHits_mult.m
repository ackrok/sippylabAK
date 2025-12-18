%% plotFPtoHits_mult
% Description: align photometry signal(s) to behavioral event times using
% spike-triggered average functions. Necessitates prior photometry signal
% processing and behavioral data extraction into combined data structure.
% This script aims to compare STA across multiple sessions for each animal.
%
% INPUTS
% 'comb' - combined data structure from extractCombstruct
% 
% OUTPUTS
% 'alignAll', 'alignAvg' - analysis outputs with STA to event
% 'fig' - generates figures plotting aligned signals, one per type of
% photometry signal recorded (eg, 5-HT, DA, GCaMP)
% 
% Anya Krok, Dec 2025

if ~exist('comb')
    error('ERROR: comb structure does not exist in workspace.');
end

%% Analyze data
opts = fieldnames(comb(1).beh); % options are all behavioral events names
choice = menu('Select analysis',opts);
lbl = opts{choice}; % name of behavioral event to use for labeling

winSta = [-3 3]; % STA window, in seconds
winBase = [-6 -3]; % baseline window, in seconds

nFP = length(comb(1).FPnames); FPnames = comb(1).FPnames;
alignAvg = cell(1,nFP);
alignAll = cell(length(comb),nFP);
for a = 1:length(comb) % iterate over recordings
    for b = 1:nFP % iterate over photometry signals
        signal = comb(a).FP{b}; % extract signal
        ev = getfield(comb(a).beh, opts{choice}); % event times as per menu choice
        ev = ev./comb(a).Fs; % convert to seconds
        [sta, staTime] = getSTA(signal, ev, comb(a).Fs, winSta);
        [base]         = getSTA(signal, ev, comb(a).Fs, winBase);    
        base = nanmean(base,1); % average across entire baseline window to create vector of length(nHits)
        staAdj = sta - base; % subtract baseline
        alignAll{a,b} = staAdj; 
        alignAvg{b}(:,a) = nanmean(staAdj,2);
    end
end
fprintf('STA analysis done.\n')

%% Plot STA, comparing across recordings per animal
[uni,~,idxMap] = unique({comb.mouse});
for b = 1:nFP
    fig(b) = figure;
    spX = floor(sqrt(length(uni))); spY = ceil(length(uni)/spX);
    for ii = 1:length(uni)
        match = find(strcmp({comb.mouse}, uni{ii})); % idx of recordings with same unique mouse ID
        pullUni = alignAll(match, b); % build cell array of only recordings from this mouse
        clr = parula(length(match));
        subplot(spX,spY,ii); hold on
        for a = 1:length(match)
            shadederrbar(staTime, nanmean(pullUni{a},2), SEM(pullUni{a},2), 'Color', clr(a,:));
        end
        xline(0);
        title(sprintf('%s - %s to %s',uni{ii}, FPnames{b}, lbl));
        xlabel(sprintf('time to %s (s)',lbl)); 
        ylabel(sprintf('%s (dF/F)',FPnames{b}));
        legend({comb(match).date}); 
    end
end