function plotrec = plotSubj(subj, plotPhase, doPlot, earlyOnly, zAfter, dataDir, subjSumFile)
% function plotrec = plotSubj(subj, [plotPhase], [doPlot], [earlyOnly], [zAfter], [dataDir], [subjSumFile])
%
% usual call:
%   plotSubj(subj, 0, 0, 0, -1, [], [])
%
% INPUT:
% plotPhase: 0 = all (default); 1 = learn only; 2 = test only; 2.1 = early test; 2.2 = late test
% doPlot: 0 = no (default); 1 = yes
% earlyOnly: -1 = late responses (after stim onset) only; 0 = all trials (default); 1 = early responses only
% zAfter: -1 = no z-scoring at all; 0 = z-score within subject (default); 1 = z-score within type
%
% OUTPUT:
% plotrec array
% plotrec(:, 1): transition probability from cue fractal to image
% plotrec(:, 2): reaction time
% plotrec(;, 3): correct response? 1 yes 0 no
% plotrec(:, 4): observed fraction of perceptual evidence congruent with given response (0-1)
% plotrec(:, 5): total amount of perceptual evidence observed (# of frames)
% plotrec(;, 6): hardcoded perceptual coherence of this trial (0-1)
% plotrec(:, 7): response key
% plotrec(:, 8): best response key
% plotrec(:, 9): ISI
% plotrec(:, 10): phase (1 = learn, 2 = test)
% plotrec(:, 11): block (1 or 2)
% plotrec(:, 12): calibrated accuracy for this perceptual coherence
% plotrec(:, 13): ITI preceding this trial
%
% and subjSummary.mat contains a record of the parameters useful to deciding subject exclusions
%

% verbose = 0: print nothing; 1: print only summary in TSV format; 2: print detailed
verbose  = 1;

plotcols = ['r' 'g'];
learnLen = 100;
testLen  = 80;
calibLen = 30;

% cmdline
if (ischar(subj))
    subj = str2num(subj);
end

if (nargin < 2)
    plotPhase = 0;
end

if (nargin < 3)
    doPlot = 0;
end

if (nargin < 4)
    earlyOnly = 0;
end

if (nargin < 5)
    zAfter   = 0;
end

if (nargin < 6)
    dataDir = '../';
end

if (nargin < 7)
    subjSumFile = 'subjSummary_expt2';
end

sd = loadSubj(subj, dataDir);

cueDuration = 0.75;

earlymask = [sd.trials(:).RT]<=[[sd.trials(:).ISI]+cueDuration];
earlymask = earlymask';
RTs       = [sd.trials(:).RT];
% z-score RTs within-subject
if (zAfter == 0)
    RTs(~isnan(RTs)) = (RTs(~isnan(RTs)) - nanmean(RTs))/nanstd(RTs);
end

plotrec = zeros(length(sd.trials), 13);
plotrec(:, 2) = NaN;

calibFiles = dir([dataDir 'combray_calib_' num2str(subj, '%.2d') '_*.mat']);

if (length(calibFiles) == 0)
    disp(['No calibration files! Skipping subject ' num2str(subj, '%.2d')]);
    return;
end

for calibIdx = 1:length(calibFiles)
    cfd{calibIdx} = load([dataDir calibFiles(calibIdx).name]);

    for stairIdx = 1:size(cfd{calibIdx}.response, 1);
        perNoise(calibIdx, stairIdx) = cfd{calibIdx}.p_stair(ceil(stairIdx/2));
    end
end

numBlocks = length(sd.calibRec);

% Actual coherence level: 2 x 4
actualCoh = zeros(numBlocks, 4);
for blockIdx = 1:numBlocks;
    for stimIdx = 1:4;
        actualCoh(blockIdx, stimIdx) = mean(sd.calibRec{blockIdx}{stimIdx}.response(1:calibLen));
    end
end

for rowIdx = 1:length(sd.trials);
    thisTp = sd.params.tp(sd.trials(rowIdx).cue, sd.trials(rowIdx).image, sd.trials(rowIdx).block);

    prow     = sd.params.tp(sd.trials(rowIdx).cue, :, sd.trials(rowIdx).block);
    bestResp = find(prow == max(prow));
    if (thisTp == 0.5)
        bestResp = sd.trials(rowIdx).resp;
    end

    if (sd.trials(rowIdx).phase == plotPhase || ~plotPhase || mod(plotPhase,1))
        if (rowIdx > length(sd.trials)/2)
            testIdx = rowIdx - length(sd.trials)/2;
        else
            testIdx = rowIdx;
        end

        if (mod(plotPhase,1))
            % early or late learning?
            if ((plotPhase == 0.5 && testIdx > learnLen/2) || ...
                (plotPhase == 1.5 && (testIdx <= learnLen/2 || testIdx > learnLen)))
                continue;
            end
        end

        % early or late test?
        if ((plotPhase == 2.1) && ...
            ((testIdx <= learnLen) || (testIdx-learnLen > testLen/2)))
            continue;
        end

        if ((plotPhase == 2.2) && ...
            ((testIdx <= learnLen) || (testIdx-learnLen <= testLen/2)))
            continue;
        end

%        disp(['Plotting ' num2str(rowIdx)]);
        plotrec(rowIdx, :) = [double(thisTp), double(RTs(rowIdx)), double(sd.trials(rowIdx).accurate), ...
                              double(sd.observedFraction(rowIdx)), double(sd.observationCount(rowIdx)), ...
                              double(perNoise(sd.trials(rowIdx).block, sd.trials(rowIdx).corrResp)), double(sd.trials(rowIdx).resp), ...
                              double(bestResp), double(sd.trials(rowIdx).ISI), double(sd.trials(rowIdx).phase), double(sd.trials(rowIdx).block), ...
                              double(actualCoh(sd.trials(rowIdx).block, sd.trials(rowIdx).corrResp)) double(sd.trials(rowIdx).ITI)];

    end
end

if (verbose > 1)
    disp(['Skipped ' num2str(sum(isnan(plotrec(:,2)))) ...
          ' trials out of ' num2str(sum(plotrec(:,2)~=0))]);
end

zmask     = ~isnan(plotrec(:,2));

% NB: Assumes fixed ISI
early     = sum(earlymask & zmask);
late      = sum(~earlymask & zmask);

hiearly   = sum(earlymask & zmask & plotrec(:, 6)==0.65);
loearly   = sum(earlymask & zmask & plotrec(:, 6)==0.85);
hilate    = sum(~earlymask & zmask & plotrec(:, 6)==0.65);
lolate    = sum(~earlymask & zmask & plotrec(:, 6)==0.85);

latemem{1}  = ~earlymask & zmask & (plotrec(:, 1)==0.8 | plotrec(:, 1)==0.2);
lateRTs{1}  = plotrec(latemem{1}, 2);
latemem{2}  = ~earlymask & zmask & (plotrec(:, 1)==0.7 | plotrec(:, 1)==0.3);
lateRTs{2}  = plotrec(latemem{2}, 2);
latemem{3}  = ~earlymask & zmask & (plotrec(:, 1)==0.6 | plotrec(:, 1)==0.4);
lateRTs{3}  = plotrec(latemem{3}, 2);
latemem{4}  = ~earlymask & zmask & (plotrec(:, 1)==0.5);
lateRTs{4}  = plotrec(latemem{4}, 2);

if (verbose > 1)
    disp(['RTs for late responses at mem = 0.8/0.2: ' num2str(nanmean(lateRTs{1})) ...
          ' +/- ' num2str(nanstd(lateRTs{1})/sqrt(sum(~isnan(lateRTs{1}))))]);
    disp(['RTs for late responses at mem = 0.7/0.3: ' num2str(nanmean(lateRTs{2})) ...
          ' +/- ' num2str(nanstd(lateRTs{2})/sqrt(sum(~isnan(lateRTs{2}))))]);
    disp(['RTs for late responses at mem = 0.6/0.4: ' num2str(nanmean(lateRTs{3})) ...
          ' +/- ' num2str(nanstd(lateRTs{3})/sqrt(sum(~isnan(lateRTs{3}))))]);
    disp(['RTs for late responses at mem = 0.5: ' num2str(nanmean(lateRTs{4})) ...
          ' +/- ' num2str(nanstd(lateRTs{4})/sqrt(sum(~isnan(lateRTs{4}))))]);
end

earlymem(1) = sum(earlymask & zmask & (plotrec(:, 1)==0.8 | plotrec(:, 1)==0.2));
totalmem(1) = sum(zmask & (plotrec(:, 1)==0.8 | plotrec(:, 1)==0.2));
earlymem(2) = sum(earlymask & zmask & (plotrec(:, 1)==0.7 | plotrec(:, 1)==0.3));
totalmem(2) = sum(zmask & (plotrec(:, 1)==0.7 | plotrec(:, 1)==0.3));
earlymem(3) = sum(earlymask & zmask & (plotrec(:, 1)==0.6 | plotrec(:, 1)==0.4));
totalmem(3) = sum(zmask & (plotrec(:, 1)==0.6 | plotrec(:, 1)==0.4));
earlymem(4) = sum(earlymask & zmask & (plotrec(:, 1)==0.5));
totalmem(4) = sum(zmask & (plotrec(:, 1)==0.5));

if (verbose > 1)
    disp(['Early responses at mem = 0.8/0.2: ' num2str(earlymem(1)) ...
          ' out of ' num2str(totalmem(1))]);
    disp(['Early responses at mem = 0.7/0.3: ' num2str(earlymem(2)) ...
          ' out of ' num2str(totalmem(2))]);
    disp(['Early responses at mem = 0.6/0.4: ' num2str(earlymem(3)) ...
          ' out of ' num2str(totalmem(3))]);
    disp(['Early responses at mem = 0.5: ' num2str(earlymem(4)) ...
          ' out of ' num2str(totalmem(4))]);

    disp([num2str(early) ' early responses and ' ...
          num2str(late) ' late responses out of ' ...
          num2str(size(plotrec(zmask,:),1)) ' responded trials.']);
end


if (earlyOnly == 1)
    zmask = earlymask & zmask;
elseif (earlyOnly == -1)
    zmask = ~earlymask & zmask;
end

if (verbose > 1)
    disp([num2str(sum(plotrec(zmask, 3))) ' correct and ', ...
          num2str(sum(plotrec(zmask, 3)==0)) ' incorrect out of ' ...
          num2str(size(plotrec(zmask,:),1)) ' included trials.']);
end

plotrec(~zmask, 2) = NaN;
plotrec(~zmask, 3) = NaN;


%%
% Print CSV summary for spreadsheet
%
% Print numPrac, Skipped trials (learn1,learn2,test1,test2),
% Early responses (Learn, test 0.65/0.85, test m=0.8, test m=0.7, test m=0.6, test m=0.5),
% Late RT (test m=0.8, test m=0.7, test m=0.6, test m=0.5),
% Errors on late responses (Learn/Test)
%
if (verbose > 0)
    try
        subjSummary = load(subjSumFile);
        subjSummary = subjSummary.subjSummary;
    catch
        subjSummary = [];
    end

    % Practice sessions
    numPrac = dir([dataDir 'combray_prac_' ...
                   num2str(subj, '%.2d') ...
                  '*.mat']);
    numPrac = length(numPrac);

    % Skipped trials in each block of (learn, test)
    % Early responses in each block of (learn, test), across all conditions
    for phaseIdx = [1 2];
        thisPhaseMask = plotrec(:, 10) == phaseIdx;
        for blockIdx = 1:numBlocks;
            blockMask = plotrec(:, 11) == blockIdx;
            skippedTrials{phaseIdx,blockIdx} = sum(isnan(plotrec(thisPhaseMask & blockMask, 2)));
            earlyRespFrac{phaseIdx,blockIdx} = sum(plotrec(thisPhaseMask & blockMask, 2) < (plotrec(thisPhaseMask & blockMask, 9)+cueDuration))/sum(thisPhaseMask & blockMask);
        end
    end

    % Non-skipped trials in learn
    for blockIdx  = 1:numBlocks;
        phaseMask{1}  = plotrec(:, 10) == 1 & ~isnan(plotrec(:, 2)) & plotrec(:, 11) == blockIdx;

        % Early responses in learn phase
        earlyLearn(blockIdx) = sum(plotrec(phaseMask{1}, 2) < (plotrec(phaseMask{1}, 9)+cueDuration));
    end

    % Non-skipped trials in test
    phaseMask{2}     = plotrec(:, 10) == 2 & ~isnan(plotrec(:, 2));
    % # of early responses in test at each perceptual coherence level
    cohLevels    = [0.65 0.85];
    for maskIdx  = [1 2];
        thisCoh                 = cohLevels(maskIdx);
        thisMask                = plotrec(phaseMask{2}, 6) == thisCoh;
        earlyTestPer{maskIdx}   = sum(plotrec(thisMask, 2) < plotrec(thisMask, 9)+cueDuration);
    end

    % # of early responses in test at each memory level
    cueLevels    = [0.8 0.7 0.6 0.5];
    for maskIdx  = 1:4;
%        thisCueProb            = 1 - 0.1 - (maskIdx/10); % 0.8, 0.7, 0.6, 0.5
        thisCueProb            = cueLevels(maskIdx);
        thisMask               = plotrec(phaseMask{2}, 1) == thisCueProb | plotrec(phaseMask{2}, 1) == (1-thisCueProb);
        earlyTestMem{maskIdx}  = sum(plotrec(thisMask, 2) < plotrec(thisMask, 9)+cueDuration);
    end

    % Mean late RTs in test at each memory level
    for maskIdx  = 1:4;
        thisCueProb            = 1 - 0.1 - (maskIdx/10); % 0.8, 0.7, 0.6, 0.5
        thisMask               = phaseMask{2} & (plotrec(:, 1) == thisCueProb | plotrec(:, 1) == (1-thisCueProb)) & (plotrec(:, 2) > plotrec(:, 9)+cueDuration);
        lateTestMemRT{maskIdx} = nanmean(plotrec(thisMask, 2));
    end

    % Errors in learn, test (note this is LATE errors ONLY)
    for phaseIdx = [1 2];
        for blockIdx = 1:numBlocks;
            blockMask = plotrec(:, 11) == blockIdx;
            lateMask = plotrec(phaseMask{phaseIdx} & blockMask, 2) > plotrec(phaseMask{phaseIdx} & blockMask, 9)+cueDuration;
            errorsByPhase{phaseIdx,blockIdx} = sum(plotrec(lateMask, 3) == 0);
        end
    end

    % Differences between calibration accuracies for 0.65 and 0.85, in each block
    acc = zeros(numBlocks, 2);
    for blockIdx = 1:numBlocks;
        for stimIdx = 1:4;
            % perIdx 1 = 0.65, 2 = 0.85
            perIdx                = (sd.calibRec{blockIdx}{stimIdx}.pThreshold == 0.85)+1;
            acc(blockIdx, perIdx) = acc(blockIdx, perIdx) + mean(sd.calibRec{blockIdx}{stimIdx}.response(1:calibLen));
        end
        calibDiffs(blockIdx) = acc(blockIdx, 2)/2 - acc(blockIdx, 1)/2;
    end

    % RT record to identify super-fast RTs
    for blockIdx = 1:numBlocks;
        for phaseIdx = 1:2;
            blockMask = plotrec(:, 11) == blockIdx;
            subjRTs{blockIdx, phaseIdx} = plotrec(phaseMask{phaseIdx} & blockMask, 2);
        end
    end

    % Some subjects might only have one session
    if (numBlocks < 2)
        calibDiffs(2) = 0;
        earlyLearn(2) = 0;
        skippedTrials{1, 2} = 0;
        skippedTrials{2, 2} = 0;
        errorsByPhase{1, 2} = 0;
        errorsByPhase{2, 2} = 0;
        earlyRespFrac{1, 2} = 0;
        earlyRespFrac{2, 2} = 0;
        subjRTs{2, 1} = [];
        subjRTs{2, 2} = [];
    end

    subjSummary(subj).numPrac        = numPrac;
    subjSummary(subj).skippedTrials  = skippedTrials;
    subjSummary(subj).earlyLearn     = earlyLearn;
    subjSummary(subj).earlyTestPer   = earlyTestPer;
    subjSummary(subj).earlyTestMem   = earlyTestMem;
    subjSummary(subj).lateTestMemRT  = lateTestMemRT;
    subjSummary(subj).errorsByPhase  = errorsByPhase;
    subjSummary(subj).calibDiffs     = calibDiffs;
    subjSummary(subj).earlyRespFrac  = earlyRespFrac;
    subjSummary(subj).subjRTs        = subjRTs;

    if (exist(subjSumFile, 'file'))
        save(subjSumFile, 'subjSummary', '-append');
    else
        save(subjSumFile, 'subjSummary');
    end
end

% z-score RTs within-subject, post-masking
if (zAfter == 1)
    plotrec(zmask, 2) = (plotrec(zmask, 2) - nanmean(plotrec(zmask, 2)))/nanstd(plotrec(zmask, 2));
end
