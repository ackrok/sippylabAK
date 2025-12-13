
function  [CorrectBlinks,WrongBlinks] = Get_Bonsai_WrongBlinks (filename)

statetrans=GetBonsai_StateTransitions(filename);
StateTransTS=table2array(statetrans(:,3));
FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));
% Find Frames before Go Tones
GoTS=StateTransTS((statetrans.Id=='Go'));
if length(FrameTSdouble)<=208001

% if length(FrameTSdouble)<=108000
WrongBlinks=[];
AllBlinks=[];
CorrectBlinks=[1:length(FrameTSdouble)];
else
for i=1:length(GoTS)   

   FramesB4Evnt=find(FramesTS<GoTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx(i)=FramesB4Evnt(end);
      NextBlinks{i}=FrameTSdouble(find(FrameTSdouble>GoTS(i)-.25&FrameTSdouble<GoTS(i)+.25));
       idxNextBlinks{i}=find(FrameTSdouble>GoTS(i)-0.25&FrameTSdouble<GoTS(i)+.25);

   else
   continue
   end
end
Go=FirstFrameB4EvntIdx;


NoGoTS=StateTransTS((statetrans.Id=='NoGo'));
if length(NoGoTS)>1
    clearvars NextBlinks
for i=1:length(NoGoTS)
   FramesB4Evnt=find(FramesTS<NoGoTS(i));
   if FramesB4Evnt>0
   FirstFrameB4EvntIdx2(i)=FramesB4Evnt(end);
   NextBlinks{i}=FrameTSdouble(find(FrameTSdouble>NoGoTS(i)-.25&FrameTSdouble<NoGoTS(i)+.25));
   end
end
NoGo=FirstFrameB4EvntIdx2;
else
NoGo=NaN;
end

c=1;
for i=1:length(NextBlinks)
diffNextBlinks=diff(NextBlinks{i});


TSdif=find(diffNextBlinks>0.0320);
steps=max(diff(TSdif));
if steps==3|steps==5
    BadBlinks(i)=1
elseif steps==4|steps==6
    BadBlinks(i)=2
elseif steps==2
    BadBlinks(i)=0
elseif length(NextBlinks(i))<5&length(cell2mat(NextBlinks(i)))>0
    if length(NextBlinks(i))==0
    BadBlinks(i)=NaN
    elseif length(cell2mat(NextBlinks(i)))==1
    BadBlinks(i)=5
    elseif length(cell2mat(NextBlinks(i)))==2
    BadBlinks(i)=6
    end
elseif length(cell2mat(NextBlinks(i)))==0
    BadBlinks(i)=nan;
end


if BadBlinks(i)==2
    idx=cell2mat(idxNextBlinks(i));
        [v,in]=min(diffNextBlinks);
    Zerolag=in+1;
    SortOutBlinks([c,c+1])=idx([Zerolag(1)-1,Zerolag(1)]);
    c=c+2;
elseif  BadBlinks(i)==1
    idx=cell2mat(idxNextBlinks(i));
    SortOutBlinks([c])=idx(TSdif(find(diff(TSdif)>2)+1)+1);
    c=c+1;
elseif  BadBlinks(i)==5
    idx=cell2mat(idxNextBlinks(i));
    SortOutBlinks([c])=idx(end);
    c=c+1;
elseif  BadBlinks(i)==6
    idx=cell2mat(idxNextBlinks(i));
    SortOutBlinks([c,c+1])=idx(end-1:end);
    c=c+2;
end
% plot(diffNextBlinks)
% pause
% clf
end

WrongBlinks=SortOutBlinks;
AllBlinks=1:length(FrameTSdouble);
CorrectBlinks=setdiff(AllBlinks,WrongBlinks);
end