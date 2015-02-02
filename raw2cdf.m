function raw2cdf
%RAW2CDF Summary of this function goes here
%   Detailed explanation goes here

% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);
import daysimeter12.*

% Map directories and paths
[Dirs,Files] = mapPaths;

% Create template for new index of files
index = struct;
index.winter = struct('file',{''},'subject',{''});
index.summer = struct('file',{''},'subject',{''});

% Winter
nWinter = numel(Files.raw.winter.file1);
for iWinter = 1:nWinter
    newFilePath = conversion(Files.raw.winter,iWinter,Dirs.original);
    index.winter.file{iWinter,1} = newFilePath;
    index.winter.subject{iWinter,1} = num2str(OldFileDetails.subject(iWinter));
end

% Summer
nSummer = numel(Files.raw.summer.file1);
for iSummer = 1:nSummer
    newFilePath = conversion(Files.raw.winter,iSummer,Dirs.original);
    index.winter.file{iSummer,1} = newFilePath;
    index.winter.subject{iSummer,1} = num2str(OldFileDetails.subject(iSummer));
end


% Save the new index of files
save(Files.logs.original,'index');

end

function cdfPath = conversion(OldFileDetails,iFile,newDir)
file1 = OldFileDetails.file1{iFile};
file2 = OldFileDetails.file2{iFile};
subjectID = num2str(OldFileDetails.subject(iFile));
format = OldFileDetails.format{iFile};

switch format
    case 'FormatA'
        [time,red,green,blue,activity,illuminance,CLA,CS,deviceSN] = importFormatA(file1,file2);
        deviceModel = '';
    case 'FormatB'
        [time,red,green,blue,activity,illuminance,CLA,CS,deviceSN] = importFormatB(file1);
        deviceModel = '';
    case 'FormatC'
        [time,red,green,blue,activity,illuminance,CLA,CS,deviceSN] = importFormatC(file1);
        deviceModel = '';
    otherwise
        error('Unknown format.');
end

data = prepCDF(time,red,green,blue,activity,illuminance,CLA,CS,...
    deviceModel,deviceSN,subjectID);
cdfName = [num2str(deviceSN(end-3:end)),'-',datestr(now,'yyyy-mm-dd-HH-MM-SS'),'.cdf'];
cdfPath = fullfile(newDir,cdfName);
writecdf(data,cdfPath);

end

function [time,red,green,blue,activity,illuminance,CLA,CS,deviceSN] = importFormatA(log_info_filename,data_log_filename)
[time,Lux,CLA,Activity] = calibrateAndPlotDay12Function(log_info_filename,data_log_filename);
time = time';
Lux = Lux';
CLA = CLA';
Activity = Activity';
end

function [time,red,green,blue,activity,illuminance,CLA,CS,deviceSN] = importFormatB(fileName)
fileName = [fileListInfo{loop,1},fileListInfo{loop,2}]
[time,timeExcel,Lux,CLA,CS,Activity] = textread(fileName,'%f%f%f%f%f%f','headerlines',1);
time = timeExcel + 693960; % convert from Excel time format to Matlab time format
IDsave(loop) = str2num(fileListInfo{loop,6});
end

function [time,red,green,blue,activity,illuminance,CLA,CS,deviceSN] = importFormatC(fileName)
fileName = [fileListInfo{loop,1} fileListInfo{loop,2}]
[dateStr,timeStr,Lux,CLA,CS,Activity] = textread(fileName,'%s%s%f%f%f%f','headerlines',1);
time = datenum(dateStr)+mod(datenum(timeStr),1);
IDsave(loop) = str2num(fileListInfo{loop,6});
end

