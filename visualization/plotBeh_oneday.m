%% plotBeh_oneday
% Description: compare behavior performance on ONE DAY across multiple
% animals
%
% INPUTS
% 'xxxx' - manually enter mouseID and dateID information for all recordings
% on single day. NOTE that these need to match folder names!
% 
% OUTPUTS
% 'fig' - generates figures plotting behavioral performance, one figure per
% animal
% 
% Anya Krok, Jan 2026

%% INPUTS
nMice = 1; % EDIT -- how many mice are you analyzing?

%% ENTER MOUSE ID and DATE ID
mouseID = {}; dateID = {}; % initialize variables
mouse = 'JT0'; date = 'YYMMDD';
% iterate over number of mice to manually enter mouse ID and date ID for
% every recording you will be analyzing
for ii = 1:nMice
    ans = inputdlg({sprintf('Mouse ID (match to folder name, %d/%d):',ii,nMice),...
        'Date ID (match to folder name):'},...
        'Input', [1 40; 1 40], {mouse, date}); % input folder names
    mouseID{ii} = ans{1}; % load into cell array 
    dateID{ii} = ans{2}; % load into cell array
    date = ans{2}; % over-write date with manual entered date
end

%% OPEN DIRECTORY TO SERVER (aka DATA > Jaden Tauber folder)
serverPath = uigetdir('','Select server path (DATA > Jaden Tauber)'); 
cd(serverPath);

%% Extract behavioral data from .csv files
comb = struct;
for ii = 1:nMice
    tic
    tmpPath = fullfile(fullfile(serverPath,mouseID{ii}),'Behavior'); % path to Jaden Tauber > JT0XX > Behavior
    cd(tmpPath);
    tmp = dir(tmpPath);
    tmpName = {tmp.name}; % extract cell array of all folder names within this directory
    idx = find(startsWith(tmpName, dateID{ii})); % find index for folder name that starts with dateID entered above
    tmpPath = fullfile(tmpPath, tmpName{idx}); % path to next folder 
    cd(tmpPath);
    tmp = dir(tmpPath);
    tmpName = {tmp.name}; % extract cell array of all folder names within this directory
    idx = find(strlength(tmpName)>9); % if folder name starts with YYYY-MM-DD, should be at least 9 characters long
    tmpPath = fullfile(tmpPath, tmpName{idx}); % path to .csv files!
    cd(tmpPath); % open directory with .csv files
    fileBeh = dir('State*.csv'); % check for .csv files starting with "State'
    statetrans = GetBonsai_Pho_StateTransitions_Celeste(fileBeh.name);
    beh = extract2AFCdataAK(statetrans);

    comb(ii).mouse = mouseID{ii}; 
    comb(ii).date = dateID{ii};
    comb(ii).beh = beh; % Store behavioral data in the structure
    toc
    fprintf('Extracted behavioral data for: %s-%s \n',mouseID{ii},date);
end

%% NOW WE PLOT
fig = figure; spX = 2; spY = 2; % generate figure outline

%% SUBPLOT (1) outcome by trial
spNum = 1; % subplot #1

barY = nan(length(comb),5); % clear var
barLbl = {'hit R','hit L','miss','noHold','other'};
for a = 1:length(comb) % iterate over all recordings for this unique mouse ID
    beh = comb(a).beh; 
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
bar(1:length(comb), barY, 'stacked')
legend({'#hits R', '#hits L','#miss', '#error', '#other'}, ...
    'direction','reverse', 'location', 'southwest');
xlabel('mouse ID'); xticklabels({comb.mouse});  
ylabel('# trials'); sp(spNum).YLim = [0 255];
str = sprintf('(%s): breakdown of hits per #trials',comb(1).date);
title(str);

%% SUBPLOT (2) lick vector to reward
spNum = 2;

bin = 0.1; % bin width, in seconds
win = [-1 1]; % window, in seconds
lickHit = cell(length(comb),2); % initialize cell array
lbl = {'lick right','lick left'}; % labels for plotting
for a = 1:length(comb)
    beh = comb(a).beh; Fs = 1;
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
legend({comb.mouse},'Location','northwest');

%% SUBPLOT (3) timing of rewards
spNum = 3;

barY = nan(length(comb),2); % preallocate matrix
for a = 1:length(comb)
    beh = comb(a).beh; 
    barY(a,1) = beh.hits(1); % time to 1st reward in samples
    barY(a,2) = beh.hits(end); % time to last reward
end

sp(spNum) = subplot(spX, spY, spNum);
b = bar(barY); % plot bar graph
for a = 1:length(b)
    b(a).Labels = round(b(a).YData);
end
xlabel('mouse ID'); xticklabels({comb.mouse});  
ylabel('time to reward (s)');
legend({'1st reward','last reward'});
str = 'time to 1st:';
for a = 1:length(comb)
    str = [str,sprintf(' (%d) %d s.', a, round(barY(a,1)))];
end
title(str);

%% SUBPLOT (4) inter-reward intervals
spNum = 4;

% histogram(iri{a},'BinWidth',5); xlabel('interval (s)'); ylabel('freq')
iri = cell(length(comb),1);
for a = 1:length(comb)
    beh = comb(a).beh; Fs = 1;
    iri{a} = diff(beh.hits./Fs); % inter-reward intervals in seconds
    iri{a} = [beh.hits(1)/Fs; iri{a}]; % add 1st reward delay
end
% Calculate the mean and minimum inter-reward intervals for plotting
iriMean = cellfun(@mean, iri);
iriMin = cellfun(@min, iri); iriMax = cellfun(@max, iri);
iriSEM = cellfun(@std,iri)./sqrt(cellfun(@length,iri));

sp(spNum) = subplot(spX, spY, spNum); hold on
errorbar(1:length(comb),iriMean,iriSEM,...
    '-o','MarkerSize',10,'MarkerFaceColor','g','Color','g','LineStyle','none');
plot(1:length(comb), iriMin, '*c', 'MarkerSize', 10);
% plot(1:length(comb), iriMax, '*b', 'MarkerSize', 10);
legend({'mean','min'},'location','northwest');
xlim([0.5 0.5+length(comb)]); xticks(1:length(comb));
xlabel('mouse ID'); xticklabels({comb.mouse});  
ylabel('inter-reward interval (s)'); 
sp(spNum).YLim(1) = 0; % y-axis to start at 0 seconds
str = 'mean IRI:';
for a = 1:length(comb)
    str = [str,sprintf(' (%d) %.1f sec.', a, iriMean(a))];
end
title(str);