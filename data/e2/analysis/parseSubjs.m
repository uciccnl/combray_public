function [submat sessmat skippedSubj params] = parseSubjs(subjFile, varargin)
% function [submat sessmat skippedSubj params] = parseSubjs([subjFile='subjSummary_e2.mat'], ...)
%
% Plot histograms of subject exclusion variables, and identify excluded subjects
%
% Returns arrays of included and skipped subjects & sessions
%
% opts = parse_args(varargin, 'verbose', false, ...
%                            'savefigs', false, ...
%                            'doPlot', false);
%

opts = parse_args(varargin, 'verbose', false, ...
                            'savefigs', false, ...
                            'doPlot', false);

%%
% Constants
numBlocks    = 2;
numTrials(1) = 100;
numTrials(2) = 80;
numPhases    = length(numTrials);

if (nargin < 1 || isempty(subjFile))
    subjFile = 'subjSummary_e2.mat';
end

%%
% Initialize
subjSummary = load(subjFile);
subjSummary = subjSummary.subjSummary;

% Non-empty subjects & sessions
submat  = find(arrayfun(@(x)(~isempty(x.calibDiffs)), subjSummary));
sessmat = ones(numBlocks, max(submat));
sessmat = sessmat(:, submat);

%%
% Exclusion criterion: 10% learning-phase trials skipped in either block
%
params.learnSkipThresh = 0.1;
if (opts.doPlot)
    if (exist('aaron_newfig', 'file'))
        aaron_newfig;
    else
        figure;
    end
end

for blockIdx = 1:numBlocks;
    if (opts.doPlot)
        subplot(numBlocks, 1, blockIdx);
        hold on;
    end

    % learning phase is phase #1
    skippedLearnTrials = arrayfun(@(x)(x.skippedTrials{1, blockIdx}), subjSummary(submat));

    if (opts.doPlot)
        numEl = hist(skippedLearnTrials);
        hist(skippedLearnTrials);

        % Plot threshold line
        plot(ones(1, max(numEl))*(params.learnSkipThresh * numTrials(1)), [1:max(numEl)], 'r--', ...
                                                                                            'LineWidth', 2);
        ylabel(['Block ' num2str(blockIdx)]);
    end

    skippedSubj{1}(blockIdx, :) = skippedLearnTrials > (params.learnSkipThresh * numTrials(1));
    sessmat(blockIdx, :)        = sessmat(blockIdx, :) & ~skippedSubj{1}(blockIdx, :);

    disp(['1. Learn-phase skip, block ' num2str(blockIdx) ...
          ', excluding subjects: ' num2str(submat(find(skippedSubj{1}(blockIdx, :))))]);
end

if (opts.doPlot)
    subplot(numBlocks, 1, 1);
    title(['Learning-phase trials skipped: ' ...
            num2str(sum(any(skippedSubj{1}))) ' excluded']);
    if (opts.savefigs)
        print('-depsc', '-r800', 'parseSubjs_1_learnPhaseTrialsSkipped.eps');
    end
end

%%
% Exclusion criterion: 10% test-phase trials skipped in either block
%
params.testSkipThresh = 0.1;
if (opts.doPlot)
    if (exist('aaron_newfig', 'file'))
        aaron_newfig;
    else
        figure;
    end
end

for blockIdx = 1:numBlocks;
    if (opts.doPlot)
        subplot(numBlocks, 1, blockIdx);
        hold on;
    end

    % test phase is phase #2
    skippedTestTrials = arrayfun(@(x)(x.skippedTrials{2, blockIdx}), subjSummary(submat));

    if (opts.doPlot)
        numEl = hist(skippedTestTrials);
        hist(skippedTestTrials);

        % Plot threshold line
        plot(ones(1, max(numEl))*(params.testSkipThresh * numTrials(2)), [1:max(numEl)], 'r--', ...
                                                                                        'LineWidth', 2);
        ylabel(['Block ' num2str(blockIdx)]);
    end

    skippedSubj{2}(blockIdx, :) = skippedTestTrials > (params.testSkipThresh * numTrials(2));
    sessmat(blockIdx, :)        = sessmat(blockIdx, :) & ~skippedSubj{2}(blockIdx, :);
    disp(['2. Test-phase skip, block ' num2str(blockIdx) ...
          ', excluding subjects: ' num2str(submat(find(skippedSubj{2}(blockIdx, :))))]);
end
if (opts.doPlot)
    subplot(numBlocks, 1, 1);
    title(['Test-phase trials skipped: ' ...
            num2str(sum(any(skippedSubj{2}))) ' excluded']);
    if (opts.savefigs)
        print('-depsc', '-r800', 'parseSubjs_2_testPhaseTrialsSkipped.eps');
    end
end

