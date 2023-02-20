function [subjData] = loadSubj(subj, dataDir)
% function [subjData] = loadSubj(subj, [dataDir])
%

opts.verbose = false;

if (nargin < 2)
    dataDir   = '..';
end
dataFiles  = dir(fullfile(dataDir, 'combray_*.txt'));
parFiles   = dir(fullfile(dataDir, 'combray_params*.mat'));
pracFiles  = dir(fullfile(dataDir, 'combray_prac_*.txt'));
evFiles    = dir(fullfile(dataDir, 'combray_evidence*.mat'));
locFiles   = dir(fullfile(dataDir, 'localizer_*.mat'));
bvFiles    = dir(fullfile('/jukebox/cohen/aaronmb/combray/mri/badvols', 'badvols_*.mat'));      % meh. shift this to a basedir/datadir setup at some point, and make Dropbox layout match jukebox

subjData   = {};

if (length(dataFiles) < subj)
    disp(['loadSubj: Requested subject ' ...
          num2str(subj) ' , but only ' ...
          num2str(length(dataFiles)) ' subjects!']);
    disp(['loadSubj: Exiting...']);
    return;
else
    if (opts.verbose)
        disp(['loadSubj: Opening file ' fullfile(dataDir, dataFiles(subj).name)]);
    end
end

subjData.params = load(fullfile(dataDir, parFiles(subj).name));
try
    subjData.localizer = load(fullfile(dataDir, locFiles(subj).name));
catch
    disp(['loadSubj: No localizer data for subject ' num2str(subj)]);
    disp(['loadSubj: Continuing...']);

    subjData.localizer = [];
end

try
    bvFn = bvFiles(arrayfun(@(x)(~isempty(strfind(x.name, ['_'...
                                                  num2str(subj, '%.2d') '.mat']))), ...
                            bvFiles)).name;

    subjData.badvols = load(fullfile('/jukebox/cohen/aaronmb/combray/mri/badvols', bvFn));
    subjData.badvols = subjData.badvols.vols;
catch
    if (opts.verbose)
        disp(['loadSubj: No badvols file for subject ' num2str(subj)]);
        disp(['loadSubj: Continuing...']);
    end

    subjData.badvols = [];
end

pracCnt = 0;
subjData.pracrec{1} = [];

for pracIdx = 1:length(pracFiles);
    if (~isempty(strfind(pracFiles(pracIdx).name, ...
                 ['combray_prac_' num2str(subj, '%.2d')])))
        pracCnt = pracCnt + 1;
        pracfd = fopen(fullfile(dataDir, pracFiles(pracIdx).name));

        % Block   Trial   RunningTime     Image   CorrResp        Resp    RT
        % 1       1       0.00            3       3               NaN     NaN
        % 1       2       7.05            4       4               4       1.35
        pracData = textscan(pracfd, '%d%d%f%d%d%d%f', ...
                            'HeaderLines', 9, ...
                            'CommentStyle', {'Block'});
        fclose(pracfd);

        for rowIdx = 1:length(pracData{1});
            subjData.pracrec{pracCnt}(rowIdx).block = pracData{1}(rowIdx);
            subjData.pracrec{pracCnt}(rowIdx).trial = pracData{2}(rowIdx);
            subjData.pracrec{pracCnt}(rowIdx).onset = pracData{3}(rowIdx);
            subjData.pracrec{pracCnt}(rowIdx).image = pracData{4}(rowIdx);       % NB: corresp and image are redundant
            subjData.pracrec{pracCnt}(rowIdx).resp  = pracData{6}(rowIdx);
            subjData.pracrec{pracCnt}(rowIdx).RT    = pracData{7}(rowIdx);
        end
    end
end

datafd   = fopen(fullfile(dataDir, dataFiles(subj).name));

% Block   Phase   Trial   RunningTime     Cue     Image   CorrResp        Resp    Accuracy        ISI     RT_from_CueOffset       ITI
% 1       1       1       0.52            4       4       4               4       1               1.00            2.32            2
rawData = textscan(datafd, '%d%d%d%f%d%d%d%d%d%f%f%f', ...
                            'HeaderLines', 9, ...
                            'CommentStyle', {'Block'});

fclose(datafd);

for rowIdx = 1:length(rawData{1})
    subjData.trials(rowIdx).block = rawData{1}(rowIdx);
    subjData.trials(rowIdx).phase = rawData{2}(rowIdx);
    subjData.trials(rowIdx).trial = rawData{3}(rowIdx);

    subjData.trials(rowIdx).runTime = rawData{4}(rowIdx);
    subjData.trials(rowIdx).cue     = rawData{5}(rowIdx);
    subjData.trials(rowIdx).image   = rawData{6}(rowIdx);

    subjData.trials(rowIdx).corrResp = rawData{7}(rowIdx);
    subjData.trials(rowIdx).resp     = rawData{8}(rowIdx);
    subjData.trials(rowIdx).accurate = rawData{9}(rowIdx);

    subjData.trials(rowIdx).ISI = rawData{10}(rowIdx);
    subjData.trials(rowIdx).RT  = rawData{11}(rowIdx);
    subjData.trials(rowIdx).ITI = rawData{12}(rowIdx);
end

subjData.observationCount = NaN(length(subjData.trials), 1);
subjData.observedFraction = NaN(length(subjData.trials), 1);
subjData.evidence         = [];
subjData.evidence.evidenceStreams = [];

try
    subjData.evidence = load(fullfile(dataDir, evFiles(subj).name));
    for blockIdx = 1:size(subjData.evidence.evidenceStreams, 1);
        for trialIdx = 1:size(subjData.evidence.evidenceStreams, 2);
            rowIdx = find([subjData.trials(:).block]==blockIdx & [subjData.trials(:).trial]==trialIdx);
            if (subjData.trials(rowIdx).phase == 1)
                continue;
            end

            resp   = subjData.trials(rowIdx).resp;

            % XXX: Also record the raw observations?
            subjData.observationCount(rowIdx) = length(subjData.evidence.evidenceStreams{blockIdx, trialIdx});
            % Record the proportion of observations for the chosen option
            subjData.observedFraction(rowIdx) = sum([subjData.evidence.evidenceStreams{blockIdx, trialIdx}==resp])/length(subjData.evidence.evidenceStreams{blockIdx, trialIdx});
        end
    end
catch
    disp(['loadSubj: Subject ' num2str(subj, '%.2d') ': Couldn''t parse evidence stream']);
end

calibFiles = dir(fullfile(dataDir, ['combray_calib_' num2str(subj, '%.2d') '_*.mat']));
if (opts.verbose)
    disp(['loadSubj: Subject ' num2str(subj, '%.2d') ': Found ' num2str(length(calibFiles)) ' calibration files.']);
end

subjData.params.perNoise = [];

try
    for calibIdx = 1:length(calibFiles);
        calibData = load(fullfile(dataDir, calibFiles(calibIdx).name));
        subjData.params.perNoise(calibIdx) = calibData.p_stair(calibIdx);       % Has to be this way because I fucked up the code for subjects 1-7
        subjData.calibRec{calibIdx} = calibData.q;
    end
catch
end

