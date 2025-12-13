% identify LickCenter / tone that immediately precedes each Hit
hitRows = find(statetrans.Id == 'Hit'); % row numbers of Hits
lickRows = nan(numel(hitRows),1);       % store preceding LickCenter (NaN if none)

for k = 1:numel(hitRows)
    r = hitRows(k);
    if r > 1
        idx = find(statetrans.Id(1:r-1) == 'LickCenter', 1, 'last');
        if ~isempty(idx)
            lickRows(k) = idx;
        end
    end
end
