function bin = ppmTobin(handles, ppm)
    data = getappdata(handles.figure1, 'data');

    faxis = frequencyAxis(data);
    
    offset = str2double(get(handles.edit_offset, 'String'));
    if isnan(offset)
        offset=0;
    end
    
    f = data.parms.synthesizer_frequency + offset;
    
    xaxis=(faxis/f)*10^6;
    
    bin =  find(xaxis > ppm, 1);
    