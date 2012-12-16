function newAxis = get_new_axis(handles, axisType)
%get_new_axis returns an x axis in either time, frequency, or ppm depending
%if ppm is selected, a third parameter 'offset' must be included
%Usage:
%time_axis = get_new_axis(handles, 'time')
%freq_axis = get_new_axis(handles, 'frequency')
%ppm_axis = get_new_axis(handles, 'ppm')

data = getappdata(handles.figure1, 'data');

if strcmp(axisType, 'time')
    t_dwell = data.parms.dim1_step;
    x = data.parms.samples;

    %time axis
    newAxis = t_dwell:t_dwell:x*t_dwell;
else %axis type either frequency or ppm
    spec_band = 1 / data.parms.dim1_step;
    samples = data.parms.samples*data.parms.padfactor;
    
    %frequency axis
    newAxis = ((-samples/2:samples/2-1)*spec_band/samples);
    
    if strcmp(axisType, 'ppm')
        offset = str2double(get(handles.edit_offset, 'String'));
        if isnan(offset)
            updateStatusBox('No offset value found, using offset = 0');
            offset=0;
        end
        f = data.parms.synthesizer_frequency + offset;
        %ppm axis
        newAxis = newAxis / f * 10^6;
    end
end