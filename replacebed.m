function [csArray,activityArray] = replacebed(timeArray,csArray,activityArray,bedTimeArray,getupTimeArray)
%
%

% Preallocate the logical index
bedIdx = false(size(timeArray));
% Add indexes for daytime of each day
for i1 = 1:numel(bedTimeArray)
    bedIdx = bedIdx | (timeArray >= bedTimeArray(i1) & timeArray <= getupTimeArray(i1));
end

% Replace night
csArray(bedIdx) = 0;
activityArray(bedIdx) = 0;

end

