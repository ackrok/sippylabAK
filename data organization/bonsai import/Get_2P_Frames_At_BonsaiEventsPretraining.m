
function [Hit,JoyStickAtFrames,LickAtFrames,LickTS,FirstLick,NoRewardPresses] =Get_2P_Frames_At_BonsaiEventsPretraining()
%function [Hit,JoyStickAtFrames,LickAtFrames,LickTS,FirstLick,NoRewardPresses] =Get_2P_Frames_At_BonsaiEventsPretraining()

% Find Sync Timestamps
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,3));
FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));

if FramesTS>0

    % FramesTS=FramesTS1(find(DiffFrameTS<0.020)+1)

    % Find Frames before Go Tones
    HitTS=StateTransTS((statetrans.Id=='Hit'));
    c=1;
    for i=1:length(HitTS)

        FramesB4Evnt=find(FramesTS<HitTS(i));
        if FramesB4Evnt>0
            FirstFrameB4EvntIdx(c)=FramesB4Evnt(end);
            Good(i)=1;
            c=c+1;
        else
            Good(i)=0;
            continue

        end
    end
    Hit=FirstFrameB4EvntIdx;
    HitTS=HitTS(Good==1);


    joystick1=GetBonsai_Joystick('JoystickTrace.csv');
    joystick(:,2)=movmean((joystick1(:,2)),200);

    JoyB4Frame=find(ismember(joystick1(:,1),FramesTS));
    % JoyStickAtFrames=joystick(JoyB4Frame,2);

    c=1;
    for i=1:length(FramesTS)
        FramesB4Evnt=find(joystick1(:,1)<FramesTS(i));
        if length(FramesB4Evnt)>0

            FirstFrameB4EvntIdx3(c)=FramesB4Evnt(end);
            c=c+1;
        end
    end
    JoyStickAtFrames=joystick(FirstFrameB4EvntIdx3,2);



    licktrace=GetBonsai_LickTrace('LickTrace.csv');
    licktrace(:,2)=movmean(licktrace(:,2),2);
    LickB4Frame=find(ismember(licktrace(:,1),FramesTS));
    LickAtFrames=movmean(licktrace(LickB4Frame,2),3);

    [v,i]=histcounts(LickAtFrames);
    [val,pos]=max(v);
    Base=(i(pos));

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
    FirstFrameB4EvntIdx2=[];
    for i=1:length(HitTS)

        FramesB4Evnt2=find(LickTS>Hit(i));
        if FramesB4Evnt2>0
            FirstFrameB4EvntIdx2(c)=FramesB4Evnt2(1);
            c=c+1;
        else
            continue
        end
    end
    if length(FirstFrameB4EvntIdx2)>0
        FirstLick=LickTS(FirstFrameB4EvntIdx2);
    else
        FirstLick=nan;
    end


    HitTS=StateTransTS((statetrans.Id=='Hit'));
    c=1;
    for i=1:length(HitTS)

        FramesB4Evnt3=find(joystick1(:,1)<HitTS(i));
        if FramesB4Evnt>0
            FirstFrameB4EvntIdx3(c)=FramesB4Evnt3(end);
            Good(i)=1;
            c=c+1;
        else
            Good(i)=0;
            continue

        end
    end
    joystickAthit=joystick1(FirstFrameB4EvntIdx3,2);


    Hitidx=StateTransTS((statetrans.Id=='Hit'));
    [count,v]=histcounts(joystickAthit);
    [num,idxMax]=max(count);
    HitLeverThres=v(idxMax);

    joysticktrace=joystick1(:,2);

    for i=2001:length(joysticktrace)

        if joysticktrace(i-1)<HitLeverThres&joysticktrace(i)>=HitLeverThres&max(joysticktrace(i-500:i))<10
            GoodPress(i)=1;
        else
            GoodPress(i)=0;
        end
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


    Hitidx=StateTransTS((statetrans.Id=='Hit'));
    [count,v]=histcounts(joystickAthit);
    [num,idxMax]=max(count);
    HitLeverThres=v(idxMax);

    joysticktrace=joystick1(:,2);

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

else



    % Hit=nan;
    % JoyStickAtFrames=nan;
    % LickAtFrames=nan;
    % LickTS=nan;
    % FirstLick=nan;
    % NoRewardPresses=nan;
end


%
% t=0:0.033333:53999*0.0333333
% plot(t,JoyStickAtFrames)
% hold on
% HitY(1:length(Hit))=HitLeverThres;
% plot(Hit*0.03333,HitY,'|g')
% NoRPY(1:length(NoRewardPresses))=HitLeverThres;
% plot(NoRewardPresses*0.03333,NoRPY,'*r')
% plot(t,PressReady(JoyB4Frame))
