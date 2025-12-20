%% plotBeh_mult
% Description: compare behavior performance across multiple recordings for an animal.
%
% INPUTS
% 'comb' - combined data structure from extractCombstruct
% 
% OUTPUTS
% 'fig' - generates figures plotting behavioral performance, one figure per
% animal
% 
% Anya Krok, Dec 2025

if ~exist('comb')
    error('ERROR: comb structure does not exist in workspace.');
end

[uni,~,idxMap] = unique({comb.mouse});
choice = menu('Select mouse to analyze',uni);
match = find(strcmp({comb.mouse},uni{choice})); % idx in comb structure for this unique mouse ID

%%
fig = figure;
spX = 2; spY = 3;

%% (1) outcome by trial
spNum = 1;

barY = nan(length(match),5); % clear var
barLbl = {'hit R','hit L','miss','noHold','other'};
for a = 1:length(match) % iterate over all recordings for this unique mouse ID
    beh = comb(match(a)).beh; 
    side = [beh.lastAct.lastLick];
    side = side(beh.lastAct.lastAct == 'Hit');
    barY(a,1) = length(find(side == "LickRight"));
    barY(a,2) = length(find(side == "LickLeft"));

    lastAct = [beh.lastAct.lastAct];
    barY(a,3) = numel(find(strcmp(lastAct, 'Miss')));
    barY(a,4) = numel(find(strcmp(lastAct, 'IncorrectAction')));
    barY(a,5) = length(lastAct) - sum(barY(a,1:4));
end

sp(spNum) = subplot(spX, spY, spNum);
bar(1:length(match), barY, 'stacked')
legend({'#hits R', '#hits L','#miss', '#error', '#other'}, ...
    'direction','reverse', 'location', 'southwest');
xlabel('recording date'); xticklabels({comb(match).date});  
ylabel('# trials'); sp(spNum).YLim = [0 255];
str = sprintf('%s - total hits (per #trials) \n',uni{choice});
for a = 1:length(match)
    str = [str,sprintf(' day %d: (%d/%d).', a, sum(barY(a,1:2)), sum(barY(a,:)))];
end
title(str);

%% (2) lick vector to reward
spNum = 2;

bin = 0.1; % bin width, in seconds
win = [-1 1]; % window, in seconds
lickHit = cell(length(match),2); % initialize cell array
lbl = {'lick right','lick left'}; % labels for plotting
for a = 1:length(match)
    beh = comb(match(a)).beh; Fs = comb(a).Fs;
    pethR = getClusterPETH (beh.lickRight./Fs, beh.hits./Fs, bin, win);
    pethL = getClusterPETH (beh.lickLeft./Fs,  beh.hits./Fs, bin, win);
    lickHit{a,1} = pethR.cts{1};
    lickHit{a,2} = pethL.cts{1};
end
pethTime = pethR.time; % extract time vector for plotting

sp(spNum) = subplot(spX, spY, spNum); hold on
clr = lines(7);
b = 1; % lickRight
for a = 1:size(lickHit,1)
    shadederrbar(pethTime, nanmean(lickHit{a,b},2), SEM(lickHit{a,b},2), clr(a,:));
end
xline(0);
xlabel('time to reward (s)'); ylabel('licks (Hz)');
title([lbl{b},' - frequency to reward']);
legend({comb(match).date},'Location','northwest');

%% (3) timing of rewards
spNum = 3;

barY = nan(length(match),2); % preallocate matrix
for a = 1:length(match)
    beh = comb(match(a)).beh; 
    barY(a,1) = beh.hits(1); % time to 1st reward in samples
    barY(a,2) = beh.hits(end); % time to last reward
end
barY = barY./comb(match(1)).Fs; % convert to seconds

sp(spNum) = subplot(spX, spY, spNum);
b = bar(barY); % plot bar graph
for a = 1:length(b)
    b(a).Labels = round(b(a).YData);
end
xlabel('recording date'); xticklabels({comb(match).date});  
ylabel('time to reward (s)');
legend({'1st reward','last reward'});
str = sprintf('time to 1st:',uni{choice});
for a = 1:length(match)
    str = [str,sprintf(' (%d) %d s = %.1f min.',...
        a, round(barY(a,1)), barY(a,1)/60)];
end
title(str);

%% (4) inter-reward intervals
spNum = 4;

% histogram(iri{a},'BinWidth',5); xlabel('interval (s)'); ylabel('freq')
iri = cell(length(match),1);
for a = 1:length(match)
    beh = comb(match(a)).beh; Fs = comb(match(a)).Fs;
    iri{a} = diff(beh.hits./Fs); % inter-reward intervals in seconds
    iri{a} = [beh.hits(1)/Fs; iri{a}]; % add 1st reward delay
end
% Calculate the mean and minimum inter-reward intervals for plotting
iriMean = cellfun(@mean, iri);
iriMin = cellfun(@min, iri); iriMax = cellfun(@max, iri);
iriSEM = cellfun(@std,iri)./sqrt(cellfun(@length,iri));

sp(spNum) = subplot(spX, spY, spNum); hold on
errorbar(1:length(match),iriMean,iriSEM,...
    '-o','MarkerSize',10,'MarkerFaceColor','g','Color','g','LineStyle','none');
plot(1:length(match), iriMin, '*c', 'MarkerSize', 10);
% plot(1:length(match), iriMax, '*b', 'MarkerSize', 10);
legend({'mean','min'},'location','northwest');
xlim([0.5 0.5+length(match)]); xticks(1:length(match));
xlabel('recording date'); xticklabels({comb(match).date});  
ylabel('inter-reward interval (s)'); 
ylim(1) = 0; % y-axis to start at 0 seconds
str = 'mean IRI:';
for a = 1:length(match)
    str = [str,sprintf(' day %d (%.1f sec).', a, iriMean(a))];
end
title(str);

%% (5) inter-reward intervals plotted OVER TIME
spNum = 5;

iri = cell(length(match),1);
for a = 1:length(match)
    beh = comb(match(a)).beh; 
    Fs = comb(match(a)).Fs; % sampling frequency
    iri{a} = diff(beh.hits./Fs); % inter-reward intervals in seconds
    iri{a} = [beh.hits(1)/Fs; iri{a}]; % add 1st reward delay
end

sp(spNum) = subplot(spX, spY, spNum); hold on
clr = lines(7);
for a = 1:length(match)
    scatter(1:length(iri{a}), iri{a}, 'filled',...
        'MarkerFaceColor',clr(a,:),'MarkerFaceAlpha',0.5);
end
legend({comb(match).date})
xlabel('trial #'); ylabel('inter-reward interval (s)');


%% number of rewards

% barY = []; % clear var
% for a = 1:length(match) % iterate over all recordings for this unique mouse ID
%     nHit = length(comb(match(a)).beh.hits); % number of hits
%     nTrial = size(comb(match(a)).beh.lastAct,1); % number of trials
%     barY(a,:) = [nHit, nTrial-nHit];
% end
% 
% sp(1) = subplot(spX, spY, 1);
% b = bar(1:length(match), barY, 'stacked');
% 
% legend({'#hits', '#trials - #hits'})
% xlabel('recording date'); xticklabels({comb(match).date});  
% ylabel('# hits'); ylim([0 255]);
% str = sprintf('%s - #hits \n',uni{choice});
% for a = 1:length(match)
%     str = [str,sprintf(' day %d: (%d/%d).',a,barY(a,1),sum(barY(a,:)))];
% end
% title(str);
