%% This code will open and pre-process .csv files from Neurophotometrics via Bonsai with Sippy Lab Lever Task
%  Follow with Photometry_XX_Neurophotom.m to align photometry signal to behavior events
%
%Written by Sarah Mennenga Aug-2022
%
% Edited by Anne Krok, Dec 2025

clear all;

%% Set up the Import Options and import PHOTOMETRY data
opts = delimitedTextImportOptions("NumVariables", 10);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["frameCounter", "Timestamp", "LedState", "ComputerTimestamp", "rawPhoto470", "rawPhoto565", "Var7", "Var8", "Var9", "Var10"];
opts.SelectedVariableNames = ["frameCounter", "Timestamp", "LedState", "ComputerTimestamp", "rawPhoto470", "rawPhoto565"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "char", "char", "char", "char"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var7", "Var8", "Var9", "Var10"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var7", "Var8", "Var9", "Var10"], "EmptyFieldRule", "auto");

% Import the data
[fileName,filePath] = uigetfile('*Photometry*.csv','Select the PHOTOMETRY file','MultiSelect','on');
cd(filePath); 
assert(exist(fileName,'file')==2, '%s does not exist.', fileName);
file=fullfile(filePath,fileName);

photometry = readtable(file,opts); % read photometry file into table
subID = inputdlg('Enter Mouse ID', 'Input', 1, {'JT0XX'});
date = inputdlg('Enter Recording Date', 'Input', 1, {'YYMMDD'});
subID = subID{1};
date = date{1};
baseName = fileName(1:10);

%% Clear temporary variables
clear opts

Fs = 200; %Set photometry sampling frequency

