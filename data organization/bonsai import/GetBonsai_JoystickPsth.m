
function [TrialsBinedP,TrialsBinedSmoothP]=GetBonsai_JoystickPosPsth(Pre,Post,Bin,EventName)

joystick=ImportBonsaiJoystick('JoystickTrace.csv'); %Import Joystick Traces

statetrans=ImportBonsaiStateTransitions('StateTransitions.csv'); % Import State Transition file

RecOnset=joystick(1,1); % Find timing of recording Onset
joystick(:,1)=joystick(:,1)-RecOnset; % Align joystick timestamps to recording onsret
StateTransTS=table2array(statetrans(:,3))-RecOnset; %get event timestamps amnd align it to recording onset


%%Event 1
IdxOfEventsFromStateTrans1=find(statetrans.Id==E); % find Event of Interest Onset in Statetrans File
TSofEventOnset1=StateTransTS(IdxOfEventsFromStateTrans1); % find corresponding Timestamps


IdxofEventsinJoystickFileDouble=find(ismember(joystick(:,1),TSofEventOnset1)); % find the joystick timestamps that match the event timestamps
EventOnset=IdxofEventsinJoystickFileDouble(1:2:end); %joystick timestamps appear to be dublicated, take only first of each


joystickMovment=diff(joystick(:,2));

SR=1000; %Sample Rate of recording in samples per S
% Pre= 2  % Time to cut out before Event onset in S
% Post=2  % Time to cut out after Event onset in S
% Bin=.01  % Binsize

for i = 1: length(EventOnset)
    
    if EventOnset(i)-(Pre*SR)+1>0&EventOnset(i)+Post*SR<length(joystickMovment)
    Trials(:,i)= joystickMovment(EventOnset(i)-(Pre*SR)+1:EventOnset(i)+Post*SR);
    TrialsP(:,i)= joystick(EventOnset(i)-(Pre*SR)+1:EventOnset(i)+Post*SR,2);
    TrialComplete(i)=1;
    else
    TrialComplete(i)=0; 
    end
end

TrialsBined=abs(squeeze(mean(reshape(Trials,Bin*SR,size(Trials,1)/(Bin*SR),size(Trials,2))))); %Bin Data
TrialsBinedP=abs(squeeze(mean(reshape(TrialsP,Bin*SR,size(Trials,1)/(Bin*SR),size(Trials,2))))); %Bin Data

for i=1:size(TrialsBined,2)
TrialsBinedSmooth(i,:)=smoothdata(TrialsBined(:,i),'gaussian',2); % Smooth Data
TrialsBinedSmoothP(i,:)=smoothdata(TrialsBinedP(:,i),'gaussian',2); % Smooth Data

end

% figure()
% hold on
% imagesc(TrialsBinedSmooth,[0,.2])
% hold on
% xticklabels = -Pre:5:Post;
% xticks = linspace(1, size(TrialsBinedSmooth, 2), numel(xticklabels));
% set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
% hold on
% plot([Pre/Bin Pre/Bin],[size(Trials,2) 0],'LineWidth',2,'LineStyle','--','Color',[1 1 1])
% set(gca,'FontSize',15);
% set(gca,'LineWidth',3);
% ylabel('Stim. Trials')
% axis tight
% hold on
% 
% box off
