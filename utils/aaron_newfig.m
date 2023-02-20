function [h] = aaron_newfig(isg, dofont)
% function [h] = aaron_newfig([isg], [dofont])
%

if (nargin < 1)
    isg = [1 1 1];
end

dofont = true;

if (nargin < 2)
    dofont = true;
end

lg = isg;

h=figure;
hold on;
set(h, 'Color', lg);
shading faceted;

ah=gca;
set_axis_opts(ah, isg);
if (dofont)
    set(gca, 'FontSize', 24);
    set(gca, 'FontWeight', 'demi');
end
