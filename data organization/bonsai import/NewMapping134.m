
function [NewCellid]=NewMapping134();

MatchFileName=dir('*MatchFile.mat')
load(MatchFileName.name)

Session1=1;
Session2=3;
Session3=4;

Session1c=roiMatchData.mapping(:,Session1);
Session2c=roiMatchData.mapping(:,Session2);
Session3c=roiMatchData.mapping(:,Session3);

idx=roiMatchData.rois{1,1}.cellCount+roiMatchData.rois{1,2}.cellCount+1:length(roiMatchData.mapping);

for c=idx
       if roiMatchData.mapping(c,Session1)~=0&roiMatchData.mapping(c,Session2)~=0
Session2c(c)=roiMatchData.mapping(c,Session1);
end
end

[value,NonMatchCells1idx]=intersect(Session2c(idx),roiMatchData.mapping(idx,Session2))

counter=roiMatchData.rois{1,1}.cellCount+1;
for c=1:length(NonMatchCells1idx)
Session2c(idx(NonMatchCells1idx(c)))=counter;
counter=counter+1;
end

idx2=roiMatchData.rois{1,1}.cellCount+roiMatchData.rois{1,2}.cellCount++roiMatchData.rois{1,3}.cellCount+1:length(roiMatchData.mapping);

for c=idx2
       if roiMatchData.mapping(c,Session1)~=0&roiMatchData.mapping(c,Session3)~=0
Session3c(c)=roiMatchData.mapping(c,Session1);
end
end

for c=idx2
       if roiMatchData.mapping(c,Session2)~=0&roiMatchData.mapping(c,Session3)~=0
Session3c(c)=roiMatchData.mapping(c,Session2);
end
end

[value,NonMatchCells2idx]=intersect(Session3c(idx2),roiMatchData.mapping(idx2,Session3));

counter=max(Session2c)+1;
for c=1:length(NonMatchCells2idx)
Session3c(idx2(NonMatchCells2idx(c)))=counter;
counter=counter+1;
end
NewCellid{1}=Session1c(1:roiMatchData.rois{1,1}.cellCount);
NewCellid{2}=Session2c(roiMatchData.rois{1,1}.cellCount+roiMatchData.rois{1,2}.cellCount+1:roiMatchData.rois{1,1}.cellCount+roiMatchData.rois{1,2}.cellCount+roiMatchData.rois{1,3}.cellCount);
NewCellid{3}=Session3c(roiMatchData.rois{1,1}.cellCount+roiMatchData.rois{1,2}.cellCount+roiMatchData.rois{1,3}.cellCount:length(roiMatchData.mapping));
end