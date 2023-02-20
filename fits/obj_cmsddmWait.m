function [val val_stage2 yPlus yMinus tArray] = obj_cmsddmWait_fullparams(x,rt,rtResp)
% function [val val_stage2 yPlus yMinus tArray] = obj_cmsddmWait_fullparams(x,rt,rtResp)
%
% PARAMS: (fix static params in calling helper function)
%
%   d1     = x(1);      drift rates
%   d2     = x(2);
%   dl     = x(3);      deadline (ISI+.75)
%   z1     = x(4);      thresholds
%   z2     = x(5);
%   x1     = x(6);      starting points
%   x1dist = x(7);      starting point stddevs
%   x2     = x(8);      XXX These get skipped for now - might add them back in as an offset process of somesort
%   x2dist = x(9);      XXX These get skipped for now - might add them back in as an offset process of somesort
%   T1     = x(10);     NDTs
%   T2     = x(11);     XXX Haven't figured out how to do two NDTs yet
%   s1     = x(12);     sample stddevs (diffusion rates)
%   s2     = x(13);
%   pWait  = x(14);     probability of a "Wait" / decision to delay accumulation in stage 1
%
% RETURNS:
%   val    = \chi^2
%
d1     = x(1);
d2     = x(2);
dl     = x(3);
z1     = x(4);
z2     = x(5);
x1     = x(6);
x1dist = x(7);
x2     = x(8);
x2dist = x(9);
T1     = x(10);
T2     = x(11);
s1     = x(12);
s2     = x(13);
pWait  = x(14);

% Logit-transform the range-bound parameters
% XXX: Should eventually do all of them.
x1    = 1./(1+exp(-x1));
x1    = (x1*(2*z1))-z1;       % [-z1 z1]
pWait = 1./(1+exp(-pWait));   % [0 1]

tFinal = max(rt)+3;

% Convert x1 to discretized support set, x1dist to pdf
xsupp  = linspace(-z1,z1,100);
x1dist = normpdf(xsupp, x1, x1dist);

[val df val_stage2 yPlus yMinus tArray] = rt2002(rt,rtResp,[d1 d2],[s1 s2],[z1 z2],xsupp,x1dist,[0 dl],tFinal,T1,pWait);
