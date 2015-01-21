function data = prepCDF(time,red,green,blue,activity,illuminance,CLA,CS,deviceModel,deviceSN,subjectID)
%PREPCDF Summary of this function goes here
%   Detailed explanation goes here

%% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);
import daysimeter12.*
import shared.*

%% Set the creationDate
creationDate = datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF');

%% Convert time
if isDST(time(1))
    offset = 2; % CEST (UTC +2 hours)
else
    offset = 1; % CET (UTC +1 hour)
end
absTime = absolutetime(time,'datenum',false,offset,'hours');

%% Look up calibration
switch deviceModel
    case 'daysimeter12'
        calibrationFile = '\\root\projects\DaysimeterAndDimesimeterReferenceFiles\data\Day12 RGB Values.txt';
        id = str2double(deviceSN(end-2:end));
    case 'dimesimeter'
        calibrationFile = '\\root\projects\DaysimeterAndDimesimeterReferenceFiles\data\RGB Calibration Values.txt';
        id = str2double(deviceSN);
    otherwise
        error('Unknown deviceModel.');
end

[IDcal,Rcal,Gcal,Bcal] = importCalibration(calibrationFile);

idx = id == IDcal;

redCalibration      = Rcal(idx);
greenCalibration	= Gcal(idx);
blueCalibration     = Bcal(idx);

%% Allocate Variables
Variables = struct(...
    'time',             absTime.localCdfEpoch(:),...
    'timeOffset',       absTime.offset.seconds(1),...
    'logicalArray',     [],...
    'red',              red(:),...
    'green',            green(:),...
    'blue',             blue(:),...
    'illuminance',      illuminance(:),...
    'CLA',              CLA(:),...
    'CS',               CS(:),...
    'activity',         activity(:),...
    'complianceArray',  [],...
    'bedArray',         []);

%% Allocate GlobalAttributes
GlobalAttributes = struct(...
    'creationDate',         creationDate,...
    'deviceModel',          deviceModel,...
    'deviceSN',             deviceSN,...
    'redCalibration',       redCalibration,...
    'greenCalibration',     greenCalibration,...
    'blueCalibration',      blueCalibration,...
    'subjectID',            subjectID,...
    'subjectSex',           'None',...
    'subjectDateOfBirth',   'None',...
    'subjectMass',          0);

%% Allocate VariableAttributes
attributeStruct = struct(...
    'description',      '',...
    'unitPrefix',       '',...
    'baseUnit',         '',...
    'unitType',         '',...
    'otherAttributes',  '');

variableNames	= fieldnames(Variables);
attributeNames	= fieldnames(attributeStruct);

nVariable	= numel(variableNames);
nAttribute	= numel(attributeNames);

VariableAttributes = struct;
% Assign variable name to each attribute.
for iVariable = 1:nVariable
    thisVariable = variableNames{iVariable};
    VariableAttributes.(thisVariable) = attributeStruct;
    for iAttribute = 1:nAttribute
        thisAttribute = attributeNames{iAttribute};
        VariableAttributes.(thisVariable).(thisAttribute) = thisVariable;
    end
end

%% Combine sub-structs
data = struct(...
    'Variables',            Variables,...
    'GlobalAttributes',     GlobalAttributes,...
    'VariableAttributes',   VariableAttributes);

end

