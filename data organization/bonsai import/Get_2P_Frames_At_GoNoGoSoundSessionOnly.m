
function [Go,NoGo,FramesTS] =Get_2P_Frames_At_GoNoGoSoundSessionOnly()

% Find Sync Timestamps
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,3));
FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
[CorrectBlinks,WrongBlinks] =  Get_Bonsai_WrongBlinks  (filename.name);
FrameTSdouble=FrameTSdouble(CorrectBlinks);
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));

% Start=StateTransTS((statetrans.Id=='Go'|statetrans.Id=='NoGo')); 
% Stop=StateTransTS((statetrans.Id=='Hit'|statetrans.Id=='Miss'|statetrans.Id=='CR'|statetrans.Id=='FA')); 
% 
% SStart=Start(find(Start>FramesTS(5*31)));
% SStart(1);
% 
% SStop=Stop(find(Stop<FramesTS(length(FramesTS)-5*31)));
% SStop(end);
% 
% statetrans=statetrans(find(StateTransTS>SStart(1)&StateTransTS<SStop(end)),:);
% StateTransTS=table2array(statetrans(:,3));

% Find Frames before Go Tones
GoTS=StateTransTS((statetrans.Id=='Go')); 
c=1;
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

