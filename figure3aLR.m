function figure3aLR;
% function figure3aLR;
%

% Refactored to address reviewer comment (remove Figure 3b) and editorial request (plot individual datapoints)
pre_replotForCABN=false;

    whichExpt = 1;
    initialize_opts_struct;

    predOnly = false;

    theseCueLevels = estruct.cueLevels((predOnly+1):end);

    early_by_subj_by_cue       = NaN(max(estruct.sessmat(:, 1)), length(theseCueLevels));
    early_by_subj_by_cue_slope = NaN(max(estruct.sessmat(:, 1)), 1);

    early_by_subj_by_coh       = NaN(max(estruct.sessmat(:, 1)), length(estruct.cohLevels));
    early_by_subj_by_coh_slope = NaN(max(estruct.sessmat(:, 1)), 1);

    early_by_subj_by_cue_by_coh       = NaN(max(estruct.sessmat(:, 1)), length(theseCueLevels), length(estruct.cohLevels));
    early_by_subj_by_cue_by_coh_slope = NaN(max(estruct.sessmat(:, 1)), length(estruct.cohLevels), 1);

    early_by_subj_by_cue_by_coh_by_isi = NaN(max(estruct.sessmat(:, 1)), length(theseCueLevels), length(estruct.cohLevels), length(eopts.whichISI));

    early_by_subj_by_isi        = NaN(max(estruct.sessmat(:, 1)), length(eopts.whichISI));
    early_by_subj_by_cue_by_isi = NaN(max(estruct.sessmat(:, 1)), length(theseCueLevels), length(eopts.whichISI));
    early_by_subj_by_coh_by_isi = NaN(max(estruct.sessmat(:, 1)), length(estruct.cohLevels), length(eopts.whichISI));

    early_responses_by_subj_regs        = cell(max(estruct.sessmat(:, 1)), 1);
    early_responses_by_subj_by_coh_regs = cell(max(estruct.sessmat(:, 1)), length(estruct.cohLevels));

    early_responses_by_cue_by_coh_by_isi = cell(max(estruct.sessmat(:, 1)), length(theseCueLevels), length(estruct.cohLevels), length(eopts.whichISI));
    early_responses_by_coh_by_isi = cell(max(estruct.sessmat(:, 1)), length(estruct.cohLevels), length(eopts.whichISI));

    correct_by_subj_by_cue       = NaN(max(estruct.sessmat(:, 1)), length(estruct.cueLevels)-1);
    correct_by_subj_by_cue_slope = NaN(max(estruct.sessmat(:, 1)), 1);

    correct_by_subj_by_coh       = NaN(max(estruct.sessmat(:, 1)), length(estruct.cohLevels));
    correct_by_subj_by_coh_slope = NaN(max(estruct.sessmat(:, 1)), 1);

    correct_by_subj_by_cue_by_coh       = NaN(max(estruct.sessmat(:, 1)), length(estruct.cueLevels)-1, length(estruct.cohLevels));
    correct_by_subj_by_cue_by_coh_slope = NaN(max(estruct.sessmat(:, 1)), length(estruct.cohLevels));

    correct_late_by_subj_by_cue_by_coh  = NaN(max(estruct.sessmat(:, 1)), length(theseCueLevels), length(estruct.cohLevels));

    correct_responses_by_subj_regs        = cell(max(estruct.sessmat(:, 1)), 1);
    correct_responses_by_subj_by_coh_regs = cell(max(estruct.sessmat(:, 1)), length(estruct.cohLevels));

    correct_late_responses_by_subj_by_coh_regs        = cell(max(estruct.sessmat(:, 1)), length(estruct.cohLevels));


    for subjIdx = 1:length(estruct.submat);
        thisSubj = estruct.submat(subjIdx);
        theseBlocks = estruct.sessmat(estruct.sessmat(:,1)==thisSubj, 2);

        early_responses_by_subj_regs{thisSubj}   = cell(2, 1);
        correct_responses_by_subj_regs{thisSubj} = cell(2, 1);

        for cohIdx = 1:length(estruct.cohLevels);
            early_responses_by_subj_by_coh_regs{thisSubj, cohIdx}        = cell(2, 1);
            correct_responses_by_subj_by_coh_regs{thisSubj, cohIdx}      = cell(2, 1);
            correct_late_responses_by_subj_by_coh_regs{thisSubj, cohIdx} = cell(2, 1);
        end

        for cohIdx = 1:length(estruct.cohLevels);
            early_responses_by_coh{cohIdx}   = [];
            correct_responses_by_coh{cohIdx} = [];

            for isiIdx = 1:length(eopts.whichISI);
                early_responses_by_coh_by_isi{cohIdx, isiIdx} = [];
            end
        end

        early_responses = cell(length(theseCueLevels), 1);
        for cueIdx = 1:length(theseCueLevels);
            early_responses{cueIdx}   = [];
            correct_responses{cueIdx} = [];

            for cohIdx = 1:length(estruct.cohLevels);
                early_responses_by_cue_by_coh{cueIdx, cohIdx} = [];
                correct_responses_by_cue_by_coh{cueIdx, cohIdx} = [];
                correct_late_responses_by_cue_by_coh{cueIdx, cohIdx} = [];

                for isiIdx = 1:length(eopts.whichISI);
                    early_responses_by_cue_by_coh_by_isi{cueIdx, cohIdx, isiIdx} = [];
                end

            end

            for isiIdx = 1:length(eopts.whichISI);
                early_responses_by_cue_by_isi{cueIdx, isiIdx} = [];
            end
        end

        % First, those that collapse across coh levels
        for stimIdx = 1:4;
            earlyResps_byCue       = cell(length(theseCueLevels), 1);
            earlyResps_byCue_byISI = cell(length(theseCueLevels), length(eopts.whichISI));

            for blockIdx = 1:length(theseBlocks);
                thisBlock = theseBlocks(blockIdx);

                levelOfThisCue = subjRec(thisSubj).params.tp(stimIdx, stimIdx, thisBlock);
                cueIdx = find(theseCueLevels==levelOfThisCue);
                if (isempty(cueIdx))
                    continue;
                end
                if (predOnly & (levelOfThisCue < 0.6))
                    continue;
                end
                theseTrials     = [[subjRec(thisSubj).trials(:).block] == thisBlock] & ...
                                  [[subjRec(thisSubj).trials(:).phase] == 2] & ...
                                  [[subjRec(thisSubj).trials(:).cue] == stimIdx];

                theseEarlyResps = ...
                  [subjRec(thisSubj).trials(theseTrials).RT]<=[[subjRec(thisSubj).trials(theseTrials).ISI]+estruct.cueDuration];

                earlyResps_byCue{cueIdx} = [earlyResps_byCue{cueIdx} theseEarlyResps];

                for isiIdx = 1:length(eopts.whichISI);
                    theseISItrials = theseTrials & [[subjRec(thisSubj).trials(:).ISI] == eopts.whichISI(isiIdx)];
                    theseEarlyISIResps = ...
                      [subjRec(thisSubj).trials(theseISItrials).RT]<=[[subjRec(thisSubj).trials(theseISItrials).ISI]+estruct.cueDuration];

                    earlyResps_byCue_byISI{cueIdx, isiIdx} = [earlyResps_byCue_byISI{cueIdx, isiIdx} theseEarlyISIResps];
                end
            end
        end

        for isiIdx = 1:length(eopts.whichISI);
            theseISItrials = [[subjRec(thisSubj).trials(:).phase] == 2] & ...
                             [[subjRec(thisSubj).trials(:).ISI] == eopts.whichISI(isiIdx)];
            theseEarlyISIResps = ...
                      [subjRec(thisSubj).trials(theseISItrials).RT]<=[[subjRec(thisSubj).trials(theseISItrials).ISI]+estruct.cueDuration];
            early_by_subj_by_isi(thisSubj, isiIdx) = nanmean(theseEarlyISIResps);
        end

        for cueIdx = 1:length(theseCueLevels);
            for isiIdx = 1:length(eopts.whichISI);
                early_by_subj_by_cue_by_isi(thisSubj, cueIdx, isiIdx) = nanmean(earlyResps_byCue_byISI{cueIdx, isiIdx});
            end
        end

        for blockIdx = 1:length(theseBlocks);
            thisBlock = theseBlocks(blockIdx);

            for stimIdx = 1:4;
                levelOfThisCue = subjRec(thisSubj).params.tp(stimIdx, stimIdx, thisBlock);
                cueIdx = find(theseCueLevels==levelOfThisCue);
                if (isempty(cueIdx))
                    continue;
                end

                cohOfThisCue = subjRec(thisSubj).calibRec{thisBlock}{stimIdx}.pThreshold;
                cohIdx = find(estruct.cohLevels==cohOfThisCue);

                theseTrials     = [[subjRec(thisSubj).trials(:).block] == thisBlock] & ...
                                  [[subjRec(thisSubj).trials(:).phase] == 2] & ...
                                  [[subjRec(thisSubj).trials(:).cue] == stimIdx];

                theseEarlyResps = [subjRec(thisSubj).trials(theseTrials).RT]<=[[subjRec(thisSubj).trials(theseTrials).ISI]+estruct.cueDuration];

                early_responses{cueIdx}                       = [early_responses{cueIdx} theseEarlyResps];
                early_responses_by_coh{cohIdx}                = [early_responses_by_coh{cohIdx} theseEarlyResps];
                early_responses_by_cue_by_coh{cueIdx, cohIdx} = [early_responses_by_cue_by_coh{cueIdx, cohIdx} theseEarlyResps];

                early_responses_by_subj_regs{thisSubj}{1} = [early_responses_by_subj_regs{thisSubj}{1} nanmean(theseEarlyResps)];
                early_responses_by_subj_regs{thisSubj}{2} = [early_responses_by_subj_regs{thisSubj}{2} levelOfThisCue];

                early_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{1} = [early_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{1} nanmean(theseEarlyResps)];
                early_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{2} = [early_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{2} levelOfThisCue];

                for isiIdx = 1:length(eopts.whichISI);
                    theseISItrials = theseTrials & [[subjRec(thisSubj).trials(:).ISI]==eopts.whichISI(isiIdx)];

                    theseEarlyResps = [subjRec(thisSubj).trials(theseISItrials).RT]<=[[subjRec(thisSubj).trials(theseISItrials).ISI]+estruct.cueDuration];

                    early_responses_by_cue_by_coh_by_isi{cueIdx, cohIdx, isiIdx} = ...
                                [early_responses_by_cue_by_coh_by_isi{cueIdx, cohIdx, isiIdx} ...
                                 theseEarlyResps];

                    early_responses_by_coh_by_isi{cohIdx, isiIdx} = ...
                                [early_responses_by_coh_by_isi{cohIdx, isiIdx} ...
                                 theseEarlyResps];

                    early_responses_by_cue_by_isi{cueIdx, isiIdx} = ...
                                [early_responses_by_cue_by_isi{cueIdx, isiIdx} ...
                                 theseEarlyResps];
                end

                accurateTrials = theseTrials & [[subjRec(thisSubj).trials(:).accurate] == 1];
                theseLateResps     = [subjRec(thisSubj).trials(:).RT]>[[subjRec(thisSubj).trials(:).ISI]+estruct.cueDuration];
                lateTheseTrials    = theseTrials & theseLateResps;
                lateAccurateTrials = accurateTrials & theseLateResps;
                correct_late_responses_by_cue_by_coh{cueIdx, cohIdx} = [correct_late_responses_by_cue_by_coh{cueIdx, cohIdx} ...
                                                                            sum(lateAccurateTrials)/sum(lateTheseTrials)];

                correct_late_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{1} = [correct_late_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{1} ...
                                                                                sum(lateAccurateTrials)/sum(lateTheseTrials)];
                correct_late_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{2} = [correct_late_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{2} ...
                                                                                levelOfThisCue];

                if (levelOfThisCue < 0.6)
                    % If cue = 0.5, accurate is meaningless on early trials.
                    continue;
                end
                correct_responses{cueIdx-(~predOnly)} = [correct_responses{cueIdx-(~predOnly)} sum(accurateTrials)/sum(theseTrials)];
                correct_responses_by_coh{cohIdx} = [correct_responses_by_coh{cohIdx} sum(accurateTrials)/sum(theseTrials)];
                correct_responses_by_cue_by_coh{cueIdx-(~predOnly), cohIdx} = [correct_responses_by_cue_by_coh{cueIdx-(~predOnly), cohIdx} sum(accurateTrials)/sum(theseTrials)];

                correct_responses_by_subj_regs{thisSubj}{1} = [correct_responses_by_subj_regs{thisSubj}{1} sum(accurateTrials)/sum(theseTrials)];
                correct_responses_by_subj_regs{thisSubj}{2} = [correct_responses_by_subj_regs{thisSubj}{2} levelOfThisCue];

                correct_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{1} = [correct_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{1} sum(accurateTrials)/sum(theseTrials)];
                correct_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{2} = [correct_responses_by_subj_by_coh_regs{thisSubj, cohIdx}{2} levelOfThisCue];
            end
        end

        % By cue
        for cueIdx = 1:length(theseCueLevels);
            if (~isempty(early_responses{cueIdx}))
                early_by_subj_by_cue(thisSubj, cueIdx)   = nanmean(early_responses{cueIdx});
            end
            if (predOnly || cueIdx > 1)
                if (~isempty(correct_responses{cueIdx-(~predOnly)}))
                    correct_by_subj_by_cue(thisSubj, cueIdx-(~predOnly)) = nanmean(correct_responses{cueIdx-(~predOnly)});
                end
            end
            for isiIdx = 1:length(eopts.whichISI);
                if (~isempty(early_responses_by_cue_by_isi{cueIdx, isiIdx}))
                    early_by_subj_by_cue_by_isi(thisSubj, cueIdx, isiIdx) = nanmean(early_responses_by_cue_by_isi{cueIdx, isiIdx});
                end
            end
        end % cue

        % By coh
        for cohIdx = 1:length(estruct.cohLevels);
            if (~isempty(early_responses_by_coh{cohIdx}))
                early_by_subj_by_coh(thisSubj, cohIdx)   = nanmean(early_responses_by_coh{cohIdx});
            end
            if (~isempty(correct_responses_by_coh{cohIdx}))
                correct_by_subj_by_coh(thisSubj, cohIdx) = nanmean(correct_responses_by_coh{cohIdx});
            end
            for isiIdx = 1:length(eopts.whichISI);
                if (~isempty(early_responses_by_coh_by_isi{cohIdx, isiIdx}))
                    early_by_subj_by_coh_by_isi(thisSubj, cohIdx, isiIdx) = nanmean(early_responses_by_coh_by_isi{cohIdx, isiIdx});
                end
            end
        end % coh

        % By cue by coh
        for cueIdx = 1:length(theseCueLevels);
            for cohIdx = 1:length(estruct.cohLevels);
                if (~isempty(early_responses_by_cue_by_coh{cueIdx, cohIdx}))
                    early_by_subj_by_cue_by_coh(thisSubj, cueIdx, cohIdx) = nanmean(early_responses_by_cue_by_coh{cueIdx, cohIdx});
                end
                if (predOnly || cueIdx > 1)
                    if (~isempty(correct_responses_by_cue_by_coh{cueIdx-(~predOnly), cohIdx}))
                        correct_by_subj_by_cue_by_coh(thisSubj, cueIdx-(~predOnly), cohIdx) = nanmean(correct_responses_by_cue_by_coh{cueIdx-(~predOnly), cohIdx});
                    end
                end
                if (~isempty(correct_late_responses_by_cue_by_coh{cueIdx, cohIdx}))
                    correct_late_by_subj_by_cue_by_coh(thisSubj, cueIdx, cohIdx) = nanmean(correct_late_responses_by_cue_by_coh{cueIdx, cohIdx});
                end

                for isiIdx = 1:length(eopts.whichISI);
                    if (~isempty(early_responses_by_cue_by_coh_by_isi{cueIdx, cohIdx, isiIdx}))
                        early_by_subj_by_cue_by_coh_by_isi(thisSubj, cueIdx, cohIdx, isiIdx) = ...
                            nanmean(early_responses_by_cue_by_coh_by_isi{cueIdx, cohIdx, isiIdx});
                    end
                end % ISI
            end % coh
        end % cue
    end

    for cohIdx = 1:length(estruct.cohLevels);
        thisCohLevel = estruct.cohLevels(cohIdx);
        disp([estruct.outputPrefix 'Accuracy at coh=' num2str(thisCohLevel) ...
                            ': ' num2str(nanmean(correct_by_subj_by_coh(:, cohIdx))) ' SEM ' num2str(sem(correct_by_subj_by_coh(:, cohIdx)))]);
    end

    [h, p, ci, stats] = ttest(correct_by_subj_by_coh(:, 1), correct_by_subj_by_coh(:, 2));
    disp([estruct.outputPrefix 'Accuracy increases as coh increases, t(' num2str(stats.df) ')=' num2str(stats.tstat, '%.3f') ...
                                   ', p=' num2str(p, '%.3f')]);

    for cueIdx = 1:length(theseCueLevels);
        thisCueLevel = theseCueLevels(cueIdx);
