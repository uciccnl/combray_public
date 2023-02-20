function figure6aLR;
% function figure6aLR;
%

pre_replotForCABN=false;

    whichExpt = 2;
    skip_load_subjs = true;
    initialize_opts_struct;

    eopts.dataFile = 'patternData_20170526.mat';
    eopts.dataField_acc = 'patternData_accAll';  % For early responses, all trials
    eopts.dataField_all = 'patternData_accOnly'; % For late responses, skip errors (result stands either way, but this is arguably more conservative since we avoid errors that might arise from inattention)

    parsedData = load(eopts.dataFile);
    parsedData_acc = getfield(parsedData, eopts.dataField_acc);
    parsedData_all = getfield(parsedData, eopts.dataField_all);

    % predictive only for early responses
    estruct.cueLevels = estruct.cueLevels(2:end);

    lineCol(1,:) = estruct.paperColors.memory;
    lineCol(2,:) = estruct.paperColors.visual;

    % -- Evidence by probability
    aaron_newfig;
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

    subplot(1,2,1);
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

if (~pre_replotForCABN)
    plot([1:3], parsedData_all.results.early_evidence_binned_by_prob(:,[1:3]), 'o', 'Color', lineCol(1,:), ...
                                                                               'LineWidth', estruct.paperStyles.individual.LineWidth, ...
                                                                               'MarkerSize', estruct.paperStyles.individual.MarkerSize);

end
    errorbar([1:length(estruct.cueLevels)], nanmean(parsedData_all.results.early_evidence_binned_by_prob(:,[1:3])), ...
                                                             sem(parsedData_all.results.early_evidence_binned_by_prob(:,[1:3])), 'Color', lineCol(1,:), ...
                                                             'LineWidth', estruct.paperStyles.LineWidth, 'LineStyle', estruct.paperStyles.LineStyle{1});

    for cueIdx = 1:length(estruct.cueLevels);
        disp([estruct.outputPrefix '(Early) Reinstatement evidence at cue=' num2str(estruct.cueLevels(cueIdx)) ': ' ...
                num2str(nanmean(parsedData_all.results.early_evidence_binned_by_prob(:, cueIdx))) ...
                ' SEM ' num2str(sem(parsedData_all.results.early_evidence_binned_by_prob(:, cueIdx)))]);
    end

    set(gca, 'XTick', [1:length(estruct.cueLevels)]);
    set(gca, 'XTickLabel', {'60%', '70%', '80%'});

    title('Early responses');
    set(gca, 'XLim', [0.75 3.25]);
if (pre_replotForCABN)
    set(gca, 'YTick', [-.05:.025:.025]);
else
    set(gca, 'YTick', [-.4:.1:.3]);
end
    ylabel('Reinstatement index');
    xlabel('Cue level');

    subplot(1,2,2);
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

if (~pre_replotForCABN)
    plot([1:3], parsedData_acc.results.late_evidence_binned_by_prob(:,[1:3]), 'o', 'Color', lineCol(2,:), ...
                                                                              'LineWidth', estruct.paperStyles.individual.LineWidth, ...
                                                                              'MarkerSize', estruct.paperStyles.individual.MarkerSize);
end
    errorbar([1:length(estruct.cueLevels)], nanmean(parsedData_all.results.late_evidence_binned_by_prob(:,[1:3])), ...
                                                             sem(parsedData_all.results.late_evidence_binned_by_prob(:,[1:3])), 'Color', lineCol(2,:), ...
                                                             'LineWidth', estruct.paperStyles.LineWidth, 'LineStyle', estruct.paperStyles.LineStyle{2});

    for cueIdx = 1:length(estruct.cueLevels);
        disp([estruct.outputPrefix '(Late) Reinstatement evidence at cue=' num2str(estruct.cueLevels(cueIdx)) ': ' ...
                num2str(nanmean(parsedData_acc.results.late_evidence_binned_by_prob(:, cueIdx))) ...
                ' SEM ' num2str(sem(parsedData_acc.results.late_evidence_binned_by_prob(:, cueIdx)))]);
    end

    set(gca, 'XTick', [1:length(estruct.cueLevels)]);
    set(gca, 'XTickLabel', {'60%', '70%', '80%'});

    title('Late responses');
    set(gca, 'XLim', [0.75 3.25]);
