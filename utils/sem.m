function y = sem(x, semdim)
% function y = sem(x, [semdim])
%
% Take the standard error of the mean for x: y = std(x)/sqrt(length(x))
%
% OPTIONAL ARGUMENTS:
%   semdim = Dimension along which to compute SEM. Default is longest dimension of x.
%

if (nargin < 2)
    datalen = max(size(x));
    semdim  = find(size(x)==datalen);
else
    datalen = size(x, semdim);
end

% Remove NaNs from the normalization.
x(isinf(x)) = NaN;
datalen = datalen - sum(isnan(x), semdim);

y = nanstd(x,0,semdim)./sqrt(datalen);
