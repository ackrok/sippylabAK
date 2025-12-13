 
function [GNG_Psth]=Get_GNG_Psth_Hit(foldername,pre,post,Mac)


% pre=5;
% post=5;
iscell=[];
cd(foldername);
%% Load Beahvioral Variables 
BehaviorFolder=dir ('*GoTone*');
cd([foldername,'/',BehaviorFolder.name])

[Go,NoGo,GoResponse,NoGoResponse,Hit,Miss,CR,FA,FramesTS,JoyStickAtFrames,LickAtFrames,GoResponse2Sec] =Get_2P_Frames_At_BonsaiEventsShortSession();

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


meanImg=readNPY('meanImg.npy');
meanImg_chan2=readNPY('meanImg_chan2.npy');
imgColor(:,:,1)=(meanImg_chan2/2000);
imgColor(:,:,2)=(meanImg/2000);
imgColor(:,:,3)=zeros(512,512);
% imshow(squeeze(imgColor))


if exist('D1D2.mat','file')
    load D1D2.mat
else
    D1D2=ones(size(cells,1),1)+4;
end

%% Comupte GNG_Psth

if isnan(FA(1))==1
TS=[Hit];
TSg=[Hit];

TStype=[ones(length(Hit),1)];
TrialIDs=[1:length(Hit)];
% ResponseTypeSession=[GoResponse];
% ResponseTypeSession2Sec=[GoResponse2Sec];
elseif isnan(FA(1))==0
TS=[Hit];
TSg=[Go];
TStype=[ones(length(Hit),1)];
TrialIDs=[1:length(Hit)];
% ResponseTypeSession=[GoResponse,NoGoResponse];
% ResponseTypeSession2Sec=[GoResponse2Sec,NoGoResponse];
end

STClocal=1;
HitTrace(1:length(JoyStickAtFrames))=0;
if length(Hit)>1
    HitTrace(Hit)=1;
end

FATrace(1:length(JoyStickAtFrames))=0;
if length(FA)>1
    FATrace(FA)=1;
end
cct=1;

for i= 1:length(TS)
if TS(i)+post*30<size(cells,2)&TS(i)-pre*30+1>0
    
    %Cut Trials and Zscore or proces otherwise
    signal=cells(:,(TS(i)-pre*30+1:TS(i)+post*30))';
    TrialMatrix1(:,STClocal,:)=signal;
    % Counter all Important Trial Info
    TrialType1(STClocal)=TStype(i);
    % ResponseType1(STClocal)=ResponseTypeSession(i);
    % ResponseType12Sec(STClocal)=ResponseTypeSession2Sec(i);

    HitMatrix1(:,STClocal)=HitTrace(TS(i)-pre*30+1:TS(i)+post*30)';
    FAMatrix1(:,STClocal)=FATrace(TS(i)-pre*30+1:TS(i)+post*30)';

    JoyMatrix1(:,STClocal)=JoyStickAtFrames(TS(i)-pre*30+1:TS(i)+post*30)';
    JoyMatrix1N(:,STClocal)=JoyStickAtFramesN(TS(i)-pre*30+1:TS(i)+post*30)';

    LickMatrix1(:,STClocal)=LickAtFramesN(TS(i)-pre*30+1:TS(i)+post*30)';
    VidChangeMatrix1(:,STClocal)=VidChangeN(TS(i)-pre*30+1:TS(i)+post*30)';
    TrialID1(STClocal)=(STClocal);
    STClocal=STClocal+1;
    Good(i)=1
else
    Good(i)=0
    cct=cct+1
end
end

