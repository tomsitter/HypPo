function paxis = ppmAxis(data, offset)

    f = data.parms.synthesizer_frequency + offset;
    faxis = frequencyAxis(data);

    paxis = faxis / f * 10^6;
end