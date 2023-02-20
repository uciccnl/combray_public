function figure7b;
% function figure7b;
%
pre_replotForCABN = false;

    whichExpt = 2;
    skip_load_subjs = true;
    initialize_opts_struct;

    eopts.dataFile = 'patternData_20170526.mat';
    eopts.dataField = 'patternData_accOnly';

if (~pre_replotForCABN)
    jitterOffsets=[-0.05 0.05];
end

    parsedData = load(eopts.dataFile);
    parsedData = getfield(parsedData, eopts.dataField);

    aggRTs = cell(2,2);
    for aggIdx_x = 1:size(aggRTs, 1);
        for aggIdx_y = 1:size(aggRTs, 2);
            aggRTs{aggIdx_x, aggIdx_y} = NaN(length(estruct.submat), 160, 2);
        end
    end

    residRTs_congruent_low = squeeze(parsedData.results.late_residsEvs_congruent_lowCoh(:, :, 1));
    evVals_congruent_low   = squeeze(parsedData.results.late_residsEvs_congruent_lowCoh(:, :, 2));

    binnedRTs_congruent_low = NaN(size(residRTs_congruent_low, 1), eopts.numBins);
    for subjIdx = 1:size(residRTs_congruent_low, 1);
        subjVals = squeeze(evVals_congruent_low(subjIdx, :));
        subjRTs  = squeeze(residRTs_congruent_low(subjIdx, :));

        aggRTs{1, 1}(subjIdx, :, 1) = [subjVals NaN(1, 160-length(subjVals))];
        aggRTs{1, 1}(subjIdx, :, 2) = [subjRTs NaN(1, 160-length(subjRTs))];

        % Get within-subject quantiles
        qbins = [-1 quantile(subjVals, eopts.numBins-1) 1.01];
        for binIdx = 1:length(qbins)-1;
            evTrials = [subjVals>=qbins(binIdx) & subjVals<qbins(binIdx+1)];

            if (sum(evTrials) > 0)
                binnedRTs_congruent_low(subjIdx, binIdx) = nanmean(subjRTs(evTrials));
            end
        end
    end

    residRTs_congruent_hi = squeeze(parsedData.results.late_residsEvs_congruent_hiCoh(:, :, 1));
    evVals_congruent_hi   = squeeze(parsedData.results.late_residsEvs_congruent_hiCoh(:, :, 2));

    binnedRTs_congruent_hi = NaN(size(residRTs_congruent_hi, 1), eopts.numBins);
    for subjIdx = 1:size(residRTs_congruent_hi, 1);
        subjVals = squeeze(evVals_congruent_hi(subjIdx, :));
        subjRTs  = squeeze(residRTs_congruent_hi(subjIdx, :));

        aggRTs{1, 2}(subjIdx, :, 1) = [subjVals NaN(1, 160-length(subjVals))];
        aggRTs{1, 2}(subjIdx, :, 2) = [subjRTs NaN(1, 160-length(subjRTs))];

        % Get within-subject quantiles
        qbins = [-1 quantile(subjVals, eopts.numBins-1) 1.01];
        for binIdx = 1:length(qbins)-1;
            evTrials = [subjVals>=qbins(binIdx) & subjVals<qbins(binIdx+1)];

            if (sum(evTrials) > 0)
                binnedRTs_congruent_hi(subjIdx, binIdx) = nanmean(subjRTs(evTrials));
            end
        end
    end

    residRTs_incongruent_low = squeeze(parsedData.results.late_residsEvs_incongruent_lowCoh(:, :, 1));
    evVals_incongruent_low   = squeeze(parsedData.results.late_residsEvs_incongruent_lowCoh(:, :, 2));

    binnedRTs_incongruent_low = NaN(size(residRTs_incongruent_low, 1), eopts.numBins);
    for subjIdx = 1:size(residRTs_incongruent_low, 1);
        subjVals = squeeze(evVals_incongruent_low(subjIdx, :));
        subjRTs  = squeeze(residRTs_incongruent_low(subjIdx, :));

        aggRTs{2, 1}(subjIdx, :, 1) = [subjVals NaN(1, 160-length(subjVals))];
        aggRTs{2, 1}(subjIdx, :, 2) = [subjRTs NaN(1, 160-length(subjRTs))];

        % Get within-subject quantiles
        qbins = [-1 quantile(subjVals, eopts.numBins-1) 1.01];
        for binIdx = 1:length(qbins)-1;
            evTrials = [subjVals>=qbins(binIdx) & subjVals<qbins(binIdx+1)];

            if (sum(evTrials) > 0)
                binnedRTs_incongruent_low(subjIdx, binIdx) = nanmean(subjRTs(evTrials));
            end
        end
    end

    residRTs_incongruent_hi = squeeze(parsedData.results.late_residsEvs_incongruent_hiCoh(:, :, 1));
    evVals_incongruent_hi   = squeeze(parsedData.results.late_residsEvs_incongruent_hiCoh(:, :, 2));

    binnedRTs_incongruent_hi = NaN(size(residRTs_incongruent_hi, 1), eopts.numBins);
    for subjIdx = 1:size(residRTs_incongruent_hi, 1);
        subjVals = squeeze(evVals_incongruent_hi(subjIdx, :));
        subjRTs  = squeeze(residRTs_incongruent_hi(subjIdx, :));

        aggRTs{2, 2}(subjIdx, :, 1) = [subjVals NaN(1, 160-length(subjVals))];
        aggRTs{2, 2}(subjIdx, :, 2) = [subjRTs NaN(1, 160-length(subjRTs))];

        % Get within-subject quantiles
        qbins = [-1 quantile(subjVals, eopts.numBins-1) 1.01];
        for binIdx = 1:length(qbins)-1;
            evTrials = [subjVals>=qbins(binIdx) & subjVals<qbins(binIdx+1)];

            if (sum(evTrials) > 0)
                binnedRTs_incongruent_hi(subjIdx, binIdx) = nanmean(subjRTs(evTrials));
            end
        end
    end


    % Statistics
    trimLen = max(sum(~isnan(aggRTs{1, 1}(:, :, 2))'));
    aggRTs{1, 1} = aggRTs{1, 1}(:, 1:trimLen, :);
    [p(1, 1) rawEffectsByCongCoh{1, 1} subjSamplesByCongCoh{1, 1} theseOpts{1, 1}] = ghootstrap(aggRTs{1, 1}, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));


    trimLen = max(sum(~isnan(aggRTs{2, 1}(:, :, 2))'));
    aggRTs{2, 1} = aggRTs{2, 1}(:, 1:trimLen, :);
    [p(2, 1) rawEffectsByCongCoh{2, 1} subjSamplesByCongCoh{2, 1} theseOpts{2, 1}] = ghootstrap(aggRTs{2, 1}, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));

    trimLen = max(sum(~isnan(aggRTs{1, 2}(:, :, 2))'));
    aggRTs{1, 2} = aggRTs{1, 2}(:, 1:trimLen, :);
    [p(1, 2) rawEffectsByCongCoh{1, 2} subjSamplesByCongCoh{1, 2} theseOpts{1, 2}] = ghootstrap(aggRTs{1, 2}, 'subjsSampled', subjSamplesByCongCoh{1, 1}, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));

    trimLen = max(sum(~isnan(aggRTs{2, 2}(:, :, 2))'));
    aggRTs{2, 2} = aggRTs{2, 2}(:, 1:trimLen, :);
    [p(2, 2) rawEffectsByCongCoh{2, 2} subjSamplesByCongCoh{2, 2} theseOpts{2, 2}] = ghootstrap(aggRTs{2, 2}, 'subjsSampled', subjSamplesByCongCoh{2, 1}, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));

    cdRT{1} = cohend(rawEffectsByCongCoh{1, 1}, rawEffectsByCongCoh{2, 1}, true);
    cdRT{2} = cohend(rawEffectsByCongCoh{1, 2}, rawEffectsByCongCoh{2, 2}, true);


    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, congruent trials, high coherence: R=' ...
                        num2str(theseOpts{1, 1}.baseEffect, '%.3f') ...
                        ', p=' num2str(p(1, 1), '%.3f')]);
    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, congruent trials, low coherence: R=' ...
                        num2str(theseOpts{1, 2}.baseEffect, '%.3f') ...
                        ', p=' num2str(p(1, 2), '%.3f')]);
    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, incongruent trials, high coherence: R=' ...
                        num2str(theseOpts{2, 2}.baseEffect, '%.3f') ...
                        ', p=' num2str(p(2, 2), '%.3f')]);
    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, incongruent trials, low coherence: R=' ...
                        num2str(theseOpts{2, 1}.baseEffect, '%.3f') ...
                        ', p=' num2str(p(2, 1), '%.3f')]);

    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, low coherence congruent and incongruent different' ...
                        ': d=' num2str(cdRT{1}, '%.3f')]);
    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, high coherence congruent and incongruent different' ...
                        ': d=' num2str(cdRT{2}, '%.3f')]);

    % Plots
    aaron_newfig;
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

    subplot(1, 2, 1);
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

