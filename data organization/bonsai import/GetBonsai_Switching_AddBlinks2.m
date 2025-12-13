function [Blinks_Idx_To_Add_To_Each_Block,BlinkTS,blocks]= GetBonsai_Switching_AddBlinks2()


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
        FramesTSduringBehavior(c)=FramesTSduringBehavior_analog(i,2);
        c=c+1;
    end
end

Behav_Blinks=FramesTSduringBehavior;

% find(diff(Behav_Blinks)>0.04&diff(Behav_Blinks)<0.08)
% histogram(diff(Behav_Blinks))

figure()
filename=dir('*StateTransitions.csv');
statetrans=GetBonsai_Pho_StateTransitions(filename.name);
StateTransTS=table2array(statetrans(:,4));
% Find Frames before Go Tones
BlinkTS_double=StateTransTS((statetrans.Id=="Blink"));
BlinkTS=BlinkTS_double(1:2:end);
BlinkTSy(1:length(BlinkTS))=3;

Behav_BlinkTSy(1:length(Behav_Blinks))=3;

plot(FramesTSduringBehavior_analog(:,2),FramesTSduringBehavior_analog(:,3))
hold on
plot(BlinkTS,BlinkTSy,'*k')
plot(StateTransTS(1),3,'*r')
hold on
plot(Behav_Blinks,Behav_BlinkTSy,'*b')

BehavBlinks_plus_start(2:length(Behav_Blinks)+1)=Behav_Blinks;
BehavBlinks_plus_start(1)=BlinkTS(1);
BlockStart=BehavBlinks_plus_start(find(diff(BehavBlinks_plus_start)>500)+1);

BlockStartY(1:length(BlockStart))=3;

plot(BlockStart,BlockStartY,'*g')

Blinks_Idx_To_Add_To_Each_Block = find((any(abs(BlinkTS - BlockStart) <= 20, 2)));

skippy=(find(diff(Behav_Blinks)>40&diff(Behav_Blinks)<80)+1);

for b = 1 : length(BlockStart)+1
    if b==1
 blocks{b}=Behav_Blinks(find(Behav_Blinks>1&Behav_Blinks<BlockStart(b)))

    elseif b>1&b<length(BlockStart)
blocks{b}=Behav_Blinks(find(Behav_Blinks>BlockStart(b-1)&Behav_Blinks<BlockStart(b)))
    else
blocks{b}=Behav_Blinks(find(Behav_Blinks>BlockStart(b-1)&Behav_Blinks<Behav_Blinks(end)))
    end     
end

% for b = 1 : length(BlockStart)
%     if b==1
% blocks{b}=Behav_Blinks(find(Behav_Blinks>BlockStart(b)&Behav_Blinks<BlockStart(b+1)))
%     else
% blocks{b}=Behav_Blinks(find(Behav_Blinks>BlockStart(b)&Behav_Blinks<Behav_Blinks(end)))
%     end     
% end
% block_3_length=length(find(Behav_Blinks>BlockStart(2)&Behav_Blinks<BlockStart(3)))
% block3=Behav_Blinks(find(Behav_Blinks>BlockStart(2)&Behav_Blinks<BlockStart(3)))
% plot(block3,ones(length(block3),1)+2,'*y') 
% block_0=block-block(1)
% FramesTS_0=FramesTS-FramesTS(1)

% figure()
% plot(block_0,ones(length(block_0),1)+2,'*r')
% hold on
% plot(FramesTS_0,ones(length(FramesTS_0),1)+2,'*b')
% 
% plot(block_0-FramesTS_0(1:length(block_0))')
% 
% 
% vector1_rep = repmat(block3_0', 1, length(FramesTS_0));
% vector2=FramesTS_0';
% % Create a matrix of differences between vector1_rep and vector2
% diff_matrix = abs(vector1_rep - vector2);
% 
% % Find the minimum difference for each column (corresponding to each element in vector1)
% [~, min_indices] = min(diff_matrix);
% 
% % Extract the closest numbers from vector2
% closest_numbers = vector2(min_indices)
