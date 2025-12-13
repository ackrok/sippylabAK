
function [GNG_Psth]=Get_GNG_Psth(foldername,pre,post,Mac)

iscell=[];
cd(foldername);
%% Load Beahvioral Variables 
BehaviorFolder=dir ('*Pretraining*');
cd([foldername,'/',BehaviorFolder.name])

[Hit,JoyStickAtFrames,LickAtFrames,LickTS,FirstLick] =Get_2P_Frames_At_BonsaiEventsPretraining();

if exist('VidChange.mat','file')
    load VidChange.mat
else
VidChange=JoyStickAtFrames;
end

JoyStickAtFramesN=normalize(JoyStickAtFrames);
VidChangeN=normalize(VidChange);
LickAtFramesN=normalize(LickAtFrames);


%% Load Neural Data
if Mac==1
cd([cell2mat(Sessions2P{s}),'\','suite2p\plane0'])
else
cd([foldername,'/','suite2p/plane0'])    
end
load Fall.mat

cellsOrigi=(F(iscell(:,1)==1,:));
for i= 1:size(cellsOrigi,1)
    cells(i,:)=dF_Anya(cellsOrigi(i,:));
end

% figure()
% 
% meanImg=readNPY('meanImg.npy');
% meanImg_chan2=readNPY('meanImg_chan2.npy');
% imgColor(:,:,1)=(meanImg_chan2/2000);
% imgColor(:,:,2)=(meanImg/2000);
% imgColor(:,:,3)=zeros(512,512);
% imshow(squeeze(imgColor))


if exist('D1D2.mat','file')
    load D1D2.mat
else
    D1D2=ones(size(cells,1),1)+4;
end

%% Comupte GNG_Psth

pre=5;
post=5;

TS=[Hit];  
TStype=[ones(length(Hit),1)];
% TrialIDs=[1:length(Go)];
STClocal=1;
% HitTrace(1:length(JoyStickAtFrames))=0;
%             if length(Hit)>1
%             HitTrace(Hit)=1;
%             end
for i= 1:length(TS)
if TS(i)+post*30<size(cells,2)&TS(i)-pre*30+1>0
    
    %Cut Trials and Zscore or proces otherwise
    signal=cells(:,(TS(i)-pre*30+1:TS(i)+post*30))';
    TrialMatrix1(:,STClocal,:)=signal;
    % Counter all Important Trial Info
    TrialType1(STClocal)=TStype(STClocal);
%     ResponseType1(STClocal)=ResponseTypeSession(STClocal);
%     HitMatrix1(:,STClocal)=HitTrace(TS(i)-pre*30+1:TS(i)+post*30)';
    JoyMatrix1(:,STClocal)=JoyStickAtFrames(TS(i)-pre*30+1:TS(i)+post*30)';
    JoyMatrix1N(:,STClocal)=JoyStickAtFramesN(TS(i)-pre*30+1:TS(i)+post*30)';

    LickMatrix1(:,STClocal)=LickAtFramesN(TS(i)-pre*30+1:TS(i)+post*30)';
%     VidChangeMatrix1(:,STClocal)=VidChangeN(TS(i)-pre*30+1:TS(i)+post*30)';
%     TrialID1(STClocal)=TrialIDs(STClocal);
    STClocal=STClocal+1;
end
end


GNG_Psth.TrialMatrix=reshape(TrialMatrix1,[size(TrialMatrix1,1),size(TrialMatrix1,2)*size(TrialMatrix1,3)]);
GNG_Psth.JoyMatrix=repmat(JoyMatrix1,1,size(TrialMatrix1,3));
GNG_Psth.JoyMatrixN=repmat(JoyMatrix1N,1,size(TrialMatrix1,3));
GNG_Psth.LickMatrix=repmat(LickMatrix1,1,size(TrialMatrix1,3))
% GNG_Psth.VidChangeMatrix=repmat(VidChangeMatrix1,1,size(TrialMatrix1,3));
% GNG_Psth.HitMatrix=repmat(HitMatrix1,1,size(TrialMatrix1,3));
TrialType=repmat(TrialType1,size(TrialMatrix1,3),1)';
GNG_Psth.TrialType=TrialType(:);
% TrialID=repmat(TrialID1,size(TrialMatrix1,3),1)';
% GNG_Psth.TrialID=TrialID(:);
% TrialD1D2=repmat(D1D2',size(TrialMatrix1,2),1);
% GNG_Psth.TrialD1D2=TrialD1D2(:);
% ResponseType=repmat(ResponseType1,size(TrialMatrix1,3),1)';
% GNG_Psth.ResponseType=ResponseType(:);
TrialCellIDsession=repmat(1:size(cells,1)',size(TrialMatrix1,2),1);
GNG_Psth.TrialCellIDsession=TrialCellIDsession(:);
TrialCellID=repmat(1:size(cells,1),size(TrialMatrix1,2),1);
GNG_Psth.TrialCellID=TrialCellID(:);
end
