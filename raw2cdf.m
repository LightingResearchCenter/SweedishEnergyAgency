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
    display('Winter');
    newFilePath = conversion(Files.raw.winter,iWinter,Dirs.original,'winter');
    index.winter.file{iWinter,1} = newFilePath;
    index.winter.subject{iWinter,1} = num2str(Files.raw.winter.subject(iWinter));
end

% Summer
nSummer = numel(Files.raw.summer.file1);
for iSummer = 1:nSummer
    display('Summer');
    newFilePath = conversion(Files.raw.summer,iSummer,Dirs.original,'summer');
    index.summer.file{iSummer,1} = newFilePath;
    index.summer.subject{iSummer,1} = num2str(Files.raw.summer.subject(iSummer));
end


% Save the new index of files
save(Files.logs.original,'index');

end

function cdfPath = conversion(OldFileDetails,iFile,newDir,season)
file1 = OldFileDetails.file1{iFile};
file2 = OldFileDetails.file2{iFile};
subjectID = num2str(OldFileDetails.subject(iFile));
format = OldFileDetails.format{iFile};

display(['Subject  ',num2str(subjectID)]);

switch format
    case 'FormatA'
        [time,red,green,blue,activity,illuminance,CLA,deviceSN] = importFormatA(file1,file2);
        deviceModel = 'daysimeter12';
    case 'FormatB'
        [time,red,green,blue,activity,illuminance,CLA,deviceSN] = importFormatB(file1);
        deviceModel = 'dimesimeter';
    case 'FormatC'
        [time,red,green,blue,activity,illuminance,CLA,deviceSN] = importFormatC(file1);
        deviceModel = 'dimesimeter';
    otherwise
        error('Unknown format.');
end

add6Hours = [1,3,4,9,10,11,13,14,15,19,21,22,25];
if ismember(OldFileDetails.subject(iFile),add6Hours) && strcmpi(season,'winter') || OldFileDetails.subject(iFile)==16 || OldFileDetails.subject(iFile)==17
%     time = time - 6/24; 
else
    time = time + 6/24; % Convert to Central European time (GMT+1) from Eastern time (GMT-5)
end

epochIndividual = diff(time)*24*60*60;
epoch30 = round(epochIndividual/30)*30;
epoch = mode(epoch30);

activity(activity>1) = 0.25;
activity = filter5min(activity,epoch);
CLA = filter5min(CLA,epoch);
CS = CSCalc_postBerlin_12Aug2011(CLA);

data = prepCDF(time,red,green,blue,activity,illuminance,CLA,CS,...
    deviceModel,deviceSN,subjectID);
cdfName = [num2str(deviceSN(end-3:end)),'-',datestr(now,'yyyy-mm-dd-HH-MM-SS'),'.cdf'];
cdfPath = fullfile(newDir,cdfName);
daysimeter12.writecdf(data,cdfPath);

end

function [time,red,green,blue,activity,illuminance,CLA,deviceSN] = importFormatA(log_info_filename,data_log_filename)
[time,red,green,blue,illuminance,CLA,activity,deviceSNnum] = importDaysimeter12(log_info_filename,data_log_filename);

time = time(:);
red = red(:);
green = green(:);
blue = blue(:);
activity = activity(:);
illuminance = illuminance(:);
CLA = CLA(:);

deviceSN = num2str(120000 + deviceSNnum);
end

function [time,red,green,blue,activity,illuminance,CLA,deviceSN] = importFormatB(filePath)
[~,timeExcel,illuminance,CLA,~,activity] = textread(filePath,'%f%f%f%f%f%f','headerlines',1);
time = timeExcel + 693960; % convert from Excel time format to Matlab time format

time = time(:);
activity = activity(:);
illuminance = illuminance(:);
CLA = CLA(:);

red = zeros(size(time));
green = red;
blue = red;

[~,fileName,~] = fileparts(filePath);
deviceSN = regexprep(fileName,'^\D*(\d\d\d).*','$1');

deviceSN = num2str(100000 + str2double(deviceSN));
deviceSN(1) = '0';

end

function [time,red,green,blue,activity,illuminance,CLA,deviceSN] = importFormatC(filePath)
[dateStr,timeStr,illuminance,CLA,~,activity] = textread(filePath,'%s%s%f%f%f%f','headerlines',1);
time = datenum(dateStr)+mod(datenum(timeStr),1);

time = time(:);
activity = activity(:);
illuminance = illuminance(:);
CLA = CLA(:);

red = zeros(size(time));
green = red;
blue = red;

deviceSN = '000000';
end

function data = filter5min(data,epoch)
%FILTER5MIN Lowpass filter data series with zero phase delay,
%   moving average window.
%   epoch = sampling epoch in seconds
minutes = 5; % length of filter (minutes)
Srate = 1/epoch; % sampling rate in hertz
windowSize = floor(minutes*60*Srate);
b = ones(1,windowSize)/windowSize;

if epoch <= 150
    data = filtfilt(b,1,data);
end

end