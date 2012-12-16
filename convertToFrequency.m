function freqval = convertToFrequency(handles, bin)

data = getappdata(handles.figure1, 'data');

%determine whether xaxis will be in ppm or hz

offset = str2double(get(handles.edit_offset, 'String'));

if isnan(offset)
    offset=0;
end

xaxis = frequencyAxis(data);

if get(handles.radio_ppm, 'Value') == 1
    %calculate chemical shift
    f = data.parms.synthesizer_frequency + offset;
    xaxis=((xaxis)/f)*10^6;
end

freqval = xaxis(round(bin));
