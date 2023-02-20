function figure3bLR;
% function figure3bLR;
%

pre_replotForCABN=false;

    whichExpt = 1;
    initialize_opts_struct;

    % PARAM: Subselect ISIs? Default: estruct.isiLevels
    whichISI = eopts.whichISI;

    lateRTs_by_subj_by_coh           = NaN(max(estruct.sessmat(:,1)), length(estruct.cohLevels));

    lateRTs_by_subj_by_cue           = NaN(max(estruct.sessmat(:,1)), length(estruct.cueLevels));

    lateRTs_by_subj_by_all_cues         = NaN(max(estruct.sessmat(:,1)), length(estruct.allCueLevels));

    lateRTs_by_subj_by_all_cues_regs               = cell(max(estruct.sessmat(:,1)), 2);

    lateRTs_by_subj_by_cue_by_coh       = NaN(max(estruct.sessmat(:,1)), length(estruct.cohLevels), length(estruct.cueLevels));

    lateRTs_by_subj_by_all_cues_by_coh  = NaN(max(estruct.sessmat(:,1)), length(estruct.cohLevels), length(estruct.allCueLevels));

    for subjIdx = 1:length(estruct.submat);
        thisSubj = estruct.submat(subjIdx);
        theseBlocks = estruct.sessmat(estruct.sessmat(:,1)==thisSubj, 2);

        lateRTs                        = cell(length(estruct.cueLevels), 1);

        for cueIdx = 1:length(lateRTs);
            lateRTs{cueIdx} = [];
        end

        lateRTs_bycoh = cell(length(estruct.cueLevels), length(estruct.cohLevels));
        for cueIdx = 1:size(lateRTs_bycoh, 1);
            for cohIdx = 1:size(lateRTs_bycoh, 2);
                lateRTs_bycoh{cueIdx, cohIdx} = [];
            end
        end

        lateRTs_allCues = cell(length(estruct.allCueLevels), 1);
        lateRTs_allCues_by_coh = cell(length(estruct.allCueLevels), length(estruct.cohLevels));

        for allCueIdx = 1:length(lateRTs_allCues);
            lateRTs_allCues{allCueIdx} = [];

            for cohIdx = 1:size(lateRTs_allCues_by_coh, 2);
                lateRTs_allCues_by_coh{allCueIdx, cohIdx} = [];
            end
        end

        isiTrials   = arrayfun(@(x)(ismember(x, whichISI)), [subjRec(thisSubj).trials(:).ISI]);

        lateTrials = [[subjRec(thisSubj).trials(:).phase] == 2] & ...
                                    [[subjRec(thisSubj).trials(:).accurate] == 1] & ...
                                    [[subjRec(thisSubj).trials(:).RT]>[[subjRec(thisSubj).trials(:).ISI]+estruct.cueDuration]] & ...
                                    isiTrials;
        % z(log(RT))
        subjLateRTs = log([subjRec(thisSubj).trials(lateTrials).RT]-[[subjRec(thisSubj).trials(lateTrials).ISI]+estruct.cueDuration]);
        subjLateRTs = (subjLateRTs - nanmean(subjLateRTs))/nanstd(subjLateRTs);

        for blockIdx = 1:length(theseBlocks);
            thisBlock = theseBlocks(blockIdx);

            for stimIdx = 1:4;
                theseTrials = [[subjRec(thisSubj).trials(lateTrials).block] == thisBlock] & [[subjRec(thisSubj).trials(lateTrials).cue] == stimIdx];

                levelOfThisCue = subjRec(thisSubj).params.tp(stimIdx, stimIdx, thisBlock);
                cueIdx = find(estruct.cueLevels==levelOfThisCue);
                if (isempty(cueIdx))
                    continue;
                end

                lateRTs{cueIdx} = [lateRTs{cueIdx} subjLateRTs(theseTrials)];

                levelOfThisCoh = subjRec(thisSubj).calibRec{thisBlock}{stimIdx}.pThreshold;
                cohIdx = find(estruct.cohLevels==levelOfThisCoh);

                lateRTs_bycoh{cueIdx, cohIdx} = [lateRTs_bycoh{cueIdx, cohIdx} subjLateRTs(theseTrials)];

                % 0: Incongruent, 1: Congruent
                for congIdx = 1:2;
                    congTrials = [[[subjRec(thisSubj).trials(lateTrials).cue] == [subjRec(thisSubj).trials(lateTrials).corrResp]] == congIdx-1] & theseTrials;

                    if (congIdx == 1)
                        levelOfThisAllCue = 1-levelOfThisCue;
                    else
                        levelOfThisAllCue = levelOfThisCue;
                    end
                    allCueIdx = find(estruct.allCueLevels==levelOfThisAllCue);
                    if (isempty(allCueIdx))
                        disp(['Shouldn''t get here: ' num2str(levelOfThisAllCue)]);
                        pause;
                    end

                    lateRTs_allCues{allCueIdx} = [lateRTs_allCues{allCueIdx} subjLateRTs(congTrials)];
                    lateRTs_allCues_by_coh{allCueIdx, cohIdx} = [lateRTs_allCues_by_coh{allCueIdx, cohIdx} ...
                                                                    subjLateRTs(congTrials)];
                end % cong

            end % stimIdx

        end % blockIdx

        for cohIdx = 1:length(estruct.cohLevels);
            if (~isempty([lateRTs_bycoh{:, cohIdx}]))
                lateRTs_by_subj_by_coh(thisSubj, cohIdx) = nanmean([lateRTs_bycoh{:, cohIdx}]);
            end
        end

        lateRTs_by_subj_by_cue_regs{thisSubj} = cell(2, 1);
        for cueIdx = 1:length(estruct.cueLevels);
            if (~isempty([lateRTs{cueIdx}]))
                lateRTs_by_subj_by_cue(thisSubj, cueIdx) = nanmean(lateRTs{cueIdx});
            end
            lateRTs_by_subj_by_cue_regs{thisSubj}{1} = [lateRTs_by_subj_by_cue_regs{thisSubj}{1} [lateRTs{cueIdx}]];
            lateRTs_by_subj_by_cue_regs{thisSubj}{2} = [lateRTs_by_subj_by_cue_regs{thisSubj}{2} ...
                                                                            repmat(estruct.cueLevels(cueIdx), [1 length([lateRTs{cueIdx}])])];
        end

        for allCueIdx = 1:length(estruct.allCueLevels);
            if (~isempty([lateRTs_allCues{allCueIdx}]))
                lateRTs_by_subj_by_all_cues(thisSubj, allCueIdx) = nanmean(lateRTs_allCues{allCueIdx});
            end
            lateRTs_by_subj_by_all_cues_regs{thisSubj, 1} = [lateRTs_by_subj_by_all_cues_regs{thisSubj, 1} [lateRTs_allCues{allCueIdx}]];
            lateRTs_by_subj_by_all_cues_regs{thisSubj, 2} = [lateRTs_by_subj_by_all_cues_regs{thisSubj, 2} ...
                                                                            repmat(estruct.allCueLevels(allCueIdx), [1 length([lateRTs_allCues{allCueIdx}])])];
        end

        % Now within each coh level
        for cohIdx = 1:length(estruct.cohLevels);
            lateRTs_by_subj_by_cue_by_coh_regs{thisSubj, cohIdx} = cell(2, 1);

            for cueIdx = 1:length(estruct.cueLevels);
                if (~isempty(lateRTs_bycoh{cueIdx, cohIdx}))
                    lateRTs_by_subj_by_cue_by_coh(thisSubj, cohIdx, cueIdx) = nanmean(lateRTs_bycoh{cueIdx, cohIdx});
                end
                lateRTs_by_subj_by_cue_by_coh_regs{thisSubj, cohIdx}{1} = [lateRTs_by_subj_by_cue_by_coh_regs{thisSubj, cohIdx}{1} [lateRTs_bycoh{cueIdx, cohIdx}]];
                lateRTs_by_subj_by_cue_by_coh_regs{thisSubj, cohIdx}{2} = [lateRTs_by_subj_by_cue_by_coh_regs{thisSubj, cohIdx}{2} ...
                                                                            repmat(estruct.cueLevels(cueIdx), [1 length([lateRTs_bycoh{cueIdx, cohIdx}])])];
            end

            lateRTs_by_subj_by_all_cues_by_coh_regs{thisSubj, cohIdx} = cell(2, 1);

            for allCueIdx = 1:length(estruct.allCueLevels);
                if (~isempty(lateRTs_allCues_by_coh{allCueIdx, cohIdx}))
                    lateRTs_by_subj_by_all_cues_by_coh(thisSubj, cohIdx, allCueIdx) = nanmean(lateRTs_allCues_by_coh{allCueIdx, cohIdx});
                end
                lateRTs_by_subj_by_all_cues_by_coh_regs{thisSubj, cohIdx}{1} = [lateRTs_by_subj_by_all_cues_by_coh_regs{thisSubj, cohIdx}{1} [lateRTs_allCues_by_coh{allCueIdx, cohIdx}]];
                lateRTs_by_subj_by_all_cues_by_coh_regs{thisSubj, cohIdx}{2} = [lateRTs_by_subj_by_all_cues_by_coh_regs{thisSubj, cohIdx}{2} ...
                                                                            repmat(estruct.allCueLevels(allCueIdx), [1 length([lateRTs_allCues_by_coh{allCueIdx, cohIdx}])])];
            end

        end % cohIdx

    end % subj

    %% Print results
    % -- By cue
        for allCueIdx = 1:length(estruct.allCueLevels);
            thisCueLevel = estruct.allCueLevels(allCueIdx);
            disp([estruct.outputPrefix 'Late zRTs by subject at cue=' num2str(thisCueLevel) ...
                                ': ' num2str(nanmean(lateRTs_by_subj_by_all_cues(:, allCueIdx))) ' SEM ' num2str(sem(lateRTs_by_subj_by_all_cues(:, allCueIdx)))]);
        end

