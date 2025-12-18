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
ii = 1; % ONLY 1ST ANIMAL
match = find(strcmp({comb.mouse},uni{ii})); % idx in comb structure for this unique mouse ID
a = 1; % for a = 1:length(match)

figure;
%% number of rewards

barY = []; % clear var
for a = 1:length(match) % iterate over all recordings for this unique mouse ID
    nHit = length(comb(match(a)).beh.hits); % number of hits
    nTrial = size(comb(match(a)).beh.lastAct,1); % number of trials
    barY(a,:) = [nHit, nTrial-nHit];
end

subplot(2,3,1)
b = bar(1:length(match), barY, 'stacked');

legend({'#hits', '#trials - #hits'})
xlabel('recording date'); xticklabels({comb(match).date});  
ylabel('# hits'); ylim([0 255]);
str = sprintf('%s - #hits \n',uni{ii});
for a = 1:length(match)
    str = [str,sprintf(' day %d: (%d/%d).',a,barY(a,1),sum(barY(a,:)))];
end
title(str);

%% timing of rewards
barY = nan(length(match),2); % preallocate matrix
for a = 1:length(match)
    barY(a,1) = comb(match(a)).beh.hits(1); % time to 1st reward in samples
    barY(a,2) = comb(match(a)).beh.hits(end); % time to last reward
end
barY = barY./comb(match(1)).Fs; % convert to seconds

subplot(2,3,2);
b = bar(barY); % plot bar graph

for a = 1:length(b)
    b(a).Labels = round(b(a).YData);
end
xlabel('recording date'); xticklabels({comb(match).date});  
ylabel('time to reward (s)');
str = sprintf('time to 1st:',uni{ii});
for a = 1:length(match)
    str = [str,sprintf(' day %d (%d s = %.1f min).',...
        a, round(barY(a,1)), barY(a,1)/60)];
end
% str = sprintf('%s \n to last:',str);
% for a = 1:length(match)
%     str = [str,sprintf(' day %d (%d s = %.1f min).',...
%         a, round(barY(a,2)), barY(a,2)/60)];
% end
title(str);

%% inter-reward intervals
% histogram(iri{a},'BinWidth',5); xlabel('interval (s)'); ylabel('freq')
iri = cell(length(match),1);
for a = 1:length(match)
    iri{a} = diff(comb(match(a)).beh.hits./comb(match(a)).Fs); % inter-reward intervals in seconds
end
% Calculate the mean and minimum inter-reward intervals for plotting
iriMean = cellfun(@mean, iri);
iriMin = cellfun(@min, iri); iriMax = cellfun(@max, iri);
iriSEM = cellfun(@std,iri)./sqrt(cellfun(@length,iri));

subplot(2,3,3); hold on
errorbar(1:length(match),iriMean,iriSEM,...
    '-o','MarkerSize',10,'MarkerFaceColor','g','Color','g','LineStyle','none');
plot(1:length(match), iriMin, '*b', 'MarkerSize', 10);
% plot(1:length(match), iriMax, '*b', 'MarkerSize', 10);
legend({'mean','min','max'});
xlim([0.5 0.5+length(match)]); xticks(1:length(match));
xlabel('recording date'); xticklabels({comb(match).date});  
ylabel('inter-reward interval (s)'); ylim([0 50+round(max(iriMean),-1)]);
str = 'mean IRI:';
for a = 1:length(match)
    str = [str,sprintf(' day %d (%.1f sec).', a, iriMean(a))];
end
title(str);

%% lick vector to reward
% STOPPED HERE
bin = 0.1; % bin width, in seconds
win = [-1 1]; % window, in seconds

pethR = getClusterPETH (beh.lickRight, beh.hits, bin, win);
pethL = getClusterPETH (beh.lickLeft, beh.hits, bin, win);

subplot(2,3,4); hold on
shadederrbar(pethR.time, nanmean(pethR.cts{1},2), SEM(pethR.cts{1},2), 'b');
shadederrbar(pethL.time, nanmean(pethL.cts{1},2), SEM(pethL.cts{1},2), 'k');
xline(0);
xlabel('time to reward (s)'); ylabel('licks (Hz)');
title('lick frequency to reward');
legend({'Right','Left'},'Location','northwest');

%% proportion of trials with each action

lastAct = [beh.lastAct.lastAct];
counts = countcats(lastAct); % count occurence of categorical array elements by category
names = categories(lastAct); % returns possible names for categories
mask = counts > 0; % limit to only non-zero categories

subplot(2,3,5);
p = piechart(counts(mask),names(mask)); p.StartAngle = 60;
title('Proportion of Trials ending with:')

%% side bias -- proportion of HITS that are LEFT vs RIGHT

sideBias = [beh.lastAct.lastLick];
sideBias = sideBias(beh.lastAct.lastAct == 'Hit');
counts = countcats(sideBias);
names = categories(sideBias);
mask = counts > 0;

subplot(2,3,6); 
p = piechart(counts(mask),names(mask)); p.StartAngle = 60;
title('Side Bias for Hits')

