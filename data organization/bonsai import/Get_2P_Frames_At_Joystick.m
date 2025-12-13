
function [JoyStickAtFrames] =Get_2P_Frames_At_Joystick()
%function [Hit,JoyStickAtFrames,LickAtFrames,LickTS,FirstLick,NoRewardPresses] =Get_2P_Frames_At_BonsaiEventsPretraining()

% Find Sync Timestamps
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,3));
FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));


joystick1=GetBonsai_Joystick('JoystickTrace.csv');
joystick(:,2)=movmean((joystick1(:,2)),200);

JoyB4Frame=find(ismember(joystick1(:,1),FramesTS));
JoyStickAtFrames=joystick(JoyB4Frame,2);
    
end


