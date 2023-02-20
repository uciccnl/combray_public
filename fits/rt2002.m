% rtResp:  >0 for correct, <=0 for incorrect
function [val,df,val_stage2,yPlus,yMinus,tArray] = rt2002(rtData, rtResp, a,s,th,x0,x0dist, ...
                                                   dl,tFinal,T0,pWait)
if nargin < 10
    T0 = 0;
    pWait = 0;
end
if nargin < 11;
    pWait = 0;
end

% [tArray,~,yPlus,yMinus] = multistage_ddm_fpt_dist(...
%    a,s,th,x0,x0dist,dl,tFinal);
% NB: fullparams same as reg, just allows for only one stage (tFinal==dl)
[tArray,~,yPlus,yMinus] = multistage_ddm_fpt_dist_fullparams(...
    a,s,th,x0,x0dist,dl,tFinal,pWait);

%% Shift properly by zero (we don't need uniform tArray)
tArray = tArray + T0;
tArray = [0 tArray];
yPlus = [0 yPlus];
yMinus = [0 yMinus];

% dt = tArray(3)-tArray(2);
% nShift = round(T0/dt);
% tmpt = (tArray(end)+(1:nShift)*dt);
% tArray = [tArray tmpt];
% yPlus = [zeros(1,nShift) yPlus];
% yMinus = [zeros(1,nShift) yMinus];

% Chi-sq from Ratcliffe Tuerlinckx 2002.
nTotalTrials = length(rtData);
[val1,df1,q1] = chisq(rtData(rtResp>0),tArray,yPlus,nTotalTrials);
[val2,df2,q2] = chisq(rtData(rtResp<=0),tArray,yMinus,nTotalTrials);
val = val1+val2;

q1 = [0 q1(1:end-1)];
q2 = [0 q2(1:end-1)];

df = [df1'; df2'];

% figure(3)
% plot(q1,df1,'r-*')
% hold on
% plot(q2,df2,'b-*')
% hold off
% drawnow
% pause

s2inds = rtData>dl(end);
if (sum(s2inds)<2);
    val_stage2=NaN;
    return
end
rtData_stage2 = rtData(s2inds);
rtResp_stage2 = rtResp(s2inds);
nTotalTrials_stage2 = length(rtData_stage2);

% disp('break');
% pause

s2_tInds = find(tArray>dl(end));
tArray_stage2 = [tArray(s2_tInds)];

% yPlus_stage2  = [0 yPlus(s2_tInds)];/max(yPlus(s2_tInds));

% Turn it into a PDF, then back into a CDF
oldYPMax = yPlus(end);
yPlus_stage2 = yPlus(s2_tInds(2:end))-yPlus(s2_tInds(1:end-1));
yPlus_stage2 = [0 cumsum(yPlus_stage2/sum(yPlus_stage2))]; % *oldYPMax];

oldYMMax = yMinus(end);
yMinus_stage2 = yMinus(s2_tInds(2:end))-yMinus(s2_tInds(1:end-1));
yMinus_stage2 = [0 cumsum(yMinus_stage2/sum(yMinus_stage2))]; % *oldYMMax];

val1_stage2 = chisq(rtData_stage2(rtResp_stage2>0),tArray_stage2,yPlus_stage2,nTotalTrials_stage2);
val2_stage2 = chisq(rtData_stage2(rtResp_stage2<=0),tArray_stage2,yMinus_stage2,nTotalTrials_stage2);

val_stage2 = val1_stage2 + val2_stage2;
