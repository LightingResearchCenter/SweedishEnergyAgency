function batchPhasor
%BATCHSLEEPANALYSIS Summary of this function goes here
%   Detailed explanation goes here

addpath('phasorAnalysis');

% Location = struct;
% Location.name = 'Stockholm, Sweeden';
% Location.latitude = 59.328930;
% Location.longitude = 18.064910;
% Location.gmtOffset = 1;

%% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'SwedishEnergyAgency2012','SummerWinterCroppedDaysimeterDataCDF');
indexFile = fullfile(projectDir,'SummerWinterBedWakeTimes.txt');
resultsDir = fullfile(projectDir,'results');
plotsDir = fullfile(projectDir,'phasorPlots');
% Scan folder for CDF files
cdfDir = projectDir;
cdfList = dir(fullfile(cdfDir,'*.cdf'));

% Import bed and wake times
BedLog = struct;
[BedLog.subject,BedLog.season,BedLog.day,BedLog.getupTime,BedLog.bedTime] = importBedWakeTimes(indexFile);

%% Preallocate output
nCDF = numel(cdfList);
output = struct;
output.subject = cell(nCDF,1);
output.season = cell(nCDF,1);
output.phasorMagnitude = cell(nCDF,1);
output.phasorAngle = cell(nCDF,1);
output.IS = cell(nCDF,1);
output.IV = cell(nCDF,1);
output.magnitudeWithHarmonics = cell(nCDF,1);
output.magnitudeFirstHarmonic = cell(nCDF,1);

% output.daytimeCS = cell(nCDF,1);
% output.daytimeLux = cell(nCDF,1);

%% Begin main loop
for i1 = 1:nCDF
    % Decompose the file name
    tokens = regexpi(cdfList(i1).name,'Subject(\d\d)(\w)\.cdf','tokens');
    subject = str2double(tokens{1}{1});
    season = str2double(regexprep(regexprep(tokens{1}{2},...
        'S','2','ignorecase'),'W','1','ignorecase'));
    
    output.subject{i1} = subject;
    if season == 1
        output.season{i1} = 'Winter';
    elseif season == 2
        output.season{i1} = 'Summer';
    else
        output.season{i1} = 'Unknown';
    end
    %% Load CDF
    data = ProcessCDF(fullfile(cdfDir,cdfList(i1).name));
    time = data.Variables.Time; % Adjust from Eastern to Mountain time
    CS = data.Variables.CS;
%     Lux = data.Variables.Lux;
    activity = data.Variables.Activity;
    
    %% Match file to bed log
    logIdx = BedLog.subject == subject & BedLog.season == season;
    % Skip files with no crop log
    if sum(logIdx) == 0
        continue;
    end
    bedTimeArray = BedLog.bedTime(logIdx);
    getupTimeArray = BedLog.getupTime(logIdx);
    
    [CS,activity] = replacebed(time,CS,activity,bedTimeArray,getupTimeArray);
    
    %% Perform analysis
    % Run phasor analysis
    [output.phasorMagnitude{i1},output.phasorAngle{i1},...
        output.IS{i1},output.IV{i1},...
        output.magnitudeWithHarmonics{i1},...
        output.magnitudeFirstHarmonic{i1}] =...
        phasorAnalysis(time,CS,activity);
    
    % Run daytime light analysis
%     [output.daytimeCS{i1},output.daytimeLux{i1}] =...
%         daytimeLight(time,CS,Lux,lat,lon,GMToff);
    
    %% Plot Data
    Title = ['Sweedish Energy Agency Subject ',num2str(subject),...
        ' ',output.season{i1}];
    PhasorReport(time,activity,CS,...
        output.phasorMagnitude{i1},output.phasorAngle{i1},...
        output.IS{i1},output.IV{i1},...
        output.magnitudeWithHarmonics{i1},...
        output.magnitudeFirstHarmonic{i1},Title);
    plotFile = fullfile(plotsDir,['subject',num2str(subject),output.season{i1},'.pdf']);
    saveas(gcf,plotFile);
    close all;
end

%% Save output
outputPath = fullfile(resultsDir,['phasor_',datestr(now,'yyyy-mm-dd_HH-MM')]);
save([outputPath,'.mat'],'output');

% Make varNames pretty
uglyVarNames = fieldnames(output);
varNames = regexprep(uglyVarNames,'([^A-Z])([A-Z])','$1 $2');
outputCell = dataset2cell(struct2dataset(output));
for i2 = 1:numel(varNames)
    outputCell{1,i2} = varNames{i2};
end
xlswrite([outputPath,'.xlsx'],outputCell);

close gcf

end

