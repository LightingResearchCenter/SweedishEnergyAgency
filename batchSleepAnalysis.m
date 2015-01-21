function batchSleepAnalysis
%BATCHSLEEPANALYSIS Summary of this function goes here
%   Detailed explanation goes here

% Find full path to github directory
[githubDir,~,~] = fileparts(pwd);
circadian = fullfile(githubDir,'circadian');
addpath(circadian)
import daysimeter12.*;
import reports.daysigram.*

%% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'SwedishEnergyAgency2012','SummerWinterCroppedDaysimeterDataCDF');
indexFile = fullfile(projectDir,'SummerWinterBedWakeTimes.txt');
plotsDir = fullfile(projectDir,'plots');
% Import bed and wake times
[subject,season,day,wakeTime,bedTime] = importBedWakeTimes(indexFile);
% Scan folder for CDF files
CDFListing = dir(fullfile(projectDir,'*.cdf'));

%% Preallocate variables
nFiles = length(CDFListing); % Number of files

templateCell = cell(nFiles,1);

Output = dataset;
Output.subject                  = templateCell;
Output.season                   = templateCell;
Output.nightsAveraged           = templateCell;
Output.actualSleepTimeMins      = templateCell;
Output.actualSleepPercent       = templateCell;
Output.actualWakeTimeMins       = templateCell;
Output.actualWakePercent        = templateCell;
Output.sleepEfficiency          = templateCell;
Output.sleepOnsetLatencyMins	= templateCell;
Output.sleepBouts               = templateCell;
Output.wakeBouts                = templateCell;
Output.meanSleepBoutTimeMins	= templateCell;
Output.meanWakeBoutTimeMins     = templateCell;

%%
nowStr = datestr(now,'yyyy-mm-dd_HHMM');
saveMat = fullfile(projectDir,['SleepAnalysis_',nowStr,'.mat']);
save(saveMat,'Output');
saveExcel = fullfile(projectDir,['SleepAnalysis_',nowStr,'.xlsx']);

%%
for i1 = 1:nFiles % Begining of main loop
    % Decompose the file name
    tokens = regexpi(CDFListing(i1).name,'Subject(\d\d)(\w)\.cdf','tokens');
    curSubjectStr = tokens{1}{1};
    curSubject = str2double(tokens{1}{1});
    curSeasonStr = tokens{1}{2};
    curSeason = str2double(regexprep(regexprep(tokens{1}{2},...
        'S','2','ignorecase'),'W','1','ignorecase'));
    % Find matching entries from bed wake time table
    idx1 = subject == curSubject & season == curSeason;
    if max(idx1) == 0 % Skip the file if it does not match any entries
        continue;
    end
    
    Output.subject{i1} = curSubject;
    Output.season{i1} = curSeasonStr;

    % Import the contents of the file
    filePath = fullfile(projectDir,CDFListing(i1).name);
    cdfData = daysimeter12.readcdf(filePath);
    % Convert the time to custom time classes
    absTime = absolutetime(cdfData.Variables.Time(:),'cdfepoch',false,1,'hours');
    relTime = relativetime(absTime);
    % Find the most frequent sampling rate.
    epochSeconds = round(mean(diff(relTime.seconds)));
    % Create a samplingrate object called epoch.
    epoch = samplingrate(epochSeconds,'seconds');
    
    % Rename variables
    activity = cdfData.Variables.Activity(:);
    cs = cdfData.Variables.CS(:);
    
    %% Analyze the file
    tempWakeTime = wakeTime(idx1);
    tempBedTime = bedTime(idx1);
    
    temp = true(size(absTime.localDateNum));
    observation = temp;
    compliance = temp;
    bed = false(size(absTime.localDateNum));
    for iBed = 1:numel(tempBedTime)
        tempBed = absTime.localDateNum >= tempBedTime(iBed) & absTime.localDateNum < tempWakeTime(iBed);
        bed  = bed | tempBed;
    end
    masks = eventmasks('observation',observation,'compliance',compliance,'bed',bed);
    
    % Sleep Analysis
    [Sleep,nIntervalsAveraged] = sleepprep(absTime.localDateNum,activity,epoch,...
        tempBedTime,tempWakeTime,compliance,curSubjectStr,curSeasonStr,saveExcel);
    
    %% Create Daysigram
    sheetTitle = ['Swedish Energy Agency, Subject: ',curSubjectStr,' ',curSeasonStr];
    fileID = [curSubjectStr,curSeasonStr];
    reports.daysigram.daysigram(sheetTitle,absTime.localDateNum,masks,activity,cs,'cs',[0,1],10,plotsDir,fileID);
    
    %% Assign output
    %   sleep
    Output.nightsAveraged{i1,1}         = nIntervalsAveraged;
    Output.actualSleepTimeMins{i1,1}    = Sleep.actualSleepTime;
    Output.actualSleepPercent{i1,1}     = Sleep.actualSleepPercent;
    Output.actualWakeTimeMins{i1,1}     = Sleep.actualWakeTime;
    Output.actualWakePercent{i1,1}      = Sleep.actualWakePercent;
    Output.sleepEfficiency{i1,1}        = Sleep.sleepEfficiency;
    Output.sleepOnsetLatencyMins{i1,1}  = Sleep.sleepLatency;
    Output.sleepBouts{i1,1}             = Sleep.sleepBouts;
    Output.wakeBouts{i1,1}              = Sleep.wakeBouts;
    Output.meanSleepBoutTimeMins{i1,1}  = Sleep.meanSleepBoutTime;
    Output.meanWakeBoutTimeMins{i1,1}   = Sleep.meanWakeBoutTime;
    
