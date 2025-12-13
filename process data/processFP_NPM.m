function [data] = processFP_NPM(data,params)
%Process Fiber Photometry acquired with Neurophotometrics system
%
%   [data] = processFP(data,params)
%
%   Description: This function is designed to process fiber photometry data
%   for the lab. The function performs demodulation (if selected),
%   filtering, baselining, and downsampling for all photometry traces in
%   the recording. The parameters for the analysis are found in the params
%   structure, which is created from a user-created scripted based on the
%   processParam.m file.
%
%   Input:
%   - data - A data structure specific to the Tritsch Lab. Created using
%   the convertH5_FP script
%   - params - A structure created from a variant of the processParams
%   script
%
%   Output:
%   - data - Updated data structure containing processed data
%
%   Originally written by: Pratik Mistry 2019
%   Edited by: Anya Krok 2025 to adapt for Neurophotometrics data
%   acquisition

nAcq = length(data.acq);
lpCut = params.FP.lpCut; filtOrder = params.FP.filtOrder;

dsRate = params.dsRate;
dsType = params.dsType;

interpType = params.FP.interpType;
fitType = params.FP.fitType; winSize = params.FP.winSize;
winOv = params.FP.winOv;
basePrc = params.FP.basePrc;

rawFs = data.gen.acqFs;
Fs = rawFs/dsRate;
data.gen.Fs = Fs;

for n = 1:nAcq
    nFP = data.acq(n).nFPchan;
    FPnames = data.acq(n).FPnames;
    data.final(n).FPnames = FPnames;
    data.final(n).nFPchan = nFP;
    data.final(n).FP = cell(nFP,1);
    data.final(n).nbFP = cell(nFP,1);
    data.final(n).FPbaseline = cell(nFP,1);
    for x = 1:nFP
        rawFP = data.acq(n).FP{x};
        nbFP = filterFP(rawFP,rawFs,lpCut,filtOrder,'lowpass');
        nbFP = downsampleTLab(nbFP,dsRate,dsType);
        [FP,baseline] = baselineFP(nbFP,interpType,fitType,basePrc,winSize,winOv,Fs);
        data.final(n).FP{x} = FP;
        data.final(n).nbFP{x} = nbFP;
        data.final(n).FPbaseline{x} = baseline;
        L = length(data.acq(n).time{x}); 
        timeVec = [1:length(1:dsRate:L)]/Fs;
        timeVec = timeVec(1:length(FP));
        data.final(n).time = timeVec(:);
    end
end