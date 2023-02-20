function [p rawEffects subjsSampled opts] = ghootstrap(data, varargin)
% function [p rawEffects subjsSampled opts] = ghootstrap(data, varagin)
%
% Generic 'ghootstrap'
%
% INPUTS:
%   data - N subjects by K observations by 2 timeseries array.
%          NaNs will be stripped before passing to testFunc.
%          Will error if empty unless 'unitTest' is specified.
%
% OPTIONS:
%   verbose      (false)     Print summary diagnostic information.
%   veryverbose  (false)     Print data on each iteration.
%   numIter      (1000)      Number of iterations.
%   testFunc     ([])        The test function. Empty for default: '@(x)(corr(x(:, 1), x(:, 2)))'.
%   randSeed     ([])        RNG seed (for repeatable effects). If empty, generate and store in opts.randSeed
%   baseEffect   ([])        Base effect against which to test effect distribution. If empty, run testFunc on full dataset provided.
%   subjsSampled ([])        If not empty, specifies the permutation of subjects to run for each iteration. Useful for comparisons across conditions.
%   unitTest     ([])        If not empty, generate some normally-distributed random data and insert some NaNs.
%                               (first three elements are size of data array, last is fraction of NaNs; or set to true for default parameters [10 20 2 0.05])
%                               N.B.: This overwrites any supplied data in 'data'.
%
% RETURNS:
%   p               Proportion of rawEffects with the opposite sign as the full run of testfunc.
%   rawEffects      Raw array of effect sizes.
%   subjsSampled    Array of sampled subject #s.
%   opts            Options that produced this run.
%
% ~ 2015.10 by Aaron M. Bornstein <aaronmb@princeton.edu> (after Ghootae Kim, described in Kim et al 2014 PNAS)
%
% TODO:
%   - Different significance test (e.g. >= x)?
%   - Calculate effect sizes? (Cohen's d?)
%   - User-specified prior over subjects? Nonparametrically estimate likelihood of each subject?
%       - Can be functional prior (e.g. higher weight to subjects with more data)
%

[opts] = parse_args(varargin, 'verbose',      false, ...
                              'veryverbose',  false, ...
                              'testFunc',     [], ...
                              'numIter',      1000, ...
                              'randSeed',     [], ...
                              'baseEffect',   [], ...
                              'subjsSampled', [], ...
                              'unitTest',     []);

if (~isempty(opts.randSeed))
    rng(opts.randSeed);
else
    opts.randSeed = rng;
    opts.randSeed = opts.randSeed.Seed;
end
if (opts.verbose)
    disp(['ghootstrap: Random seed: ' num2str(opts.randSeed)]);
end

if (isempty(opts.testFunc))
    opts.testFunc = @(x)(corr(x(:, 1), x(:, 2)));
end
if (opts.verbose)
    disp(['ghootstrap: Using testFunc ' func2str(opts.testFunc)]);
end

if (~isempty(opts.unitTest))
    if (opts.verbose)
        disp(['ghootstrap: Running unit test...']);
    end
    if (length(opts.unitTest) < 4)
        nanFrac = 0.05;
        data    = randn(10, 20, 2);
    else
        nanFrac = opts.unitTest(4);
        data    = randn(opts.unitTest(1:3));
    end

    % Add NaNs to randomly-generated data.
    % NB: Adds NaNs evenly to each subject & slice
    for sliceIdx = 1:size(data, 3);
        for subjIdx = 1:size(data, 1);
            nanEls  = randperm(size(data,2));
            nanEls  = nanEls(1:ceil(nanFrac*size(data,2)));

            data(subjIdx, nanEls, sliceIdx) = NaN;
        end
    end

    if (opts.verbose)
        disp(['ghootstrap: Generated test data of dimensions: ' num2str(size(data))]);
        for sliceIdx = 1:size(data, 3);
            sliceData = reshape(data, [size(data, 1)*size(data,2) size(data, 3)]);
            disp(['ghootstrap: Data series ' num2str(sliceIdx) ...
                  ': Number of non-NaN elements=' num2str(sum(~isnan(sliceData(:, sliceIdx)))) ...
                  ', mean=' num2str(nanmean(sliceData(:, sliceIdx))) ...
                  ', std=' num2str(nanstd(sliceData(:, sliceIdx)))]);
        end % for sliceIdx
    end % if verbose
end % if unitTest

% For each of numIter iters, draw N subjects with replacement (allowing duplicates).
% NB: Uniform across subjects.
if (isempty(opts.subjsSampled))
    subjsSampled    = ceil(rand(opts.numIter, size(data, 1))*size(data, 1));
else
    subjsSampled    = opts.subjsSampled;
end
% assert(opts.numIter == size(subjsSampled, 1)); % In case passed values don't match.
numTrials       = size(data, 2);

% Stack subjects so data are in timeseries format.
data            = reshape(data, [size(data, 1)*size(data, 2) size(data, 3)]);
strippedData    = stripnans(data);

if (size(strippedData, 1) < 3)
    disp(['ghootstrap: Insufficient data']);
    p = NaN;
    rawEffects = NaN;
    subjsSampled = NaN;
    return;
end
if (isempty(opts.baseEffect))
    opts.baseEffect = opts.testFunc(strippedData);
end
if (opts.verbose)
    disp(['ghootstrap: Base effect size: ' num2str(opts.baseEffect)]);
end

if (opts.verbose)
    disp(['ghootstrap: Running ' num2str(opts.numIter) ...
          ' iterations...']);
end

% Run numIter iterations, selecting numTrials from each subject.
for iterIdx = 1:opts.numIter;
    theseSubjs          = subjsSampled(iterIdx, :);
    trialSelect         = [];
    for thisSubj = theseSubjs;
        trialSelect = [trialSelect ; ((numTrials*(thisSubj-1))+1):(numTrials*thisSubj)];
    end

    theseData           = data(trialSelect, :);
    rawEffects(iterIdx) = opts.testFunc(stripnans(theseData));
    if (opts.veryverbose)
        disp(['ghootstrap: Iteration ' num2str(iterIdx) ...
              ', selecting data from subjects ' num2str(theseSubjs) ...
              '. Effect=' num2str(rawEffects(iterIdx), '%.2f') ...
              ' (' num2str(sign(rawEffects(iterIdx))==sign(opts.baseEffect)) ...
              ')']);
    end
end % for iterIdx

p = mean(sign(rawEffects)~=sign(opts.baseEffect));

if (opts.verbose)
    disp(['ghootstrap: Result: ' num2str(p*100) ...
          '% of iterations with different effect direction from full dataset.']);
end

end % function ghootstrap

function d = stripnans(d)
    d = d(~any(isnan(d)'), :);
end
