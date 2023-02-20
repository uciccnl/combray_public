function d = cohend(x1, x2, ispaired)
% function d = cohend(x1, [x2], ispaired)
%

x1 = stripnan(x1);

if nargin < 2
    x2 = zeros(size(x1));
else
    x2 = stripnan(x2);
end

if nargin < 3
    ispaired = false;
end

if (ispaired)
    s = std([x1(:) ; x2(:)]);
else
    n1 = length(x1);
    n2 = length(x2);

    s1sq = 1/(n1-1) * sum((x1-mean(x1)).^2);
    s2sq = 1/(n2-1) * sum((x2-mean(x2)).^2);

    s = [(n1 - 1)*(s1sq) + (n2 - 1)*(s2sq)];
    s = sqrt(s/(n1+n2-2));
end

d = (mean(x1) - mean(x2))/s;
