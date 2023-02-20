function fit_combray_ddm_model(exptName, modelName, quickfit, saveFile, continueExisting)
% function fit_combray_ddm_model(exptName, modelName, [quickfit=true], [saveFile=['fit_' exptName '_' modelName '_1.mat']], [continueExisting=true])
%
% Valid exptName:
%   e1
%   e2
%   expt_intersect
%
% Valid modelName:
%   c1ddm_fullparams
%   c2ddm_fullparams
%   cmsddm_fullparams
%


%% Load collated data and task settings
combray_constants;

%% Load lb, ub, constraints, saveFile name
combray_model_constants;

if (nargin < 3)
    quickfit = true;
else
    if (ischar(quickfit))
        % qsub
        quickfit = logical(str2double(quickfit));
    end
end

if (nargin < 4)
    saveFile = default_saveFile;
end

if (nargin < 5)
    continueExisting = true;
else
    if (ischar(continueExisting))
        % qsub
        continueExisting = logical(str2double(continueExisting));
    end
end

%% Genetic algorithm options
if (quickfit)
    genmul = 100;
    popmul = 12;
    saveFile = [saveFile(1:end-4) '_quickfit.mat'];
else
    genmul = 1000;
    popmul = 50;
end

disp(['fit_combray_ddm_model: Fitting experiment ' exptName ', data file ' dataFileName]);
disp(['fit_combray_ddm_model: Fitting model: ' modelName]);
disp(['fit_combray_ddm_model: Using objective function: ' modelBase]);
disp(['fit_combray_ddm_model: Writing results to file: ' saveFile]);

doparallel = 'always';
opts = gaoptimset('UseParallel',doparallel,'Display','diagnose',...
                  'Generations',genmul*effectiveVars,...
                  'PopulationSize',popmul*effectiveVars);

nFits = length(cueArray(:,1))*length(cohArray)*length(dlArray);

% initialize
recoveredParameters = nan(nFits,nVars);
nTrialArray         = nan(nFits,1);
finalChiSq          = nan(nFits,1);
exitFlags           = nan(nFits,1);
fitSettings         = nan(nFits,3);

if (exist(saveFile, 'file') && continueExisting)
    disp(['fit_combray_ddm_model: Using existing saved file ' saveFile]);

    existingData = load(saveFile);

    recoveredParameters = existingData.recoveredParameters;
    nTrialArray         = existingData.nTrialArray;
    finalChiSq          = existingData.finalChiSq;
    exitFlags           = existingData.exitFlags;
    fitSettings         = existingData.fitSettings;
end

combray_dlParam = find(isnan(lb));
combray_rngSeed = 19850604;

runIter = 1;
for jj = 1:length(cueArray)
    for kk = 1:length(cohArray)
        for ll = 1:length(dlArray)

            % Unwrap cue/coh/dl
            cue = cueArray(jj);
            coh = cohArray(kk);
            dl  = dlArray(ll);

            %% Grab data and nTrials %%
            D = dat{jj,kk,ll};
            rt = D(:,1);
            resp = D(:,2);
            nTrials = length(rt);

            % Progress output
            disp(['Using ' num2str(nTrials) ' trials for'...
                  ' cue: ' num2str(cue) ...
                  ' coh: ' num2str(coh) ...
                  ' deadline: ' num2str(dl)]);

            if (length(finalChiSq) > runIter && ~isnan(finalChiSq(runIter)))
                disp(['Already ran. Skipping...']);
                runIter = runIter + 1;
                continue;
            end

            % Save for bookkeeping
            fitSettings(runIter,:) = [cue coh dl];
            nTrialArray(runIter) = nTrials;

            if (~nTrials)
                runIter = runIter + 1;
                continue;
            end

            % Deadline clamp
            if (~isempty(combray_dlParam))
                lb(combray_dlParam) = dl+.75;
                ub(combray_dlParam) = dl+.75;
            end

            % Random seed for reproducibility
            rng(combray_rngSeed,'twister');

            % Genetic algorithm for fitting
            [recoveredParameters(runIter,:),...
             finalChiSq(runIter), ...
             exitFlags(runIter)  ] = ...
                ga(@(x) objFunc(x, rt, resp), ...
                   length(lb), conA,conB,...
                   [],[], lb,ub,[],opts);

            if (strfind(modelName, 's2only'))
                [~,finalChiSq(runIter)] = objFunc(recoveredParameters(runIter,:), rt, resp);
            end

            % Save
            save(saveFile, ...
                 'recoveredParameters',...
                 'nTrialArray',...
                 'finalChiSq',...
                 'exitFlags',...
                 'fitSettings', ...
                 'sessmat', ...
                 'opts', ...
                 'lb', ...
                 'ub', ...
                 'exptName', ...
                 'modelName');

            runIter = runIter + 1;
        end
    end
end