end % End of main loop

%% Save output
outputCell = dataset2cell(Output);
varNameArray = outputCell(1,:);
prettyVarNameArray = lower(regexprep(varNameArray,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell(1,:) = prettyVarNameArray;

xlswrite(saveExcel,outputCell,1);

end

function [Sleep,nIntervalsAveraged] = sleepprep(time,activity,epoch,bedTimeArray,riseTimeArray,complianceArray,subject,season,saveExcel)

import sleep.*;

time(~complianceArray) = [];
activity(~complianceArray) = [];

analysisStartTimeArray = bedTimeArray  - 20/(60*24);
analysisEndTimeArray   = riseTimeArray + 20/(60*24);

nIntervals = numel(bedTimeArray);
dailySleep = cell(nIntervals,1);
    
for i1 = 1:nIntervals
    % Perform analysis
    try
        dailySleep{i1} = sleep(time,activity,epoch,...
        analysisStartTimeArray(i1),analysisEndTimeArray(i1),...
        bedTimeArray(i1),riseTimeArray(i1),'auto');
    catch err
        display(err.message);
        continue
    end
end

% Average results
[Sleep,nIntervalsAveraged] = averageanalysis(dailySleep);

%% Save output
flatParam = cat(1,dailySleep{:});
varNames = fieldnames(flatParam)';
tempCell = struct2cell(flatParam)';
prettyVarNameArray = lower(regexprep(varNames,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell = [prettyVarNameArray;tempCell];

xlswrite(saveExcel,outputCell,['sub',subject,season]);

end

function [param,nIntervalsAveraged] = averageanalysis(dailyParam)
%AVERAGEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

% Unnest parameters
flatParam = cat(1,dailyParam{:});
varNames = fieldnames(flatParam)';
tempCell = struct2cell(flatParam)';

% Remove empty rows
emptyIdx = cellfun(@isempty,tempCell);
emptyRow = any(emptyIdx,2);
tempCell1 = tempCell(~emptyRow,:);

% Separate numeric parameters
idx1 = cellfun(@isnumeric,tempCell1);
idx2 = ~any(~idx1,1);
varNames2 = varNames(idx2);
tempCell2 = tempCell1(:,idx2);

% Average numeric parameters
tempMat = cell2mat(tempCell2);
tempMat2 = mean(tempMat,1);

% Create structure for output
tempCell3 = num2cell(tempMat2);
param = cell2struct(tempCell3,varNames2,2);

% Intervals averaged
nIntervalsAveraged = size(tempMat,1);

end