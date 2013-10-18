function batchSleepAnalysis
%BATCHSLEEPANALYSIS Summary of this function goes here
%   Detailed explanation goes here

addpath('sleepAnalysis');

%% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'SwedishEnergyAgency2012','SummerWinterCroppedDaysimeterDataCDF');
indexFile = fullfile(projectDir,'SummerWinterBedWakeTimes.txt');
% Import bed and wake times
[subject,season,day,wakeTime,bedTime] = importBedWakeTimes(indexFile);
% Scan folder for CDF files
CDFListing = dir(fullfile(projectDir,'*.cdf'));

%% Preallocate variables
nFiles = length(CDFListing); % Number of files
nDays = length(day); % Anticipated number of days
out = dataset;
% Preallocate subject and session data
out.Subject = cell(nDays,1);
out.Season = cell(nDays,1);
out.Day = cell(nDays,1);
% Preallocate sleep parameters
out.SleepStart = cell(nDays,1);
out.SleepEnd = cell(nDays,1);
out.ActualSleep = cell(nDays,1);
out.ActualSleepPercent = cell(nDays,1);
out.ActualWake = cell(nDays,1);
out.ActualWakePercent = cell(nDays,1);
out.SleepEfficiency = cell(nDays,1);
out.Latency = cell(nDays,1);
out.SleepBouts = cell(nDays,1);
out.WakeBouts = cell(nDays,1);
out.MeanSleepBout = cell(nDays,1);
out.MeanWakeBout = cell(nDays,1);

%%
i3 = 1; % Initialize independent counter
for i1 = 1:nFiles % Begining of main loop
    % Decompose the file name
    tokens = regexpi(CDFListing(i1).name,'Subject(\d\d)(\w)\.cdf','tokens');
    curSubject = str2double(tokens{1}{1});
    curSeason = str2double(regexprep(regexprep(tokens{1}{2},...
        'S','2','ignorecase'),'W','1','ignorecase'));
    % Find matching entries from bed wake time table
    idx1 = subject == curSubject & season == curSeason;
    if max(idx1) == 0 % Skip the file if it does not match any entries
        continue;
    end
    % Import the contents of the file
    data = ProcessCDF(fullfile(projectDir,CDFListing(i1).name));
    %% Analyze the file
    tempDay = day(idx1);
    tempWakeTime = wakeTime(idx1);
    tempBedTime = bedTime(idx1);
    for i2 = 1:length(tempDay) % Begin secondary loop
        out.Subject{i3} = curSubject;
        out.Season{i3} = curSeason;
        out.Day{i3} = tempDay(i2);
        try
            [tempSleepStart,tempSleepEnd,...
                out.ActualSleep{i3},out.ActualSleepPercent{i3},...
                out.ActualWake{i3},out.ActualWakePercent{i3},...
                out.SleepEfficiency{i3},out.Latency{i3},...
                out.SleepBouts{i3},out.WakeBouts{i3},...
                out.MeanSleepBout{i3},out.MeanWakeBout{i3}] = ...
                CalcSleepParams(data.Variables.Activity,...
                data.Variables.Time,tempBedTime(i2),tempWakeTime(i2));
            out.SleepStart{i3} = datestr(tempSleepStart,...
                'dd-mmm-yyyy HH:MM:SS');
            out.SleepEnd{i3} = datestr(tempSleepEnd,...
                'dd-mmm-yyyy HH:MM:SS');
        catch err
            display(err.message);
        end
        i3 = i3 + 1; % Increment independent counter
    end % End secondary loop
    
end % End of main loop

%% Save output
saveMat = fullfile(projectDir,'SleepAnalysis.mat');
save(saveMat,'out');
saveExcel = fullfile(projectDir,'SleepAnalysis.xlsx');
xlswrite(saveExcel,dataset2cell(out));

end

