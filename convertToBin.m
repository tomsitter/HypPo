function bin = convertToBin(handles, freq)

    data = getappdata(handles.figure1, 'data');

    f_centre = frequencyAxis(data);

    bin =  (-f_centre/2:f_centre/2-1) * samples / spec_band;