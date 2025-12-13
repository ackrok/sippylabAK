%% OPEN folder with RAW DATA
clear
close all
behavDir = 'R:\sippyt01labspace\Shared Folders\Amanda_Anya\Data\CuRT_practice'; % name path to where files are

% commonly used directories:
% /Users/akrok/Desktop/Sippy Lab/2AFC
%
% data should appear in folder structure as follows:
%
%   behavDir > Hab > Day1 > 20251105 - time > data files
%   behavDir > OneTone > Day1 > 20251105 - time > data files
%

cd(behavDir); % call directory to Current Folder
mice = [dir('FP*'); dir('JT*'); dir('AK*')]; % extract mouse names
wheel = [];

%% LOOP THROUGH MICE
tic
for i_mouse = 1:length(mice)
    data(i_mouse).ID = mice(i_mouse).name;
    thisMouse = [mice(i_mouse).folder, '\', mice(i_mouse).name];
    cd(thisMouse);
    sessions = dir();
    for i_session = 3:length(sessions)
        sessionName = sessions(i_session).name;
        thisSession = [sessions(i_session).folder, '\', sessions(i_session).name];
        cd(thisSession)
        days = dir('Day*');
        for i_day = 1:length(days)
            thisDay = [days(i_day).folder, '\', days(i_day).name];
            cd(thisDay)
            dayName = days(i_day).name;
            file = dir('202*');   
            cd([file(1).folder, '\', file(1).name])
            filename = 'StateTransitions.csv';
            try
            if contains(sessionName, 'Hab')
                behaviorFile = extractLickData(filename, 1);
                data(i_mouse).(sessionName)(i_day) = ...
                    extract2AFCdataFun(behaviorFile, dayName, 0);
            elseif contains(sessionName, 'One')
                behaviorFile = extractLickData(filename, 0);
                data(i_mouse).(sessionName)(i_day) = ...
                    extract2AFCdataFun(behaviorFile, dayName, 1);
            end
            catch
            end
        end
    end
end
cd(behavDir)
save('extractedData.mat', 'data')
toc

