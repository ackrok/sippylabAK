
function data = extract2AFCdataFun(file, dayName, trainDay)
%Compiles relevant behavior variables from bonsai output file
%("StateTransitions.csv") into a data structure

    data.Day = dayName;
if trainDay == 0 %Free Reward Habituation Sessions
    data.LickR_TS = file.ElapsedTS_0(find(contains(file.Id, 'LickRight')));
    % data.LickL_TS = file.ElapsedTS_0(find(contains(file.Id, 'LickLeft')));
    LR_bin = 0:.1:file.ElapsedTS_0(end);
    data.LR_R = histcounts(data.LickR_TS, LR_bin) ./ .1;
    % data.LR_L = histcounts(data.LickL_TS, LR_bin) ./ .1;
    data.RightHits = file.ElapsedTS_0(find(contains(file.Id, 'Hit')));
    % data.LeftHits = file.ElapsedTS_0(find(contains(file.Id, 'Incorrect')));

    %Reward aligned lick rates
    [STA, time, zSTA] = getSTA_AA(data.LR_R, data.RightHits, 10, ...
        LR_bin, [-1 2]);
    data.STA_Right.LR = STA;
    data.STA_Right.LR_z = baselineSubtract_AA(zSTA, [-1 -.5], time);
    data.STA_Right.LR_avg = nanmean(data.STA_Right.LR,1);
    data.STA_Right.LR_zavg = nanmean(data.STA_Right.LR_z,1);
    data.STA_Right.LR_time = time;
    
    % [STA, time, zSTA] = getSTA_AA(data.LR_L, data.LeftHits, 10, ...
    %     LR_bin, [-1 2]);
    % data.STA_Left.LR = STA;
    % data.STA_Left.LR_z = baselineSubtract_AA(zSTA, [-1 -.5], time);
    % data.STA_Left.LR_avg = nanmean(data.STA_Left.LR,1);
    % data.STA_Left.LR_zavg = nanmean(data.STA_Left.LR_z,1);
    % data.STA_Left.LR_time = time;