if (pre_replotForCABN)
        [h, p] = ttest(early_by_subj_by_cue(:, cueIdx));
        disp([estruct.outputPrefix 'Early responses at cue=' num2str(thisCueLevel) ...
                            ': ' num2str(nanmean(early_by_subj_by_cue(:, cueIdx))) ' SEM ' num2str(sem(early_by_subj_by_cue(:, cueIdx))) ...
                            ', p=' num2str(p, '%.3f')]);
end
        if (thisCueLevel < 0.55)
            continue;
        end

        disp([estruct.outputPrefix 'Accuracy at cue=' num2str(thisCueLevel) ...
                            ': ' num2str(nanmean(correct_by_subj_by_cue(:, cueIdx-(~predOnly)))) ' SEM ' num2str(sem(correct_by_subj_by_cue(:, cueIdx-(~predOnly))))]);
    end

    theseResps = NaN(length(estruct.submat), 8, 2);
    theseCorrectResps = NaN(length(estruct.submat), 8, 2);
    for subjIdx = 1:length(estruct.submat);
        respLen = length([early_responses_by_subj_regs{estruct.submat(subjIdx)}{1}]);
        theseResps(subjIdx, 1:respLen, 1) = [early_responses_by_subj_regs{estruct.submat(subjIdx)}{1}];
        theseResps(subjIdx, 1:respLen, 2) = [early_responses_by_subj_regs{estruct.submat(subjIdx)}{2}];

        respLen = length([correct_responses_by_subj_regs{estruct.submat(subjIdx)}{1}]);
        theseCorrectResps(subjIdx, 1:respLen, 1) = [correct_responses_by_subj_regs{estruct.submat(subjIdx)}{1}];
        theseCorrectResps(subjIdx, 1:respLen, 2) = [correct_responses_by_subj_regs{estruct.submat(subjIdx)}{2}];

        if (true)
            % This should be unnecessary
            % Clip 0.5
            isLowCue = [squeeze(theseCorrectResps(subjIdx, :, 2))<0.55];
            theseCorrectResps(subjIdx, isLowCue, 1) = NaN;
            theseCorrectResps(subjIdx, isLowCue, 2) = NaN;
        end
    end

