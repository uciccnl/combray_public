function figure4(whichExpt);
% function figure4(whichExpt);
%
%   whichExpt = [1,2]
%

    if nargin < 1;
        whichExpt = 1;
    end

    skip_load_subjs = true;
    initialize_opts_struct;

    exptStrs = {'e1', 'e2'};
    estruct.outputPrefix = 'combray_pkg: ';

    fitsDir    = fullfile('fits', exptStrs{whichExpt});
    modelStrs  = {'c1ddm', 'c2ddm', 'cmsddm'};

    for fitIdx = 1:length(modelStrs);
        fitDats{fitIdx} = load(fullfile(fitsDir, ['fit_' modelStrs{fitIdx} '.mat']));
    end

    % Cut 'bad' fits (something weird with c1ddm, and with c2ddm in some of the very-short ISI E1 conditions. This isn't great, but is of minimal consequence to result.)
    % Just make sure to cut for everyone.
    cutFits = repmat(false, [length(fitDats{end}.finalChiSq) 1]);
    for fitIdx = 1:length(modelStrs);
        cutFits = cutFits | fitDats{fitIdx}.finalChiSq>1e8; % 10000;
    end

    for fitIdx = 2:length(modelStrs);
        fitDats{fitIdx}.finalChiSq(cutFits) = 0;
    end

    % Convert \chi^2 to BIC
    % Compute # of effective free params (not clamped)
    makeArray=@(x)([x.finalChiSq repmat(sum(x.lb~=x.ub),[length(x.finalChiSq) 1]) x.nTrialArray]);

    % 1ddm
    inArray = makeArray(fitDats{1});
    bicVals(:,3)=arrayfun(@bicx2, inArray(:,1), inArray(:,2), inArray(:,3));
    fitDats{1}.finalChiSq = bicVals(:,3);


    % 2ddm
    inArray = makeArray(fitDats{2});
    bicVals(:,1)=arrayfun(@bicx2, inArray(:,1), inArray(:,2), inArray(:,3));
    fitDats{2}.finalChiSq = bicVals(:,1);

    % msddm
    inArray = makeArray(fitDats{3});
    bicVals(:,2)=arrayfun(@bicx2, inArray(:,1), inArray(:,2), inArray(:,3));
    fitDats{3}.finalChiSq = bicVals(:,2);

    countBICs = ~isinf(bicVals(:,1));
    disp([estruct.outputPrefix 'BIC(MSDDM)=' num2str(sum(bicVals(countBICs, 2)), '%.3f') ...
                ', BIC(2DDM)=' num2str(sum(bicVals(countBICs, 1)), '%.3f')]);
    disp([estruct.outputPrefix 'BIC diff total (2DDM-MSDDM): ' num2str(sum(bicVals(countBICs,1)-bicVals(countBICs,2)), '%.3f') ...
                ', mean: ' num2str(mean(bicVals(countBICs,1)-bicVals(countBICs,2)), '%.3f') ...
                ', favoring: ' num2str(sum(bicVals(countBICs,2)<bicVals(countBICs,1))) ' out of ' num2str(sum(countBICs))]);

    disp([estruct.outputPrefix 'BIC(1DDM)=' num2str(sum(bicVals(countBICs, 3)), '%.3f')]);
    disp([estruct.outputPrefix 'BIC diff total (1DDM-MSDDM): ' num2str(sum(bicVals(countBICs,3)-bicVals(countBICs,2)), '%.3f') ...
                ', mean: ' num2str(mean(bicVals(countBICs,3)-bicVals(countBICs,2)), '%.3f') ...
                ', favoring: ' num2str(sum(bicVals(countBICs,2)<bicVals(countBICs,3))) ' out of ' num2str(sum(countBICs))]);


    condStrs = cell(length(estruct.cueLevels) * ...
                    length(estruct.cohLevels) * ...
                    length(estruct.isiLevels), 1);
    aggCondStrs = cell(length(estruct.cueLevels) * ...
                        length(estruct.cohLevels));
    aggCondChi = cell(1, 2);
    aggCondIdx = 0;
    condIdx    = 1;
    for cueIdx = 1:length(estruct.cueLevels);
        for cohIdx = 1:length(estruct.cohLevels);
            if (cohIdx == 1)
                condStrs{condIdx} = [num2str(estruct.cueLevels(cueIdx), '%.2f') '-' ...
                                         num2str(estruct.cohLevels(cohIdx), '%.2f')];
            else
                condStrs{condIdx} = num2str(estruct.cohLevels(cohIdx), '%.2f');
            end

            aggCondIdx = aggCondIdx + 1;
            aggCondStrs{aggCondIdx} = [num2str(estruct.cueLevels(cueIdx), '%.2f') '-' ...
                                         num2str(estruct.cohLevels(cohIdx), '%.2f')];

            for modelIdx = [2 3];
                aggCondChi{modelIdx}(aggCondIdx) = 0;
            end

            for isiIdx = 1:length(estruct.isiLevels);
                if (~isempty(condStrs{condIdx}))
                    condStrs{condIdx} = [condStrs{condIdx} '-'];
                end
                condStrs{condIdx} = [condStrs{condIdx} num2str(estruct.isiLevels(isiIdx))];

                for modelIdx = [2 3];
                    aggCondChi{modelIdx}(aggCondIdx) = aggCondChi{modelIdx}(aggCondIdx) + fitDats{modelIdx}.finalChiSq(condIdx);
                end

                condIdx = condIdx + 1;
            end
        end
    end

    % Model comparison (MS-DDM v 2-DDM); by cue-coh only
    aaron_newfig;
    set(gca, 'FontSize', 24);
    set(gca, 'FontWeight', 'demi');
    hold on;

    aggModelDiff = aggCondChi{2} - aggCondChi{3};
    includeConds = find(aggModelDiff~=0);

    aggCondStrs  = {aggCondStrs{includeConds}};
    aggModelDiff = aggModelDiff(includeConds);
    bar(aggModelDiff);
    ylabel({'Difference in BIC';' 2DDM \leftrightarrow MSDDM'});
    xlabel({'Condition'; '(Cue-Coh)'}); %
    set(gca, 'XTick', [1:length(aggModelDiff)]);
    set(gca, 'XTickLabel', aggCondStrs);
    set(gca, 'XLim', [0 length(aggModelDiff)+1]);


