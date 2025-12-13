

clear
close all
% behavDir = 'R:\sippyt01labspace\Shared Folders\Amanda_Anya\Data\CuRT_practice';
behavDir = '/Users/akrok/Desktop/Sippy Lab/2AFC';
cd(behavDir)
mice = [dir('FP*'); dir('AA*')];
wheel = {'+', '-', '+', '-', '+'};
%% LOOP THROUGH MICE
tic
for i_mouse = 1:length(mice)
    data(i_mouse).ID = mice(i_mouse).name;
    data(i_mouse).Wheel = wheel{i_mouse};
    thisMouse = [mice(i_mouse).folder, '\', mice(i_mouse).name];
    cd(thisMouse)
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
%% ANALYSIS
% clear
% cd('R:\sippyt01labspace\Shared Folders\Amanda_Anya\Data\CuRT_practice')
% load('extractedData.mat')

Rew_bin = 0:60:90*60;
m=0;
for i_mouse = 1:length(data)
    sess = fieldnames(data); sess = sess(2:end);
    if i_mouse ~= 4
        m=m+1;
    end
    for i_sess = 1:length(sess)
        for i_day = 1:length(data(i_mouse).(sess{i_sess}))
            thisData = data(i_mouse).(sess{i_sess})(i_day);
            toPlotData.(sess{i_sess}).PokeRate{i_day}(i_mouse,:) = nan(size(Rew_bin(1:end-1)));
            toPlotData.(sess{i_sess}).RewRate{i_day}(i_mouse,:) = nan(size(Rew_bin(1:end-1)));
            toPlotData.(sess{i_sess}).LR{i_day}(i_mouse,:) = nan([1 26]);

            if contains(sess{i_sess}, 'Hab')
                toPlotData.(sess{i_sess}).L_RewCount{i_day}(i_mouse) = ...
                    length(thisData.LeftHits);
                toPlotData.(sess{i_sess}).R_RewCount{i_day}(i_mouse) = ...
                    length(thisData.RightHits);
                toPlotData.(sess{i_sess}).Tot_RewCount{i_day}(i_mouse) = ...
                    toPlotData.(sess{i_sess}).R_RewCount{i_day}(i_mouse) + toPlotData.(sess{i_sess}).L_RewCount{i_day}(i_mouse);
                toPlotData.(sess{i_sess}).Rew_Latency{i_day}(i_mouse) = min([thisData.LeftHits; thisData.RightHits]);
                toPlotData.(sess{i_sess}).TotalTime{i_day}(i_mouse) = max([thisData.LeftHits; thisData.RightHits]);


                toPlotData.(sess{i_sess}).R_RewRate{i_day}(i_mouse,:) = histcounts(thisData.RightHits, Rew_bin);
                toPlotData.(sess{i_sess}).L_RewRate{i_day}(i_mouse,:) = histcounts(thisData.LeftHits, Rew_bin);
                toPlotData.(sess{i_sess}).Tot_RewRate{i_day}(i_mouse,:) = ...
                    toPlotData.(sess{i_sess}).R_RewRate{i_day}(i_mouse,:) + toPlotData.(sess{i_sess}).L_RewRate{i_day}(i_mouse,:);

                toPlotData.(sess{i_sess}).R_LR{i_day}(i_mouse,:) = thisData.STA_Right.LR_avg;
                toPlotData.(sess{i_sess}).L_LR{i_day}(i_mouse,:) = thisData.STA_Left.LR_avg;
                toPlotData.(sess{i_sess}).Tot_LR{i_day}(i_mouse,:) = ...
                    nanmean([thisData.STA_Right.LR_avg;thisData.STA_Left.LR_avg],1);
                toPlotData.(sess{i_sess}).LR_first{i_day}(i_mouse,:) = ...
                    nanmean([thisData.STA_Right.LR_z(1:round(end./3),:); ...
                        thisData.STA_Left.LR_z(1:round(end./3),:)],1);
                toPlotData.(sess{i_sess}).LR_last{i_day}(i_mouse,:) = ...
                    nanmean([thisData.STA_Right.LR_z(round(end./3*2):end,:); ...
                        thisData.STA_Left.LR_z(round(end./3*2):end,:)],1);
                toPlotData.(sess{i_sess}).IRI{i_day}(i_mouse) = nanmean([diff(thisData.RightHits(thisData.RightHits <= 60*20)); ...
                    diff(thisData.LeftHits(thisData.LeftHits <= 60*20))], 'all');         

            elseif contains(sess{i_sess}, 'One') && i_mouse~=4
                toPlotData.(sess{i_sess}).numPokes{i_day}(m) = ...
                    length(thisData.Center_TS);
                toPlotData.(sess{i_sess}).numHits{i_day}(m) = ...
                    length(thisData.Hits);
                toPlotData.(sess{i_sess}).numErrors{i_day}(m) = ...
                    length(thisData.Errors);
                toPlotData.(sess{i_sess}).PokeRate{i_day}(m,:) = ...
                    histcounts(thisData.Center_TS, Rew_bin);
                toPlotData.(sess{i_sess}).noHolds{i_day}(m) = ...
                    length(thisData.noHolds)/length(thisData.Center_TS) * 100;
                toPlotData.(sess{i_sess}).noHoldRate{i_day}(m,:) = ...
                    histcounts(thisData.noHolds, Rew_bin);
                if ~isempty(thisData.Hits)
                    toPlotData.(sess{i_sess}).RewRate{i_day}(m,:) = ...
                        histcounts(thisData.Hits, Rew_bin);
                    toPlotData.(sess{i_sess}).LR_Poke{i_day}(m,:) = thisData.STA_Right.Poke_LR_avg;
                    toPlotData.(sess{i_sess}).LR_Rew{i_day}(m,:) = thisData.STA_Right.Rew_LR_avg;
                    toPlotData.(sess{i_sess}).LR_first{i_day}(m,:) = ...
                        nanmean(thisData.STA_Right.Rew_LR_z(1:round(end./3),:),1);
                    toPlotData.(sess{i_sess}).LR_last{i_day}(m,:) = ...
                        nanmean(thisData.STA_Right.Rew_LR_z(round(end./3*2):end,:),1);
                    toPlotData.(sess{i_sess}).Rew_Latency{i_day}(m) = min(thisData.Hits);
                    toPlotData.(sess{i_sess}).TotalTime{i_day}(m) = max(thisData.Hits);
                    toPlotData.(sess{i_sess}).IRI{i_day}(m) = nanmean(diff(thisData.Hits), 'all');
                    hitPokes = thisData.TrialTS.TS(contains(thisData.TrialTS.Trial, 'Right'));
                    toPlotData.(sess{i_sess}).RewTimes{i_day}(m) = nanmean(thisData.rewLatency);
                else
                    toPlotData.(sess{i_sess}).Rew_Latency{i_day}(m) = 60*90;
                end
            end
        end
    end
end









%% HABITUATION - REW COUNT AND SIDE BIAS

figure;
set(gcf,'Color','w')
sp(1) = subplot(2,2,1);sp(2) = subplot(2,2,2);
timeToPlot = thisData.STA_Right.LR_time;
for i = 1:size(toPlotData.Hab.Tot_RewRate{1},1)
    subplot(2,2,1)
    hold on
    plot(Rew_bin(2:end)/60, toPlotData.Hab.Tot_RewRate{1}(i,:), '.--', 'LineWidth',.5)
    subplot(2,2,2)
    hold on
    plot(Rew_bin(2:end)/60, toPlotData.Hab.Tot_RewRate{2}(i,:), '.--', 'LineWidth',.5)

    legendNames{i} = data(i).ID;
end
subplot(2,2,1)
hold on
plot(Rew_bin(2:end)/60, nanmean(toPlotData.Hab.Tot_RewRate{1},1),'-', 'Color', [0.4940 0.1840 0.5560], ...
    'LineWidth',3)
xlabel('Time (min)'); ylabel('Reward Count / bin'); legend({legendNames{:}, 'Avg'}); title('Day 1')
set(gca, 'fontsize', 18)
subplot(2,2,2)
hold on
plot(Rew_bin(2:end)/60, nanmean(toPlotData.Hab.Tot_RewRate{2},1), '-', 'Color', [0.8500 0.3250 0.0980], ...
    'LineWidth',3)
xlabel('Time (min)'); ylabel('Reward Count / bin'); legend({legendNames{:}, 'Avg'}); title('Day 2')
set(gca, 'fontsize', 18)
linkaxes(sp)

subplot(2,2,3)
barplot_joe(toPlotData.Hab.IRI, ...
    {[0.4940 0.1840 0.5560], [0.8500 0.3250 0.0980]}, 1:2, 2, {'Day 1', 'Day 2'})
hold on
plot(1:2, [toPlotData.Hab.IRI{1}(contains({data.Wheel}, '-')); toPlotData.Hab.IRI{2}(contains({data.Wheel}, '-'))], 'ko--')
plot(1:2, [toPlotData.Hab.IRI{1}(contains({data.Wheel}, '+')); toPlotData.Hab.IRI{2}(contains({data.Wheel}, '+'))], 'ro--')
set(gca, 'fontsize', 18)
ylabel('IRI (First 20min)'); title('Inter Reward Interval')

subplot(2,2,4)
errorbarplot_joe(timeToPlot, toPlotData.Hab.Tot_LR{2}, [0.8500 0.3250 0.0980], [0.8500 0.3250 0.0980])
hold on
errorbarplot_joe(timeToPlot, toPlotData.Hab.Tot_LR{1}, [0.4940 0.1840 0.5560], [0.4940 0.1840 0.5560])
xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Day 2', 'Day 1'}); vline(0, 'k--')
title('Lick Rate')


% subplot(2,2,3)
% barplot_joe([toPlotData.Hab.L_RewCount, toPlotData.Hab.R_RewCount], ...
%     {'c', 'b', 'm', 'r'}, 1:4, 2, {'Left-D1', 'Left-D2', 'Right-D1', 'Right-D2'})
% hold on
% plot(1:4, [toPlotData.Hab.L_RewCount{1}; toPlotData.Hab.L_RewCount{2}; ...
%     toPlotData.Hab.R_RewCount{1}; toPlotData.Hab.R_RewCount{2}], 'ko--')
% set(gca, 'fontsize', 18)
% ylabel('Reward Count'); title('Reward Port Bias')

% subplot(2,2,3)
% errorbarplot_joe(timeToPlot, toPlotData.Hab.LR_last{1}, [0.8500 0.3250 0.0980], [0.8500 0.3250 0.0980])
% hold on
% errorbarplot_joe(timeToPlot, toPlotData.Hab.LR_first{1}, [0.4940 0.1840 0.5560], [0.4940 0.1840 0.5560])
% xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Last 1/3', 'First 1/3'}); 
% title('Lick rates over session - Day 1')
% subplot(2,2,4)
% errorbarplot_joe(timeToPlot, toPlotData.Hab.LR_last{2}, [0.8500 0.3250 0.0980], [0.8500 0.3250 0.0980])
% hold on
% errorbarplot_joe(timeToPlot, toPlotData.Hab.LR_first{1}, [0.4940 0.1840 0.5560], [0.4940 0.1840 0.5560])
% xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Last 1/3', 'First 1/3'}); 
% title('Lick rates over session - Day 2')


figure;
set(gcf,'Color','w')
subplot(1,3,1)
barplot_joe(toPlotData.Hab.Tot_RewCount, {[0.4940 0.1840 0.5560], [0.8500 0.3250 0.0980]}, 1:2, 2, ...
    {'Day 1', 'Day 2'})
hold on
plot(1:2, [toPlotData.Hab.Tot_RewCount{1}(contains({data.Wheel}, '-')); toPlotData.Hab.Tot_RewCount{2}(contains({data.Wheel}, '-'))], 'ko--')
plot(1:2, [toPlotData.Hab.Tot_RewCount{1}(contains({data.Wheel}, '+')); toPlotData.Hab.Tot_RewCount{2}(contains({data.Wheel}, '+'))], 'ro--')
set(gca, 'fontsize', 18)
ylabel('Count'); title('Number of rewards')

subplot(1,3,2)
barplot_joe(toPlotData.Hab.Rew_Latency, {[0.4940 0.1840 0.5560], [0.8500 0.3250 0.0980]}, 1:2, 2, ...
    {'Day 1', 'Day 2'})
hold on
plot(1:2, [toPlotData.Hab.Rew_Latency{1}(contains({data.Wheel}, '-')); toPlotData.Hab.Rew_Latency{2}(contains({data.Wheel}, '-'))], 'ko--')
plot(1:2, [toPlotData.Hab.Rew_Latency{1}(contains({data.Wheel}, '+')); toPlotData.Hab.Rew_Latency{2}(contains({data.Wheel}, '+'))], 'ro--')
set(gca, 'fontsize', 18)
ylabel('Latency'); title('Latency to first reward')

subplot(1,3,3)
barplot_joe(toPlotData.Hab.TotalTime, {[0.4940 0.1840 0.5560], [0.8500 0.3250 0.0980]}, 1:2, 2, ...
    {'Day 1', 'Day 2'})
hold on
plot(1:2, [toPlotData.Hab.TotalTime{1}(contains({data.Wheel}, '-')); toPlotData.Hab.TotalTime{2}(contains({data.Wheel}, '-'))], 'ko--')
plot(1:2, [toPlotData.Hab.TotalTime{1}(contains({data.Wheel}, '+')); toPlotData.Hab.TotalTime{2}(contains({data.Wheel}, '+'))], 'ro--')
set(gca, 'fontsize', 18)
ylabel('Time (s)'); title('Time to consume 150uL')



%% COMPARE GROUPS

idx1 = find((contains({data.Wheel}, '-'))); idx2 = find((contains({data.Wheel}, '+')));
figure; sp(1) = subplot(1,2,1);
errorbarplot_joe(timeToPlot, toPlotData.Hab.Tot_LR{1}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(timeToPlot, toPlotData.Hab.Tot_LR{1}(idx2,:), 'r', 'r')
xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('Hab D1 Lick Rate')
sp(2) = subplot(1,2,2);
errorbarplot_joe(timeToPlot, toPlotData.Hab.Tot_LR{2}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(timeToPlot, toPlotData.Hab.Tot_LR{2}(idx2,:), 'r', 'r')
xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('Hab D2 Lick Rate')















%% ONE TONE TRAINING
wheel = {'+', '-', '+', '+'};

figure;
set(gcf,'Color','w')
sp(1) = subplot(2,2,1);sp(2) = subplot(2,2,2);
%timeToPlot = thisData.STA_Right.LR_time;
for i = 1:length(toPlotData.OneTone.numPokes)-1
    % yyaxis left 
    subplot(2,2,1)
    hold on
    plot(i, toPlotData.OneTone.numPokes{i}(contains(wheel,'-')), ...
        'k.', 'MarkerSize', 12)
    plot(i, toPlotData.OneTone.numPokes{i}(contains(wheel,'+')), ...
        'r.', 'MarkerSize', 12)
    % yyaxis right; 
    subplot(2,2,2)
    hold on; %yyaxis left
    plot(i, toPlotData.OneTone.numHits{i}(contains(wheel,'-')), ...
        'k.', 'MarkerSize', 12)
    plot(i, toPlotData.OneTone.numHits{i}(contains(wheel,'+')), ...
        'r.', 'MarkerSize', 12)
    % yyaxis right
    % plot(i, toPlotData.OneTone.numErrors{i}, 'ro')

    toPlotData.OneTone.numPokesAvg(1,i) = nanmean(toPlotData.OneTone.numPokes{i});
    toPlotData.OneTone.numHitsAvg(1,i) = nanmean(toPlotData.OneTone.numHits{i});
    % toPlotData.OneTone.numErrorsAvg(1,i) = nanmean(toPlotData.OneTone.numErrors{i});
end
subplot(2,2,1)
% yyaxis left
hold on
plot(1:i,toPlotData.OneTone.numPokesAvg(1:i), '-', 'LineWidth',3, 'Color',"#0072BD")
xlabel('Day'); ylabel('Poke Count'); 
set(gca, 'fontsize', 18)
subplot(2,2,2)
% yyaxis right; 
hold on
plot(1:i, toPlotData.OneTone.numHitsAvg(1:i), '-', 'LineWidth',3, 'Color',"#D95319")
ylabel('Hit Count')
% yyaxis right; hold on
% plot(1:i, toPlotData.OneTone.numErrorsAvg(1:i), 'r-', 'LineWidth',3)
% ylabel('Error Count')
xlabel('Training Day'); 
set(gca, 'fontsize', 18)
% linkaxes(sp)
%
sp(1) = subplot(2,2,3);
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Poke{1}, [0.4940 0.1840 0.5560], [0.4940 0.1840 0.5560])
hold on
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Poke{4}, [0.8500 0.3250 0.0980], [0.8500 0.3250 0.0980])
xlabel('Time from Poke (s)'); ylabel('Lick Rate (Hz)'); legend({'Day 1', 'Day 4'}); vline(0, 'k--')
ylim([0 11])

subplot(2,2,4);
barplot_joe({toPlotData.OneTone.RewTimes{1}, toPlotData.OneTone.RewTimes{4}}, ...
    {[0.4940 0.1840 0.5560], [0.8500 0.3250 0.0980]}, 1:2, 2, {'Day 1', 'Day 4'})
hold on
plot(1:2, [toPlotData.OneTone.RewTimes{1}(contains(wheel, '-')); toPlotData.OneTone.RewTimes{4}(contains(wheel, '-'))], 'ko--')
plot(1:2, [toPlotData.OneTone.RewTimes{1}(contains(wheel, '+')); toPlotData.OneTone.RewTimes{4}(contains(wheel, '+'))], 'ro--')
ylabel('Retrieval Latency (s)'); 

% 
% sp(2) = subplot(2,2,4);
% errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Rew{2}, [0.8500 0.3250 0.0980], [0.8500 0.3250 0.0980])
% hold on
% errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Rew{4}, [0.4940 0.1840 0.5560], [0.4940 0.1840 0.5560])
% xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Day 2', 'Day 4'}); vline(0, 'k--')
% ylim([0 11])
% linkaxes(sp)

