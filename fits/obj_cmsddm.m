function [val val_stage2 yPlus yMinus tArray] = obj_cmsddm_fullparams(x,rt,rtResp)
% function [val val_stage2 yPlus yMinus tArray] = obj_cmsddm_fullparams(x,rt,rtResp)
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
%   stage  = x(14);     return fit values for which stage? 0 = both; 1 = first; 2 = second
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
stage  = x(14);

tFinal = max(rt)+3;

% Convert x1 to discretized support set, x1dist to pdf
xsupp = linspace(-z1,z1,100);
x1dist = normpdf(xsupp, x1, x1dist);
% x2dist = normpdf(xsupp, x2, x2dist);

[val df val_stage2 yPlus yMinus tArray] = rt2002(rt,rtResp,[d1 d2],[s1 s2],[z1 z2],xsupp,x1dist,[0 dl],tFinal,T1);
