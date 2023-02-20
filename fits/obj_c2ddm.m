function [val chisq_stage2 yPlus yMinus tArray] = obj_c2ddm_fullparams(x,rt,rtResp)
% function [val chisq_stage2 yPlus yMinus tArray] = obj_c2ddm_fullparams(x,rt,rtResp)
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
%   x2     = x(8);
%   x2dist = x(9);
%   T1     = x(10);     NDTs
%   T2     = x(11);
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
dl2    = tFinal-dl;

% Convert x1 to discretized support set, x1dist to pdf
x1supp = linspace(-z1,z1,100);
x1dist = normpdf(x1supp, x1, x1dist);
x2supp = linspace(-z2,z2,100);
x2dist = normpdf(x2supp, x2, x2dist);

val = 0;
chisq_stage2 = NaN;

yPlusFirst = [];
yMinusFirst = [];
tArrayFirst = [];

yPlusSecond = [];
yMinusSecond = [];
tArraySecond = [];

if (stage < 1.5)
    % First stage
    rt_stage1     = rt(rt<=dl);
    rtResp_stage1 = rtResp(rt<=dl);
    [chisq_stage1 df vs yPlusFirst yMinusFirst tArrayFirst] = rt2002(rt_stage1,rtResp_stage1,d1,s1,[z1 z1],x1supp,x1dist,[0 dl],dl,T1);

    val = chisq_stage1;
end

if (stage < 0.5 || stage > 1.5)
    % Second stage
    rt_stage2     = rt(rt>dl)-dl;
    rtResp_stage2 = rtResp(rt>dl);

    [chisq_stage2 df vs yPlusSecond yMinusSecond tArraySecond] = rt2002(rt_stage2,rtResp_stage2,d2,s2,[z2 z2],x2supp,x2dist,[0 dl2],dl2,T2);

%    [0 1 0 0 1 0 0 0 1 0 0.5 0 1 2]

%    [d2 dl2 x2 T2]
%    chisq_stage2

    val = val + chisq_stage2;
end

if (val == 0)
    %NOREACH
    [stage val chisq_stage2 dl]
end

yPlus       = [yPlusFirst yPlusSecond+yPlusFirst(end)];
yMinus      = [yMinusFirst yMinusSecond+yMinusFirst(end)];
reNormConst = yPlus(end)+yMinus(end);
yPlus       = yPlus./reNormConst;
yMinus      = yMinus./reNormConst;
tArray      = [tArrayFirst tArraySecond+dl];