%% COMPARE GROUPS
idx1 = find((contains(wheel, '-'))); idx2 = find((contains(wheel, '+')));
figure; sp(1) = subplot(2,2,1); 
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Rew{1}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Rew{1}(idx2,:), 'r', 'r')
xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('Train D1 Lick Rate')
sp(2) = subplot(2,2,2);
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Rew{4}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_Rew{4}(idx2,:), 'r', 'r')
xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('Train D4 Lick Rate')
sp(3) = subplot(2,2,3); 
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_first{1}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_first{1}(idx2,:), 'r', 'r')
xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('D1 Lick Rate - First 1/2')
sp(4) = subplot(2,2,4);
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_first{4}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(timeToPlot, toPlotData.OneTone.LR_first{4}(idx2,:), 'r', 'r')
xlabel('Time from Reward (s)'); ylabel('Lick Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('D4 Lick Rate - First 1/2')
linkaxes(sp)
%%
figure; sp(1) = subplot(2,2,1);
errorbarplot_joe(Rew_bin(2:end), toPlotData.OneTone.RewRate{3}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(Rew_bin(2:end), toPlotData.OneTone.RewRate{3}(idx2,:), 'r', 'r')
xlabel('Time (s)'); ylabel('Hit Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('D3 Reward Rate')
sp(2) = subplot(2,2,2);
errorbarplot_joe(Rew_bin(2:end), toPlotData.OneTone.PokeRate{3}(idx1,:), 'k', 'k')
hold on
errorbarplot_joe(Rew_bin(2:end), toPlotData.OneTone.PokeRate{3}(idx2,:), 'r', 'r')
xlabel('Time (s)'); ylabel('EE Rate (Hz)'); legend({'Wheel-', 'Wheel+'}); vline(0, 'k--')
title('D3 Poke Rate')
sp(3) = subplot(2,2,3);
barplot_joe(toPlotData.OneTone.numHits(1:4), {[0.4940 0.1840 0.5560], 'c', 'b', [0.8500 0.3250 0.0980]}, ...
    1:4, 2, {'D1', 'D2', 'D3', 'D4'})
hold on
plot(1:4, [toPlotData.OneTone.numHits{1}(contains(wheel, '-')); ...
    toPlotData.OneTone.numHits{2}(contains(wheel, '-')); ...
    toPlotData.OneTone.numHits{3}(contains(wheel, '-')); ...
    toPlotData.OneTone.numHits{4}(contains(wheel, '-'))], 'ko--')
plot(1:4, [toPlotData.OneTone.numHits{1}(contains(wheel, '+')); ...
    toPlotData.OneTone.numHits{2}(contains(wheel, '+')); ...
    toPlotData.OneTone.numHits{3}(contains(wheel, '+')); ...
    toPlotData.OneTone.numHits{4}(contains(wheel, '+'))], 'ro--')
ylabel('# of Hits'); 
sp(4) = subplot(2,2,4);
barplot_joe(toPlotData.OneTone.noHolds(1:4), {[0.4940 0.1840 0.5560], 'c', 'b', [0.8500 0.3250 0.0980]}, ...
    1:4, 2, {'D1', 'D2', 'D3', 'D4'})
hold on
plot(1:4, [toPlotData.OneTone.noHolds{1}(contains(wheel, '-')); ...
    toPlotData.OneTone.noHolds{2}(contains(wheel, '-')); ...
    toPlotData.OneTone.noHolds{3}(contains(wheel, '-')); ...
    toPlotData.OneTone.noHolds{4}(contains(wheel, '-'))], 'ko--')
plot(1:4, [toPlotData.OneTone.noHolds{1}(contains(wheel, '+')); ...
    toPlotData.OneTone.noHolds{2}(contains(wheel, '+')); ...
    toPlotData.OneTone.noHolds{3}(contains(wheel, '+')); ...
    toPlotData.OneTone.noHolds{4}(contains(wheel, '+'))], 'ro--')
ylabel('# of No Holds'); 


