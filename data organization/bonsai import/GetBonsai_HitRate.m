
function [Hits]=GetBonsai_HitRate()
statetrans=ImportBonsaiStateTransitions('StateTransitions.csv'); % Import State Transition file
Hits=length(find(statetrans.Id=='Hit')); % find Event of Interest Onset in Statetrans File


