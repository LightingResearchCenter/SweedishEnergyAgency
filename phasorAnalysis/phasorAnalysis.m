function [phasorMagnitude, phasorAngle, IS, IV, MagH, f24abs] = phasorAnalysis(time, CS, activity)
%PHASORANALYSIS Performs analysis on CS and activity

%% Process and analyze data
epoch = round(mode(diff(time)*24*60*60)); % sample epoch in seconds
Srate = 1/epoch; % sample rate in Hertz

% Apply gaussian filter to data
win = ceil(300/epoch); % approximate number of samples in 5 minutes
CS = gaussian(CS, win);
activity = gaussian(activity, win);

% Calculate intradaily stability and variablity
[IS,IV] = IS_IVcalc(activity,epoch);

% Calculate phasors
[phasorMagnitude,phasorAngle] = cos24(CS, activity, time);

% f24H returns all the harmonics of the 24-hour rhythm (as complex numbers)
[f24H,f24] = phasor24Harmonics(CS,activity,Srate);
% the magnitude including all the harmonics
MagH = sqrt(sum((abs(f24H).^2)));

f24abs = abs(f24);

end