if (pre_replotForCABN)
    [p rawEffects subjSamples opts] = ghootstrap(theseResps); % , 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));
    disp([estruct.outputPrefix '(ghootstrap) Early responses increase as cue increases, R=' num2str(opts.baseEffect, '%.3f') ...
                                   ', p=' num2str(p, '%.3f')]);
end

    [p rawEffects subjSamples opts] = ghootstrap(theseCorrectResps);
    disp([estruct.outputPrefix '(ghootstrap) Accuracy increases as cue increases, R=' num2str(opts.baseEffect, '%.3f') ...
                                   ', p=' num2str(p, '%.3f')]);

    rawEffectsByCoh  = cell(length(estruct.cohLevels), 1);
    subjSamplesByCoh = cell(length(estruct.cohLevels), 1);
    correct_rawEffectsByCoh  = cell(length(estruct.cohLevels), 1);
    correct_subjSamplesByCoh = cell(length(estruct.cohLevels), 1);
    lateCorrect_rawEffectsByCoh  = cell(length(estruct.cohLevels), 1);
    lateCorrect_subjSamplesByCoh = cell(length(estruct.cohLevels), 1);
    for cohIdx = 1:length(estruct.cohLevels);
        rawEffectsByCoh{cohIdx}  = [];
        subjSamplesByCoh{cohIdx} = [];
        correct_rawEffectsByCoh{cohIdx}  = [];
        correct_subjSamplesByCoh{cohIdx} = [];
        lateCorrect_rawEffectsByCoh{cohIdx}  = [];
        lateCorrect_subjSamplesByCoh{cohIdx} = [];
    end

        aaron_newfig;
        set(gca, 'FontSize', 32);
        set(gca, 'FontWeight', 'demi');
        hold on;
