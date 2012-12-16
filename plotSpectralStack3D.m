function plotSpectralStack3D(handles)

%get state of filters
filter = strcmp(get(handles.tog_filter, 'State'), 'on');
filter2 = strcmp(get(handles.tog_filter2, 'State'), 'on');

%plots all spectra
%hypData is an object with all the information
hypData = getappdata(handles.figure1, 'data');

%part is a string for what you want to see ('real', 'imag', 'mag', 'all')
part = 'mag';
samples = hypData.parms.samples*hypData.parms.padfactor;
numspec = hypData.parms.rows;

% offsetdlg=inputdlg('Input the frequency offset in Hz:');

offset = str2double(get(handles.edit_offset, 'String'));
if isnan(offset)
    offset=0;
end
% if ~isempty(offsetdlg)
%     offset = str2double(offsetdlg{1});
% end

% if isempty(offset) || isnan(offset)
%     xaxis = 1:samples;
%     xlabel('bin')
% else

%calculate chemical shift
f = hypData.parms.synthesizer_frequency + offset;
f_centre = frequencyAxis(hypData);
xaxis=(f_centre/f)*10^6;
xlbl = sprintf('offset (0 = %d ppm)', offset);
xlabel(xlbl);

% end

%yaxis is used for spacing all the spectrum
%it is a vector of n's, depending on which spectrum it iws
yaxis = ones(1, samples);
ylabel('Acquisition');

switch part
    case 'real'
        for n=1:numspec
            if filter
                d=filterData(hypData.getFFT(n));
            elseif filter2
                d=gaussLorentzFilt(handles, hypData.getFFT(n));
            else
                d = hypData.getFFT(n);
            end
            plot3(xaxis,yaxis*n,real(d),'b-');
        end
    case 'imag'
        for n=1:numspec
            if filter
                d=fft_centre(filterData(hypData.getFID(n)));
            elseif filter2
                d=fft_centre(gaussLorentzFilt(handles, hypData.getFID(n)));
            else
                d = hypData.getFFT(n);
            end
            plot3(xaxis,yaxis*n,imag(d),'b-');
        end
    case 'mag'
       for n=1:numspec
            if filter
                d=fft_centre(filterData(hypData.getFID(n)));
            elseif filter2
                d=fft_centre(gaussLorentzFilt(handles, hypData.getFID(n)));
            else
                d = hypData.getFFT(n);
            end
            plot3(xaxis,yaxis*n,abs(d), 'b-');
        end
    case 'all'
        for n=1:numspec
            if filter
                d=fft_centre(filterData(hypData.getFID(n)));
            elseif filter2
                d=fft_centre(gaussLorentzFilt(handles, hypData.getFID(n)));
            else
                d = hypData.getFFT(n);
            end
            plot3(xaxis,yaxis*n,real(d),'b-');
            plot3(xaxis,yaxis*n,imag(d),'r-');
            plot3(xaxis,yaxis*n,abs(d),'g-');
        end
end

zlabel('Signal');
xlim([min(xaxis) max(xaxis)]);

axis ij
view(-60,20)
set(handles.tog_rotate, 'Visible', 'on')