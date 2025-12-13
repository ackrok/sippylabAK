function [VidChange]=VidChangePreprocessing();




videoTS=GetBonsai_VideoTimestamps('VideoTimestamps.csv');
vidfile=dir("*.avi");
v = VideoReader(vidfile.name);
AllFrames=v.NumFrames;
Frames1=[1;(floor(AllFrames/4))];
Frames2=[(floor(AllFrames/4))+1;floor(AllFrames/2)];
Frames3=[(floor(AllFrames/2))+1;floor(AllFrames/2)+(floor(AllFrames/4))];
Frames4=[floor(AllFrames/2)+(floor(AllFrames/4))+1;AllFrames];
video = read(v,Frames1);

parfor i=1:size(video,4)
Greyvid1(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video
video = read(v,Frames2);

parfor i=1:size(video,4)
Greyvid2(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video 
video = read(v,Frames3);
parfor i=1:size(video,4)
Greyvid3(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video 
video = read(v,Frames4);
parfor i=1:size(video,4)
Greyvid4(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video v
Greyvid=cat(3,Greyvid1,Greyvid2,Greyvid3,Greyvid4);


StatTransFile=dir('*StateTransitions*');
statetrans=GetBonsai_StateTransitions(StatTransFile.name);
% Att=Get_TextFile('HalfOctaveATT.txt');

Frames=(find(statetrans.Id=='Blink'))/2;
StateTransTS=table2array(statetrans(:,3));

FrameTSdouble=StateTransTS(statetrans.Id=='Blink');
FramesTS=FrameTSdouble(1:2:(length(FrameTSdouble)));


parfor(i=1:length(FramesTS),18)
    if isempty(find(videoTS<FramesTS(i)))==true
   FirstFrameB4EvntIdx(i)=1;
    else
   FramesB4Evnt=find(videoTS<FramesTS(i));
   FirstFrameB4EvntIdx(i)=FramesB4Evnt(end);
   i
    end
end
VidAtFrame=Greyvid(:,:,FirstFrameB4EvntIdx);

DiffGrevid=diff(VidAtFrame,1,3);
VidChange=movmean(squeeze(mean(mean(abs(DiffGrevid)))),10);
save('VidChange.mat','VidChange')
clearvars Greyvid
