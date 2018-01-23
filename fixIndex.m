clear
close all
clc

[Dirs,Files] = mapPaths;

TempIndex = load(Files.logs.edited);
index = TempIndex.index;
fields = fieldnames(index);

for iField = 1:numel(fields)
    thisField = fields{iField};
    for iFile = 1:numel(index.(thisField).file)
        thisFile = index.(thisField).file{iFile};
        thisFile = [thisFile,'.cdf'];
        index.(thisField).file{iFile} = thisFile;
    end
end

% Save the new index of files
save(Files.logs.edited,'index');