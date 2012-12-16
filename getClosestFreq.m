function freq = getClosestFreq(data, bin)

xaxis = frequencyAxis(data);

freq = xaxis(bin-1);