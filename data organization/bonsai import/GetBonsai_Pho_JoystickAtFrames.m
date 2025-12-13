
function [JoyStickAtFrames]=GetBonsai_Pho_JoystickAtFrames(FramesTS)
joystick1=GetBonsai_Pho_Joystick('JoystickTrace.csv');

joystick1(:,3)=movmean((joystick1(:,3)),10);
[x,idxU]=unique(joystick1(:,2));
joystick1uniqe=joystick1(idxU,:);
joystick1uniqe(find(isnan(joystick1uniqe(:,2))),2)=1;
JoyStickAtFrames=interp1(joystick1uniqe(:,2),joystick1uniqe(:,3),FramesTS,'nearest');