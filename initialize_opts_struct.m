if (0 == exist('whichExpt', 'var'))
    whichExpt = 1;
end

addpath('utils');

estruct.cueDuration  = 0.75;
estruct.cueLevels    = [0.5 0.6 0.7 0.8];
estruct.allCueLevels = unique([[1-estruct.cueLevels] estruct.cueLevels]);
estruct.cohLevels    = [0.65 0.85];

if (whichExpt == 1)
    estruct.isiLevels    = [0.5 1 4 6 8 10];
    estruct.expt_dir    = fullfile(pwd, 'data', 'e1');
    addpath(fullfile(estruct.expt_dir, 'analysis'));
    [estruct.submat estruct.sessmat skippedSubj params] = parseSubjs;
else
    estruct.isiLevels    = [4 6 8];
    estruct.expt_dir    = fullfile(pwd, 'data', 'e2');
    addpath(fullfile(estruct.expt_dir, 'analysis'));
    [estruct.submat estruct.sessmat skippedSubj params] = parseSubjs;
end

estruct.outputPrefix = ['combray_pkg: '];

estruct.submat = unique(estruct.sessmat(:,1));

estruct.paperColors.lightGray = [0.6 0.6 0.6];

estruct.paperColors.visual    = [240 120 60]/255;   % Orange
estruct.paperColors.memory    = [80 120 240]/255;   % Purple-blue
estruct.paperStyles.LineStyle{1} = '-.';
estruct.paperStyles.LineStyle{2} = ':';
estruct.paperStyles.CapSize      = 16;
estruct.paperStyles.LineWidth    = 12;

estruct.paperColors.individual.visual = estruct.paperColors.visual + 10/255; % 'y';
estruct.paperColors.individual.memory = estruct.paperColors.memory + 10/255; % 'c';
estruct.paperStyles.individual.MarkerSize = 8;
estruct.paperStyles.individual.LineWidth  = 4;

eopts.numBins  = 3;
eopts.whichISI = estruct.isiLevels;

if (0 == exist('skip_load_subjs', 'var'))
    for subjIdx = 1:length(estruct.submat);
        thisSubj          = estruct.submat(subjIdx);
        subjRec(thisSubj) = loadSubj(thisSubj, estruct.expt_dir);
    end
end

disp([estruct.outputPrefix num2str(length(estruct.submat)) ' subjects, ' num2str(size(estruct.sessmat,1)) ' blocks.']);
