function figureS3;
% function figureS3;
%


ssd_c2=load(['fits/e2/fit_c2ddm.mat']);

[R,p]=corr(ssd_c2.fitSettings(:,3), ssd_c2.recoveredParameters(:,9));

disp(['R=' num2str(R, '%.3f') ...
      ', P=' num2str(p, '%.3f')]);

isiArray=unique(ssd_c2.fitSettings(:,3));
plotArray=[];
for isiIdx=1:length(isiArray);
    plotArray=[plotArray ssd_c2.recoveredParameters(ssd_c2.fitSettings(:,3)==isiArray(isiIdx),9)];
end
aaron_newfig;
boxplot(plotArray);
set(gca, 'XTickLabel', arrayfun(@num2str, isiArray+.75, 'UniformOutput', false))
xlabel('Anticipation period (seconds)');
ylabel('\sigma_{x_0,2}');