%% Set up the Import Options and import the FRAME COUNTER data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["frameCounter", "timeStamp"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";


% Import the data
files = dir(fullfile(filePath,'Frames*.csv'));
fileNames = {files.name};
dateMatch = 1; %~cellfun('isempty',strfind(fileNames, date));
frameCounter = readtable(fullfile(filePath,fileNames{dateMatch}), opts);


% Clear temporary variables
clear opts


%% Align photometry data to computer clock
[frame,rawPhoto470,timeStamp] = timealign(photometry.frameCounter,frameCounter.frameCounter,photometry.rawPhoto470,frameCounter.timeStamp);
[frame,rawPhoto565,timeStamp] = timealign(photometry.frameCounter,frameCounter.frameCounter,photometry.rawPhoto565,frameCounter.timeStamp);

photometry = table(frame,rawPhoto470,rawPhoto565,timeStamp);

%% Set up the Import Options and import the STATE TRANSITIONS data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "trial", "stateTransitions", "timeStamp"];
opts.SelectedVariableNames = ["trial", "stateTransitions", "timeStamp"];
opts.VariableTypes = ["char", "double", "categorical", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var1"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "stateTransitions"], "EmptyFieldRule", "auto");

% Import the data
files = dir(fullfile(filePath,'*StateTransitions*.csv'));
fileNames = {files.name};
dateMatch = 1; %~cellfun('isempty',strfind(fileNames, date));
stateTransitions = readtable(fullfile(filePath,fileNames{dateMatch}), opts);

% Clear temporary variables
clear opts

%% Set up the Import Options and import the RESPONSE STATS data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = "response";
opts.SelectedVariableNames = "response";
opts.VariableTypes = "categorical";

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
% opts = setvaropts(opts, [], "WhitespaceRule", "preserve");
opts = setvaropts(opts, "response", "EmptyFieldRule", "auto");

% Import the data
files = dir(fullfile(filePath,'*ResponseStat*.csv'));
fileNames = {files.name};
dateMatch = 1; %~cellfun('isempty',strfind(fileNames, date));
responseStats = readcell(fullfile(filePath,fileNames{dateMatch}), opts);

% Clear temporary variables
clear opts


 %% Set up the Import Options and import SOUNDS data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = "sounds";
opts.SelectedVariableNames = "sounds";
opts.VariableTypes = "double";

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
%opts = setvaropts(opts, "Var1", "WhitespaceRule", "preserve");
%opts = setvaropts(opts, "Var1", "EmptyFieldRule", "auto");

% Import the data
files = dir(fullfile(filePath,'*Sounds*.csv'));
fileNames = {files.name};
dateMatch = 1; %~cellfun('isempty',strfind(fileNames, date));
sounds = readtable(fullfile(filePath,fileNames{dateMatch}), opts);

% Clear temporary variables
clear opts


%% Signal Processing

%De-interleave the photometry data
photo470 = photometry.rawPhoto470(2:2:end);  % Odd-Indexed Elements
photo565 = photometry.rawPhoto565(1:2:end);  % Even-Indexed Elements
frame470 = photometry.frame(2:2:end);  % Odd-Indexed Elements
frame565 = photometry.frame(1:2:end);  % Even-Indexed Elements
timeStamp470 = photometry.timeStamp(2:2:end);  % Odd-Indexed Elements
timeStamp565 = photometry.timeStamp(1:2:end);  % Even-Indexed Elements

% remove edge artifact from photometry data
photomCut =3;
photo565 = [photo565(photomCut:end,:)]; 
photo470 = [photo470(photomCut:end,:)]; 
frame565 = [frame565(photomCut:end,:)]; 
frame470 = [frame470(photomCut:end,:)]; 
timeStamp565 = [timeStamp565(photomCut:end,:)]; 
timeStamp470 = [timeStamp470(photomCut:end,:)]; 
frameCounter = [frameCounter(photomCut:end,:)]; 

l470 = length(photo470);
l565 = length(photo565);
lSig = min (l470,l565);

photo470 = photo470(1:lSig);
frame470 = frame470(1:lSig);
timeStamp470 = timeStamp470(1:lSig);
photo565 = photo565(1:lSig);
frame565 = frame565(1:lSig);
timeStamp565 = timeStamp565(1:lSig);


%Inspect the raw de-interleaved data
figure; hold on
%ylim([-10 15]);
yyaxis left;
plot([photo470], '-', 'Color',[0.1,0.8,0.1]); 
ylabel('Raw 470 Signal', 'FontSize', 20);
yyaxis right;
plot([photo565], '-', 'Color',[0.8,0.5,0.5]); 
ylabel('Raw 565 Signal', 'FontSize', 20);
xlabel('Time (s)', 'FontSize', 20);
title(sprintf('%s-%s',subID,date),'FontSize',20)
set(gca,'FontSize',20);
set(gcf,'Position',[100 100 2000 500]);
% message = sprintf('Inspect Raw De-Interleaved Data');
% uiwait(msgbox(message, 'modal'));
% region0G = photo470;

% B = photomOpto\photom470;
% estMotion = photomOpto*B;
% region0G = photom470./estMotion;
% figure;
% plot(region0G);
% ylabel('F', 'FontSize', 20);
% xlabel('Time (s)', 'FontSize', 20);
% set(gca,'FontSize',20);
% title('Motion-Corrected Signal','FontSize',20)
% message = sprintf('Inspect Motion Corrected Photometry Data');
% uiwait(msgbox(message, 'modal'));
% 
% %Correct signal for photobleaching
% figure;
% plot([photomOpto], '-', 'Color',[0.8,0.1,0.1]); %Plot 560 data
% hold on
% tempx = (1:length(photomOpto))'; 
% fitExp = fit(tempx, photomOpto, 'exp2'); %fit with biexponential decay
% plot(fitExp(tempx), '-', 'Color',[0.5,0.5,0.5]); %plot function against 560 signal
% xlabel('Time (s)', 'FontSize', 20);
% set(gca,'FontSize',20);
% message = sprintf('Inspect Biexponential Decay');
% uiwait(msgbox(message, 'modal'));
% 
% fitExpScale = robustfit(fitExp(tempx),region0G); %Scale exponential fit to 470 signal
% linFit = fitExp(tempx)*fitExpScale(2)+fitExpScale(1); %save the output
% figure;
% plot(region0G);
% hold on
% plot(linFit); %plot scaled function against 470 signal
% ylabel('F', 'FontSize', 20);
% xlabel('Time (s)', 'FontSize', 20);
% set(gca,'FontSize',20);
% title('Motion-Corrected Signal','FontSize',20)
% message = sprintf('Inspect Scaled Decay against 470 Signal');
% uiwait(msgbox(message, 'modal'));
% 
% region0G = region0G./linFit; %divide 470 by scaled decay model
% figure;
% plot(region0G);
% ylabel('F', 'FontSize', 20);
% xlabel('Time (s)', 'FontSize', 20);
% set(gca,'FontSize',20);
% title('PhotoBleaching+Motion-Corrected Signal','FontSize',20)
% message = sprintf('Inspect Corrected Photometry Data');
% uiwait(msgbox(message, 'modal'));


%% Set Baseline for dFF

region0G = photo470; 
region0R = photo565;

% Mean Baseline
% region0GBl= mean(region0G,1); 
% region0GdFF = ((region0G - region0GBl)./region0GBl)*100; 
%  region0GdFF = region0GdFF - nanmean(region0GdFF);

% %STA Baseline
% %Set baseline photometry signal for correct response trials
% sta_baseHit = getSTA(region0G, hit_trials./Fs, Fs, [-1 0]);
% sta_baseHit = nanmean(sta_baseHit, 1); 

%Bottom 5% Baseline
blBin = 10; %Set bin size for baselining (in seconds)
blBin = blBin*Fs;
region0GBl = region0G;
binNum = floor(length(region0GBl)/blBin); 
cutLength = blBin*binNum; 
region0GBlcut = [region0GBl(1:cutLength)];
region0GBlBin = reshape(region0GBlcut,[blBin,binNum]);
region0GBls = sort(region0GBlBin,1); 
bl5Perc = blBin*0.05; %Set to bottom 5 percent
region0GBl5perc=region0GBls(1:bl5Perc,:);
region0GBlM = mean(region0GBl5perc,1); 

% Convert raw signal in pixel saturation units to deltaF/F (%) for each bin
region0GBlBindFF = ((region0GBlBin - region0GBlM)./region0GBlM)*100; 
region0GdFF = reshape(region0GBlBindFF,[cutLength,1]); %restack into continuous signal
region0GdFF = region0GdFF - nanmean(region0GdFF);

%process end of signal using final mean (from uneven bins)
region0GEnd =  [region0GBl(cutLength+1:end)]; 
region0GdFFend = ((region0GEnd - region0GBlM(binNum))./region0GBlM(binNum))*100; 
region0GdFFend = region0GdFFend - nanmean(region0GdFFend);

%combine processed signals into continuous signal of original length (-edge artifact)
region0GdFF = [region0GdFF; region0GdFFend];

%repeat for red signal
%Bottom 5% Baseline
blBin = 10; %Set bin size for baselining (in seconds)
blBin = blBin*Fs;
region0RBl = region0R;
binNum = floor(length(region0RBl)/blBin); 
cutLength = blBin*binNum; 
region0RBlcut = [region0RBl(1:cutLength)];
region0RBlBin = reshape(region0RBlcut,[blBin,binNum]);
region0RBls = sort(region0RBlBin,1); 
bl5Perc = blBin*0.05; %Set to bottom 5 percent
region0RBl5perc=region0RBls(1:bl5Perc,:);
region0RBlM = mean(region0RBl5perc,1); 

% Convert raw signal in pixel saturation units to deltaF/F (%) for each bin
region0RBlBindFF = ((region0RBlBin - region0RBlM)./region0RBlM)*100; 
region0RdFF = reshape(region0RBlBindFF,[cutLength,1]); %restack into continuous signal
region0RdFF = region0RdFF - nanmean(region0RdFF);

%process end of signal using final mean (from uneven bins)
region0REnd =  [region0RBl(cutLength+1:end)]; 
region0RdFFend = ((region0REnd - region0RBlM(binNum))./region0RBlM(binNum))*100; 
region0RdFFend = region0RdFFend - nanmean(region0RdFFend);

%combine processed signals into continuous signal of original length (-edge artifact)
region0RdFF = [region0RdFF; region0RdFFend];


figure; hold on
plot(region0GdFF,'g'); plot(region0RdFF,'r');
ylabel('dF/F', 'FontSize', 20);
xlabel('Time (s)', 'FontSize', 20);
set(gca,'FontSize',20);
title('PhotoBleaching+Motion-Corrected Signal','FontSize',20)
% message = sprintf('Inspect Final Photometry Data');
% uiwait(msgbox(message, 'modal'));

photometry470 = table(frame470,region0GdFF,timeStamp470);
photometry565 = table(frame565,region0RdFF,timeStamp565);

%% Process/downsample behavior data

photoStart = timeStamp470(1,1); %Align beginning of lick to photometry signal
photoEnd = timeStamp470(end); %Align beginning of lick to photometry signal

% lickStart = find(lick.timestamp>=photoStart);
% lickEnd = find(lick.timestamp<=photoEnd);
% lickStart = lickStart(1,1);
% lickEnd = lickEnd(end);
% lick = [lick(lickStart:lickEnd,:)]; 
% lickFs = 2000; %Set lick sensor sampling frequency
% lickDFs = lickFs./Fs;
%ickDS = downsample(lick,25);


% joystickStart = find(joystick.timestamp>=photoStart); %Align beginning of joystick to photometry signal
% joystickStart = joystickStart(1,1);
% joystick = [joystick(joystickStart:end,:)]; 
% joystickFs = 2000; %Set joystick sampling frequency
% joystickDFs = joystickFs./Fs;
% joystickSz = numel(joystick.joystick);

%% Normalize signal and save normalized data for group compilation
%add other behavior data to norm or norm to .mat file

region0GdFFz = normalize(region0GdFF);
photometryZ = table(frame470,region0GdFFz,timeStamp470);
normSuffix = '.csv';
normFile = fullfile(filePath, [subID '_' date '_Photometry' normSuffix]); 
output_file = (normFile); % name of file containing combined data
writetable(photometryZ,output_file);

%% Pre-process data for alignment with photometry signal

%Create variables enocoding each frame as 0/1 for each event
stateTransitions.hits = categorical(stateTransitions.stateTransitions);
stateTransitions.hits  = renamecats(stateTransitions.hits,{'Hit'},{'1'});
stateTransitions.hits  = str2double(string(stateTransitions.hits));
stateTransitions.hits(isnan(stateTransitions.hits))=0;

stateTransitions.miss = categorical(stateTransitions.stateTransitions);
stateTransitions.miss = renamecats(stateTransitions.miss,{'Miss'},{'1'});
stateTransitions.miss = str2double(string(stateTransitions.miss));
stateTransitions.miss(isnan(stateTransitions.miss))=0;

clearvars hitsStats missStats

% Align behavior events to computer timestamps
[~,~,hitsStats] = timealign(photometry470.timeStamp470,stateTransitions.timeStamp,photometry470.region0GdFF,stateTransitions.hits);
[~,~,missStats] = timealign(photometry470.timeStamp470,stateTransitions.timeStamp,photometry470.region0GdFF,stateTransitions.miss);

hitsStats(isnan(hitsStats))=0;
missStats(isnan(missStats))=0;

% Find event times in samples
hit_trials = find(hitsStats>0.5);
hit_trials_diff = diff(hit_trials);
index_new_hit = find(hit_trials_diff >1);
hit_trials = hit_trials(index_new_hit + 1);

miss_trials = find(missStats>0.5);
miss_trials_diff = diff(miss_trials);
index_new_miss = find(miss_trials_diff >1);
miss_trials = miss_trials(index_new_miss + 1);

region0GdFF = fillmissing(region0GdFF,'movmean',5);


%% Set graphing parameters

% Set window, in seconds, to use for alignment
win = [-0.5 2]; 
winLick = [-0.5 1];

%% Align baseline PHOTOMETRY signal to baseline for event 
 
%Set baseline photometry signal for correct response trials
sta_baseHit = getSTA(region0GdFF, hit_trials./Fs, Fs, win);
sta_baseHit = nanmean(sta_baseHit, 1); 

%Set baseline photometry signal for incorrect response trials
sta_baseIncResp = getSTA(region0GdFF, incResp_trials./Fs, Fs, win);
sta_baseIncResp = nanmean(sta_baseIncResp, 1);

%Set baseline photometry signal for correct response trials
sta_baseMiss = getSTA(region0GdFF, miss_trials./Fs, Fs, win);
sta_baseMiss = nanmean(sta_baseMiss, 1); 

%Set baseline photometry signal for sounds
sta_baseSound = getSTA(region0GdFF, sound_trials./Fs, Fs, win);
sta_baseSound = nanmean(sta_baseSound, 1); 

%Set baseline photometry signal for licks
sta_baseLick = getSTA(region0GdFF, lick_trials./Fs, Fs, winLick);
sta_baseLick = nanmean(sta_baseLick, 1); 
 
%Set baseline photometry signal for pushes
 sta_basePush = getSTA(region0GdFF, push_trials./Fs, Fs, win);
 sta_basePush = nanmean(sta_basePush, 1); 
 
%Set baseline photometry signal for pulls
 sta_basePull = getSTA(region0GdFF, pull_trials./Fs, Fs, win);
 sta_basePull = nanmean(sta_basePull, 1); 
 
 
% %% Align baseline JOYSTICK signal to baseline for event 
%  
% %Set baseline photometry signal for correct response trials
% sta_baseHitJoy = getSTA(joystick.joystick, hit_trials./joystickFs, joystickFs, win);
% sta_baseHitJoy = nanmean(sta_baseHitJoy, 1); 
% 
% %Set baseline photometry signal for incorrect response trials
% sta_baseIncRespJoy = getSTA(joystick.joystick, incResp_trials./joystickFs, joystickFs, win);
% sta_baseIncRespJoy = nanmean(sta_baseIncRespJoy, 1);
% 
% %Set baseline photometry signal for correct response trials
% sta_baseMissJoy = getSTA(joystick.joystick, miss_trials./joystickFs, joystickFs, win);
% sta_baseMissJoy = nanmean(sta_baseMissJoy, 1); 
% 
% %Set baseline photometry signal for sounds
% sta_baseSoundJoy = getSTA(joystick.joystick, sound_trials./joystickFs, joystickFs, win);
% sta_baseSoundJoy = nanmean(sta_baseSoundJoy, 1); 
% 
% %Set baseline photometry signal for licks
% sta_baseLickJoy = getSTA(joystick.joystick, lick_trials./joystickFs, joystickFs, win);
% sta_baseLickJoy = nanmean(sta_baseLickJoy, 1); 
%  
% %Set baseline photometry signal for pushes
%  sta_basePushJoy = getSTA(joystick.joystick, push_trials./joystickFs, joystickFs, win);
%  sta_basePushJoy = nanmean(sta_basePushJoy, 1); 
%  
% %Set baseline photometry signal for pulls
%  sta_basePullJoy = getSTA(joystick.joystick, pull_trials./joystickFs, joystickFs, win);
%  sta_basePullJoy = nanmean(sta_basePullJoy, 1); 


%% Align PHOTOMETRY to events

%Spike Triggered Averages for Hit Trials
[sta_hit, time] = getSTA(region0GdFF, hit_trials./Fs, Fs, win);
sta_hit = sta_hit - sta_baseHit;

%Spike Triggered Averages for Incorrect Response Trials
[sta_incResp, time] = getSTA(region0GdFF, incResp_trials./Fs, Fs, win);
sta_incResp = sta_incResp - sta_baseIncResp;

%Spike Triggered Averages for Miss Trials
[sta_miss, time] = getSTA(region0GdFF, miss_trials./Fs, Fs, win);
sta_miss = sta_miss - sta_baseMiss;

%Spike Triggered Averages for Sounds
[sta_sound, time] = getSTA(region0GdFF, sound_trials./Fs, Fs, win);
sta_sound = sta_sound - sta_baseSound;

%Spike Triggered Averages for Licks
[sta_lick, time] = getSTA(region0GdFF, lick_trials./Fs, Fs, winLick);
sta_lick = sta_lick - sta_baseLick;

%Spike Triggered Averages for Pushes
[sta_push, time] = getSTA(region0GdFF, push_trials./Fs, Fs, win);
sta_push = sta_push - sta_basePush;

%Spike Triggered Averages for Pulls
[sta_pull, time] = getSTA(region0GdFF, pull_trials./Fs, Fs, win);
sta_pull = sta_pull - sta_basePull;


%% Align JOYSTICK to events

% %Spike Triggered Averages for Hit Trials
% [sta_hitJoy, timeJoy] = getSTA(joystick.joystick, hit_trials./Fs, joystickFs, win);
% %sta_hitJoy = sta_hitJoy - sta_baseHitJoy;
% 
% %Spike Triggered Averages for Incorrect Response Trials
% [sta_incRespJoy, timeJoy] = getSTA(joystick.joystick, incResp_trials./Fs, joystickFs, win);
% %sta_incRespJoy = sta_incRespJoy - sta_baseIncRespJoy;
% 
% %Spike Triggered Averages for Miss Trials
% [sta_missJoy, timeJoy] = getSTA(joystick.joystick, miss_trials./Fs, joystickFs, win);
% %sta_missJoy = sta_missJoy - sta_baseMissJoy;
% 
% %Spike Triggered Averages for Sounds
% [sta_soundJoy, timeJoy] = getSTA(joystick.joystick, sound_trials./Fs, joystickFs, win);
% %sta_soundJoy = sta_soundJoy - sta_baseSoundJoy;
% 
% %Spike Triggered Averages for Licks
% [sta_lickJoy, timeJoy] = getSTA(joystick.joystick, lick_trials./Fs, joystickFs, win);
% %sta_lickJoy = sta_lickJoy - sta_baseLickJoy;
% 
% %Spike Triggered Averages for Pushes
% [sta_pushJoy, timeJoy] = getSTA(joystick.joystick, push_trials./Fs, joystickFs, win);
% %sta_pushJoy = sta_pushJoy - sta_basePushJoy;
% 
% %Spike Triggered Averages for Pulls
%  [sta_pullJoy, timeJoy] = getSTA(joystick.joystick, pull_trials./Fs, joystickFs, win);
% %sta_pullJoy = sta_pullJoy - sta_basePullJoy;


%% Respoonse Data

%Proportion Correct
pullCount = length(pull_trials);
pushCount = length(push_trials);
missCount = length(miss_trials);

propCorrectPUSH = (pushCount/(pushCount+pullCount))*100;
propCorrectPULL = (pullCount/(pushCount+pullCount))*100;

% Average IRI
responses= responseStats;
idxMiss = strfind(responseStats(:,1), 'Miss');
idxMiss = find(not(cellfun('isempty', idxMiss)));
responses([idxMiss],:) = [];
responses = cell2mat(responses(:,2));
IRI = diff (responses, 1, 1);
IRI = mean(IRI);
IRI = IRI/1000;

% Average Reward-First Lick Interval


% Write Reponse Data
RespData = {'subID', 'date', 'pushCount', 'pullCount', 'missCount', 'propCorrectPUSH', 'propCorrectPULL', 'IRI';
    subID, date, pushCount, pullCount, missCount, propCorrectPUSH, propCorrectPULL, IRI};


message = sprintf('Ready to Graph');
uiwait(msgbox(message, 'modal'));



%% Save processed data as .mat file

data.filePath = filePath;
data.fileNames = fileNames;
data.date = date;
data.subID = subID;

data.region0GdFF = region0GdFF;
data.region0GdFFz = region0GdFFz;
data.Fs = Fs;

data.lick = lick;
data.joystick = joystick;
data.sounds = sounds;

data.hit_trials = hit_trials;
data.incResp_trials = incResp_trials;
data.miss_trials = miss_trials;

data.sound_trials = sound_trials;
data.lick_trials = lick_trials;
data.push_trials = push_trials;
data.pull_trials = pull_trials;

data.sta_baseHit = sta_baseHit;
data.sta_baseIncResp = sta_baseIncResp;
data.sta_baseMiss = sta_baseMiss;

data.sta_hit = sta_hit;
data.sta_incResp = sta_incResp;
data.sta_miss = sta_miss;

% data.sta_baseHitJoy = sta_baseHitJoy
% data.sta_baseIncRespJoy = sta_baseIncRespJoy
% data.sta_baseMissJoy = sta_baseMissJoy

data.sta_hitJoy = sta_hitJoy;
data.sta_incRespJoy = sta_incRespJoy;
data.sta_missJoy = sta_missJoy;

data.RespData = RespData;

mat_suffix = '.mat';
matFile = fullfile(filePath, [subID '_' baseName '_' date mat_suffix]);
save(matFile,'data');

message = sprintf('Preprocessing Complete');
uiwait(msgbox(message, 'modal'));


%% GRAPH

%Mean & SEM of HIT trials
figure; hold on
%ylim([-6 6])
shadedErrorBar(time, nanmean(sta_hit,2), nansem(sta_hit,2), 'lineProps','g'); %plot hit trials
plot([0 0],[ylim], ':', 'Color',[0.5,0.5,0.5]); %plot grey dotted line at x=0
set(gca,'FontSize',20)
xlabel('Time From Event (s)', 'FontSize', 20);
ylabel('Delta F/F (%)', 'FontSize', 20);
legend('Rewarded Trials', 'FontSize', 20);


%All Hit Trials
figure; hold on;
frames = size(sta_hit,1); 
dt = 0.0125; % time interval between two frames - in seconds 
time = (0:frames-1)*dt;
time = time+(win(1,1));
plot(time,sta_hit);
plot([0 0],[ylim], ':', 'Color',[0.5,0.5,0.5]); %plot grey dotted line at x=0
plot([1 1],[ylim], '-', 'Color',[0.5,0.5,0.5]); %plot grey dotted line at x=0
legend('FontSize', 20);


