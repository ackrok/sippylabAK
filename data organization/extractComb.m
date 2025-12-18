%% extractComb
% Initialize a structure to store recordings for single cohort of
% animals across multiple recording days
% Experiments: photometry, behavior
%
% Anya Krok, Dec 2025

[fileName,filePath] = uigetfile('*.mat','Select the DATA files','MultiSelect','on');
cd(filePath);  % open file directory

%%
comb = struct; % create empty structure
for a = 1:length(fileName)
    tic
    load(fullfile(filePath, fileName{a})); % load each .mat file
    comb(a).mouse = data.mouse; % store the loaded data in the structure
    comb(a).date  = data.date; % store the loaded data in the structure
    comb(a).rec   = data.ID; % recording ID
    comb(a).FPnames = data.final.FPnames;
    comb(a).FP = data.final.FP;
    comb(a).time = data.final.time;
    comb(a).Fs = data.gen.Fs;
    comb(a).beh = data.beh;
    toc
end

% time = [1:length(comb(a).FP{1})]'/comb(a).Fs; 
% time = time(1:length(comb(a).FP{1})); % code for if want to save storage
% space and not save time vector 

%% 
save(fullfile(filePath,['combinedData_',char(datetime("today")),'.mat']),'comb');
fprintf('SAVED comb.mat in filePath \n');