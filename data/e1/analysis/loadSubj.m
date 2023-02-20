function [subjData] = loadSubj(subj, dataDir)
% function [subjData] = loadSubj(subj, [dataDir])
%

if (nargin < 2)
    dataDir   = '..';
end
dataFiles  = dir(fullfile(dataDir, 'combray_*.txt'));
parFiles   = dir(fullfile(dataDir, 'combray_params*.mat'));
evFiles    = dir(fullfile(dataDir, 'combray_evidence*.mat'));

subjData  = {};

if (length(dataFiles) < subj)
    disp(['Only ' num2str(length(dataFiles)) ' subjects!']);
    return;
else
    disp(['Opening file ' dataDir dataFiles(subj).name]);
end

subjData.params = load(fullfile(dataDir, parFiles(subj).name));

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

            % Also record the raw observations
            subjData.observationCount(rowIdx) = length(subjData.evidence.evidenceStreams{blockIdx, trialIdx});
            % Record the proportion of observations for the chosen option
            subjData.observedFraction(rowIdx) = sum([subjData.evidence.evidenceStreams{blockIdx, trialIdx}==resp])/length(subjData.evidence.evidenceStreams{blockIdx, trialIdx});
        end
    end
catch
    disp(['Subject ' num2str(subj, '%.2d') ': Couldn''t parse evidence stream']);
end

calibFiles = dir(fullfile(dataDir, ['combray_calib_' num2str(subj, '%.2d') '_*.mat']));
disp(['Subject ' num2str(subj, '%.2d') ': Found ' num2str(length(calibFiles)) ' calibration files.']);

subjData.params.perNoise = [];

try
    for calibIdx = 1:length(calibFiles);
        calibData = load(fullfile(dataDir, calibFiles(calibIdx).name));
        subjData.params.perNoise(calibIdx) = calibData.p_stair(calibIdx);       % Has to be this way because I fucked up the code for subjects 1-7
        subjData.calibRec{calibIdx} = calibData.q;
    end
catch
end

