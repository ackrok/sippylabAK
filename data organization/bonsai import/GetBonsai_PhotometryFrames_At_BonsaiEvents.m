
function [Go,NoGo,GoResponse,NoGoResponse,Hit,Miss,CR,FA,FramesTS,JoyStickAtFrames,LickAtFrames,ManReward] =GetBonsai_PhotometryFrames_At_BonsaiEvents(FramesTS)

% FramesTS=Green1(:,1);
% Find Sync Timestamps
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_Pho_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,4));


% Find Frames before Go Tones
GoTS=StateTransTS((statetrans.Id=='Go'));
if length(GoTS)>0
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
else
    Go=NaN;
end

% Find Frames before NoGo Tones
NoGoTS=StateTransTS((statetrans.Id=='NoGo'));
c=1;
if length(NoGoTS)>1
    for i=3:length(NoGoTS)
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
if length(HitTS)>0

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
else
    Hit=NaN;
end
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
CRTS(isnan(CRTS))=CRTS(end-1);

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

FATS=StateTransTS(find(statetrans.Id=='FalseAlarm'));
if length(FATS)>1
    c=1;
    for i=2:length(FATS)
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
else
    ManReward=[];
end

joystick1=GetBonsai_Pho_Joystick('JoystickTrace.csv');
joystick1(:,3)=movmean((joystick1(:,3)),10);

licktrace=GetBonsai_Pho_LickTrace('LickTrace.csv');
licktrace(:,3)=movmean(licktrace(:,3),200)*10;

% tic
% c=1
% for i=1:length(FramesTS)
% FramesB4EvntJ=find(joystick1(:,2)<FramesTS(i));
% FramesB4EvntL=find(licktrace(:,2)<FramesTS(i));
% 
%     if FramesB4EvntJ>0
%         FirstFrameB4EvntIdxJoy(c)=FramesB4EvntJ(end);
%         FirstFrameB4EvntIdxLick(c)=FramesB4EvntL(end);
% 
%         c=c+1;
%     else
%         continue
%     end
% end
% toc
% JoyB4Frame=find(ismember(round(joystick1(:,2),0),round(FramesTS,0)));
% unique(joystick1(JoyB4Frame,2))
% JoyStickAtFrames=joystick(FirstFrameB4EvntIdxJoy,2);
[x,idxU]=unique(joystick1(:,2));
joystick1uniqe=joystick1(idxU,:);
joystick1uniqe(find(isnan(joystick1uniqe(:,2))),2)=1;
JoyStickAtFrames=interp1(joystick1uniqe(:,2),joystick1uniqe(:,3),FramesTS,'nearest');

[x,idxU]=unique(licktrace(:,2));
licktraceuniqe=licktrace(idxU,:);
licktraceuniqe(find(isnan(licktraceuniqe(:,2))),2)=1;

LickAtFrames=interp1(licktraceuniqe(:,2),licktraceuniqe(:,3),FramesTS,'nearest');

% licktrace1=round(licktrace(:,2),0);
% LickB4Frame=find(ismember(licktrace1,FramesTS));
% LickAtFrames=licktrace(FirstFrameB4EvntIdxLick,2);
% LickAtFrames=NaN;

HitAtFrames=zeros(54000,1);
HitAtFrames(Hit(find(Hit>1)))=1;
if Miss>0;
    HitAtFrames(Miss(find(Miss>1)))=-1;
end

pre=1;
post=11;
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
    post=11;
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

% %%
% 
% HitTS=StateTransTS((statetrans.Id=='Hit'));
% c=1;
% for i=1:length(HitTS)
% 
%     FramesB4Evnt5=find(joystick1(:,1)<HitTS(i));
%     if FramesB4Evnt>0
%         FirstFrameB4EvntIdx5(c)=FramesB4Evnt5(end);
%         Good(i)=1;
%         c=c+1;
%     else
%         Good(i)=0;
%         continue
% 
%     end
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
% 
% 
% % Find Frames before HitsTones
% PressTS=joystick1(find(GoodPress==1),1);
% c=1;
% if PressTS>1
% 
%     for i=1:length(PressTS)
%         FramesB4Evnt=find(FramesTS<PressTS(i));
%         if FramesB4Evnt>0
%             FirstFrameB4EvntIdx6(c)=FramesB4Evnt(end);
%             c=c+1;
%         else
%             continue
%         end
%     end
%     NoRewardPresses=FirstFrameB4EvntIdx6;
% else
%     NoRewardPresses=NaN;
% end