elseif trainDay == 1 %Center Nose poke + Tone Sessions
    data.LickR_TS = file.ElapsedTS_0(find(contains(file.Id, 'LickRight')));
    % data.LickL_TS = file.ElapsedTS_0(find(contains(file.Id, 'LickLeft')));
    data.Center_TS = file.ElapsedTS_0(find(contains(file.Id, 'LickCenter')));
    data.TrialTS = table(file.ElapsedTS_0(find(strcmp(file.Id, 'Right') | ...
        strcmp(file.Id, 'Left'))), ...
        file.Id(find(strcmp(file.Id, 'Right') | ...
        strcmp(file.Id, 'Left'))), 'VariableNames', {'TS', 'Trial'});
    LR_bin = 0:.1:file.ElapsedTS_0(end);
    data.LR_R = histcounts(data.LickR_TS, LR_bin) ./ .1;
    % data.LR_L = histcounts(data.LickL_TS, LR_bin) ./ .1;
    data.pokeRate = histcounts(data.Center_TS, LR_bin) ./ .1;
    data.Hits = file.ElapsedTS_0(find(contains(file.Id, 'Hit')));
        %Solenoid open ts
    data.Errors = file.ElapsedTS_0(find(contains(file.Id, 'Timeout')));
        %Mouse licked wrong port
    data.Misses = file.ElapsedTS_0(find(contains(file.Id, 'Miss')));
        %Mouse did not retrieve reward within timeout (3s) period
    data.noHolds = file.ElapsedTS_0(find(contains(file.Id, 'Incorrect')));
        %Mouse did not center nose poke for long enough (300ms)

    if ~isempty(data.Hits)
        for i=1:length(data.Hits)
            TrialStart = data.Center_TS(find(data.Center_TS < ...
                data.Hits(i),1,'last')); %Find the beginning of each rewarded trial
            data.rewLatency(i) = data.Hits(i) - TrialStart;
            try
                TrialType(i,:) = data.TrialTS(find(data.TrialTS.TS > ...
                    TrialStart,1,'first'),:); %Left or Right port trial?
            catch
            end
        end
        RightPokes = TrialType.TS(strcmp(TrialType.Trial,'Right'));
            %When mouse initiated the trial (center poke)
        % LeftPokes = TrialType.TS(strcmp(TrialType.Trial,'Left'));
        RightHits = data.Hits(strcmp(TrialType.Trial,'Right'));
            %When mouse got reward (solenoid open ts)
        % LeftHits = data.Hits(strcmp(TrialType.Trial,'Left'));
    else
        RightPokes = [];
        LeftPokes = [];
        RightHits = []; 
        LeftHits = [];
        data.rewLatency = [];
    end
        
    % Reward/Center nose poke aligned lick rates
    %
    % ONCE HAVE getSTA_AA and baselineSubtract_AA then UNCOMMENT THIS 
    %   Anya 12/6/2025
    %
    % if ~isempty(RightHits)
    %     [STA_hits, time_hits, zSTA_hits] = getSTA_AA(data.LR_R, RightHits, 10, ...
    %         LR_bin, [-1 2]);
    %     [STA, time, zSTA] = getSTA_AA(data.LR_R, RightPokes, 10, ...
    %         LR_bin, [-1 2]);
    % else
    %     STA = []; time = []; zSTA = [];
    %     STA_hits = []; time_hits = []; zSTA_hits = [];
    % end
    %     data.STA_Right.Poke_LR = STA;
    %     data.STA_Right.Poke_LR_z = baselineSubtract_AA(zSTA, [-1 -.5], time);
    %     data.STA_Right.Poke_LR_avg = nanmean(data.STA_Right.Poke_LR,1);
    %     data.STA_Right.Poke_LR_zavg = nanmean(data.STA_Right.Poke_LR_z,1);
    % 
    %     data.STA_Right.Rew_LR = STA_hits;
    %     data.STA_Right.Rew_LR_z = baselineSubtract_AA(zSTA_hits, [-1 -.5], time);
    %     data.STA_Right.Rew_LR_avg = nanmean(data.STA_Right.Rew_LR,1);
    %     data.STA_Right.Rew_LR_zavg = nanmean(data.STA_Right.Rew_LR_z,1);
    %     data.STA_Right.LR_time = time;    
%
% UP TO HERE (Anya, 12/6/2025)
%
    % if ~isempty(LeftHits)
    %     [STA, time, zSTA] = getSTA_AA(data.LR_L, LeftPokes, 10, ...
    %         LR_bin, [-1 2]);
    %     [STA_hits, time_hits, zSTA_hits] = getSTA_AA(data.LR_R, LeftHits, 10, ...
    %         LR_bin, [-1 2]);
    % else
    %     STA = []; time = []; zSTA = [];
    %     STA_hits = []; time_hits = []; zSTA_hits = [];
    % end
        % data.STA_Left.Poke_LR = STA;
        % data.STA_Left.Poke_Poke_LR_z = baselineSubtract_AA(zSTA, [-1 -.5], time);
        % data.STA_Left.Poke_LR_avg = nanmean(data.STA_Left.Poke_LR,1);
        % data.STA_Left.Poke_LR_zavg = nanmean(data.STA_Left.Poke_Poke_LR_z,1);
        % 
        % data.STA_Left.Rew_LR = STA_hits;
        % data.STA_Left.Rew_Poke_LR_z = baselineSubtract_AA(zSTA_hits, [-1 -.5], time);
        % data.STA_Left.Rew_LR_avg = nanmean(data.STA_Left.Rew_LR,1);
        % data.STA_Left.Rew_LR_zavg = nanmean(data.STA_Left.Rew_Poke_LR_z,1);
        % data.STA_Left.LR_time = time;
    
end