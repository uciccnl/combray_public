function [val val_stage2 yPlus yMinus tArray] = obj_c1ddm_fullparams(x,rt,rtResp)
% function [val val_stage2 yPlus yMinus tArray] = obj_c1ddm_fullparams(x,rt,rtResp)
%
% PARAMS: (fix static params in calling helper function)
%
%   d1     = x(1);      drift rates
%   z1     = x(2);      thresholds
%   x1     = x(3);      starting points
%   x1dist = x(4);      starting point stddevs
%   T1     = x(5);     NDTs
%   s1     = x(6);     sample stddevs (diffusion rates)
%
% RETURNS:
%   val    = \chi^2
%

   d1     = x(1);    %      drift rates
   z1     = x(2);    %      thresholds
   x1     = x(3);    %      starting points
   x1dist = x(4);    %      starting point stddevs
   T1     = x(5);    %     NDTs
   s1     = x(6);    %     sample stddevs (diffusion rates)

tFinal = max(rt)+3;

% Convert x1 to discretized support set, x1dist to pdf
x1supp = linspace(-z1,z1,100);
x1dist = normpdf(x1supp, x1, x1dist);

% doesn't matter what dl is, because startpoint_2 = endpoint_1, and accumulation rate/threshold is the same
[val df val_stage2 yPlus yMinus tArray] = rt2002(rt,rtResp,[d1 d1],[s1 s1],[z1 z1],x1supp,x1dist,[0 0.5],tFinal,T1);

if (val == 0)
    %NOREACH
    [stage val chisq_stage2 dl]
end
