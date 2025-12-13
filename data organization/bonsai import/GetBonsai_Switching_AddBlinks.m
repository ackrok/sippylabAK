

function [Blinks_Idx_To_Add_To_Each_Block,skippy]= GetBonsai_Switching_AddBlinks()


% During Switching Experiments we run two seperate instances of Bonsai
% on two different harp behavior boxes. One box controls the behavior and
% we load new bonsai scripts to this box whenever we change from one block
% to another block. the problem is that this controler box cant keep track of
% how many frames the 2p collects in the brief moments in whch we load a
% new script to start the next block. To keep track of these forgotten frames, we run
% a second behavior box which stays active during the entire session. 
% This second box receives ttl pulses from the first box whenever
% behavior is running and ttl pulses from the 2p whenever a frame is
% recorded. This way we can keep track of recoreded frames that happen when
% the first box was off or on and then correct for this during analysis.

%FramesTSduringBehavior_analog=GetBonsai_LickTrace('FrameTS_during_Behavior.csv');
FramesTSduringBehavior_analog = GetBonsai_FrameTS_duringBehavior('FrameTS_during_Behavior.csv');
c=1
for i= 2:length(FramesTSduringBehavior_analog)
    if FramesTSduringBehavior_analog(i,3)>4.9&FramesTSduringBehavior_analog(i-1,3)<=4.9
        FramesTSduringBehavior(c)=FramesTSduringBehavior_analog(i,1);
        c=c+1;
    end
end

Behav_Blinks=FramesTSduringBehavior;

% find(diff(Behav_Blinks)>0.04&diff(Behav_Blinks)<0.08)
% histogram(diff(Behav_Blinks))

figure()
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,3));
% Find Frames before Go Tones
BlinkTS_double=StateTransTS((statetrans.Id=="Blink"));
BlinkTS=BlinkTS_double(1:2:end);
BlinkTSy(1:length(BlinkTS))=3;

Behav_BlinkTSy(1:length(Behav_Blinks))=3;

plot(FramesTSduringBehavior_analog(:,1),FramesTSduringBehavior_analog(:,3))
hold on
plot(BlinkTS,BlinkTSy,'*k')
plot(StateTransTS(1),3,'*r')
hold on
plot(Behav_Blinks,Behav_BlinkTSy,'*b')

BehavBlinks_plus_start(2:length(Behav_Blinks)+1)=Behav_Blinks;
BehavBlinks_plus_start(1)=BlinkTS(1);
BlockStart=BehavBlinks_plus_start(find(diff(BehavBlinks_plus_start)>0.5)+1);

BlockStartY(1:length(BlockStart))=3;

plot(BlockStart,BlockStartY,'*g')

Blinks_Idx_To_Add_To_Each_Block = find((any(abs(BlinkTS - BlockStart) <= 0.02, 2)));

% plot(BlinkTS(Blinks_Idx_To_Add_To_Each_Block),ones(6,1)+2,'*y')


idx=find(FramesTSduringBehavior_analog==Behav_Blinks( 7271  ))
%plot(FramesTSduringBehavior_analog(idx(1)-1000:idx(1)+1000,2))

xlim([FramesTSduringBehavior_analog(idx(1)-1000,1),FramesTSduringBehavior_analog(idx(1)+1000,1)])

idx=find(ismember(FramesTSduringBehavior_analog(:,1),Behav_Blinks(find(diff(Behav_Blinks)>0.04&diff(Behav_Blinks)<0.08))))

skippy=find(diff(Behav_Blinks)>0.04&diff(Behav_Blinks)<0.08)

