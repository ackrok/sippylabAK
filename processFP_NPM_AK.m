addpathSippyAK

selectDir = uigetdir(); % pop-up window to select file directory
cd(selectDir); % open file directors

%%
mouse = inputdlg('Enter Mouse ID', 'Input', 1, {'JT0XX'});
date = inputdlg('Enter Recording Date', 'Input', 1, {'YYMMDD'});
dayName = sprintf('%s-%s',mouse{1},date{1});

FramesFile=dir('Frames*.csv'); 
Frames=table2array(GetBonsai_PhotometryFrames(FramesFile.name));

File=dir('*Photometry_*.csv');
RawTable=GetBonsai_Photometry(File.name);
pull = find(~isnan(table2array(RawTable(1, 5:size(RawTable,2))))); % identify colums R0 - G15 that include photometry values
PhotometryTable=table2array(RawTable(:,[1:3, pull+4])); % extract data colums that have photometry signal
PhotometryTable(1:length(Frames),2)=Frames(:,2);

filename = 'StateTransitions.csv';
behaviorFile = extractLickData(filename, 1); % for non-habituation data
beh = extract2AFCdataFun(behaviorFile, dayName, 1);
beh.LR_R = beh.LR_R(:); beh.pokeRate = beh.pokeRate(:); beh.rewLatency = beh.rewLatency(:); % make column vectors

%% R0 red R1 green
ledState = 4; % which LED state we are drawing from, ledState 4 is 565nm
signalRaw_red = PhotometryTable(PhotometryTable(:,3)==ledState,[2,4]); 
ledState = 2; % which LED state we are drawing from, ledState 2 is 470nm
signalRaw_grn = PhotometryTable(PhotometryTable(:,3)==ledState,[2,5]); 

%% create data structure
data = struct;
data.ID = dayName;
data.acq.FPnames = {'5-HT','rDA'};
data.acq.nFPchan = 2;
cutLength = floor(size(signalRaw_grn,1)/300)*300;
signalRaw_grn = signalRaw_grn(1:cutLength,:);
signalRaw_red = signalRaw_red(1:cutLength,:);
data.acq.time{1} = signalRaw_grn(:,1); data.acq.time{2} = signalRaw_red(:,1);
data.acq.FP{1} = signalRaw_grn(:,2); data.acq.FP{2} = signalRaw_red(:,2);

fiberTS = data.acq.time{1}/1e3;  %in seconds - not starting at zero
fiberTriggerBin = ((fiberTS(end-1,1)-fiberTS(1,1))/...
                    (length(fiberTS)-1)); %neurophotometrics acquisition rate
acqFs = round (1 / fiberTriggerBin); % sampling rate
data.gen.acqFs = acqFs;

params = struct;
params.FP.lpCut = 15; % Cut-off frequency for filter
params.FP.filtOrder = 8; % Order of the filter
params.dsRate = 1; params.dsType = 2; % 1 = Bin Summing; 2 = Bin Averaging;
params.FP.interpType = 'linear'; params.FP.fitType = 'interp';
params.FP.winSize = 10; params.FP.winOv = 0; params.FP.basePrc = 5;
data.gen.params = params;

data.beh.bonsai = beh;

[data] = processFP_NPM(data,params);
[dFF] = baselineFP_SM(data.acq.FP{1}, data.gen.acqFs, params);

%% align time stamps for behavioral events (hits) to photometry time stamps
% 
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_Pho_StateTransitions_Celeste(filename.name);
beh = alignBehTStoPhotoTS(data, statetrans); 
% vectors with index as frame relative to photometry signal

beh.bonsai = data.beh.bonsai;
data.beh = beh; 

%% PLOT RW FP
fig = figure; hold on
for x = 1:2
    subplot(1,2,x);
    plot(data.acq.time{x}, data.acq.FP{x});
    xlabel('Time'); ylabel('raw signal'); 
    title(data.acq.FPnames{x});
end 

%% processed FP 
fig = figure; hold on
for x = 1:2
    subplot(1,2,x);
    plot(data.final.time{x}, data.final.FP{x});
    xlabel('Time (s)'); ylabel('FP (dF/F)'); 
    title(data.final.FPnames{x});
end 

%% ALIGN SIGNAL TO HITS
winSta = [-2 2]; winBase = [-2 1.5];

fig = figure;
for a = 1:length(data.final.FP) % photometry signal to analyze

    hits = data.beh.Hits;
    poke = data.beh.Hits - data.beh.rewLatency;
    time = data.final.time{a};
    hitsSamp = []; hitsSampErr = []; pokeSamp = []; pokeSampErr = [];
    for x = 1:length(hits)
        [c, index] = min(abs(time - hits(x)));
        hitsSamp(x) = index; % index along time, FP signal vectors closest to hit time
        hitsSampErr(x) = c; % error, aka difference between time in signal and hit time
        [c, index] = min(abs(time - poke(x)));
        pokeSamp(x) = index; pokeSampErr(x) = c; % closest to poke time
    end
    [staHits, staTime] = getSTA(data.final.FP{a}, data.final.time{a}(hitsSamp), data.gen.Fs, winSta);
    [staPoke, ~] = getSTA(data.final.FP{a}, data.final.time{a}(pokeSamp), data.gen.Fs, winSta);
    
    % baseline adjust STA
    staHitsAdj = staHits - nanmean(staHits(find(staTime == winBase(1)):find(staTime == winBase(2)),:),1);
    staPokeAdj = staPoke - nanmean(staPoke(find(staTime == winBase(1)):find(staTime == winBase(2)),:),1);

    % and PLOT
    subplot(1,2,a); hold on
    shadederrbar(staTime, nanmean(staHitsAdj,2), SEM(staHitsAdj,2),'b');
    shadederrbar(staTime, nanmean(staPokeAdj,2), SEM(staPokeAdj,2),'k');
    xline(0)
    legend({'Hits','Pokes'})
    xlabel('Time to Hit (s)'); ylabel('FP (dF/F)'); title(data.final.FPnames{a});
end
