ss      = load('subjSummary.mat');
subjs   = unique(ss.sessmat(:,1));

allTrials = [];
for subjIdx = 1:length(subjs);
    pr{subjs(subjIdx)} = plotSubj(subjs(subjIdx), 0, 0, 0, -1);

    goodBlocks = ss.sessmat(ss.sessmat(:,1)==subjs(subjIdx),2);
    for blockIdx = 1:length(goodBlocks);
        trialFilter = [pr{subjs(subjIdx)}(:,11)==goodBlocks(blockIdx) & ...
                       pr{subjs(subjIdx)}(:,10)==2 & ...
                       ~isnan(pr{subjs(subjIdx)}(:,2))];

        % cue, coh, isi, RT, correct
        allTrials = [allTrials ;
                    pr{subjs(subjIdx)}(trialFilter,1) ...
                    pr{subjs(subjIdx)}(trialFilter,6) ...
                    pr{subjs(subjIdx)}(trialFilter,9) ...
                    pr{subjs(subjIdx)}(trialFilter,2) ...
                    pr{subjs(subjIdx)}(trialFilter,3)];
    end
end

cueLevels    = unique(allTrials(:,1));
cueLevels(cueLevels<0.5) = 1-cueLevels(cueLevels<0.5);
cueLevels    = unique(cueLevels);
cohLevels    = unique(allTrials(:,2));
isiLevels    = unique(allTrials(:,3));

collatedData = cell(length(cueLevels), length(cohLevels), length(isiLevels));
for cueIdx = 1:length(cueLevels);
    for cohIdx = 1:length(cohLevels);
        for isiIdx = 1:length(isiLevels);
            trialFilter = (allTrials(:,1)==cueLevels(cueIdx) | allTrials(:,1)==(1-cueLevels(cueIdx))) & ...
                          allTrials(:,2)==cohLevels(cohIdx) & ...
                          allTrials(:,3)==isiLevels(isiIdx);
            % RT, correct (1/0)
            collatedData{cueIdx, cohIdx, isiIdx} = [allTrials(trialFilter,4) allTrials(trialFilter,5)];
            disp(['collateData: cue=' num2str(cueLevels(cueIdx)) ...
                             ', coh=' num2str(cohLevels(cohIdx)) ...
                             ', isi=' num2str(isiLevels(isiIdx)) ...
                             ': ' num2str(sum(trialFilter)) ...
                             ' trials (' num2str(sum(allTrials(trialFilter, 5))) ...
                             ' correct); average per subject=' num2str(sum(trialFilter)/length(subjs)) ...
                             ' (' num2str(sum(allTrials(trialFilter, 5))/length(subjs)) ...
                             ' correct).']);
        end
    end
end

sessmat = ss.sessmat;

save('collatedData.mat', ...
     'collatedData', ...
     'sessmat');

