%% Compare behavioral data across multiple recordings
% 
% 

[filePath] = uigetdir2; % Essentially multiselect directories, returns filePath in cell array

%%
if ~exist('combBeh','var')
    combBeh = struct; % Initiate structure to store data such that works with other plotting scripts
end

%%
for a = 1:length(filePath)
    tic
    thisPath = filePath{a};
    cd(thisPath);
    fileBeh = dir('State*.csv'); % check for .csv files starting with "State'
    if isempty(fileBeh)
        tmp = dir(thisPath);
        if isempty([tmp.isdir])
            error('ERROR: no files or folder in this directory.')
        end
        thisPathSubfolders = {tmp.name};
        idx = find(strlength(thisPathSubfolders)>9); % if folder name starts with YYYY-MM-DD, should be at least 9 characters long
        if length(idx) > 1
            choice = menu('Select sub-folder with data (can open it in Finder to confirm).',thisPathSubfolders);
            idx = thisPathSubfolders{choice}; 
        end
        cd(fullfile(thisPath, thisPathSubfolders{idx}));
        fileBeh = dir('State*.csv'); % check for .csv files starting with "State'
    end
    statetrans = GetBonsai_Pho_StateTransitions_Celeste(fileBeh.name);
    beh = extract2AFCdataAK(statetrans);

    str = thisPath; % string with file path
    mouse = regexp(str, 'JT0\d{2}', 'match', 'once'); % extract JT followed by 0 and two digits (e.g. JT019)
    date = regexp(str, '\d{6}', 'match', 'once'); % extract any sequence of exactly six digits (e.g. 251215)

    b = size(combBeh,2); if isempty(fieldnames(combBeh)); b = 0; end
    combBeh(b+1).mouse = mouse; 
    combBeh(b+1).date = date;
    combBeh(b+1).beh = beh; % Store behavioral data in the structure
    toc
    fprintf('Extracted behavioral data for: %s-%s \n',mouse,date);
end

%% 
