function fpTS = firstFrameBeforeEventIndex(compTS, timeVector)
% 
% Description: permits alignment of photometry signal, acquired with
% Neurophotometrics, with behavioral events, acquired with Bonsai
% 
% When looping over each compTS, this function first finds all the 
% photometry frames that happen before the behavior event, then returns
% the indices of those frames ('FramesB4Evnt'), and finally takes last one.
%
% fpTS = firstFrameBeforeEventIndex(compTS, timeVector)
%
% INPUTS
% - 'compTS': timestamps in computer software clock time of the desired
%       behavior event(s) from StateTransitions.csv table
% - 'timeVector': vector of time values from Neurophotometrics output
%
% OUTPUT
% - 'fpTS': timestamps as index relative to photometry signal.
%       Specifically, returns frame in photometry signal that is
%       immediately BEFORE the behavioral event timestamp
%

idx = []; c = 1;
framesTS = timeVector;
for ii = 1:length(compTS)
    FramesB4Evnt = find(framesTS < compTS(ii)); 
    if FramesB4Evnt > 0
        idx(c) = FramesB4Evnt(end);
        c = c+1;
    else
        continue
    end
end
fpTS = idx(:);