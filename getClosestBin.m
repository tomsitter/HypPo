function [bin, freq] = getClosestBin(data, x)

xaxis = frequencyAxis(data);

bin = find(xaxis > x, 1) - 1;

if isempty(bin) %bin not found, using last possible bin
    bin = data.parms.samples*data.parms.padfactor;
elseif bin == 0 %first bin was match, setting to bin 1
    bin = 1;
end

freq = xaxis(bin);