if (pre_replotForCABN)
    set(gca, 'YTick', [.05:.025:.1]);
else
    ylim([-.4 .3]);
    set(gca, 'YTick', [-.4:.1:.3]);
end
    xlabel('Cue level');

    [h,p,ci,stats]=ttest2(parsedData_all.results.early_evidence_binned_by_prob(:),parsedData_acc.results.late_evidence_binned_by_prob(:));
    disp([estruct.outputPrefix 'Early evidence lower than late evidence: t_{' num2str(stats.df) '}=' num2str(stats.tstat) ', P=' num2str(p, '%.3f')]);


    totev = NaN(size(parsedData_acc.results.evidence_by_prob, 1), ...
                size(parsedData_acc.results.early_evidence_by_prob, 2) + size(parsedData_all.results.late_evidence_by_prob, 2), ...
                1);

    % z-score within-subj
    for subjIdx = 1:size(parsedData_acc.results.evidence_by_prob, 1);
        totev(subjIdx, :) = [parsedData_acc.results.early_evidence_by_prob(subjIdx,:,1) parsedData_all.results.late_evidence_by_prob(subjIdx,:,1)];
        totev(subjIdx, :) = [totev(subjIdx,:)-nanmean(totev(subjIdx,:))]/nanstd(totev(subjIdx,:));
    end

    zeev = NaN(size(parsedData_acc.results.early_evidence_by_prob));
    zeev_binned_by_prob = NaN(size(parsedData_acc.results.early_evidence_by_prob, 1), length(estruct.cueLevels));
    for subjIdx = 1:size(parsedData_acc.results.early_evidence_by_prob, 1);
        zeev(subjIdx,:,1) = totev(subjIdx,1:size(parsedData_acc.results.early_evidence_by_prob,2));
        zeev(subjIdx,:,2) = parsedData_acc.results.early_evidence_by_prob(subjIdx,:,2);

        for cueIdx = 1:length(estruct.cueLevels);
            zeevtrials = zeev(subjIdx,:,2)==estruct.cueLevels(cueIdx);
            zeev_binned_by_prob(subjIdx, cueIdx) = nanmean(zeev(subjIdx,zeevtrials,1));
        end
    end

    trimLen = max(sum(~isnan(zeev(:, :, 2))'));
    zeev=zeev(:,1:trimLen,:);
    [p rawEffects subjSamples gopts] = ghootstrap(zeev, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));
    disp([estruct.outputPrefix '(Early) Reinstatement index by cue level: R=' num2str(gopts.baseEffect, '%.3f') ...
                        ', P=' num2str(p, '%.3f')]);


    zlev = NaN(size(parsedData_all.results.late_evidence_by_prob));
    zlev_binned_by_prob = NaN(size(parsedData_all.results.late_evidence_by_prob, 1), length(estruct.cueLevels));
    for subjIdx = 1:size(parsedData_all.results.late_evidence_by_prob, 1);
        zlev(subjIdx,:,1) = totev(subjIdx,(size(parsedData_acc.results.early_evidence_by_prob,2)+1):end);
        zlev(subjIdx,:,2) = parsedData_all.results.late_evidence_by_prob(subjIdx,:,2);

        for cueIdx = 1:length(estruct.cueLevels);
            zlevtrials = zlev(subjIdx,:,2)==estruct.cueLevels(cueIdx);
            zlev_binned_by_prob(subjIdx, cueIdx) = nanmean(zlev(subjIdx,zlevtrials,1));
        end
    end

    trimLen = max(sum(~isnan(zlev(:, :, 2))'));
    zlev=zlev(:,1:trimLen,:);
    [p rawEffects subjSamples gopts] = ghootstrap(zlev, 'testFunc', @(x)(corr(x(:, 1), x(:, 2), 'type', 'Pearson')));
    disp([estruct.outputPrefix '(Late) Reinstatement index by cue level: R=' num2str(gopts.baseEffect, '%.3f') ...
                        ', P=' num2str(p, '%.3f')]);

