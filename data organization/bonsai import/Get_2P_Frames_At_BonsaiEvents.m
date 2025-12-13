
function [Go,NoGo,GoResponse,NoGoResponse,Hit,Miss,CR,FA,FramesTS,JoyStickAtFrames,LickAtFrames,NoRewardPresses,dp] =Get_2P_Frames_At_BonsaiEvents()

% Find Sync Timestamps
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,3));
FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
[CorrectBlinks,WrongBlinks] =  Get_Bonsai_WrongBlinks  (filename.name);
FrameTSdouble=FrameTSdouble(CorrectBlinks);
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));

if length(FramesTS)==54000

% Find Frames before Go Tones
GoTS=StateTransTS((statetrans.Id=='Go')); 
c=1;
for i=1:length(GoTS)   

   FramesB4Evnt=find(FramesTS<GoTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
Go=FirstFrameB4EvntIdx;

% Find Frames before NoGo Tones
NoGoTS=StateTransTS((statetrans.Id=='NoGo'));
c=1;
if length(NoGoTS)>1
for i=2:length(NoGoTS)   
   FramesB4Evnt=find(FramesTS<NoGoTS(i));
   FirstFrameB4EvntIdx2(c)=FramesB4Evnt(end);
   c=c+1;
end
NoGo=FirstFrameB4EvntIdx2;
else
NoGo=NaN;
end

% Find Frames before HitsTones
HitTS=StateTransTS(find(statetrans.Id=='Hit'));
c=1;
for i=1:length(HitTS)  
   FramesB4Evnt=find(FramesTS<HitTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx3(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
Hit=FirstFrameB4EvntIdx3;

% Find Frames before Miss Tones
MissTS=StateTransTS(find(statetrans.Id=='Miss'));
if MissTS>0
c=1;
for i=1:length(MissTS)
   FramesB4Evnt=find(FramesTS<MissTS(i));
   FirstFrameB4EvntIdx4(c)=FramesB4Evnt(end);
   c=c+1;
end
Miss=FirstFrameB4EvntIdx4;
else
Miss=NaN;
end 

 
CRTS=StateTransTS(find(statetrans.Id=='CorrectRejection'));
if length(CRTS)>1
   c=1;
for i=1:length(CRTS)
   FramesB4Evnt=find(FramesTS<CRTS(i));
   FirstFrameB4EvntIdx5(c)=FramesB4Evnt(end);
   c=c+1;
end
CR=FirstFrameB4EvntIdx5;
else
CR=NaN;
end

if length(find(statetrans.Id=='Timeout'))==0
FATS=StateTransTS(find(statetrans.Id=='FalseAlarm'));
else length(find(statetrans.Id=='Timeout'))>0
FATS=StateTransTS(find(statetrans.Id=='Timeout'));
end
if length(FATS)>1
    c=1;
for i=1:length(FATS)
   FramesB4Evnt=find(FramesTS<FATS(i));
   FirstFrameB4EvntIdx6(c)=FramesB4Evnt(end);
   c=c+1;
end
FA=FirstFrameB4EvntIdx6;
else
FA=NaN;
end

GoTS=StateTransTS((statetrans.Id=='Annotation')); 
c=1;
for i=1:length(GoTS)   

   FramesB4Evnt=find(FramesTS<GoTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx7(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
if exist("FirstFrameB4EvntIdx7")~=0
ManReward=FirstFrameB4EvntIdx7;
end
joystick1=GetBonsai_Joystick('JoystickTrace.csv');
joystick(:,2)=movmean((joystick1(:,2)),10);

JoyB4Frame=find(ismember(joystick1(:,1),FramesTS));
JoyStickAtFrames=joystick(JoyB4Frame,2);
    
licktrace=GetBonsai_LickTrace('LickTrace.csv');
licktrace(:,2)=movmean(licktrace(:,2),200)*10;
LickB4Frame=find(ismember(licktrace(:,1),FramesTS));
LickAtFrames=movmean(licktrace(LickB4Frame,2),1);


HitAtFrames=zeros(54000,1);
HitAtFrames(Hit(find(Hit>1)))=1;
if Miss>0;
HitAtFrames(Miss(find(Miss>1)))=-1;
end

pre=1;
post=6;
for i= 1:length(Go)
if Go(i)+(post+.1)*30<size(HitAtFrames,1)&Go(i)-pre*30+1>0
    if sum(HitAtFrames(Go(i)-pre*30:Go(i)+post*30))>0;
    GoResponse(i)=1;
    elseif sum(HitAtFrames(Go(i)-pre*30:Go(i)+(post+.1)*30))<0;
    GoResponse(i)=2;
    end
else
    GoResponse(i)=10;
end
end

if length(NoGoTS)>1&(length(CR)>1|length(FA)>1)
CRAtFrames=zeros(54000,1);
if length(CR)>1
CRAtFrames(CR)=1;
end
if length(FA)>1
CRAtFrames(FA)=-1;
end

pre=1;
post=6;
for i= 1:length(NoGo)
if NoGo(i)+(post+.1)*30<size(CRAtFrames,1)&NoGo(i)-pre*30+1>0
    if sum(CRAtFrames(NoGo(i)-pre*30:NoGo(i)+post*30))>0;
    NoGoResponse(i)=3;
    elseif sum(CRAtFrames(NoGo(i)-pre*30:NoGo(i)+(post+.1)*30))<0;
    NoGoResponse(i)=4;
    end
    else
    NoGoResponse(i)=10;
    end
end

else
    NoGoResponse=NaN;
end

%%

HitTS=StateTransTS((statetrans.Id=='Hit'));
c=1;
for i=1:length(HitTS)   

   FramesB4Evnt5=find(joystick1(:,1)<HitTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx5(c)=FramesB4Evnt5(end);
   Good(i)=1;
   c=c+1;
   else
   Good(i)=0;
   continue   

   end
end
joystickAthit=joystick1(FirstFrameB4EvntIdx5,2);


Hitidx=StateTransTS((statetrans.Id=='Hit'));
[count,v]=histcounts(joystickAthit);
[num,idxMax]=max(count);
HitLeverThres=v(idxMax);

joysticktrace=joystick1(:,2);

HitTrace(1:length(joysticktrace))=0;
HitTrace(FirstFrameB4EvntIdx5)=1;

% HitLeverThres=30;
for i=4001:length(joysticktrace)-500
    
    % Find Instances in which joystick crosses the Reward Threshold while
    % not having crossed the ITI extension threshold for 1 second and no
    % Reward or Tone Occured
    if joysticktrace(i-1)<HitLeverThres&joysticktrace(i)>=HitLeverThres&max(joysticktrace(i-1000:i-100))<10&max(HitTrace(i-500:i+500))<1
        GoodPress(i)=1;
    else
        GoodPress(i)=0;

    end
end


% Find Frames before HitsTones
PressTS=joystick1(find(GoodPress==1),1);
c=1;
for i=1:length(PressTS)  
   FramesB4Evnt=find(FramesTS<PressTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx6(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
NoRewardPresses=FirstFrameB4EvntIdx6;

if length(NoGo)>0
dp=dprime(length(Hit)/length(Go),length(FA)/length(NoGo));
else
dp=nan
end
%% 