GNG_Psth.TrialMatrix=reshape(TrialMatrix1,[size(TrialMatrix1,1),size(TrialMatrix1,2)*size(TrialMatrix1,3)]);
GNG_Psth.JoyMatrix=repmat(JoyMatrix1,1,size(TrialMatrix1,3));
GNG_Psth.JoyMatrixN=repmat(JoyMatrix1N,1,size(TrialMatrix1,3));
GNG_Psth.LickMatrix=repmat(LickMatrix1,1,size(TrialMatrix1,3))
GNG_Psth.VidChangeMatrix=repmat(VidChangeMatrix1,1,size(TrialMatrix1,3));
GNG_Psth.HitMatrix=repmat(HitMatrix1,1,size(TrialMatrix1,3));
GNG_Psth.FAMatrix=repmat(FAMatrix1,1,size(TrialMatrix1,3));
TrialType=repmat(TrialType1,size(TrialMatrix1,3),1)';
GNG_Psth.TrialType=TrialType(:);
TrialID=repmat(TrialID1,size(TrialMatrix1,3),1)';
GNG_Psth.TrialID=TrialID(:);
TrialD1D2=repmat(D1D2',size(TrialMatrix1,2),1);
GNG_Psth.TrialD1D2=TrialD1D2(:);
% ResponseType=repmat(ResponseType1,size(TrialMatrix1,3),1)';
% GNG_Psth.ResponseType=ResponseType(:);
% ResponseType2Sec=repmat(ResponseType12Sec,size(TrialMatrix1,3),1)';
% GNG_Psth.ResponseType2Sec=ResponseType2Sec(:);
TrialCellIDsession=repmat(1:size(cells,1)',size(TrialMatrix1,2),1);
GNG_Psth.TrialCellIDsession=TrialCellIDsession(:);
TrialCellID=repmat(1:size(cells,1),size(TrialMatrix1,2),1);
GNG_Psth.TrialCellID=TrialCellID(:);
GNG_Psth.Image=imgColor;
GNG_Psth.ROIs=stat(iscell(:,1)==1);


clearvars TS TStype STClocal TrialIDs 

if isnan(FA(1))
TS=[Hit];
TStype=[ones(length(Hit),1)];
TrialIDs=[1:length(Hit)];
STClocal=1;
else
TS=[Hit,FA]
TStype=[ones(length(Hit),1);ones(length(FA),1)+1];
TrialIDs=[1:length(Hit),1:length(FA)];
STClocal=1;
end

GoTrace(1:length(JoyStickAtFrames))=0;
if length(Go)>1
    GoTrace(Go)=1;
end

NoGoTrace(1:length(JoyStickAtFrames))=0;
if length(NoGo)>1
    NoGoTrace(NoGo)=1;
end
cct=1;
 
 for i= 1:length(TS)
if TS(i)+post*30<size(cells,2)&TS(i)-pre*30+1>0
    
    %Cut Trials and Zscore or proces otherwise
    signal=cells(:,(TS(i)-pre*30+1:TS(i)+post*30))';
    TrialMatrix1HitFA(:,STClocal,:)=signal;
    % Counter all Important Trial Info
    TrialType1HitFA(STClocal)=TStype(STClocal);
    GoMatrix1(:,STClocal)=GoTrace(TS(i)-pre*30+1:TS(i)+post*30)';
    NoGoMatrix1(:,STClocal)=NoGoTrace(TS(i)-pre*30+1:TS(i)+post*30)';

    JoyMatrix1HitFA(:,STClocal)=JoyStickAtFrames(TS(i)-pre*30+1:TS(i)+post*30)';
    JoyMatrix1NHitFA(:,STClocal)=JoyStickAtFramesN(TS(i)-pre*30+1:TS(i)+post*30)';

%     LickMatrix1(:,STClocal)=LickAtFramesN(TS(i)-pre*30+1:TS(i)+post*30)';
    VidChangeMatrix1HitFA(:,STClocal)=VidChangeN(TS(i)-pre*30+1:TS(i)+post*30)';
    TrialID1HitFA(STClocal)=TrialIDs(STClocal);
    STClocal=STClocal+1;
    Good1(i)=1
else
    Good1(i)=0
    cct=cct+1

end
end
GNG_Psth.TrialMatrixHitFA=reshape(TrialMatrix1HitFA,[size(TrialMatrix1HitFA,1),size(TrialMatrix1HitFA,2)*size(TrialMatrix1HitFA,3)]);
GNG_Psth.JoyMatrixHitFA=repmat(JoyMatrix1HitFA,1,size(TrialMatrix1HitFA,3));
GNG_Psth.JoyMatrixNHitFA=repmat(JoyMatrix1NHitFA,1,size(TrialMatrix1HitFA,3));
GNG_Psth.VidChangeMatrixHitFA=repmat(VidChangeMatrix1HitFA,1,size(TrialMatrix1HitFA,3));
TrialTypeHitFA=repmat(TrialType1HitFA,size(TrialMatrix1HitFA,3),1)';
GNG_Psth.TrialTypeHitFA=TrialTypeHitFA(:);
TrialIDHitFA=repmat(TrialID1HitFA,size(TrialMatrix1HitFA,3),1)';edit 
GNG_Psth.TrialIDHitFA=TrialIDHitFA(:);
TrialD1D2HitFA=repmat(D1D2',size(TrialMatrix1HitFA,2),1);
GNG_Psth.TrialD1D2HitFA=TrialD1D2HitFA(:);
TrialCellIDHitFA=repmat(1:size(cells,1),size(TrialMatrix1HitFA,2),1);
GNG_Psth.TrialCellIDHitFA=TrialCellIDHitFA(:);
GNG_Psth.GoMatrix=repmat(GoMatrix1,1,size(TrialMatrix1HitFA,3));
GNG_Psth.NoGoMatrix=repmat(NoGoMatrix1,1,size(TrialMatrix1HitFA,3));
end

