
%% Select MULTIPLE folders with data files
[filePath] = uigetdir2; % Essentially multiselect directories, returns filePath in cell array

%%
for a = 1:length(filePath)
    tic
    thisPath = filePath{a};
    cd(thisPath);
    fileBeh = dir('State*.csv'); % check for .csv files starting with "State..."
    filePhoto = dir('Photo*.csv'); % check for .csv files starting with "Photo..."
    fileFrames = dir('Frames*.csv'); 
    c = 0;
    while isempty(fileFrames)
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
        filePhoto = dir('Photo*.csv'); % check for .csv files starting with "Photo..."
        fileFrames = dir('Frames*.csv'); 
        c = c + 1; % add to ticker
        if c > 3
            break % exit loop when count exceeds 3
        end
    end
    fprintf('Folder with .csv files identified...')
    
    % open data from .csv files into workspace
    frames         = table2array(GetBonsai_PhotometryFrames(fileFrames.name));
    try statetrans = GetBonsai_Pho_StateTransitions_Celeste(fileBeh.name);
    catch statetrans = [];
    end
    try photoT     = GetBonsai_Photometry(filePhoto.name);
    catch photoT = []; 
    end
    fprintf('Imported data from .csv files...')

    % convert fileName into mouse and date IDs
    str = thisPath; % string with file path
    try
        mouse  = regexp(str, 'JT0\d{2}', 'match', 'once'); % extract JT followed by 0 and two digits (e.g. JT019)
        date   = regexp(str, '\d{6}', 'match', 'once'); % extract any sequence of exactly six digits (e.g. 251215)
        manual = inputdlg({sprintf('%s \n\n\n Mouse ID:',str), 'Recording Date:'},...
            'Input', [1 40; 1 40], {mouse, date});
        mouse = manual{1}; date = manual{2};
    catch
        manual = inputdlg({sprintf('%s \n\n\n Mouse ID:',str), 'Recording Date:'},...
            'Input', [1 40; 1 40], {'JT0XX','YYMMDD'});
        mouse = manual{1}; date = manual{2};
    end
    data.mouse = mouse;
    data.date = date;
    data.ID = [mouse,'-',date];

    % extract into 'data' structure
    % beh = extract2AFCdataAK(statetrans);
    data = extractDataFromCsv(data, frames, photoT, statetrans);

    % save file in same folder where .csv files are located
    save([data.ID,'_data.mat'],'data');
    % save(fullfile('/Volumes/sippylab/Data/Jaden Tauber/cohort1_5HTDA_ketamine',[data.ID,'_data.mat']),'data');
    fprintf('SAVED data.mat for: %s \n', data.ID);
    toc
end