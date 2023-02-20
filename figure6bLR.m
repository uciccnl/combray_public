function figure6b;
% function figure6b;
%

pre_replotForCABN = false;

    whichExpt = 2;
    skip_load_subjs = true;
    initialize_opts_struct;

    eopts.dataFile = 'patternData_20170526.mat';
    eopts.dataField = 'patternData_accOnly';

    parsedData = load(eopts.dataFile);
    parsedData = getfield(parsedData, eopts.dataField);

    aaron_newfig;
    set(gca, 'FontSize', 32);
    set(gca, 'FontWeight', 'demi');
    hold on;

    lineCol(1, :) = estruct.paperColors.memory;
    lineCol(2, :) = estruct.paperColors.visual;
    jitterOffsets = [-0.05 0 0.05];

    title(['Reinstatement index for post-stimulus responses by ISI']);
    for cohIdx = 1:2;
        theseEv{cohIdx} = squeeze(parsedData.results.evidence_binned_by_ISI_by_coh_late(:, :, cohIdx));
if (~pre_replotForCABN)
        subplot(1, 2, cohIdx);
        set(gca, 'FontSize', 32);
        set(gca, 'FontWeight', 'demi');
        hold on;
        plot([1:3], theseEv{cohIdx}, 'o', 'Color', [lineCol(cohIdx, :)], 'MarkerEdgeColor', [lineCol(cohIdx, :)], ...
                                          'LineWidth', estruct.paperStyles.individual.LineWidth);
end
        errorbar(nanmean(theseEv{cohIdx}), sem(theseEv{cohIdx}), 'LineWidth', estruct.paperStyles.LineWidth, 'Color', lineCol(cohIdx, :), ...
                                                                 'LineStyle', estruct.paperStyles.LineStyle{cohIdx}, 'CapSize', estruct.paperStyles.CapSize);
    end

if (pre_replotForCABN)
    legend('Low coherence', 'High coherence', 'Location', 'NorthWest');

    ylabel(['Reinstatement index']);
    xlabel(['Anticipation period (seconds)']);
    set(gca, 'XTick', [1:length(eopts.whichISI)]);
    set(gca, 'XTickLabel', {'4.75', '6.75', '8.75'});
    set(gca, 'YTick', [0.025:0.025:0.125]);
    set(gca, 'XLim', [0.5 3.5]);
else
    cohName = {'Low'; 'High'};

    for cohIdx = 1:2;
        subplot(1, 2, cohIdx);
        title([cohName{cohIdx} ' coherence']);
        xlabel(['Anticipation period (seconds)']);
        set(gca, 'XTick', [1:length(eopts.whichISI)]);
        set(gca, 'XLim', [0.5 3.5]);
        set(gca, 'XTickLabel', {'4.75', '6.75', '8.75'});
        ylim([-0.2 0.5]);
        set(gca, 'YTick', [-0.2:0.1:0.5]);

    end

    subplot(1, 2, 1);
    ylabel(['Reinstatement index']);
end

    isis = [4.75, 6.75, 8.75];

    lowEvidence=parsedData.results.evidence_binned_by_ISI_by_coh_late(:,:,1);
    lateISIs=double(~isnan(lowEvidence));
    for isiIdx=1:3; lateISIs(:,isiIdx)=lateISIs(:,isiIdx)*isis(isiIdx); end
    lateISIs(lateISIs==0)=NaN;
    ghootArray_low(:,:,1)=lowEvidence;
    ghootArray_low(:,:,2)=lateISIs;
    [p rawEffectsLow  subjsSampledLow gopts]  = ghootstrap(ghootArray_low);
    disp([estruct.outputPrefix '(ghootstrap) (Late, low coherence) Reinstatement index by ISI: R=' ...
                        num2str(gopts.baseEffect, '%.3f') ...
                        ', P=' num2str(p, '%.3f')]);
    for isiIdx = 1:length(isis);
        disp([estruct.outputPrefix '(Late, low coherence) Reinstatement evidence at ISI=' num2str(isis(isiIdx)) ': ' ...
                num2str(nanmean(lowEvidence(:, isiIdx))) ...
                ' SEM ' num2str(sem(lowEvidence(:, isiIdx)))]);
    end

    highEvidence=parsedData.results.evidence_binned_by_ISI_by_coh_late(:,:,2);
    lateISIs=double(~isnan(highEvidence));
    for isiIdx=1:3; lateISIs(:,isiIdx)=lateISIs(:,isiIdx)*isis(isiIdx); end
    lateISIs(lateISIs==0)=NaN;
    ghootArray_high(:,:,1)=highEvidence;
    ghootArray_high(:,:,2)=lateISIs;
    [p rawEffectsHigh subjsSampledHigh gopts] = ghootstrap(ghootArray_high, 'subjsSampled', subjsSampledLow);
    disp([estruct.outputPrefix '(ghootstrap) (Late, high coherence) Reinstatement index by ISI: R=' ...
                        num2str(gopts.baseEffect, '%.3f') ...
                        ', P=' num2str(p, '%.3f')]);
    for isiIdx = 1:length(isis);
        disp([estruct.outputPrefix '(Late, high coherence) Reinstatement evidence at ISI=' num2str(isis(isiIdx)) ': ' ...
                num2str(nanmean(highEvidence(:, isiIdx))) ...
                ' SEM ' num2str(sem(highEvidence(:, isiIdx)))]);
    end

    cdRT = cohend(rawEffectsLow, rawEffectsHigh, true);
    disp([estruct.outputPrefix '(ghootstrap) (Late) Reinstatement index-ISI correlation different between coherence levels: ' ...
                        'd=' num2str(cdRT, '%.3f')]);
