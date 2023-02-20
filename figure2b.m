function figure2b;
% function figure2b;
%

    whichExpt = 2;
    whichISI  = 4;
    initialize_opts_struct;

    plotISIs = whichISI;

    % PARAM: Accurate only?
    accOnly  = true;

    aggRTs_byCue = cell(length(estruct.cueLevels), length(estruct.cohLevels));
    for cueIdx = 1:length(estruct.cueLevels);
        for cohIdx = 1:length(estruct.cohLevels);
            aggRTs_byCue{cueIdx, cohIdx} = [];
            for isiIdx = 1:length(plotISIs);
                aggRTs_byCue_byCoh_byISI{cueIdx, cohIdx, isiIdx} = [];
                aggRTs_byCue_byCoh_byISI_zscored{cueIdx, cohIdx, isiIdx} = [];
            end
        end
    end

    aggRTs_byISI = cell(length(plotISIs), 1);
    for isiIdx = 1:length(plotISIs);
        aggRTs_byISI{isiIdx} = [];
    end

    for subjIdx = 1:length(estruct.submat);
        thisSubj = estruct.submat(subjIdx);

        theseBlocks = estruct.sessmat(estruct.sessmat(:,1)==thisSubj, 2);

        % Select out the trials with ISIs we want to plot
        isiTrials   = arrayfun(@(x)(ismember(x, plotISIs)), [subjRec(thisSubj).trials(:).ISI]);

        for blockIdx = 1:length(theseBlocks);
            thisBlock  = theseBlocks(blockIdx);
            stimLevels = [];
            for stimIdx = 1:4;
                stimCueLevels(stimIdx) = subjRec(thisSubj).params.tp(stimIdx, stimIdx, thisBlock);
            end

            for stimIdx = 1:4;
                stimCohLevels(stimIdx) = [subjRec(thisSubj).calibRec{thisBlock}{stimIdx}.pThreshold];
            end

            % Get Phase 2 RTs for this block
            testTrials  = [[subjRec(thisSubj).trials(:).block] == thisBlock] & [[subjRec(thisSubj).trials(:).phase] == 2];
            accurateTrials = [[subjRec(thisSubj).trials(:).accurate] == 1] | repmat(~accOnly, [1 length(subjRec(thisSubj).trials(:))]);
            lateTrials  = [[subjRec(thisSubj).trials(:).RT] >= [subjRec(thisSubj).trials(:).ISI] + 0.75];

            for isiIdx = 1:length(plotISIs);
                theseISItrials = [[subjRec(thisSubj).trials(:).ISI] == plotISIs(isiIdx)];
                theseTrials = theseISItrials & testTrials & accurateTrials;

                theseRTs = [subjRec(thisSubj).trials(theseTrials).RT];
                theseRTs = theseRTs - plotISIs(isiIdx) - 0.75;
                aggRTs_byISI{isiIdx} = [aggRTs_byISI{isiIdx} theseRTs];
            end

            for cueIdx = 1:length(estruct.cueLevels);
                % Pick out the stimuli that match this cue level
                whichCueStims = find(stimCueLevels==estruct.cueLevels(cueIdx));
                if (isempty(whichCueStims))
                    % None in this block
                    continue;
                end

                cueTrials = arrayfun(@(x)(ismember(x, whichCueStims)), [subjRec(thisSubj).trials(:).cue]);

                for cohIdx = 1:length(estruct.cohLevels);
                    whichCohStims = find(stimCohLevels==estruct.cohLevels(cohIdx));
                    if (isempty(whichCohStims))
                        % None in this block
                        continue;
                    end

                    cohTrials   = arrayfun(@(x)(ismember(x, whichCohStims)), [subjRec(thisSubj).trials(:).cue]);

                    nanTrials = isnan([subjRec(thisSubj).trials(:).RT]);
                    theseTrials = testTrials & accurateTrials & isiTrials & cueTrials & cohTrials & ~nanTrials;

                    if (~sum(theseTrials) && 0)
                        disp([estruct.outputPrefix 'Subject ' num2str(thisSubj) ', no trials matching ' num2str(estruct.cueLevels(cueIdx),'%.2f') ...
                                                    '-' num2str(estruct.cohLevels(cohIdx), '%.2f')]);
                    end

                    % Raw RTs, stimulus-locked
                    theseRTs  = [subjRec(thisSubj).trials(theseTrials).RT];
                    theseISIs = [subjRec(thisSubj).trials(theseTrials).ISI];
                    theseRTs  = theseRTs - theseISIs - 0.75;

                    theseRTs_z  = [subjRec(thisSubj).trials(:).RT];
                    theseISIs_z = [subjRec(thisSubj).trials(:).ISI];
                    theseRTs_z  = theseRTs_z - theseISIs_z - 0.75;
                    theseTrials_z = theseTrials & lateTrials;

                    % Add to aggregate
                    aggRTs_byCue{cueIdx, cohIdx} = [aggRTs_byCue{cueIdx, cohIdx} theseRTs];

                    % See if ISI affects late RTs
                    for isiIdx = 1:length(plotISIs);
                        theseISItrials = [[subjRec(thisSubj).trials(:).ISI] == plotISIs(isiIdx)];

                        theseTrials = testTrials & accurateTrials & cueTrials & cohTrials & theseISItrials & lateTrials & ~nanTrials;
                        theseRTs = [subjRec(thisSubj).trials(theseTrials).RT] - plotISIs(isiIdx) - 0.75;

                        aggRTs_byCue_byCoh_byISI{cueIdx, cohIdx, isiIdx} = [aggRTs_byCue_byCoh_byISI{cueIdx, cohIdx, isiIdx} ...
                                                                               theseRTs];

                        aggRTs_byCue_byCoh_byISI_zscored{cueIdx, cohIdx, isiIdx} = ...
                                            [aggRTs_byCue_byCoh_byISI_zscored{cueIdx, cohIdx, isiIdx} ...
                                             theseRTs_z(theseTrials)];
                    end

                end % cohLevel
            end % cueLevel
        end % block
    end % subj


    for isiIdx = 1:length(plotISIs);
        %% Histograms (byISI)
        aaron_newfig;
        hold on;
        set(gca, 'FontSize', 32);
        set(gca, 'FontWeight', 'demi');
        hold on;
        % Use 100ms bins
        binEdges = [(-plotISIs(isiIdx)-.75):0.1:ceil(max([aggRTs_byISI{isiIdx}]))];
        binCounts = histc([aggRTs_byISI{isiIdx}], binEdges);
        bar(binEdges, binCounts, 'histc');
        set(get(gca,'child'), 'FaceColor', estruct.paperColors.lightGray, 'EdgeColor', 'k', 'FaceAlpha', 0.9);

        if (isiIdx == 1)
            exptPrefix = [''];
            exptSuffix = [' early'];
        else
            exptPrefix = '';
            exptSuffix = '';
        end
        title([exptPrefix num2str(plotISIs(isiIdx), '%.2f') 's']);
        edgeMax(isiIdx) = max(binEdges);
        binMax(isiIdx) = max(binCounts);
        if (isiIdx == length(plotISIs));
            xlabel(['RT (stimulus-locked)']);
        end
        if (isiIdx == 1)
            ylabel(['# trials']);
        end
        [dip,p_value,xlow,xup]=hdiptest(aggRTs_byISI{isiIdx});
        disp([estruct.outputPrefix 'ISI=' num2str(plotISIs(isiIdx)) ...
                                   ', more than one mode: HDS=' ...
                                   num2str(dip, '%.4f') ...
                                   ', p=' num2str(p_value, '%.4f')]);

        set(gca, 'XLim', [-max(plotISIs)-.75-.25 edgeMax*1.1]);
    end
