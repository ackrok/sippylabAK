%% plotFP over time

if ~exist('comb')
    error('ERROR: comb structure does not exist in workspace.');
end

[uni,~,idxMap] = unique({comb.mouse});
choice = menu('Select mouse to analyze',uni);
match = find(strcmp({comb.mouse},uni{choice})); % idx in comb structure for this unique mouse ID

%%
figure; 
for b = 1:2
    subplot(2,1,b); hold on
    for ii = match
        plot(comb(ii).time, comb(ii).FP{b}); % Assuming 'time' and 'FP' are fields in the comb structure
    end
    xlabel('time (s)'); ylabel([comb(ii).FPnames{b},' (dF/F)']);
    title(['FP over Time for Mouse: ', uni{choice}]);
    %xlim([250 400])
end