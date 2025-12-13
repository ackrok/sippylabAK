
function [AllBonsaiGoNoGoVariables2p]=GetBonsai_AllGoNoGo2p()

statetrans=GetBonsai_StateTransitions('StateTransitions.csv');

Frames=(find(statetrans.Id=='Blink'))/2;
StateTransTS=table2array(statetrans(:,3));

FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));
S1.FramesTS=FramesTS;

GoTS=StateTransTS((statetrans.Id=='Go'));

for i=1:length(GoTS)
    
   if find(FramesTS<GoTS(i))>0
   FramesB4Evnt=find(FramesTS<GoTS(i));
   FirstFrameB4EvntIdx(i)=FramesB4Evnt(end);
   else
       continue
   end
end
S1.TS1a=FirstFrameB4EvntIdx;

NoGoTS=StateTransTS((statetrans.Id=='NoGo'));

for i=1:length(NoGoTS)
    
    if find(FramesTS<NoGoTS(i))>0
   FramesB4Evnt=find(FramesTS<NoGoTS(i));
   FirstFrameB4EvntIdx2(i)=FramesB4Evnt(end);
    else
        continue
    end
end
S1.TS2a=FirstFrameB4EvntIdx2;

HitTS=StateTransTS(find(statetrans.Id=='Hit'));

for i=1:length(HitTS)
    if find(FramesTS<HitTS(i))>0
   FramesB4Evnt=find(FramesTS<HitTS(i));
   FirstFrameB4EvntIdx3(i)=FramesB4Evnt(end);
    else
        continue
    end
end
S1.TS3a=FirstFrameB4EvntIdx3;




joystick=GetBonsai_Joystick('JoystickTrace.csv');
% joystick(2:end,2)=movmean(diff(joystick(:,2)),200)*10;

JoyB4Frame=find(ismember(joystick(:,1),FramesTS));
S1.JoyStickAtFramesA=joystick(JoyB4Frame,2);
    
licktrace=GetBonsai_LickTrace('LickTrace.csv');
licktrace(:,2)=movmean(licktrace(:,2),200)*10;

LickB4Frame=find(ismember(licktrace(:,1),FramesTS));
S1.LickAtFramesA=licktrace(LickB4Frame,2);

%% Find Correct responses based on new criteria
pre=2;
post=2;

GoTS1=S1.TS1a;
for i= 1:length(GoTS1)

if GoTS1(i)+post*30<size(S1.JoyStickAtFramesA,1)&GoTS1(i)-pre*30+1>0

LeverMatrix1(i,:)=S1.JoyStickAtFramesA(GoTS1(i)-pre*30:GoTS1(i)+post*30);

end
end

GoTS1=S1.TS2a;
for i= 1:length(GoTS1)

if GoTS1(i)+post*30<size(S1.JoyStickAtFramesA,1)&GoTS1(i)-pre*30+1>0

LeverMatrix2(i,:)=S1.JoyStickAtFramesA(GoTS1(i)-pre*30:GoTS1(i)+post*30);

end
end

S1.CorrectFastGoA=(max(LeverMatrix1(:,60:75),[],2)>25);
S1.FalseNegA=(max(LeverMatrix1(:,60:120),[],2)<5);
S1.CorrectNoGoA=(max(LeverMatrix2(:,60:120),[],2)<5);
S1.FastFalsePosA=(max(LeverMatrix2(:,60:75),[],2)>15);



GoTS1=S1.TS2a;
pre=5;
post=5;
for i= 1:length(GoTS1)

if GoTS1(i)+post*30<size(S1.JoyStickAtFramesA,1)&GoTS1(i)-pre*30+1>0

LeverMatrix3(i,:)=S1.JoyStickAtFramesA(GoTS1(i)-pre*30:GoTS1(i)+post*30);

end
end
S1.Active1mA=(max(LeverMatrix3(:,:),[],2)>15);



GoTS1=S1.TS1a;
for i= 1:length(GoTS1)

if GoTS1(i)+post*30<size(S1.LickAtFramesA,1)&GoTS1(i)-pre*30+1>0

LickMatrix1A(i,:)=S1.LickAtFramesA(GoTS1(i)-pre*30:GoTS1(i)+post*30);

end
end
S1.LickMatrix1A=LickMatrix1A;

AllBonsaiGoNoGoVariables2p=S1