%% STA: signal to hits or center poke
% requires structure 'comb' from extractCombstruct

addpathSippyAK_local

%% Analyze data
lbl = 'HIT';
% lbl = 'CENTER';

winSta = [-6 6]; % STA window, in seconds
winBase = [-6 -3]; % baseline window, in seconds

alignAvg = cell(1,2);
alignAll = cell(length(comb),2);
for b = 1:2 % photometry signals
    for a = 1:length(comb)
        signal = comb(a).FP{b}; % extract signal
        switch lbl; case 'HIT'; ev = comb(a).beh.hits./comb(a).Fs; 
            case 'CENTER'; ev = comb(a).beh.lickCenter./comb(a).Fs; 
            otherwise error('Unknown label'); end
        [sta, staTime] = getSTA(signal, ev, comb(a).Fs, winSta);
        [base]         = getSTA(signal, ev, comb(a).Fs, winBase);    
        base = nanmean(base,1); % average across entire baseline window to create vector of length(nHits)
        staAdj = sta - base; % subtract baseline
        alignAll{a,b} = staAdj; 
        alignAvg{b}(:,a) = nanmean(staAdj,2);
    end
end

%% Plot by photometry signal
b = 2; % b = 1 (5-HT) or 2 (rDA)

fig = figure;
for a = 1:length(comb)
    subplot(1,2,a); hold on
    switch b; case 1; clr = 'g'; case 2; clr = 'r'; end
    shadederrbar(staTime, nanmean(alignAll{a,b},2), SEM(alignAll{a,b},2),clr);
    xline(0);
    title(sprintf('%s-%s: (%d trials)',...
        comb(a).mouse,comb(a).date,size(alignAll{a,b},2)));
    xlabel(sprintf('time to %s (s)',lbl)); ylabel('FP (dF/F)');
end

%% Plot all mice
fig = figure; 
for b = 1:2
    subplot(1,2,b); hold on
    plot(staTime, alignAvg{b});
    xline(0);
    title(sprintf('%s to %s (n = %d)',comb(1).FPnames{b},lbl,size(alignAvg{b},2)))
    xlabel(sprintf('time to %s (s)',lbl)); ylabel('FP (dF/F)');
end

%% requires 'data' structure, after running processFP_NPM_AK
% ev = data.beh.hits;       lbl = 'HIT';
% % ev = data.beh.lickCenter; lbl = 'CENTER';
% 
% winSta = [-1 2]; % STA window, in seconds
% winBase = [-2 -1.5]; % baseline window, in seconds
% 
% a = 1; % which signal to run -- (1) green, (2) red
% [staHits, staTime] = getSTA(data.final.FP{a}, ev./data.gen.Fs, data.gen.Fs, winSta);
% [staBase] = getSTA(data.final.FP{a}, ev./data.gen.Fs, data.gen.Fs, winBase);    
% base = nanmean(staBase,1); % average across entire baseline window to create vector of length(nHits)
% staHitsAdj_g = staHits - base; % subtract baseline
% 
% a = 2; % which signal to run -- (1) green, (2) red
% [staHits, ~] = getSTA(data.final.FP{a}, ev./data.gen.Fs, data.gen.Fs, winSta);
% [staBase] = getSTA(data.final.FP{a}, ev./data.gen.Fs, data.gen.Fs, winBase);    
% base = nanmean(staBase,1); % average across entire baseline window to create vector of length(nHits)
% staHitsAdj_r = staHits - base; % subtract baseline
% 
% fig = figure; 
% a = 1; subplot(2,2,1); hold on
% plot(staTime, staHitsAdj_g, '-', 'Color', [0 0 0 0.1]);
% xline(0,'r')
% title(sprintf('%s - %s', data.ID, data.final.FPnames{a}));
% xlabel(sprintf('Time to %s (s)',lbl)); ylabel('FP (dF/F)');
% subplot(2,2,2); hold on
% shadederrbar(staTime, nanmean(staHitsAdj_g,2), SEM(staHitsAdj_g,2), 'g');
% xline(0,'k');
% xlabel(sprintf('Time to %s (s)',lbl)); ylabel('FP (dF/F)');
% 
% a = 2; subplot(2,2,3); hold on
% plot(staTime, staHitsAdj_r, '-', 'Color', [0 0 0 0.1]);
% xline(0,'r')
% title(sprintf('%s - %s', data.ID, data.final.FPnames{a}));
% xlabel(sprintf('Time to %s (s)',lbl)); ylabel('FP (dF/F)');
% subplot(2,2,4); hold on
% shadederrbar(staTime, nanmean(staHitsAdj_r,2), SEM(staHitsAdj_r,2), 'r');
% xline(0,'k');
% xlabel(sprintf('Time to %s (s)',lbl)); ylabel('FP (dF/F)');
% 
