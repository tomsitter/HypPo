function noise = calcNoise(dpts)
%return the standard deviation of the data points in the selected range
if length(dpts) <= 1
    noise = -1;
else
    noise = std(dpts);
end