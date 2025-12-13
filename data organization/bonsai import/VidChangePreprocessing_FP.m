function [VidChange]=VidChangePreprocessing(signal);
% signal=Green1


numWorkers=18;
poolobj=gcp('nocreate');
if isempty (poolobj) 
    delete(gcp('nocreate'));
    parpool('local',numWorkers);
end


videoTS=GetBonsai_VidTimestampsFP('VidFrames.csv');
vidfile=dir("*.avi");
v = VideoReader(vidfile.name);
AllFrames=v.NumFrames;
Frames1=[1;(floor(AllFrames/4))];
Frames2=[(floor(AllFrames/4))+1;floor(AllFrames/2)];
Frames3=[(floor(AllFrames/2))+1;floor(AllFrames/2)+(floor(AllFrames/4))];
Frames4=[floor(AllFrames/2)+(floor(AllFrames/4))+1;AllFrames];
video = read(v,Frames1);

parfor (i=1:size(video,4),18)
Greyvid1(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video
video = read(v,Frames2);
parfor (i=1:size(video,4),18)
Greyvid2(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video 
video = read(v,Frames3);
parfor (i=1:size(video,4),18)
Greyvid3(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video 
video = read(v,Frames4);
parfor (i=1:size(video,4),18)
Greyvid4(:,:,i)=rgb2gray(video(:,:,:,i));
end
clearvars video v
Greyvid=cat(3,Greyvid1,Greyvid2,Greyvid3,Greyvid4);

clearvars Greyvid1 Greyvid2 Greyvid3 Greyvid4
FramesTS=signal(:,1);


parfor(i=1:length(FramesTS),18)
    if isempty(find(videoTS<FramesTS(i)))==true
   FirstFrameB4EvntIdx(i)=1;
    else
   FramesB4Evnt=find(videoTS<FramesTS(i));
   FirstFrameB4EvntIdx(i)=FramesB4Evnt(end);
    end
end

FirstFrameB4EvntIdx1=FirstFrameB4EvntIdx(FirstFrameB4EvntIdx<length(Greyvid));
VidAtFrame=Greyvid(:,:,FirstFrameB4EvntIdx1);
clearvars Greyvid
DiffGrevid=diff(VidAtFrame,1,3);
VidChange=movmean(squeeze(mean(mean(abs(DiffGrevid)))),10);

save('VidChange.mat','VidChange')
delete(gcp('nocreate'));
