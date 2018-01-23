function batchAnalysis
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here


% Enable dependecies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);
import daysimeter12.*
import reports.daysigram.*
import reports.composite.*

% Map paths
[Dirs,Files] = mapPaths;
nowStr = datestr(now,'yyyy-mm-dd_HHMM');
sleepExcel = fullfile(Dirs.results,['SleepAnalysisNightly_',nowStr,'.xlsx']);
analysisExcel = fullfile(Dirs.results,['AnalysisSummary_',nowStr,'.xlsx']);

% Import bed and wake times
BedLog = struct;
[BedLog.subject,BedLog.season,BedLog.day,BedLog.riseTime,BedLog.bedTime] = importBedWakeTimes(Files.logs.bed);

% Loop through seasons
output = struct;

approvedSubjects = {'3';'4';'9';'10';'11';'13';'14';'15';'16';'17';'21'};

seasons = fieldnames(Files.edited);
nSeasons = numel(seasons);
for iSeason = 1:nSeasons
    thisSeason = seasons{iSeason};
    output.(thisSeason) = struct;
    
    % Loop through files
    nSub = numel(approvedSubjects);
    cellTemplate = cell(nSub,1);
    output.(thisSeason).subject = cellTemplate;
    
    output.(thisSeason).wakingArimeanCs = cellTemplate;
    output.(thisSeason).wakingGeomeanCs = cellTemplate;
    output.(thisSeason).wakingMedianCs = cellTemplate;
    
    output.(thisSeason).wakingArimeanCla = cellTemplate;
    output.(thisSeason).wakingGeomeanCla = cellTemplate;
    output.(thisSeason).wakingMedianCla = cellTemplate;
    
    output.(thisSeason).wakingArimeanLux = cellTemplate;
    output.(thisSeason).wakingGeomeanLux = cellTemplate;
    output.(thisSeason).wakingMedianLux = cellTemplate;
    
    output.(thisSeason).wakingArimeanAi = cellTemplate;
    output.(thisSeason).wakingGeomeanAi = cellTemplate;
    output.(thisSeason).wakingMedianAi = cellTemplate;
    
    output.(thisSeason).daysInPhasor = cellTemplate;
    output.(thisSeason).phasorMagnitude = cellTemplate;
    output.(thisSeason).phasorAngleHours = cellTemplate;
    
    output.(thisSeason).daysInIsiv = cellTemplate;
    output.(thisSeason).IS = cellTemplate;
    output.(thisSeason).IV = cellTemplate;
    
    output.(thisSeason).nightsAveraged = cellTemplate;
    output.(thisSeason).actualSleepDurationMinutes = cellTemplate;
    output.(thisSeason).sleepEfficiency = cellTemplate;
    output.(thisSeason).sleepOnsetLatencyMinutes = cellTemplate;
    
    
    for iSub = 1:nSub
        thisSubject = approvedSubjects{iSub};
        iFile = strcmpi(thisSubject,Files.edited.(thisSeason).subject);
        thisFile    = Files.edited.(thisSeason).file{iFile};
        thisLog = selectlog(BedLog,thisSubject,thisSeason);
        
        % Analysis
        [Session,Data,Phasor,Actigraphy,Miller,Average,SleepParam,nIntervalsAveraged] = analysis(thisFile,thisLog,thisSeason,sleepExcel);
        
        output.(thisSeason).subject{iSub} = thisSubject;
        
        output.(thisSeason).wakingArimeanCs{iSub} = Average.cs.arithmeticMean;
        output.(thisSeason).wakingGeomeanCs{iSub} = Average.cs.geometricMean;
        output.(thisSeason).wakingMedianCs{iSub} = Average.cs.median;
        
        output.(thisSeason).wakingArimeanCla{iSub} = Average.cla.arithmeticMean;
        output.(thisSeason).wakingGeomeanCla{iSub} = Average.cla.geometricMean;
        output.(thisSeason).wakingMedianCla{iSub} = Average.cla.median;
        
        output.(thisSeason).wakingArimeanLux{iSub} = Average.illuminance.arithmeticMean;
        output.(thisSeason).wakingGeomeanLux{iSub} = Average.illuminance.geometricMean;
        output.(thisSeason).wakingMedianLux{iSub} = Average.illuminance.median;
        
        output.(thisSeason).wakingArimeanAi{iSub} = Average.activity.arithmeticMean;
        output.(thisSeason).wakingGeomeanAi{iSub} = Average.activity.geometricMean;
        output.(thisSeason).wakingMedianAi{iSub} = Average.activity.median;
        
        output.(thisSeason).daysInPhasor{iSub} = Phasor.nDays;
        output.(thisSeason).phasorMagnitude{iSub} = Phasor.magnitude;
        output.(thisSeason).phasorAngleHours{iSub} = Phasor.angle.hours;
        
        output.(thisSeason).daysInIsiv{iSub} = Actigraphy.nDays;
        output.(thisSeason).IS{iSub} = Actigraphy.interdailyStability;
        output.(thisSeason).IV{iSub} = Actigraphy.intradailyVariability;
        
        output.(thisSeason).nightsAveraged{iSub} = nIntervalsAveraged;
        output.(thisSeason).actualSleepDurationMinutes{iSub} = SleepParam.actualSleepTime;
        output.(thisSeason).sleepEfficiency{iSub} = SleepParam.sleepEfficiency;
        output.(thisSeason).sleepOnsetLatencyMinutes{iSub} = SleepParam.sleepLatency;
        
        % Reports
        reports(Session,Data,Phasor,Actigraphy,Miller,Average,Dirs.plots);
    end
    
    % Make varNames pretty
    uglyVarNames = fieldnames(output.(thisSeason));
    varNames = lower(regexprep(uglyVarNames,'([^A-Z])([A-Z])','$1 $2'));
    tempOutputCell{iSeason} = dataset2cell(struct2dataset(output.(thisSeason)));
    for i2 = 1:numel(varNames)
        tempOutputCell{iSeason}{1,i2} = varNames{i2};
    end
    outputWidth = size(tempOutputCell{1},2);
    bufferCell{iSeason} = cell(3,outputWidth);
    bufferCell{iSeason}{end,1} = upper(thisSeason);
