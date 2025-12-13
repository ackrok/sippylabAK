
function [Reward,JoyStickAtFrames,LickAtFrames,LickTS,FirstLick] =Get_2P_Frames_At_BonsaiEventsHabit()

% Find Sync Timestamps
filename='StateTransitions.csv';
statetrans=GetBonsai_StateTransitions(filename);
StateTransTS=table2array(statetrans(:,3));
FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));


 
% FramesTS=FramesTS1(find(DiffFrameTS<0.020)+1)

% Find Frames before Go Tones
RewardTS=StateTransTS((statetrans.Id=='Annotation'));
c=1;
for i=1:length(RewardTS)   

   FramesB4Evnt=find(FramesTS<RewardTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx(c)=FramesB4Evnt(end);
   c=c+1;
   else
   continue
   end
end
Reward=FirstFrameB4EvntIdx;



joystick=GetBonsai_Joystick('JoystickTrace.csv');
joystick(2:end,2)=movmean(diff(joystick(:,2)),200)*10;

JoyB4Frame=find(ismember(joystick(:,1),FramesTS));
JoyStickAtFrames=joystick(JoyB4Frame,2);
    
licktrace=GetBonsai_LickTrace('LickTrace.csv');
licktrace(:,2)=movmean(licktrace(:,2),2);
LickB4Frame=find(ismember(licktrace(:,1),FramesTS));
LickAtFrames=movmean(licktrace(LickB4Frame,2),3);

[v,i]=histcounts(LickAtFrames)
[val,pos]=max(v)
Base=(i(pos))

LickAtFrames=LickAtFrames-Base;

Threshold=0.01;
for i=1:length(LickAtFrames)-1
    if LickAtFrames(i)<=Threshold&LickAtFrames(i+1)>Threshold
        Lick(i)=1;
    else
        Lick(i)=0;
    end
end

LickTS=find(Lick==1);
c=1;

for i=1:length(RewardTS)   

   FramesB4Evnt2=find(LickTS>Reward(i));
   if FramesB4Evnt2>0
   FirstFrameB4EvntIdx2(c)=FramesB4Evnt2(1);
   c=c+1;
   else
   continue
   end
end
FirstLick=LickTS(FirstFrameB4EvntIdx2);

y(1:length(FirstLick))=0.01;

yy(1:length(Reward))=0.01;
plot(LickAtFrames)
hold on
plot(FirstLick,y,'*r')
plot(Reward,yy,'*g')
