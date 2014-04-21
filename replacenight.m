function [csArray,activityArray] = replacenight(timeArray,csArray,activityArray,Location)
%
% Location = Location.latitude, Location.longitude, Location.gmtOffset

% Find the dates that are included in the data
Date = unique(floor(timeArray));
Date = Date(:); % make sure Date is a vertical vector

% Caluclate approximate sunrise and sunset time
[sunrise,sunset] = simpleSunCycle(Location.latitude,Location.longitude,Date);

% Adjust sunrise and sunset times from GMT to desired timezone
sunrise = sunrise + Location.gmtOffset/24 + isDST(Date)/24;
sunset = sunset + Location.gmtOffset/24 + isDST(Date)/24;
% Fix rollover error
idxRoll = sunset < sunrise;
sunset(idxRoll) = sunset(idxRoll) + 1;

% Find times that occur during the day
% Preallocate the logical index
dayIdx = false(size(timeArray));
% Add indexes for daytime of each day
for i1 = 1:numel(Date)
    dayIdx = dayIdx | (timeArray >= sunrise(i1) & timeArray <= sunset(i1));
end

nightIdx = ~dayIdx;

% Replace night
csArray(nightIdx) = 0;
activityArray(nightIdx) = 0;

end