end

outputCell = [bufferCell{1};...
              tempOutputCell{1};...
              bufferCell{2};...
              tempOutputCell{2}];
xlswrite(analysisExcel,outputCell);

close all;

end

%% ANALYSIS
function [Session,Data,Phasor,Actigraphy,Miller,Average,SleepParam,nIntervalsAveraged] = analysis(thisFile,thisLog,thisSeason,sleepExcel)
%ANALYSIS

cdfData = daysimeter12.readcdf(thisFile);
[absTime,relTime,epoch,light,activity,masks,subjectID,deviceID] = daysimeter12.convertcdf(cdfData);

Session = struct;
Session.season = thisSeason;
Session.subject = subjectID;
Session.deviceID = deviceID;

Data = struct;
Data.absTime = absTime;
Data.relTime = relTime;
Data.epoch = epoch;
Data.light = light;
Data.activity = activity;
Data.masks = masks;

Phasor = phasor.prep(absTime,epoch,light,activity,masks);

Actigraphy = isiv.prep(absTime,epoch,activity,masks);

Miller = struct('time',[],'cs',[],'activity',[]);
[          ~,Miller.cs] = millerize.millerize(relTime,light.cs,masks);
[Miller.time,Miller.activity] = millerize.millerize(relTime,activity,masks);

Average = reports.composite.daysimeteraverages(light,activity,masks);

[SleepParam,nIntervalsAveraged] = sleepprep(absTime,activity,epoch,thisLog,masks,subjectID,thisSeason,sleepExcel);

end

%% REPORTS
function reports(Session,Data,Phasor,Actigraphy,Miller,Average,plotDir)
%REPORTS

subjectID = Session.subject;
paddedSub = num2str(str2double(subjectID),'%02.2i');
deviceID = Session.deviceID;
season = Session.season;

% Composite Report
compositeTitle = 'Swedish Energy Agency - Seasonal Study';
compositeID = [paddedSub,season];
reports.composite.compositeReport(plotDir,Phasor,Actigraphy,Average,Miller,compositeID,deviceID,compositeTitle);
clf;


% Daysigram
masks = Data.masks;
time = Data.absTime.localDateNum;

startTime = min(time(masks.observation));
stopTime  = max(time(masks.observation));

