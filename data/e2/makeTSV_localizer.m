subjData = dir('localizer_*.mat');

for subjIdx = 1:length(subjData);

    subjNum = split(subjData(subjIdx).name, '_'); % (end-8:end-7);
    subjNum = subjNum{2};

          try

    subjDataFile = load(subjData(subjIdx).name);
    thisSubj = subjDataFile;

    fd = fopen(['localizer_subject_' subjNum '.tsv'], 'w+');
    fprintf(fd, 'trial\tonset\ttype\trepeat\n');

    for blockIdx = 1:length(thisSubj.blockType);
        blockType = thisSubj.blockType(blockIdx);
        for trialIdx = 1:length(thisSubj.probeOrder{blockIdx});
            trialNumber = (blockIdx-1)*10 + trialIdx;
            thisOnset = thisSubj.localizerOnsets{trialNumber};
            isRepeat = thisSubj.probeOrder{blockIdx}(trialIdx)==0;
            fprintf(fd, '%d\t%.4f\t%d\t%d\n', ...
                        trialNumber, thisOnset, blockType, isRepeat);
        end
    end

    fclose(fd);

          catch
            disp(['Skipping subject ' subjData(subjIdx).name ', for missing onsets...']);
          end

end
