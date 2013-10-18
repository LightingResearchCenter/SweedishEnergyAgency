function [Subject,Phase,ActualSleep,ActualSleepPercent,ActualWake,...
    ActualWakePercent,SleepEfficiency,Latency,SleepBouts,WakeBouts,...
    MeanSleepBout,MeanWakeBout] = AnalyzeFile(Time,Activity,BedTime,GetUpTime,Subject,Phase,Threshold,f)
Days = length(BedTime);

% Preallocate AnalysisStart and AnalysisEnd
AnalysisStart = zeros(Days,1);
AnalysisEnd = zeros(Days,1);

% Set AnalysisStart and AnalysisEnd for each day
for i = 1:Days
    AnalysisStart(i) = addtodate(BedTime(i),-3,'minute');
    AnalysisEnd(i) = addtodate(GetUpTime(i),3,'minute');
end

% Preallocate sleep parameters
SleepStart = zeros(Days,1);
SleepEnd = zeros(Days,1);
ActualSleep = zeros(Days,1);
ActualSleepPercent = zeros(Days,1);
ActualWake = zeros(Days,1);
ActualWakePercent = zeros(Days,1);
SleepEfficiency = zeros(Days,1);
Latency = zeros(Days,1);
SleepBouts = zeros(Days,1);
WakeBouts = zeros(Days,1);
MeanSleepBout = zeros(Days,1);
MeanWakeBout = zeros(Days,1);
% Call function to calculate sleep parameters for each day
for i = 1:Days
[SleepStart(i),SleepEnd(i),ActualSleep(i),ActualSleepPercent(i),...
    ActualWake(i),ActualWakePercent(i),SleepEfficiency(i),Latency(i),...
    SleepBouts(i),WakeBouts(i),MeanSleepBout(i),MeanWakeBout(i)] = ...
    CalcSleepParams(Activity,Time,AnalysisStart(i),AnalysisEnd(i),...
    BedTime(i),GetUpTime(i),Threshold,f);
end

end