if (~pre_replotForCABN)
        title('Accuracy');
end
        subplot(1, 2, 1);
        set(gca, 'FontSize', 32);
        set(gca, 'FontWeight', 'demi');
        hold on;

if (pre_replotForCABN)
        title('Accuracy');
        ylabel('Fraction of all responses');
        xlabel('Cue level');
        set(gca, 'YTick', [0:0.1:1]);
        set(gca, 'YTickLabel', arrayfun(@(x)(num2str(x, '%.2f')), [0:0.1:1.0], 'UniformOutput', false));
        set(gca, 'XTick', [1:length(theseCueLevels)-(~predOnly)]);
        set(gca, 'XTickLabel', arrayfun(@(x)([num2str(x*100, '%d') '%']), theseCueLevels(2:end), 'UniformOutput', false));
        axis([0.5 length(theseCueLevels)-(~predOnly)+0.5 0.6 0.9]);
else
        ylabel('Correct responses');
        cohName{1} = 'Low';
        cohName{2} = 'High';

        for cohIdx = 1:length(estruct.cohLevels);
            subplot(1, 2, cohIdx);
            set(gca, 'FontSize', 32);
            set(gca, 'FontWeight', 'demi');
            hold on;
            title([cohName{cohIdx} ' coherence']);
            xlabel('Cue level');
            set(gca, 'YTick', [0:0.1:1]);
            set(gca, 'YTickLabel', arrayfun(@(x)([num2str(x, '%d') '%']), [0:10:100], 'UniformOutput', false));
            set(gca, 'XTick', [1:length(theseCueLevels)-(~predOnly)]);
            set(gca, 'XTickLabel', arrayfun(@(x)([num2str(x*100, '%d') '%']), theseCueLevels(2:end), 'UniformOutput', false));
            axis([0.5 length(theseCueLevels)-(~predOnly)+0.5 0.5 1.0]);
        end
