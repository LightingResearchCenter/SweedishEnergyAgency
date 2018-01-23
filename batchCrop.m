function batchCrop
%BATCHCROP Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);
import daysimeter12.*

% Map paths
[Dirs,Files] = mapPaths;

% Import index of raw files
rawDataIndex = importRawIndex(Files.logs.raw);

% Import bed and wake times
BedLog = struct;
[BedLog.subject,BedLog.season,BedLog.day,BedLog.getupTime,BedLog.bedTime] = importBedWakeTimes(Files.logs.bed);

% Create template for new index of files
index = struct;
index.winter = struct('file',{''},'subject',{''});
index.summer = struct('file',{''},'subject',{''});

% Winter
nWinter = numel(Files.original.winter.file);
for iWinter = 1:nWinter
    thisFile    = Files.original.winter.file{iWinter};
    thisSubject = Files.original.winter.subject{iWinter};
    newFilePath = cropPrep(thisFile,Dirs.edited,'winter',thisSubject,rawDataIndex,BedLog);
    index.winter.file{iWinter,1} = newFilePath;
    index.winter.subject{iWinter,1} = thisSubject;
end

% Summer
nSummer = numel(Files.original.summer.file);
for iSummer = 1:nSummer
    thisFile    = Files.original.summer.file{iSummer};
    thisSubject = Files.original.summer.subject{iSummer};
    newFilePath = cropPrep(thisFile,Dirs.edited,'summer',thisSubject,rawDataIndex,BedLog);
    index.summer.file{iSummer,1} = newFilePath;
    index.summer.subject{iSummer,1} = thisSubject;
end

% Save the new index of files
save(Files.logs.edited,'index');

end


%% Sub-function
function newFilePath = cropPrep(cdfPath,saveDir,season,subjectID,rawDataIndex,BedLog)

subject = str2double(subjectID);
switch season
    case 'winter'
        seasonNum = 1;
    case 'summer'
        seasonNum = 2;
    otherwise
        error('Unkown season')
end

thisIndexLogical = strcmpi(season,rawDataIndex.season) & (subject == rawDataIndex.subject);
thisIndex = rawDataIndex(thisIndexLogical,:);

startTime = datenum(thisIndex.startDate);
stopTime  = datenum(thisIndex.stopDate );

% Match file to bed log
logIdx = BedLog.subject == subject & BedLog.season == seasonNum;
% Skip files with no crop log
if sum(logIdx) == 0
    warning(['Subject ',subjectID,' ',season,' file missing bed log and will be skipped.']);
    newFilePath = '';
else
    bedTimeArray = BedLog.bedTime(logIdx);
    getupTimeArray = BedLog.getupTime(logIdx);
    
    [~,fileName,~] = fileparts(cdfPath);
    newFilePath = fullfile(saveDir,[fileName,'.cdf']);
    
    customcrop(cdfPath,newFilePath,startTime,stopTime,bedTimeArray,getupTimeArray)
end

end