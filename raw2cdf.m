function raw2cdf
%RAW2CDF Summary of this function goes here
%   Detailed explanation goes here

% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);
import daysimeter12.*

for iFile = 1:nFile
    cdfPath = fullfile();
    data = prepCDF(time,red,green,blue,activity,illuminance,CLA,CS,...
        deviceModel,deviceSN,subjectID);
    writecdf(data,cdfPath);
end

end

