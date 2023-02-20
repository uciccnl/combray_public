function figure7aLR;
% function figure7aLR;
%
pre_replotForCABN = false;

    whichExpt = 2;
    skip_load_subjs = true;
    initialize_opts_struct;

    eopts.dataFile = 'patternData_20170526.mat';
    eopts.dataField = 'patternData_accOnly';

    parsedData = load(eopts.dataFile);
    parsedData = getfield(parsedData, eopts.dataField);

    aggRTs = cell(2,1);
    aggRTs{1} = NaN(length(estruct.submat), 160, 2);
    aggRTs{2} = NaN(length(estruct.submat), 160, 2);

    aaron_newfig;
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;
if (~pre_replotForCABN)
    jitterOffsets = [0 0];
end

    residRTs = squeeze(parsedData.results.late_residsEvs_congruent(:, :, 1));
    evVals   = squeeze(parsedData.results.late_residsEvs_congruent(:, :, 2));

    binnedRTs = NaN(size(residRTs, 1), eopts.numBins);
    for subjIdx = 1:size(residRTs, 1);
        subjVals = squeeze(evVals(subjIdx, :));
        subjRTs  = squeeze(residRTs(subjIdx, :));

        aggRTs{1}(subjIdx, :, 1) = [subjVals NaN(1, 160-length(subjVals))];
        aggRTs{1}(subjIdx, :, 2) = [subjRTs NaN(1, 160-length(subjRTs))];

        % Get within-subject quantiles
        qbins = [-1 quantile(subjVals, eopts.numBins-1) 1.01];
        for binIdx = 1:length(qbins)-1;
            evTrials = [subjVals>=qbins(binIdx) & subjVals<qbins(binIdx+1)];

            if (sum(evTrials) > 0)
                binnedRTs(subjIdx, binIdx) = nanmean(subjRTs(evTrials));
            end
        end
    end

if (~pre_replotForCABN)
    subplot(1, 2, 1);
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

    plot([1:(eopts.numBins)]+jitterOffsets(1), binnedRTs, 'o', 'Color', estruct.paperColors.memory, 'MarkerEdgeColor', estruct.paperColors.memory, ...
                                                               'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
                                                               'LineWidth', estruct.paperStyles.individual.LineWidth);
    axis([0.5 (eopts.numBins)+.5 -2 1.5]);
    ylims = get(gca, 'YLim');
    set(gca, 'YTick', [min(ylims):0.5:max(ylims)]);
    set(gca, 'XTick', [1 (eopts.numBins)]);
    set(gca, 'XTickLabel', {'Lowest', 'Highest'});
    xlabel(['Reinstatement index']);
    ylabel(['Response time']);

    title('Valid cue');
end
    hValid = errorbar([1:(eopts.numBins)], nanmean(binnedRTs), sem(binnedRTs), 'LineWidth', estruct.paperStyles.LineWidth, 'Color', estruct.paperColors.memory, ... 
                                                                               'LineStyle', estruct.paperStyles.LineStyle{1}, ...
                                                                               'CapSize', estruct.paperStyles.CapSize);

    residRTs = squeeze(parsedData.results.late_residsEvs_incongruent(:, :, 1));
    evVals   = squeeze(parsedData.results.late_residsEvs_incongruent(:, :, 2));

    binnedRTs = NaN(size(residRTs, 1), eopts.numBins);
    for subjIdx = 1:size(residRTs, 1);
        subjVals = squeeze(evVals(subjIdx, :));
        subjRTs  = squeeze(residRTs(subjIdx, :));

        aggRTs{2}(subjIdx, :, 1) = [subjVals NaN(1, 160-length(subjVals))];
        aggRTs{2}(subjIdx, :, 2) = [subjRTs NaN(1, 160-length(subjRTs))];

        % Get within-subject quantiles
        qbins = [-1 quantile(subjVals, eopts.numBins-1) 1.01];
        for binIdx = 1:length(qbins)-1;
            evTrials = [subjVals>=qbins(binIdx) & subjVals<qbins(binIdx+1)];

            if (sum(evTrials) > 0)
                binnedRTs(subjIdx, binIdx) = nanmean(subjRTs(evTrials));
            end
        end
    end

if (~pre_replotForCABN)
    subplot(1, 2, 2);
    hold on;
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

    plot([1:(eopts.numBins)]+jitterOffsets(2), binnedRTs, 'o', 'Color', estruct.paperColors.visual, 'MarkerEdgeColor', estruct.paperColors.visual, ...
                                                               'MarkerSize', estruct.paperStyles.individual.MarkerSize, ...
                                                               'LineWidth', estruct.paperStyles.individual.LineWidth);
    axis([0.5 (eopts.numBins)+.5 -2 1.5]);
    ylims = get(gca, 'YLim');
    set(gca, 'YTick', [min(ylims):0.5:max(ylims)]);
    set(gca, 'XTick', [1 (eopts.numBins)]);
    set(gca, 'XTickLabel', {'Lowest', 'Highest'});
    xlabel(['Reinstatement index']);
    
    title('Invalid cue');
end
    hInvalid = errorbar([1:(eopts.numBins)], nanmean(binnedRTs), sem(binnedRTs), 'Color', estruct.paperColors.visual, 'LineWidth', estruct.paperStyles.LineWidth, ...
                                                                                 'LineStyle', estruct.paperStyles.LineStyle{2}, ...
                                                                                 'CapSize', estruct.paperStyles.CapSize);
if (pre_replotForCABN)
    axis([0.5 (eopts.numBins)+.5 -0.3 0.3]);
    ylims = get(gca, 'YLim');
    set(gca, 'YTick', [min(ylims):0.1:max(ylims)]);
    set(gca, 'XTick', [1 (eopts.numBins)]);
    set(gca, 'XTickLabel', {'Lowest', 'Highest'});
    xlabel(['Reinstatement index']);
    ylabel(['Response time']);

    legend([hValid hInvalid], 'Valid cue', 'Invalid cue', 'Location', 'NorthEast');
end

    % Statistics
    trimLen = max(sum(~isnan(aggRTs{1}(:, :, 2))'));
    aggRTs{1} = aggRTs{1}(:, 1:trimLen, :);
    [p(1) rawEffectsByCong{1} subjSamplesByCong{1} gopts{1}] = ghootstrap(aggRTs{1}, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));

    trimLen = max(sum(~isnan(aggRTs{2}(:, :, 2))'));
    aggRTs{2} = aggRTs{2}(:, 1:trimLen, :);
    [p(2) rawEffectsByCong{2} subjSamplesByCong{2} gopts{2}] = ghootstrap(aggRTs{2}, 'subjsSampled', subjSamplesByCong{1}, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));
    cdRT = cohend(rawEffectsByCong{1}, rawEffectsByCong{2}, true);

    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, congruent trials: R=' ...
                        num2str(gopts{1}.baseEffect, '%.3f') ...
                        ', p=' num2str(p(1), '%.3f')]);

    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, incongruent trials: R=' ...
                        num2str(gopts{2}.baseEffect, '%.3f') ...
                        ', p=' num2str(p(2), '%.3f')]);

    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement evidence by residual zRT, congruent and incongruent different' ...
                        ': d=' num2str(cdRT, '%.3f')]);


