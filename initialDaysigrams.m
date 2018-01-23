function initialDaysigrams
%INITIALDAYSIGRAMS Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);
import daysimeter12.* reports.daysigram.*

% Map paths
[Dirs,Files] = mapPaths;

rawDataIndex = importRawIndex(Files.logs.raw);

% Winter
nWinter = numel(Files.original.winter.file);
for iWinter = 1:nWinter
    thisFile = Files.original.winter.file{iWinter};
    plotPrep(thisFile,Dirs.plots,'winter',rawDataIndex);
end

% Summer
nSummer = numel(Files.original.summer.file);
for iSummer = 1:nSummer
    thisFile = Files.original.summer.file{iSummer};
    plotPrep(thisFile,Dirs.plots,'summer',rawDataIndex);
end

end


%% Sub-function
function plotPrep(cdfPath,plotDir,season,rawDataIndex)
import daysimeter12.* reports.daysigram.*

cdfData = daysimeter12.readcdf(cdfPath);
[absTime,relTime,epoch,light,activity,masks,subjectID,deviceSN] = daysimeter12.convertcdf(cdfData);

thisIndexLogical = strcmpi(season,rawDataIndex.season) & (str2double(subjectID) == rawDataIndex.subject);
thisIndex = rawDataIndex(thisIndexLogical,:);

startTime = datenum(thisIndex.startDate);
stopTime  = datenum(thisIndex.stopDate );

displayStart= floor(startTime);
displayStop	= ceil( stopTime );
displayIdx	= absTime.localDateNum > displayStart & absTime.localDateNum < displayStop;

time = absTime.localDateNum(displayIdx);

maskTemplate = true(size(absTime.localDateNum));
masks.observation	=  time >= startTime & time <= stopTime;
masks.compliance	=  maskTemplate;
masks.bed           = ~maskTemplate;

cs = light.cs(displayIdx);
activity = activity(displayIdx);

sheetTitle = {'Swedish Energy Agency - Seasonal Study';...
              ['Subject ',subjectID,'  ',season]};
paddedSub = num2str(str2double(subjectID),'%02.2i');
fileID = [season,'_sub',paddedSub,'_sn',deviceSN];

reports.daysigram.daysigram(1,sheetTitle,time,masks,activity,cs,'cs',[0 1],10,plotDir,fileID);

end