if (~pre_replotForCABN)
    plot([1:(eopts.numBins)]+jitterOffsets(1), binnedRTs_congruent_low, 'o', 'Color', estruct.paperColors.memory, 'MarkerEdgeColor', estruct.paperColors.memory, ...
                                                                             'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
                                                                             'LineWidth', estruct.paperStyles.individual.LineWidth);
end
    h(1) = errorbar([1:(eopts.numBins)], nanmean(binnedRTs_congruent_low), sem(binnedRTs_congruent_low), ...
                                         'LineWidth', estruct.paperStyles.LineWidth, 'LineStyle', estruct.paperStyles.LineStyle{1}, ...
                                         'CapSize', estruct.paperStyles.CapSize, 'Color', estruct.paperColors.memory);


if (~pre_replotForCABN)
    plot([1:(eopts.numBins)]+jitterOffsets(2), binnedRTs_incongruent_low, 'o', 'Color', estruct.paperColors.visual, 'MarkerEdgeColor', estruct.paperColors.visual, ...
                                                                               'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
                                                                               'LineWidth', estruct.paperStyles.individual.LineWidth);
end
    h(2) = errorbar([1:(eopts.numBins)], nanmean(binnedRTs_incongruent_low), sem(binnedRTs_incongruent_low), ...
                                         'LineWidth', estruct.paperStyles.LineWidth, 'LineStyle', estruct.paperStyles.LineStyle{2}, ...
                                         'CapSize', estruct.paperStyles.CapSize, 'Color', estruct.paperColors.visual);

    set(gca, 'XTick', [1 (eopts.numBins)]);
    set(gca, 'XTickLabel', {'Lowest', 'Highest'});
    xlabel({['Reinstatement index'];['(binned within-subject)']});
    ylabel(['Response time']);
    title(['Weak sensory evidence']);

    subplot(1, 2, 2);
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

