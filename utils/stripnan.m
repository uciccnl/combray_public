function y = stripnan(x)
     y = x(~isnan(x));
end
