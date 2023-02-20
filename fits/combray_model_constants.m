default_saveFile = ['fit_' exptName '_' modelName '.mat'];
default_saveFile = fullfile(dataDirName, default_saveFile);

% Common parameters
z1  = [0.05 5.00];
z2  = z1;

if (~isempty(strfind(modelName, '_clamped_threshold_one')))
    z1 = [1 1];
elseif (~isempty(strfind(modelName, '_clamped_threshold_two')))
    z2 = [1 1];
elseif (~isempty(strfind(modelName, '_clamped_threshold_both')))
    z1 = [1 1];
    z2 = z1;
end

x1  = [-z1(2) z1(2)];
x1d = [0.001 5];
x2  = [-z2(2) z2(2)];
x2d = x1d;
T1  = [0.05 1.10];
T2  = T1;
w   = [0 3];

% Continuous-only params
d1  = [-0.1 5];
d2  = d1;
n1  = [1 1];
n2  = n1;

if (strfind(modelName, 'c1ddm_fullparams'))
    %    [   d1   z1   x1     x1d   T1    n1  ]
    lb = [d1(1) z1(1) x1(1) x1d(1) T1(1) n1(1)];
    ub = [d1(2) z1(2) x1(2) x1d(2) T1(2) n1(2)];

    % impose abs(x1) \leq z1
    conA = [0 -1  1  0  0  0;
            0 -1  -1 0  0  0];
    conB = [0;
            0];
elseif (strfind(modelName, 'c2ddm_fullparams'))
    isStage = 0;
    dl      = [NaN NaN];

    %    [   d1   d2     dl    z1   z2    x1     x1d   x2    x2d    T1    T2     n1    n2    stage]
    lb = [d1(1) d2(1) dl(1) z1(1) z2(1) x1(1) x1d(1) x2(1) x2d(1) T1(1) T2(1)  n1(1) n2(1) isStage];
    ub = [d1(2) d2(2) dl(2) z1(2) z2(2) x1(2) x1d(2) x2(2) x2d(2) T1(2) T2(2)  n1(2) n2(2) isStage];

    % impose abs(x1) \leq z1 and abs(x2) \leq z2
    conA = [0 0 0 -1  0  1  0  0 0 0 0 0 0 0;
            0 0 0 -1  0 -1  0  0 0 0 0 0 0 0;
            0 0 0  0 -1  0  0  1 0 0 0 0 0 0;
            0 0 0  0 -1  0  0 -1 0 0 0 0 0 0];
    conB = [0;
            0;
            0;
            0];

elseif (strfind(modelName, 'cmsddm_fullparams'))
    %    [d1       d2   dl    z1    z2    x1    x1d  x2 x2d    T1   T2    n1     n2  stage]
    lb = [d1(1) d2(1)  NaN z1(1) z2(1) x1(1) x1d(1)   0   0 T1(1)    0 n1(1)  n2(1)      0];
    ub = [d1(2) d2(2)  NaN z1(2) z2(2) x1(2) x1d(2)   0   0 T1(2)    0 n1(2)  n2(2)      0];

    % impose abs(x1) \leq z1 and abs(x2) \leq z2
    conA = [0 0 0 -1  0  1  0  0 0 0 0 0 0 0;
            0 0 0 -1  0 -1  0  0 0 0 0 0 0 0;
            0 0 0  0 -1  0  0  1 0 0 0 0 0 0;
            0 0 0  0 -1  0  0 -1 0 0 0 0 0 0];
    conB = [0;
            0;
            0;
            0];

elseif (strfind(modelName, 'cmsddmWait_fullparams'))
    %    [d1       d2   dl    z1    z2    x1    x1d  x2 x2d    T1   T2    n1     n2  pWait]
    lb = [d1(1) d2(1)  NaN z1(1) z2(1) -Inf x1d(1)   0   0 T1(1)    0 n1(1)  n2(1)  -Inf];
    ub = [d1(2) d2(2)  NaN z1(2) z2(2) Inf x1d(2)   0   0 T1(2)    0 n1(2)  n2(2)  Inf];

    % impose abs(x1) \leq z1 and abs(x2) \leq z2
    % XXX: these are now taken care of inside the code due to logit trick, can release
    conA = [0 0 0 0  0  0  0  0 0 0 0 0 0 0;
            0 0 0 0  0 0  0  0 0 0 0 0 0 0;
            0 0 0  0 0  0  0  0 0 0 0 0 0 0;
            0 0 0  0 0  0  0 0 0 0 0 0 0 0];
    conB = [0;
            0;
            0;
            0];
else
    disp(['Unknown model variant: ' modelName]);
    return;
end

modelBase = strtok(modelName, '_');
objFunc = str2func(['obj_' modelBase]);

nVars = length(lb);
effectiveVars = length(lb)-sum(lb==ub)-sum(isnan(lb)); % Take effective # of vars, for genmul