%%
% Exclusion criterion: Errors on late responses in learning phase in either block.
%
params.learnErrorThresh = 0.3;
if (opts.doPlot)
    if (exist('aaron_newfig', 'file'))
        aaron_newfig;
    else
        figure;
    end
end
for blockIdx = 1:numBlocks;
    if (opts.doPlot)
        subplot(numBlocks, 1, blockIdx);
        hold on;
    end

    errorTrials = arrayfun(@(x)(x.errorsByPhase{1, blockIdx}), subjSummary(submat)) + skippedLearnTrials;

    if (opts.doPlot)
        numEl = hist(errorTrials);
        hist(errorTrials);

        plot(ones(1, max(numEl))*(params.learnErrorThresh * numTrials(1)), [1:max(numEl)], 'r--', ...
                                                                                             'LineWidth', 2);
        ylabel(['Block ' num2str(blockIdx)]);
    end

    skippedSubj{3}(blockIdx, :) = errorTrials > (params.learnErrorThresh * numTrials(1));
    sessmat(blockIdx, :)        = sessmat(blockIdx, :) & ~skippedSubj{3}(blockIdx, :);
    disp(['3. Late errors plus skipped trials, block ' num2str(blockIdx) ...
          ', excluding subjects: ' num2str(submat(find(skippedSubj{3}(blockIdx, :))))]);
end
if (opts.doPlot)
    subplot(numBlocks, 1, 1);
    title(['Errors on late responses + skipped trials in learning phase: ' ...
            num2str(sum(any(skippedSubj{3}))) ' excluded']);
    if (opts.savefigs)
        print('-depsc', '-r800', 'parseSubjs_3_errorsLateResponses.eps');
    end
end

%%
% Excusion criterion: Perceptual coherence calibration levels not different by at least 0.05 on any stimulus, for any block
%
params.calibThresh = 0.05;
if (opts.doPlot)
    if (exist('aaron_newfig', 'file'))
        aaron_newfig;
    else
        figure;
    end
end
for blockIdx = 1:numBlocks;
    if (opts.doPlot)
        subplot(numBlocks, 1, blockIdx);
        hold on;
    end

    calibDiffs  = arrayfun(@(x)(x.calibDiffs(blockIdx)), subjSummary(submat));

    if (opts.doPlot)
        numEl = hist(calibDiffs);
        hist(calibDiffs);

        plot(ones(1, max(numEl))*(params.calibThresh), [1:max(numEl)], 'r--', ...
                                                                       'LineWidth', 2);
        ylabel(['Block ' num2str(blockIdx)]);
    end

    skippedSubj{4}(blockIdx, :) = calibDiffs < params.calibThresh;
    sessmat(blockIdx, :)        = sessmat(blockIdx, :) & ~skippedSubj{4}(blockIdx, :);
    disp(['4. Calibration accuracy differences, block ' num2str(blockIdx) ...
          ', excluding subjects: ' num2str(submat(find(skippedSubj{4}(blockIdx, :))))]);
end
if (opts.doPlot)
    subplot(numBlocks, 1, 1);
    title(['Calibration accuracy differences: ' ...
            num2str(sum(any(skippedSubj{4}))) ' excluded']);
    if (opts.savefigs)
        print('-depsc', '-r800', 'parseSubjs_4_calibrationDifferences.eps');
    end
end

%%
% Exclusion criterion: Too many or too few early responses in either block, test or learn
%   (Rationale: They are not paying attention to the cue or the stimulus)
%
params.earlyRespFrac{1} = [0.00 0.70];      % Phase 1: Should have few early responses
params.earlyRespFrac{2} = [0.05 0.85];      % Phase 2: Should have many early responses
if (opts.doPlot)
    if (exist('aaron_newfig', 'file'))
        aaron_newfig;
    else
        figure;
    end