if (0) % (pre_replotForCABN)
        for cohIdx = 1:length(estruct.cohLevels);
            subplot(1, 2, cohIdx);
            set(gca, 'FontSize', 32);  
            set(gca, 'FontWeight', 'demi');
%            xlabel('Cue level');
%            set(gca, 'YTick', [0:0.1:1]);
%            set(gca, 'YTickLabel', arrayfun(@(x)(num2str(x, '%.2f')), [0:0.1:1.0], 'UniformOutput', false));
%            set(gca, 'XTick', [1:length(theseCueLevels)-(~predOnly)]);
%            set(gca, 'XTickLabel', arrayfun(@(x)([num2str(x*100, '%d') '%']), theseCueLevels(2:end), 'UniformOutput', false));
%            axis([0.5 length(theseCueLevels)-(~predOnly)+0.5 0.5 1.0]);
        end
else
        byValid_fig = aaron_newfig;
        set(gca, 'FontSize', 32);
        set(gca, 'FontWeight', 'demi');
        hold on;
        byValid_plotHandles = zeros(1,2);
end

        theseRTs = NaN(length(estruct.submat), 80, 2);
        for subjIdx = 1:length(estruct.submat);
            RTlen = length([lateRTs_by_subj_by_all_cues_regs{estruct.submat(subjIdx), 1}]);
            theseRTs(subjIdx, 1:RTlen, 1) = [lateRTs_by_subj_by_all_cues_regs{estruct.submat(subjIdx), 1}];
            theseRTs(subjIdx, 1:RTlen, 2) = [lateRTs_by_subj_by_all_cues_regs{estruct.submat(subjIdx), 2}];
        end

        [p rawEffects subjSamples opts] = ghootstrap(theseRTs);
        disp([estruct.outputPrefix '(ghootstrap) Late zRTs decrease as cue increases, R=' num2str(opts.baseEffect, '%.3f') ...
                            ', p=' num2str(p, '%.3f')]);

    % -- By coh
    lateCohRTs = cell(2, 1);
    for cohIdx = 1:length(estruct.cohLevels);
        thisCohLevel = estruct.cohLevels(cohIdx);

        lateCohRTs{cohIdx} = [lateRTs_by_subj_by_coh(:, cohIdx)];

        disp([estruct.outputPrefix 'Late zRTs at coh=' num2str(thisCohLevel) ': ' num2str(nanmean(lateCohRTs{cohIdx})) ' SEM ' num2str(sem(lateCohRTs{cohIdx}))]);
    end

    [h, p, ci, stats] = ttest([lateCohRTs{1}(:)], [lateCohRTs{2}(:)]);
    cohRTDiff = [lateCohRTs{1}(:)]-[lateCohRTs{2}(:)];
    disp([estruct.outputPrefix 'Late zRTs different between coh, mean ' num2str(nanmean(cohRTDiff), '%.3f') ...
                               ' SEM ' num2str(sem(cohRTDiff), '%.3f') ...
                                ' t_{' num2str(stats.df) '}=' num2str(stats.tstat, '%.3f') ...
                                ', p=' num2str(p, '%.3f')]);

    % -- By cue and coherence
    rawEffectsByCoh  = cell(length(estruct.cohLevels), 1);
    subjSamplesByCoh = cell(length(estruct.cohLevels), 1);
    for cohIdx = 1:length(estruct.cohLevels);
        rawEffectsByCoh{cohIdx}  = [];
        subjSamplesByCoh{cohIdx} = [];
    end
    lineCol(1,:) = estruct.paperColors.memory;
    lineCol(2,:) = estruct.paperColors.visual;

