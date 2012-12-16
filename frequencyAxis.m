function faxis = frequencyAxis(data)
    %spec_band = data.parms.sample_frequency;
    spec_band = 1 / data.parms.dim1_step;
    samples = data.parms.samples*data.parms.padfactor;
    
    faxis = ((-samples/2:samples/2-1)*spec_band/samples);
end