end

if (pre_replotForCABN)
        subplot(1, 2, 2);
        set(gca, 'FontSize', 32);
        set(gca, 'FontWeight', 'demi');
        hold on;
        title('Early responses');
        xlabel('Cue level');
        set(gca, 'YTick', [0:0.1:1]);
        set(gca, 'YTickLabel', arrayfun(@(x)(num2str(x, '%.2f')), [0:0.1:1.0], 'UniformOutput', false));
        set(gca, 'XTick', [1:length(theseCueLevels)]);
        set(gca, 'XTickLabel', arrayfun(@(x)([num2str(x*100, '%d') '%']), theseCueLevels, 'UniformOutput', false));
        axis([0.75 length(theseCueLevels)+0.25 0.0001 0.55]);
else
    dotCol(1,:)  = estruct.paperColors.individual.memory;
    dotCol(2,:)  = estruct.paperColors.individual.visual;
end
    lineCol(1,:) = estruct.paperColors.memory;
    lineCol(2,:) = estruct.paperColors.visual;

    for cohIdx = 1:length(estruct.cohLevels);
if (pre_replotForCABN)
            subplot(1, 2, 1);
else
            subplot(1, 2, cohIdx);
end
            hold on;
            theseCorrect = squeeze(correct_by_subj_by_cue_by_coh(:, :, cohIdx));
