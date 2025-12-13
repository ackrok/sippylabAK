% function [Go,NoGo,GoResponse,NoGoResponse,Hit,Miss,CR,FA,FramesTS,JoyStickAtFrames,GoResponse2Sec,dp,NoRewardPresses,GoResponseDp,NoGoResponseDp] =Get_2P_Frames_At_BonsaiEventsSwitching()

function [Go,Hit,JoyStickAtFrames,FramesTS] =Get_2P_Frames_At_BonsaiEventsSwitching(Block)

% Find Sync Timestampsed

filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_Pho_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,4));
FrameTSdouble=StateTransTS(statetrans.Id=='Blink');

FramesTS=FrameTSdouble(1:4:(length(FrameTSdouble)));
if length(FramesTS)-length(Block)==-1
    FramesTS(2:length(FramesTS)+1)=FramesTS;
    FramesTS(1)=FramesTS(2)-33;
end

block_0=Block-Block(1);
FramesTS_0=FramesTS-FramesTS(1);
block_0_rep= repmat(FramesTS_0, 1, length(block_0));
diff_matrix = abs(block_0_rep - block_0);
[~, min_indices] = min(diff_matrix);
FramesTS = FramesTS(min_indices);

% Find Frames before Go Tones
GoTS=StateTransTS((statetrans.Id=='Go')); 
c=1;
if length(GoTS)>1
for i=1:length(GoTS)   

   FramesB4Evnt=find(FramesTS<GoTS(i));
   if FramesB4Evnt>0
   if FramesB4Evnt(FramesB4Evnt(end)<54000-(5*30+1)&FramesB4Evnt(end)>5*30+1)
   FirstFrameB4EvntIdx(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
   end
end
Go=FirstFrameB4EvntIdx;
else
Go=nan;
end
% Find Frames before NoGo Tones
NoGoTS=StateTransTS((statetrans.Id=='NoGo'));
c=1;
if length(NoGoTS)>1
for i=1:length(NoGoTS)   
   FramesB4Evnt=find(FramesTS<NoGoTS(i));
   if FramesB4Evnt>0
   if (FramesB4Evnt(end)<54000-(5*30+1)&FramesB4Evnt(end)>5*30+1)
   FirstFrameB4EvntIdx2(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
   end
end
NoGo=FirstFrameB4EvntIdx2;
else
NoGo=nan;
end

  -5.7916e+04
  -5.7917e+04

  -5.791651839999855--5.791680000000447
% Find Frames before HitsTones
HitTS=StateTransTS(find(statetrans.Id=='Hit'));
c=1;
if HitTS>0
for i=1:length(HitTS)  
   FramesB4Evnt=find(FramesTS<HitTS(i));
   if length(FramesB4Evnt)>1&(FramesB4Evnt(end)<54000-(5*30+1)&FramesB4Evnt(end)>5*30+1)
   FirstFrameB4EvntIdx3(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
Hit=FirstFrameB4EvntIdx3;
else
Hit=NaN;
end

% Find Frames before Miss Tones
MissTS=StateTransTS(find(statetrans.Id=='Miss'));
if MissTS>0
c=1;
for i=1:length(MissTS)
   FramesB4Evnt=find(FramesTS<MissTS(i));
   if (FramesB4Evnt(end)<54000-(5*30+1)&FramesB4Evnt(end)>5*30+1)
   FirstFrameB4EvntIdx4(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
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
   if (FramesB4Evnt(end)<54000-(5*30+1)&FramesB4Evnt(end)>5*30+1)
   FirstFrameB4EvntIdx5(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
CR=FirstFrameB4EvntIdx5;
else
CR=NaN;
end

if length(find(statetrans.Id=='Timeout'))==0
FATS=StateTransTS(find(statetrans.Id=='FalseAlarm'));
else length(find(statetrans.Id=='Timeout'))>0
FATS=StateTransTS(find(statetrans.Id=='Timeout'|statetrans.Id=='EarlyResponse'));
end
if length(FATS)>1
    c=1;
for i=1:length(FATS)
   FramesB4Evnt=find(FramesTS<FATS(i));
   if (FramesB4Evnt(end)<54000-(10*30+1)&FramesB4Evnt(end)>10*30+1)
   FirstFrameB4EvntIdx6(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
FA=FirstFrameB4EvntIdx6;
else
FA=NaN;
end



GoTS=StateTransTS((statetrans.Id=='Annotation')); 
c=1;
for i=1:length(GoTS)   

   FramesB4Evnt=find(FramesTS<GoTS(i));
   if length(FramesB4Evnt)>0
   if (FramesB4Evnt(end)<54000-(10*30+1)&FramesB4Evnt(end)>10*30+1)
   FirstFrameB4EvntIdx7(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
   end
end
if exist("FirstFrameB4EvntIdx7")~=0
ManReward=FirstFrameB4EvntIdx7;
end


%%
joystick1=GetBonsai_Pho_Joystick('JoystickTrace.csv');
joystick(:,2)=movmean((joystick1(:,3)),10);

JoyB4Frame=find(ismember(joystick1(:,2),FramesTS));
% JoyStickAtFrames=joystick(JoyB4Frame,2);
c=1;
for i=1:length(FramesTS)  
   FramesB4Evnt=find(joystick1(:,2)<FramesTS(i));
   if length(FramesB4Evnt)>0
   FirstFrameB4EvntIdx3(c)=FramesB4Evnt(end);
   c=c+1;  
   end
end
JoyStickAtFrames=joystick(FirstFrameB4EvntIdx3,2);


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
       [Xhit,yhit]=find(HitAtFrames(Go(i)-pre*30:Go(i)+post*30)==1);
    GoResponse(i)=1;

    if Xhit(1)<=(pre*30+2*30)
    GoResponse2Sec(i)=1;

       elseif Xhit(1)>(pre*30+2*30)
    GoResponse2Sec(i)=22;
       end
    elseif sum(HitAtFrames(Go(i)-pre*30:Go(i)+(post+.1)*30))<0;
    GoResponse(i)=2;
    GoResponse2Sec(i)=2;

    else
        GoResponse(i)=10;
        GoResponse2Sec(i)=10;

    end
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
post=3;
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


if length(NoGo)>0
dp=dprime(length(Hit)/length(Go),length(FA)/length(NoGo));
else
dp=nan
end


if length(Go)>1
Go=Go(find(GoResponse2Sec~=10));
NoGo=NoGo(find(NoGoResponse~=10));
GoResponse2Sec=GoResponse2Sec(find(GoResponse2Sec~=10));
GoResponse=GoResponse(find(GoResponse2Sec~=10));
else
GoResponse2Sec=nan;
GoResponse=nan;
end

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



joysticktrace=joystick1(:,2);
Hitidx=StateTransTS((statetrans.Id=='Hit'));
[count,v]=histcounts(joystickAthit);
[num,idxMax]=max(count);
HitLeverThres=v(idxMax);

HitTrace(1:length(joysticktrace))=0;
HitTrace(FirstFrameB4EvntIdx5)=1;

% HitLeverThres=30;
GoodPress(1:4000)=0;
for i=4001:length(joysticktrace)-1000

    if joysticktrace(i-1)<HitLeverThres&joysticktrace(i)>=HitLeverThres-10&max(joysticktrace(i-2000:i-100))<10&max(HitTrace(i-500:i+500))<1&max(GoodPress(i-500:i-1))==0
        GoodPress(i)=1;
    else
        GoodPress(i)=0;

    end
end

for i=4001:length(joysticktrace)

    if max(joysticktrace(i-2000:i))<10
        PressReady(i)=1;
    else
       PressReady(i)=0;

    end
end


% Find Frames before HitsTones
PressTS=joystick1(find(GoodPress==1),1);
if length(PressTS)>1

c=1;
for i=1:length(PressTS)  
   FramesB4Evnt=find(FramesTS<PressTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx8(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
NoRewardPresses=FirstFrameB4EvntIdx8;
else
NoRewardPresses=nan;
end

if length(NoGo)>1
Response=zeros(54000,1);
Response(Go)=GoResponse;
Response(NoGo)=NoGoResponse;
TrialWindow=10
clearvars dPRollin10T
for i=1:length(Response)
    AllNextResponses=find(Response>0);
    AllResponsesBeforeI=find(AllNextResponses<i);
    if length(AllResponsesBeforeI)<TrialWindow
        dPRollinOT(i)=0;
    else
     window=(AllNextResponses(AllResponsesBeforeI(length(AllResponsesBeforeI)-(TrialWindow-1)))-2:i);
    dPRollin10T(i)=dprime(length(find(Response(window)==1))/length(find(Response(window)==1|Response(window)==2)),length(find(Response(window)==4))/length(find(Response(window)==3|Response(window)==4)));
    end
end


dPRollinX=dPRollin10T(Response>0)
GoResponseDp=dPRollin10T(Response==1|Response==2);
NoGoResponseDp=dPRollin10T(Response==3|Response==4);
else
    GoResponseDp=[];
    NoGoResponseDp=[];
end
%%

% HitTS=StateTransTS((statetrans.Id=='Hit'));
% c=1;
% for i=1:length(HitTS)   
% 
%    FramesB4Evnt5=find(joystick1(:,1)<HitTS(i));
%    if FramesB4Evnt>0
%    FirstFrameB4EvntIdx5(c)=FramesB4Evnt5(end);
%    Good(i)=1;
%    c=c+1;
%    else
%    Good(i)=0;
%    continue   
% 
%    end
% end
% joystickAthit=joystick1(FirstFrameB4EvntIdx5,2);
% 
% 
% Hitidx=StateTransTS((statetrans.Id=='Hit'));
% [count,v]=histcounts(joystickAthit);
% [num,idxMax]=max(count);
% HitLeverThres=v(idxMax);
% 
% joysticktrace=joystick1(:,2);
% 
% HitTrace(1:length(joysticktrace))=0;
% HitTrace(FirstFrameB4EvntIdx5)=1;
% 
% % HitLeverThres=30;
% for i=4001:length(joysticktrace)-500
% 
%     if joysticktrace(i-1)<HitLeverThres&joysticktrace(i)>=HitLeverThres&max(joysticktrace(i-2000:i-100))<10&max(HitTrace(i-500:i+500))<1
%         GoodPress(i)=1;
%     else
%         GoodPress(i)=0;
% 
%     end
% end


% Find Frames before HitsTones
% PressTS=joystick1(find(GoodPress==1),1);
% c=1;
% for i=1:length(PressTS)  
%    FramesB4Evnt=find(FramesTS<PressTS(i));
%    if FramesB4Evnt>0
%    FirstFrameB4EvntIdx6(c)=FramesB4Evnt(end);
%    c=c+1;
%    else
%    continue
%    end
% end
% NoRewardPresses=FirstFrameB4EvntIdx6;
% 
% else
%     Go=nan;
%     NoGo=nan;
%     GoResponse=nan;
%     NoGoResponse=nan;
%     Hit=nan;
%     Miss=nan;
%     CR=nan;
%     FA=nan;
%     JoyStickAtFrames=nan;
%     LickAtFrames=nan;
%     LickTS=nan;
%     FirstLick=nan;
%     NoRewardPresses=nan;


