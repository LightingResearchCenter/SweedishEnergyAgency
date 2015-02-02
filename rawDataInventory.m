function Files = rawDataInventory(folder,indexFile)

rawDataIndex = importRawIndex(indexFile);

file1 = fullfile(folder,rawDataIndex.file1);
file2 = fullfile(folder,rawDataIndex.file2);

idxWinter = strcmpi('Winter',rawDataIndex.season);
idxSummer = strcmpi('Summer',rawDataIndex.season);

Files = struct;
Files.winter = struct;
Files.summer = struct;

Files.winter.file1 = file1(idxWinter);
Files.winter.file2 = file2(idxWinter);
Files.winter.subject = rawDataIndex.subject(idxWinter);
Files.winter.format = rawDataIndex.format(idxWinter);

Files.summer.file1 = file1(idxSummer);
Files.summer.file2 = file2(idxSummer);
Files.summer.subject = rawDataIndex.subject(idxSummer);
Files.summer.format = rawDataIndex.format(idxSummer);

end