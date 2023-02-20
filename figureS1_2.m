function figureS1_2(whichExpt, includeOne);
% function figureS1_2(whichExpt, includeOne);
%
%   whichExpt = [1,2]
%   includeOne = true if including 1DDM, false if not
%

    if (nargin < 1)
        whichExpt = 1;
    end

    if (nargin < 2);
        includeOne = false;
    end
    skip_load_subjs = true;
    initialize_opts_struct;

    exptStr = ['e' num2str(whichExpt)];

    fitsDir = fullfile('fits', exptStr);
    collatedData = load(fullfile(fitsDir, ['collatedData_' exptStr '.mat']));

    modelStrs  = {'c1ddm', 'cmsddm', 'c2ddm'};
    modelLegends = {'1DDM', 'MSDDM', '2DDM'};
    modelColor = {'g', 'k', 'r'};

    for fitIdx = 1:length(modelStrs);
        fitFunc{fitIdx} = str2func(['obj_' modelStrs{fitIdx}]);
        fitDat{fitIdx}  = load(fullfile(fitsDir, ['fit_' modelStrs{fitIdx} '.mat']));

        aggregatedBinEdges{fitIdx}       = [];
        aggregatedBinCountsUpper{fitIdx} = [];
        aggregatedBinCountsLower{fitIdx} = [];
        aggregatedFitCurveUpper{fitIdx}  = [];
        aggregatedFitCurveLower{fitIdx}  = [];
    end % fitIdx

    numConds   = length(fitDat{1}.nTrialArray);
    modelLineHandle = NaN(1, length(modelStrs));

    for condIdx = 1:numConds;
      for fitIdx = (1+(~includeOne)):length(modelStrs);
        if (1 > fitDat{fitIdx}.nTrialArray(condIdx))
            continue;
        end

        fitParams   = fitDat{fitIdx}.recoveredParameters(condIdx, :);
        fitSettings = fitDat{fitIdx}.fitSettings(condIdx, :);

        cueIdx = find(unique(fitDat{fitIdx}.fitSettings(:, 1)) == fitDat{fitIdx}.fitSettings(condIdx, 1));
        cohIdx = find(unique(fitDat{fitIdx}.fitSettings(:, 2)) == fitDat{fitIdx}.fitSettings(condIdx, 2));
        isiIdx = find(unique(fitDat{fitIdx}.fitSettings(:, 3)) == fitDat{fitIdx}.fitSettings(condIdx, 3));
        thisCue = fitDat{fitIdx}.fitSettings(condIdx, 1);
        thisCoh = fitDat{fitIdx}.fitSettings(condIdx, 2);
        thisISI = fitDat{fitIdx}.fitSettings(condIdx, 3);

        disp(['processing ' num2str(thisCue) '-' num2str(thisCoh) '-' num2str(thisISI)]);

        dataRTs   = collatedData.collatedData{cueIdx,cohIdx,isiIdx}(:,1);
        dataResps = collatedData.collatedData{cueIdx,cohIdx,isiIdx}(:,2);

        [~, ~, fitCurveUpper, fitCurveLower, tArray] = fitFunc{fitIdx}(fitParams, dataRTs, dataResps);

        dataRTsUpper = dataRTs(dataResps > 0.5);
        dataRTsLower = dataRTs(dataResps < 0.5);

        binWidth = 0.10;    % seconds

        % Trim excess p ...
        maxT = 1 + find(tArray>max(dataRTs),1,'first');
        fitCurveUpper = fitCurveUpper(1:maxT);
        fitCurveLower = fitCurveLower(1:maxT);
        tArray = tArray(1:maxT);

        % ... and re-normalize
        renormConst = fitCurveUpper(maxT)+fitCurveLower(maxT);
        fitCurveUpper = fitCurveUpper/renormConst;
        fitCurveLower = fitCurveLower/renormConst;

        % cdf -> pdf -> bin by binWidth
        fitCurveUpper = diff([0 fitCurveUpper]);
        fitCurveLower = diff([0 fitCurveLower]);

        clusterWidth = [0:binWidth:(tArray(end)+binWidth)];
        clusterEdge  = [1];
        cumFitCurveUpper = zeros(length(clusterWidth), 1);
        cumFitCurveLower = zeros(length(clusterWidth), 1);

        for clusterIdx = 2:length(clusterWidth);
            clusterEdge(clusterIdx) = find(tArray<=clusterWidth(clusterIdx),1,'last');
            cumFitCurveUpper(clusterIdx) = sum(fitCurveUpper((clusterEdge(clusterIdx-1)):clusterEdge(clusterIdx)));
            cumFitCurveLower(clusterIdx) = sum(fitCurveLower((clusterEdge(clusterIdx-1)):clusterEdge(clusterIdx)));
        end

        maxEdge = binWidth + max(dataRTs) - thisISI - 0.75;
        binEdges = [(-thisISI-.75):binWidth:maxEdge];
        dataRTsUpper = dataRTsUpper - thisISI - 0.75;
        dataRTsLower = dataRTsLower - thisISI - 0.75;
        binCountsUpper = histc(dataRTsUpper, binEdges);
        binCountsLower = histc(dataRTsLower, binEdges);

        if (length(binEdges) > length(aggregatedBinEdges{fitIdx}))
            aggregatedBinCountsUpper{fitIdx} = [zeros(length(binEdges)-length(aggregatedBinEdges{fitIdx}), 1) ; aggregatedBinCountsUpper{fitIdx}];
            aggregatedBinCountsLower{fitIdx} = [zeros(length(binEdges)-length(aggregatedBinEdges{fitIdx}), 1) ; aggregatedBinCountsLower{fitIdx}];

            aggregatedFitCurveUpper{fitIdx} = [zeros(length(binEdges)-length(aggregatedBinEdges{fitIdx}), 1) ; aggregatedFitCurveUpper{fitIdx}];
            aggregatedFitCurveLower{fitIdx} = [zeros(length(binEdges)-length(aggregatedBinEdges{fitIdx}), 1) ; aggregatedFitCurveLower{fitIdx}];

            aggregatedBinEdges{fitIdx} = binEdges;
        end

        aggregatedBinCountsUpper{fitIdx} = aggregatedBinCountsUpper{fitIdx} + [zeros(length(aggregatedBinEdges{fitIdx})-length(binEdges), 1) ; binCountsUpper];
        aggregatedBinCountsLower{fitIdx} = aggregatedBinCountsLower{fitIdx} + [zeros(length(aggregatedBinEdges{fitIdx})-length(binEdges), 1) ; binCountsLower];

        aggregatedFitCurveUpper{fitIdx} = aggregatedFitCurveUpper{fitIdx} + [zeros(length(aggregatedBinEdges{fitIdx})-length(binEdges), 1) ; cumFitCurveUpper];
        aggregatedFitCurveLower{fitIdx} = aggregatedFitCurveLower{fitIdx} + [zeros(length(aggregatedBinEdges{fitIdx})-length(binEdges), 1) ; cumFitCurveLower];

        upperScaleFac = sum(binCountsUpper+binCountsLower);
        lowerScaleFac = sum(binCountsUpper+binCountsLower);
    end % fitIdx
  end % condIdx

  % Aggregate (all)
  aggModelLineHandle = NaN(1, length(modelStrs));
  aaron_newfig;
  hold on;
  bar(aggregatedBinEdges{fitIdx}, aggregatedBinCountsUpper{fitIdx}, 'histc');
  bar(aggregatedBinEdges{fitIdx}, -aggregatedBinCountsLower{fitIdx}, 'histc');
  set(get(gca,'child'), 'FaceColor', estruct.paperColors.lightGray, 'EdgeColor', 'k', 'FaceAlpha', 0.8);

  upperScaleFac = sum(aggregatedBinCountsUpper{fitIdx}+aggregatedBinCountsLower{fitIdx});
  lowerScaleFac = sum(aggregatedBinCountsUpper{fitIdx}+aggregatedBinCountsLower{fitIdx});

  for fitIdx = (1+(~includeOne)):length(modelStrs);
    % Now a pdf, not a cdf, so renorm by sum
    renormConst = sum(aggregatedFitCurveUpper{fitIdx}) + sum(aggregatedFitCurveLower{fitIdx});
    aggregatedFitCurveUpper{fitIdx} = aggregatedFitCurveUpper{fitIdx}./renormConst;
    aggregatedFitCurveLower{fitIdx} = aggregatedFitCurveLower{fitIdx}./renormConst;
    aggModelLineHandle(fitIdx) = plot(aggregatedBinEdges{fitIdx}, upperScaleFac*aggregatedFitCurveUpper{fitIdx}, [modelColor{fitIdx} '-'], 'LineWidth', 2);
    plot(aggregatedBinEdges{fitIdx}, -lowerScaleFac*aggregatedFitCurveLower{fitIdx}, [modelColor{fitIdx} '-'], 'LineWidth', 2);
  end

  aggModelLineHandle = aggModelLineHandle((1+(~includeOne)):end);
  modelLegends       = {modelLegends{(1+(~includeOne)):end}};

  legend(aggModelLineHandle, modelLegends);
  xlabel(['RT (stimulus-locked, seconds)']);
  ylabel({'# responses'; 'cue-inconsistent \leftrightarrow cue-consistent'});
  set(gca, 'XLim', [min(aggregatedBinEdges{fitIdx}) 3.25])
