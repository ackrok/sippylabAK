%% plotFPtoHits
% Description: align photometry signal(s) to behavioral event times using
% spike-triggered average functions. Necessitates prior photometry signal
% processing and behavioral data extraction into combined data structure.
%
% INPUTS
% 'comb' - combined data structure from extractCombstruct
% 
% OUTPUTS
% 'alignAll', 'alignAvg' - analysis outputs with STA to event
% 'fig' - generates 1-3 figures plotting aligned signals
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

nFP = length(comb(1).FPnames);
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

%% Group analyzed data based on unique mouse IDs
[uni,~,idxMap] = unique({comb.mouse});
alignUni = cell(length(uni),nFP);
for ii = 1:length(uni)
    match = find(strcmp({comb.mouse}, uni{ii})); % idx of recordings with same unique mouse ID
    for b = 1:nFP
        pull = alignAll(match, b);
        alignUni{ii,b} = horzcat(pull{:}); % concatenate data
    end
end

%% Plot by photometry signal
FPnames = comb(1).FPnames;
opts2 = cell(nFP+1,1);
for b = 1:nFP; opts2{b} = [FPnames{b},' to ',lbl,', by mouse']; end
opts2{nFP+1} = ['all photometry to ',lbl,', averaged'];
choice2 = listdlg('ListString',opts2);

for ii = 1:length(choice2)
    switch choice2(ii)
        case 1
            b = 1; clr = 'g';
            fig(choice2(ii)) = figure;
            spX = floor(sqrt(length(comb))); spY = ceil(length(comb)/spX);
            for a = 1:length(comb)
                subplot(spX,spY,a); hold on
                shadederrbar(staTime, nanmean(alignAll{a,b},2), SEM(alignAll{a,b},2),clr);
                xline(0);
                title(sprintf('%s-%s: (%d trials)',...
                    comb(a).mouse,comb(a).date,size(alignAll{a,b},2)));
                xlabel(sprintf('time to %s (s)',lbl)); 
                ylabel(sprintf('%s FP (dF/F)',FPnames{b}));
            end
        case 2
            b = 2; clr = 'r';
            fig(choice2(ii)) = figure;
            spX = floor(sqrt(length(comb))); spY = ceil(length(comb)/spX);
            for a = 1:length(comb)
                subplot(spX,spY,a); hold on
                shadederrbar(staTime, nanmean(alignAll{a,b},2), SEM(alignAll{a,b},2),clr);
                xline(0);
                title(sprintf('%s-%s: (%d trials)',...
                    comb(a).mouse,comb(a).date,size(alignAll{a,b},2)));
                xlabel(sprintf('time to %s (s)',lbl));
                ylabel(sprintf('%s FP (dF/F)',FPnames{b}));
            end
        case 3
            fig(choice2(ii)) = figure;
            for b = 1:length(FPnames)
                subplot(2,nFP,b);
                plot(staTime, alignAvg{b});
                xline(0);
                title(sprintf('%s to %s (n = %d)',comb(1).FPnames{b},lbl,size(alignAvg{b},2)))
                xlabel(sprintf('time to %s (s)',lbl)); ylabel('FP (dF/F)');
                legend({comb.mouse});

                subplot(2,nFP,b+2);
                switch b; case 1; clr = 'g'; case 2; clr = 'r'; end
                shadederrbar(staTime, nanmean(alignAvg{b},2), SEM(alignAvg{b},2), clr);
                xline(0);
                xlabel(sprintf('time to %s (s)',lbl)); ylabel('FP (dF/F)');
                legend(FPnames{b});
            end
    end
end