displayStart= floor(startTime);
displayStop	= ceil( stopTime );
displayIdx	= time > displayStart & time < displayStop;

time                = time(displayIdx);
masks.observation	= masks.observation(displayIdx);
masks.compliance	= masks.compliance(displayIdx);
masks.bed           = masks.bed(displayIdx);
cs                  = Data.light.cs(displayIdx);
activity            = Data.activity(displayIdx);

daysigramTitle = {'Swedish Energy Agency - Seasonal Study';...
                 ['Subject ',subjectID,'  ',season]};
daysigramID = ['subject',paddedSub,season,'_deviceID',deviceID];
reports.daysigram.daysigram(2,daysigramTitle,time,masks,activity,cs,'cs',[0 1],10,plotDir,daysigramID);
clf;
end

%% SELECTLOG
function thisLog = selectlog(BedLog,thisSubject,thisSeason)
%SELECTLOG Finds the bed log given a subject and season
%   Returns structure of arrays of datenums
subjectNum = str2double(thisSubject);
switch thisSeason
    case 'winter'
        seasonNum = 1;
    case 'summer'
        seasonNum = 2;
    otherwise
        error('Unkown season')
end

% Match file to bed log
logIdx = BedLog.subject == subjectNum & BedLog.season == seasonNum;
% Skip files with no crop log
if sum(logIdx) == 0
    warning(['Subject ',subjectID,' ',season,' file missing bed log and will be skipped.']);
else
    bedTimeArray = BedLog.bedTime(logIdx);
    riseTimeArray = BedLog.riseTime(logIdx);
end

thisLog = struct;
thisLog.bed = bedTimeArray(:);
thisLog.rise = riseTimeArray(:);

end

%% SLEEPPREP
function [SleepParam,nIntervalsAveraged] = sleepprep(absTime,activity,epoch,thisLog,masks,subject,season,saveExcel)
%SLEEPPREP
% 

time = absTime.localDateNum;
bedTimeArray = thisLog.bed;
riseTimeArray = thisLog.rise;

time = time(masks.compliance & masks.observation);
activity = activity(masks.compliance & masks.observation);

analysisStartTimeArray = bedTimeArray  - 20/(60*24);
analysisEndTimeArray   = riseTimeArray + 20/(60*24);

nIntervals = numel(bedTimeArray);
dailySleep = cell(nIntervals,1);
    
for i1 = 1:nIntervals
    % Perform analysis
    if bedTimeArray(i1) >= min(time) && riseTimeArray(i1) <= max(time)
        if any(time >= bedTimeArray(i1) & time <= riseTimeArray(i1))
            dailySleep{i1} = sleep.sleep(time,activity,epoch,...
            analysisStartTimeArray(i1),analysisEndTimeArray(i1),...
            bedTimeArray(i1),riseTimeArray(i1),'auto');
        end
    end
end


% Save output
flatParam = cat(1,dailySleep{:});
if ~isempty(flatParam)
    % Average results
    [SleepParam,nIntervalsAveraged] = averageanalysis(dailySleep);
    
    varNames = fieldnames(flatParam)';
    tempCell = struct2cell(flatParam)';
    prettyVarNameArray = lower(regexprep(varNames,'([^A-Z])([A-Z0-9])','$1 $2'));
    outputCell = [prettyVarNameArray;tempCell];
    
    xlswrite(saveExcel,outputCell,['sub',subject,season]);
else
    SleepParam = struct;
    SleepParam.sleepEfficiency = [];
    SleepParam.sleepLatency = [];
    nIntervalsAveraged = 0;
end

end

%% AVERAGEANALYSIS
function [param,nIntervalsAveraged] = averageanalysis(dailyParam)
%AVERAGEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

% Unnest parameters
flatParam = cat(1,dailyParam{:});
if ~isempty(flatParam)
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
    if ~isempty(tempCell3)
        param = cell2struct(tempCell3,varNames2,2);
        % Intervals averaged
        nIntervalsAveraged = size(tempMat,1);
    else
        param = struct;
        for iVar = 1:numel(varNames2);
            param.(varNames2{iVar}) = [];
        end
        nIntervalsAveraged = 0;
    end
else
    param = [];
    nIntervalsAveraged = 0;
end

end