end
if (0)
for blockIdx = 1:numBlocks;
    skippedSubj{5}(blockIdx, :) = zeros(1, length(submat));

    for phaseIdx = 1:numPhases;
        thisEarlyResp = arrayfun(@(x)(x.earlyRespFrac{phaseIdx, blockIdx}), subjSummary(submat));
        if (opts.doPlot)
            subplot(numBlocks, numPhases, numBlocks*(blockIdx-1) + phaseIdx);
            hold on;

            numEl = hist(thisEarlyResp, 20);
            hist(thisEarlyResp, 20);
            hold on;

            % Plot threshold lines
            if (phaseIdx == 2)
                plot(ones(1,max(numEl))*params.earlyRespFrac{phaseIdx}(1), [1:max(numEl)], 'r--', ...
                                                                                 'LineWidth', 2);
            end
            plot(ones(1,max(numEl))*params.earlyRespFrac{phaseIdx}(2), [1:max(numEl)], 'r--', ...
                                                                             'LineWidth', 2);
            ylabel(['Block ' num2str(blockIdx) ...
                    ', phase ' num2str(phaseIdx)]);
        end

        if (phaseIdx == 1)
            % Can't have too few early responses in learn, but can have too many
            skippedSubj{5}(blockIdx, :) = skippedSubj{5}(blockIdx, :) | ...
                                          thisEarlyResp > params.earlyRespFrac{phaseIdx}(2);
        else
            % Can have either too few or too many in test
            skippedSubj{5}(blockIdx, :) = skippedSubj{5}(blockIdx, :) | ...
                                          thisEarlyResp < params.earlyRespFrac{phaseIdx}(1) | ...
                                          thisEarlyResp > params.earlyRespFrac{phaseIdx}(2);
        end
    end
    sessmat(blockIdx, :)        = sessmat(blockIdx, :) & ~skippedSubj{5}(blockIdx, :);
    disp(['5. Early responses, block ' num2str(blockIdx) ...
          ', excluding subjects: ' num2str(submat(find(skippedSubj{5}(blockIdx, :))))]);

    if (opts.doPlot)
        subplot(numBlocks, numPhases, 1);
        title(['5. Too few or too many early responses: ' ...
                num2str(sum(any(skippedSubj{5}))) ' excluded']);
        if (opts.savefigs)
            print('-depsc', '-r800', 'parseSubjs_5_earlyRespFrac.eps');
        end
    end
end
end

%%
% Exclusion criterion: 'Superfast' RTs
%
params.superFastRT    = 0.5;      % in seconds
params.superFastFrac  = 0.5;      % Proportion below superfast threshold
if (opts.doPlot)
    if (exist('aaron_newfig', 'file'))
        aaron_newfig;
    else
        figure;
    end
end
for blockIdx = 1:numBlocks;
    skippedSubj{6}(blockIdx, :) = zeros(1, length(submat));

    for phaseIdx = 1:numPhases;
        subjRTs = arrayfun(@(x)(mean(x.subjRTs{blockIdx, phaseIdx}<=params.superFastRT)), subjSummary(submat));
        if (opts.doPlot)
            subplot(numBlocks, numPhases, numBlocks*(blockIdx-1) + phaseIdx);
            hold on;

            numEl = hist(subjRTs, 20);
            hist(subjRTs, 20);
            hold on;

            % Plot threshold lines
            plot(ones(1,max(numEl))*params.superFastFrac, [1:max(numEl)], 'r--', ...
                                                                          'LineWidth', 2);
            ylabel(['Block ' num2str(blockIdx) ...
                    ', phase ' num2str(phaseIdx)]);
        end

        % Can have either too few or too many in test
        skippedSubj{6}(blockIdx, :) = skippedSubj{6}(blockIdx, :) | ...
                                      subjRTs > params.superFastFrac;
    end
    sessmat(blockIdx, :)        = sessmat(blockIdx, :) & ~skippedSubj{6}(blockIdx, :);
    disp(['6. Super-fast RTs block ' num2str(blockIdx) ...
          ', excluding subjects: ' num2str(submat(find(skippedSubj{6}(blockIdx, :))))]);

    if (opts.doPlot)
        subplot(numBlocks, numPhases, 1);
        title(['6. Super-fast RTs: ' ...
                num2str(sum(any(skippedSubj{6}))) ' excluded']);
        if (opts.savefigs)
            print('-depsc', '-r800', 'parseSubjs_6_superFastRTs.eps');
        end
    end
end

[exclSess exclSubj] = ind2sub(size(sessmat), find(sessmat==0));
if (0)
    disp(['Excluded ' num2str(sum(~sessmat(:))) ...
          ' sessions: ']);
    num2str([submat(exclSubj)' exclSess])
end

[inclSess inclSubj] = ind2sub(size(sessmat), find(sessmat));
disp(['Included ' num2str(sum(sessmat(:))) ...
      ' sessions: ']);
num2str([submat(inclSubj)' inclSess]')
sessmat = [submat(inclSubj)' inclSess];

allExcluded   = any(skippedSubj{1}) | any(skippedSubj{2}) | any(skippedSubj{3}) | any(skippedSubj{4}) | any(skippedSubj{5});
allIncluded   = ~allExcluded;
allExcluded   = find(allExcluded);
allIncluded   = find(allIncluded);
totalExcluded = length(allExcluded);
totalIncluded = length(allIncluded);
if (0)
    disp(['Subjects excluded: ' ...
           num2str(length(allExcluded)) ' / ' ...
           num2str(length(submat)) ' subjects (' ...
           num2str(submat(allExcluded)), ')']);
    disp(['Subjects included: ' ...
           num2str(length(allIncluded)) ' / ' ...
           num2str(length(submat)) ' subjects (' ...
           num2str(submat(allIncluded)), ')']);
end
submat = submat(allIncluded);

save(subjFile, 'subjSummary', 'params', 'skippedSubj', 'submat', 'sessmat');
