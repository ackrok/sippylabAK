function [dFF] = baselineFP_SM(rawFP, acqFs, params)
% Processing photometry signal from Neurophotometrics based on code from
% Sarah Mennenga. This code converts raw photometry signal into dF/F using
% baseline bin averaging method. Note, this does not include filtering or
% downsampling of signal.
%
% INPUT
% - 'rawFP' - raw photometry signal vector
% - 'acqFs' - acquisition sampling rate (in Hz)
% - 'params' - structure with processing variables
%       - must include params.FP.winSize, params.FP.basePrc
%
% OUTPUT
% - 'dFF' - processed photometry signal vector (in dF/F)
%
% Adapted by Anya Krok, Dec 2025
%

winSize = params.FP.winSize; % usually 10
winOv = params.FP.winOv; % usually 0
basePrc = params.FP.basePrc; % usually 5%

winSize = params.FP.winSize; % set bin size for baselining (in seconds)
winSize = winSize * acqFs; % convert to samples
binNum = floor(length(rawFP)/winSize); 
cutLength = winSize * binNum; 
rawFPcut = [rawFP(1:cutLength)];
rawFPbin = reshape(rawFPcut,[winSize,binNum]);
rawFPls = sort(rawFPbin,1); 
binPrc = winSize*(basePrc/100); % percentage of baseline (5%)
rawFPbasePrc=rawFPls(1:binPrc,:);
rawFPmean = mean(rawFPbasePrc,1); 

% convert raw signal in pixel saturation units to deltaF/F (%) for each bin
dFF = ((rawFPbin - rawFPmean)./rawFPmean)*100; 
dFF = reshape(dFF,[cutLength,1]); % restack into continuous signal
dFF = dFF - nanmean(dFF);

% process end of signal using final mean (from uneven bins)
fpEnd =  [rawFP(cutLength+1:end)]; 
dFFend = ((fpEnd - rawFPmean(binNum))./rawFPmean(binNum))*100; 
dFFend = dFFend - nanmean(dFFend);

% combine processed signals into continuous signal of original length (-edge artifact)
dFF = [dFF; dFFend];