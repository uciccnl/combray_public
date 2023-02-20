function figureS4;
% function figureS4;
%


ssd_c2=load(['fits/e2/fit_c2ddm.mat']);

[R,p]=corr(ssd_c2.fitSettings(:,1),ssd_c2.recoveredParameters(:,11),'type','Pearson');

disp(['R=' num2str(R, '%.3f') ...
      ', P=' num2str(p, '%.3f')]);


cueArray=unique(ssd_c2.fitSettings(:,1));
plotArray=[];
for cueIdx=1:length(cueArray);
    plotArray=[plotArray ssd_c2.recoveredParameters(ssd_c2.fitSettings(:,1)==cueArray(cueIdx),11)];
end
aaron_newfig;
boxplot(plotArray);
set(gca, 'XTickLabel', arrayfun(@num2str,cueArray, 'UniformOutput', false))
xlabel('Cue probability');
ylabel('Second-stage non-decision time (T_{0,2})');

