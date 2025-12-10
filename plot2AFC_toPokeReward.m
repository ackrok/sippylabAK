
% 'data' structure with fields:
%   - 'ID': mouse ID
%   - 'Hab': habituation data
%   - 'OneTone': tone-reward data
%
% 'Hab' and 'OneTone' similar structures with fields:
%   - 'Day'      } date of recording
%   - 'LickR_TS' } timeStamps for right port, in sec
%   - 'LickL_TS' } timeStamps for left port, in sec
%   - 'Center_TS'} timeStamps for center port, in sec
%   - 'TrialTS'  } timeStamps for ?initiation of trial as a table, in sec
%   - 'LR_R'     } lick rate for right port, vector is 1 x numSamp
%   - 'LR_L'     } lick rate for left port, vector is 1 x numSamp
%   - 'pokeRate'  } poke rate for center port, vector is 1 x numSamp
%   - 'Hits'      } timeStamps for Hits, in sec
%   - 'Errors'    } timeStamps for Errors, in sec
%   - 'Misses'    } timeStamps for Misses, in sec
%   - 'noHolds'   } timeStamps for noHolds, in sec
%   - 'rewLatency'} for Hits, time to reward collection, in sec
%   - 'STA_Right' } sub-structure with reward-triggered lick rate for Hits
%
% 'STA_right' structure with fields:
%   - 'Poke_LR'     } Lick rate aligned to Time to Poke
%   - 'Poke_LR_z'   } same as above, z-scored
%   - 'Poke_LR_avg' } same as above, average across Hit trials
%   - 'Poke_LR_zavg'} same as above, average across Hit trials and z-scored
%   - 'Rew_LR'      } Lick rate aligned to Time to Reward
%   - 'Rew_LR_z'    } same as above, z-scored
%   - 'Rew_LR_avg'  } same as above, average across Hit trials
%   - 'Rew_LR_zavg' } same as above, average across Hit trials and z-scored
%   - 'LR_time'     } time vector for STA
%
%
%% EXTRACT DATA
addpath('/Users/akrok/Desktop/Sippy Lab/2AFC');
addpath('/Users/akrok/Documents/GitHub/ach-paper_v3/ach-paper-v3/gen');

filename = 'StateTransitions.csv';
behaviorFile = extractLickData(filename, 0); % for non-habituation data
data = extract2AFCdataFun(behaviorFile, dayName, 1);

%% plot STA poke, reward for ONE SESSION
x = 1; % mouse ID
y = 2; % day ID
tmpSTA = dataAA(x).OneTone(y).STA_Right;

fig = figure;
hold on
shadederrbar(tmpSTA.LR_time(:), nanmean(tmpSTA.Poke_LR,1)', SEM(tmpSTA.Poke_LR,1)', 'k');
shadederrbar(tmpSTA.LR_time(:), nanmean(tmpSTA.Rew_LR,1)', SEM(tmpSTA.Rew_LR,1)', 'b');
xline(0,'--');
ylabel('Lick Rate (Hz)');
legend({'time to Poke', 'time to Reward'});
title(sprintf('%s - %s \n',dataAA(x).ID,dataAA(x).OneTone(y).Day));

%% plot STA poke, reward for MULTIPLE SESSIONS, same mouse
fig = figure;

x = 1; % mouse ID
nDays = length(dataAA(x).OneTone);
for y = 1:nDays
    tmpSTA = dataAA(x).OneTone(y).STA_Right;
    sp(y) = subplot(1,nDays,y);
    hold on
    shadederrbar(tmpSTA.LR_time(:), nanmean(tmpSTA.Poke_LR,1)', SEM(tmpSTA.Poke_LR,1)', 'k');
    shadederrbar(tmpSTA.LR_time(:), nanmean(tmpSTA.Rew_LR,1)', SEM(tmpSTA.Rew_LR,1)', 'b');
    xline(0,'--');
    ylabel('Lick Rate (Hz)');
    legend({'time to Poke', 'time to Reward'});
    title(sprintf('%s - %s \n',dataAA(x).ID,dataAA(x).OneTone(y).Day));
end
linkaxes(sp,'y');

%% 