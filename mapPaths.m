function [Dirs,Files] = mapPaths
%MAPPATHS Summary of this function goes here
%   Detailed explanation goes here

% Map folders
Dirs = struct;

Dirs.project	= '\\root\projects\SwedishEnergyAgency2012\SummerWinterCroppedDaysimeterDataCDF';
Dirs.logs       = fullfile(Dirs.project,'logs');
Dirs.raw        = fullfile(Dirs.project,'rawData');
Dirs.original	= fullfile(Dirs.project,'originalData');
Dirs.edited     = fullfile(Dirs.project,'editedData');
Dirs.plots      = fullfile(Dirs.project,'plots');
Dirs.results	= fullfile(Dirs.project,'results');

% Map files
Files = struct;

Files.logs      = struct;
Files.raw       = struct;
Files.original	= struct;
Files.edited	= struct;

% Map log files
Files.logs.bed = fullfile(Dirs.logs,'SummerWinterBedWakeTimes.txt');
Files.logs.raw = fullfile(Dirs.logs,'rawDataIndex.csv');
Files.logs.original = fullfile(Dirs.logs,'originalDataIndex.mat');
Files.logs.edited = fullfile(Dirs.logs,'editedDataIndex.mat');

% Map data files and file details
% Raw data files
if exist(Files.logs.raw,'file') == 2 %file exists
    Files.raw = rawDataInventory(Dirs.raw,Files.logs.raw);
end
% Original data files
if exist(Files.logs.original,'file') == 2 %file exists
    TempOriginal = load(Files.logs.original);
    Files.original = TempOriginal.index;
end
% Edited data files
if exist(Files.logs.edited,'file') == 2 %file exists
    TempEdited = load(Files.logs.edited);
    Files.edited = TempEdited.index;
end

end