if (~pre_replotForCABN)
    dotCol(1,:)  = estruct.paperColors.individual.memory;
    dotCol(2,:)  = estruct.paperColors.individual.visual;
end

    for cohIdx = 1:length(estruct.cohLevels);
        thisCohLevel = estruct.cohLevels(cohIdx);

        for allCueIdx = 1:length(estruct.allCueLevels);
            thisCueLevel = estruct.allCueLevels(allCueIdx);
            disp([estruct.outputPrefix 'Late zRTs by subject at coh=' num2str(thisCohLevel) ', cue=' num2str(thisCueLevel) ...
                                ': ' num2str(nanmean(lateRTs_by_subj_by_all_cues_by_coh(:, cohIdx, allCueIdx))) ' SEM ' num2str(sem(lateRTs_by_subj_by_all_cues_by_coh(:, cohIdx, allCueIdx)))]);
        end


        theseRTs = squeeze(lateRTs_by_subj_by_all_cues_by_coh(:, cohIdx, :));

            figure(byValid_fig);
            % Take mean of each group within-subject
            theseRTs_byValid_invalid    = nanmean(theseRTs(:, [1:3]), 2);
            theseRTs_byValid_indecisive = nanmean(theseRTs(:, [4]), 2);
            theseRTs_byValid_valid      = nanmean(theseRTs(:, [5:7]), 2);
            theseRTs_byValid            = [theseRTs_byValid_invalid theseRTs_byValid_indecisive theseRTs_byValid_valid];