if (~pre_replotForCABN)
    plot([1:(eopts.numBins)]+jitterOffsets(1), binnedRTs_congruent_hi, 'o', 'Color', estruct.paperColors.memory, ...
                                                                            'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
                                                                            'LineWidth', estruct.paperStyles.individual.LineWidth);
end
    h(1) = errorbar([1:(eopts.numBins)], nanmean(binnedRTs_congruent_hi), sem(binnedRTs_congruent_hi), ...
                                         'LineWidth', estruct.paperStyles.LineWidth, 'LineStyle', estruct.paperStyles.LineStyle{1}, ...
                                         'CapSize', estruct.paperStyles.CapSize, 'Color', estruct.paperColors.memory);


if (~pre_replotForCABN)
    plot([1:(eopts.numBins)]+jitterOffsets(2), binnedRTs_incongruent_hi, 'o', 'Color', estruct.paperColors.visual, ...
                                                                              'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
                                                                              'LineWidth', estruct.paperStyles.individual.LineWidth);
end
    h(2) = errorbar([1:(eopts.numBins)], nanmean(binnedRTs_incongruent_hi), sem(binnedRTs_incongruent_hi), ...
                                         'LineWidth', estruct.paperStyles.LineWidth, 'LineStyle', estruct.paperStyles.LineStyle{2}, ...
                                         'CapSize', estruct.paperStyles.CapSize, 'Color', estruct.paperColors.visual);

    legend(h, 'Valid cue', 'Invalid cue', 'Location', 'NorthEast')
    set(gca, 'XTick', [1 (eopts.numBins)]);
    set(gca, 'XTickLabel', {'Lowest', 'Highest'});
    xlabel({['Reinstatement index'];['(binned within-subject)']});
%    ylabel(['Residual zRT']);
    title(['Strong sensory evidence']);

    % Equalize axes
    ylims = zeros(2, 2);
    for plotIdx = 1:2;
        subplot(1, 2, plotIdx);
        ylims(plotIdx,:) = get(gca, 'YLim');
    end

    for plotIdx = 1:2;
        subplot(1, 2, plotIdx);
        axis([0.5 (eopts.numBins)+.5 min(ylims(:)) max(ylims(:))]);
        if (pre_replotForCABN)
            set(gca, 'YTick', [min(ylims(:)):0.1:max(ylims(:))]);
        else
            set(gca, 'YTick', [min(ylims(:)):0.5:max(ylims(:))]);
        end
    end