if (~pre_replotForCABN)
% 'MarkerEdgeColor', [dotCol(cohIdx, :)], ...
            plot([1:length(theseCueLevels)-(~predOnly)], theseCorrect, 'o', ...
                                                                       'Color', [dotCol(cohIdx, :)], ...
                                                                       'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
                                                                       'LineWidth', estruct.paperStyles.individual.LineWidth);
end
            correctLine(cohIdx) = errorbar([1:length(theseCueLevels)-(~predOnly)], nanmean(theseCorrect), sem(theseCorrect), ...
                                                                                                          'LineStyle', estruct.paperStyles.LineStyle{cohIdx}, ...
                                                                                                          'LineWidth', estruct.paperStyles.LineWidth, ...
                                                                                                          'Color', lineCol(cohIdx, :), ...
                                                                                                          'CapSize', estruct.paperStyles.CapSize);

if (pre_replotForCABN)
            subplot(1, 2, 2);
            hold on;
            theseEarly = squeeze(early_by_subj_by_cue_by_coh(:, :, cohIdx));
            earlyLine(1+cohIdx) = errorbar([1:length(theseCueLevels)], nanmean(theseEarly), sem(theseEarly), '-', 'Color', lineCol(cohIdx, :), 'LineWidth', 8);
end

        theseResps = NaN(length(estruct.submat), 8, 2);
        theseCorrectResps = NaN(length(estruct.submat), 8, 2);
        theseLateCorrectResps = NaN(length(estruct.submat), 8, 2);
        for subjIdx = 1:length(estruct.submat);