if (~pre_replotForCABN)
%                                                                     'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
            jitterOffsets = [-0.05 0.05];
            plot([1:3]+jitterOffsets(cohIdx), theseRTs_byValid, 'o', 'Color', [dotCol(cohIdx, :)], 'MarkerEdgeColor', [dotCol(cohIdx, :)], ...
                                                                     'LineWidth', estruct.paperStyles.individual.LineWidth);
end 
            byValid_plotHandles(cohIdx) = errorbar([1:3], nanmean(theseRTs_byValid), sem(theseRTs_byValid), 'LineStyle', estruct.paperStyles.LineStyle{cohIdx}, ...
                                                    'LineWidth', estruct.paperStyles.LineWidth, 'Color', lineCol(cohIdx, :), 'CapSize', estruct.paperStyles.CapSize);

        lateRTs_all_by_all_cues_by_coh = nanmean(lateRTs_by_subj_by_all_cues_by_coh(:, cohIdx, :), 1);

            theseRTs = NaN(length(estruct.submat), 80, 2);
            for subjIdx = 1:length(estruct.submat);
                RTlen = length([lateRTs_by_subj_by_all_cues_by_coh_regs{estruct.submat(subjIdx), cohIdx}{1}]);
                theseRTs(subjIdx, 1:RTlen, 1) = [lateRTs_by_subj_by_all_cues_by_coh_regs{estruct.submat(subjIdx), cohIdx}{1}];
                theseRTs(subjIdx, 1:RTlen, 2) = [lateRTs_by_subj_by_all_cues_by_coh_regs{estruct.submat(subjIdx), cohIdx}{2}];
            end

            [p rawEffectsByCoh{cohIdx} subjSamplesByCoh{cohIdx} opts] = ghootstrap(theseRTs, 'subjsSampled', subjSamplesByCoh{1});
            disp([estruct.outputPrefix '(ghootstrap) Late zRTs decrease as cue increases, at coh=' num2str(thisCohLevel) ', R=' num2str(opts.baseEffect, '%.3f') ...
                            ', p=' num2str(p, '%.3f')]);
    end

        figure(byValid_fig);
        title(['Response times to flicker probe']);
        xlabel(['Cue']);
%        ylabel(['zRT']);
        ylabel(['Response time']);
if (pre_replotForCABN)
        set(gca, 'YTick', [-0.25:0.25:1]);
        set(gca, 'YTickLabel', arrayfun(@(x)(num2str(x)), ...
                          [-0.25:0.25:1], 'UniformOutput', false));
else
        ylim([-1.75 2]);
        set(gca, 'YTick', [-1.5:0.5:2]);
        set(gca, 'YTickLabel', arrayfun(@(x)(num2str(x)), ...
                          [-1.5:0.5:2], 'UniformOutput', false));
end
        set(gca, 'XLim', [0.75 3.25]);
        set(gca, 'XTick', [1:3]);
        set(gca, 'XTickLabel', {'Invalid', 'Neutral', 'Valid'});
        legend(byValid_plotHandles, 'Low coherence', 'High coherence');

        cdRT = cohend(rawEffectsByCoh{1}, rawEffectsByCoh{2}, true);
        disp([estruct.outputPrefix '(ghootstrap) Late zRTs by cue slope between cohs different Cohens d=' num2str(cdRT, '%.3f')]);
