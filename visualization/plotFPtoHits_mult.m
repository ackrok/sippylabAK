%% plotFPtoHits_mult
% Description: align photometry signal(s) to behavioral event times using
% spike-triggered average functions. Necessitates prior photometry signal
% processing and behavioral data extraction into combined data structure.
% This script aims to compare STA across multiple sessions for each animal.
%
% INPUTS
% 'comb' - combined data structure from extractCombstruct
% 
% OUTPUTS
% 'alignAll', 'alignAvg' - analysis outputs with STA to event
% 'fig' - generates figures plotting aligned signals, one per type of
% photometry signal recorded (eg, 5-HT, DA, GCaMP)
% 
% Anya Krok, Dec 2025

%% Analyze data
if ~exist('comb')
    error('ERROR: comb structure does not exist in workspace.');
end

%% 
win = [-1 5]; % STA window, in seconds
winBase = [win(1)-1, win(1)]; % baseline window, in seconds

out = analyzeFP_STA(comb, win, winBase);

time = out.time; % time vector
nUni = length(out); % number of unique mouse ID
nFP = out(1).nFP; % number of photometry signals
FPnames = out(1).FPnames; % photometry signal IDs

%% Plot STA, comparing across recordings per animal
% Select behavioral event to plot
opts = out(1).sta.Properties.VariableNames;
choice = menu('Input',opts);
thisEv = opts{choice};

opts = cell(nFP,1);
for b = 1:nFP; opts{b} = [FPnames{b},' to ',thisEv,', by mouse']; end
choice = listdlg('ListString',opts);

for c = 1:length(choice)
    figure;
    spX = floor(sqrt(nUni)); spY = ceil(nUni/spX);
    clr = lines(7); % color matrix

    idxFP = choice(c); % index for photometry signal
    for idxMouse = 1:nUni
        subplot(spX,spY, idxMouse); hold on
        
        % iterate over each recording for unique mouse ID
        for idxRec = 1:length(out(idxMouse).recs) 
            pullSta = out(idxMouse).sta.(thisEv){idxRec,idxFP};
            shadederrbar(time, nanmean(pullSta,2), SEM(pullSta,2), clr(idxRec,:));
        end
        xline(0);
        title(sprintf('%s - %s to %s',out(idxMouse).mouse, FPnames{idxFP}, thisEv));
        xlabel(sprintf('time to %s (s)',thisEv)); 
        ylabel(sprintf('%s (dF/F)',FPnames{idxFP}));
        legend(out(idxMouse).recs); 
    end
end


    % switch choice(c)
    %    case 1
            % idxFP = choice(c); % index for photometry signal
            % figure;
            % spX = floor(sqrt(nUni)); spY = ceil(nUni/spX);
            % clr = lines(7); % color matrix
            % for ii = 1:nUni
            %     subplot(spX,spY,ii); hold on
            % 
            %     for a = 1:length(out(ii).recs) % iterate over each recording for unique mouse ID
            %         pullSta = out(ii).sta.(thisEv){a,idxFP};
            %         shadederrbar(time, nanmean(pullSta,2), SEM(pullSta,2), clr(a,:));
            %     end
            %     xline(0);
            %     title(sprintf('%s - %s to %s',out(ii).mouse, FPnames{idxFP}, thisEv));
            %     xlabel(sprintf('time to %s (s)',thisEv)); 
            %     ylabel(sprintf('%s (dF/F)',FPnames{idxFP}));
            %     legend(out(ii).recs); 
            % end
    %    case 2
            % b = choice(c); % index for photometry signal
            % figure;
            % spX = floor(sqrt(nUni)); spY = ceil(nUni/spX);
            % clr = lines(7); % color matrix
            % for ii = 1:nUni
            %     subplot(spX,spY,ii); hold on
            % 
            %     for a = 1:length(out(ii).recs) % iterate over each recording for unique mouse ID
            %         pullSta = out(ii).sta.(thisEv){a,b};
            %         shadederrbar(time, nanmean(pullSta,2), SEM(pullSta,2), clr(a,:));
            %     end
            %     xline(0);
            %     title(sprintf('%s - %s to %s',out(ii).mouse, FPnames{b}, thisEv));
            %     xlabel(sprintf('time to %s (s)',thisEv)); 
            %     ylabel(sprintf('%s (dF/F)',FPnames{b}));
            %     legend(out(ii).recs); 
            % end
    % end
% end