if (pre_replotForCABN)
            respLen = length([early_responses_by_subj_by_coh_regs{estruct.submat(subjIdx), cohIdx}{1}]);
            theseResps(subjIdx, 1:respLen, 1) = [early_responses_by_subj_by_coh_regs{estruct.submat(subjIdx), cohIdx}{1}];
            theseResps(subjIdx, 1:respLen, 2) = [early_responses_by_subj_by_coh_regs{estruct.submat(subjIdx), cohIdx}{2}];
end

            respLen = length([correct_responses_by_subj_by_coh_regs{estruct.submat(subjIdx), cohIdx}{1}]);
            theseCorrectResps(subjIdx, 1:respLen, 1) = [correct_responses_by_subj_by_coh_regs{estruct.submat(subjIdx), cohIdx}{1}];
            theseCorrectResps(subjIdx, 1:respLen, 2) = [correct_responses_by_subj_by_coh_regs{estruct.submat(subjIdx), cohIdx}{2}];
        end

if (pre_replotForCABN)
        [p rawEffectsByCoh{cohIdx} subjSamplesByCoh{cohIdx} opts] = ghootstrap(theseResps, 'subjsSampled', subjSamplesByCoh{1});
        disp([estruct.outputPrefix '(ghootstrap) Early responses increase as cue increases, coh=' num2str(estruct.cohLevels(cohIdx)) ', R=' num2str(opts.baseEffect, '%.3f') ...
                                       ', p=' num2str(p, '%.3f')]);
end

        [p correct_rawEffectsByCoh{cohIdx} correct_subjSamplesByCoh{cohIdx} opts] = ghootstrap(theseCorrectResps, 'subjsSampled', correct_subjSamplesByCoh{1});
        disp([estruct.outputPrefix '(ghootstrap) Accuracy increases as cue increases, coh=' num2str(estruct.cohLevels(cohIdx)) ', R=' num2str(opts.baseEffect, '%.3f') ...
                                       ', p=' num2str(p, '%.3f')]);
    end

if (pre_replotForCABN)
        legend(correctLine, 'Low coherence', 'High coherence', 'Location', 'NorthWest');

    cdRT = cohend(rawEffectsByCoh{1}, rawEffectsByCoh{2}, true);
    disp([estruct.outputPrefix '(ghootstrap) Early responses by cue slope between cohs different Cohens d=' num2str(cdRT, '%.3f')]);
end

    cdRT = cohend(correct_rawEffectsByCoh{1}, correct_rawEffectsByCoh{2}, true);
    disp([estruct.outputPrefix '(ghootstrap) Accuracy by cue slope between cohs different Cohens d=' num2str(cdRT, '%.3f')]);

