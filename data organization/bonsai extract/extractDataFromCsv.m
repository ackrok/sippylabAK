function data = extractDataFromCsv(frames, photoT, statetrans)

% data = extractDataFromCsv(frames, photoT, statetrans)
%
% INPUTS
% fileBeh = dir('State*.csv'); % check for .csv files starting with "State'
% statetrans = GetBonsai_Pho_StateTransitions_Celeste(fileBeh.name);
%
% fileFrames = dir('Frames*.csv'); 
% frames     = table2array(GetBonsai_PhotometryFrames(fileFrames.name));
% 
% filePhoto = dir('Photo*.csv'); % check for .csv files starting with "Photo..."
% photoT    = GetBonsai_Photometry(filePhoto.name);
%
% Anya Krok, December 2025

%% extract photometry data

idx = find(~isnan(table2array(photoT(1, 5:size(photoT,2))))); % identify colums R0 - G15 that include photometry values
photoT = table2array(photoT(:,[1:3, idx+4])); % extract data colums that have photometry signal
photoT(1:length(frames),2)=frames(:,2);

% R0 - red 
% R1 - green
ledState = 4; % which LED state we are drawing from, ledState 4 is 565nm
signalRaw_red = photoT(photoT(:,3)==ledState,[2,4]); 
ledState = 2; % which LED state we are drawing from, ledState 2 is 470nm
signalRaw_grn = photoT(photoT(:,3)==ledState,[2,5]); 

%% create data structure
data = struct;
data.mouse = []; data.date = []; data.ID = [];
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

%% process photometry data
params = struct;
params.FP.lpCut = 15; % Cut-off frequency for filter
params.FP.filtOrder = 8; % Order of the filter
params.dsRate = 1; params.dsType = 2; % 1 = Bin Summing; 2 = Bin Averaging;
params.FP.interpType = 'linear'; params.FP.fitType = 'interp';
params.FP.winSize = 10; params.FP.winOv = 0; params.FP.basePrc = 5;
data.gen.params = params;

[data] = processFP_NPM(data,params);

%% extract behavior data
beh = alignBehTStoPhotoTS(data, statetrans); % frame relative to photometry signal
data.beh = beh;