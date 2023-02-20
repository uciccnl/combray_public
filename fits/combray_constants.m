%% Arrays setup
dataDirName  = ['msddm_fitting_' exptName];

dataFileName = fullfile(dataDirName, ['collatedData_' exptName]);
dat = load(dataFileName);
sessmat = dat.sessmat;
dat = dat.collatedData;

cueArray = [.5 .6 .7 .8];
cohArray = [.65 .85];

if (strfind(exptName, 'expt1'))
    dlArray = [0.5 1 4 6 8 10];
else
    dlArray = [4 6 8];
end

nFits = length(cueArray(:,1))*length(cohArray)*length(dlArray);
