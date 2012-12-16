function updateVisPlot(handles)

%save and load axis dimensions from previous changes
%unless opening a new file
try
    ST = dbstack(1);
    callingfunc = ST.name;
catch err
    disp(err.message)
end
if isnan(callingfunc) 
    callingfunc = 'NaN';
end

xdim = NaN;

%stored, but not implemented
ydim = NaN;

%when waterfall is turned off, restore any saved axes dimensions
if strcmp(callingfunc, 'tog_waterfall_OffCallback')
    %determine current xaxis units
    if get(handles.radio_ppm, 'Value') == 1 %user wants ppm
        if isappdata(handles.axes1, 'xlim_ppm')
            xdim = getappdata(handles.axes1, 'xlim_ppm');
        end            
        if isappdata(handles.axes1, 'ylim_ppm')
            ydim = getappdata(handles.axes1, 'ylim_ppm');
        end
    else
        if isappdata(handles.axes1, 'xlim_hz')
            xdim = getappdata(handles.axes1, 'xlim_hz');
        end
        if isappdata(handles.axes1, 'ylim_hz')
            ydim = getappdata(handles.axes1, 'ylim_hz');
        end
    end
% if waterfall (spectral stack plots) is being turned on/used,
% then ignore the saved axis dimensions
elseif strcmp(callingfunc, 'tog_waterfall_OnCallback') || ...
       strcmp(callingfunc, 'slider_2d3d_Callback') || ...
       strcmp(callingfunc, 'check_domain_Callback')
    ;;
%if a new file is being load, reset the saved axes dimension
elseif strcmp(callingfunc, 'push_open_ClickedCallback') || ...
   strcmp(callingfunc, 'file_slider_Callback') || ...
   strcmp(callingfunc, 'visualizer_OpeningFcn')
    if isappdata(handles.axes1, 'xlim_hz')
        rmappdata(handles.axes1, 'xlim_hz');
    end
    if isappdata(handles.axes1, 'ylim_hz')
        rmappdata(handles.axes1, 'ylim_hz');
    end
    if isappdata(handles.axes1, 'xlim_ppm')
        rmappdata(handles.axes1, 'xlim_ppm');
    end
    if isappdata(handles.axes1, 'ylim_ppm')
        rmappdata(handles.axes1, 'ylim_ppm');
    end
%otherwise we want to save/restore any axis information
else
     %get previous xaxis units, or if there are none saved, save them
     if isappdata(handles.axes1, 'prevAxis')
         prevAxis = getappdata(handles.axes1, 'prevAxis');
     else
         prevAxis = get(handles.radio_ppm, 'Value');
         setappdata(handles.axes1, 'prevAxis', prevAxis);
     end
    
    %determine current xaxis units
    curAxis = get(handles.radio_ppm, 'Value');
    
    %get current axis dimensions
    cur_xdim = get(handles.axes1, 'XLim');
    cur_ydim = get(handles.axes1, 'YLim');
    
    %save the dimensions to the appropriate field
    if prevAxis == 1 
        setappdata(handles.axes1, 'xlim_ppm', cur_xdim);
        setappdata(handles.axes1, 'ylim_ppm', cur_ydim);
    else
        setappdata(handles.axes1, 'xlim_hz', cur_xdim);
        setappdata(handles.axes1, 'ylim_hz', cur_ydim);
    end
    
    %determine if the xaxis units have been changed
    if curAxis ~= prevAxis
        if curAxis == 1 %user wants ppm
            if isappdata(handles.axes1, 'xlim_ppm')
                xdim = getappdata(handles.axes1, 'xlim_ppm');
            end            
            if isappdata(handles.axes1, 'ylim_ppm')
                ydim = getappdata(handles.axes1, 'ylim_ppm');
            end
        else
            if isappdata(handles.axes1, 'xlim_hz')
                xdim = getappdata(handles.axes1, 'xlim_hz');
            end
            if isappdata(handles.axes1, 'ylim_hz')
                ydim = getappdata(handles.axes1, 'ylim_hz');
            end
        end
    %current xaxis units same as before, so just carry dimensions forward
    else
        xdim = cur_xdim;
        ydim = cur_ydim;
    end
    setappdata(handles.axes1, 'prevAxis', curAxis);
end

%reset the current graph
cla(handles.axes1, 'reset');
hold on;

if not(isappdata(handles.figure1, 'data'))
    return;
end
    
data = getappdata(handles.figure1, 'data');
phasedatafid = getappdata(handles.figure1, 'phasedatafid');

%this will get turned on by PlotSpectralStack3D,
%otherwise we want it off because all other plots are 2D.
set(handles.tog_rotate, 'Visible', 'off')
set(handles.tog_rotate, 'State', 'off');

%get state of buttons
filter = strcmp(get(handles.tog_filter, 'State'), 'on');
filter2 = strcmp(get(handles.tog_filter2, 'State'), 'on');
frqdomain = get(handles.check_domain, 'Value');
viewavg = get(handles.radio_viewavg, 'Value');

%here we determine what is to be plotted
%the value contained in the variable 'dpts' dictates what will be
%plotted
%the spectral stacks (waterfall plots) are the top priority
if strcmp(get(handles.tog_waterfall, 'State'), 'on')
    %determine which stack to plot (2D or 3D)
    if get(handles.slider_2d3d, 'Value')
        plotSpectralStack3D(handles);
    else
        plotSpectralStack2D(handles);
    end
    hold off;
    %return now because plotSpectralStack does all the required work
    return;
%the next priority is the averaged data
%make sure the view average button is checked, and that there is averaged
%data
elseif viewavg && not(isempty(data.getAveragedData))
    %val determines which domain is to be plotted
    avgdata = data.getAveragedData;
     if frqdomain
         if filter
            dpts = fft_centre( filterData( avgdata));
         elseif filter2
             dpts = fft_centre( gaussLorentzFilt( handles, avgdata ));
         else
            dpts = fft_centre(avgdata);
         end
     else
         if filter
            dpts = filterData(avgdata);
         elseif filter2
             dpts = gaussLorentzFilt( avgdata);
         else
            dpts = avgdata;
         end
     end
     
     %this will get put in the legend
     str = 'Averaged Data';
%next, check if the data is being phased
elseif not(isempty(phasedatafid))
    %temporary fix to ensure phase angle is put into legend.
    phaseangle = getappdata(handles.figure1, 'phaseangle');
    if phaseangle ~= -1
        str = sprintf('Phase Angle: %.2d',phaseangle);
    end
    corrPhase=exp(-1j*(phaseangle*pi/180));
    
    %plot the appropriate phase data
    if frqdomain
        if filter
            dpts = fft_centre( ...
                   filterData( ...
                   phasedatafid * corrPhase));
        elseif filter2
            dpts = fft_centre( ...
                  gaussLorentzFilt( handles, ...
                   phasedatafid * corrPhase)); 
        else
            dpts = fft_centre( phasedatafid * corrPhase );
        end
    else
        if filter
            dpts = filterData ( phasedatafid * corrPhase );
        elseif filter2
            dpts = gaussLorentzFilter ( handles, phasedatafid * corrPhase );
        else
            dpts = phasedatafid * corrPhase;
        end
    end
 
%finally, if none of those options are checked, plot the spectrum
else
    %determine if the data has been previously phased
    phaseangle = data.getPhaseAngle;
    if phaseangle ~= -1
        %pa = exp(-1j * data.getPhaseAngle * pi / 180);
        str = sprintf('Phase Angle: %.2d',phaseangle);
    end

    %determine which domain to plot (time or freq)
    if frqdomain
        if filter
            dpts = fft_centre( ...
                   filterData( ...
                   data.getFID() * data.correctPhase()));
        elseif filter2
            dpts = fft_centre( ...
                   gaussLorentzFilt( handles, ...
                   data.getFID() * data.correctPhase()));
        else
            dpts = data.getFFT() * data.correctPhase();
        end
    else
        if filter
            dpts = filterData(data.getFID() * data.correctPhase());
        elseif filter2
            dpts = gaussLorentzFilt(handles, data.getFID() * data.correctPhase());
        else
            dpts = data.getFID() * data.correctPhase();
        end
    end
end

if strcmp(get(handles.tog_normalize, 'State'), 'on')
    norm_val = str2double(get(handles.edit_normalize, 'String'));
    if norm_val > 0
        dpts = dpts ./ norm_val;
    else
        dpts = dpts ./ max(abs(dpts));
    end
end

%update current working data
setappdata(handles.figure1, 'currentDpts', dpts);

offset = str2double(get(handles.edit_offset, 'String'));
if isnan(offset)
    offset=0;
end

if frqdomain
    if get(handles.radio_ppm, 'Value') == 1
        %calculate chemical shift
        xaxis = ppmAxis(data, offset);
    else
        xaxis = frequencyAxis(data);
        xlbl = 'frequency (Hz), f - fo';
    end
else
    dpts = dpts(1:data.parms.samples);
    xaxis = timeAxis(data);
    xlbl = 'Time';
end

%save working data xaxis
setappdata(handles.figure1, 'currentAxis', xaxis);

%plot the appropriate data.
%these check the state of the real/imag/mag boxes on the main gui to
%determine which to plot
if strcmp(get(handles.tog_real, 'State'), 'on')
    plot(xaxis, real(dpts), 'b')
    if (frqdomain && ...
        get(handles.radio_ppm, 'Value') == 0 && ...
        get(handles.slider_realmag, 'Value') == 0)
            updateSNR(handles);
    end
end

if strcmp(get(handles.tog_imag, 'State'), 'on')
    plot(xaxis, imag(dpts), 'r')
end

if strcmp(get(handles.tog_mag, 'State'), 'on')
    plot(xaxis, abs(dpts), 'g')
    if (frqdomain && ...
        get(handles.radio_ppm, 'Value') == 0 && ...
        get(handles.slider_realmag, 'Value') == 1)
            updateSNR(handles);
    end
end

%if a legend string was initialized, display it
if exist('str', 'var')
    legend(str);
end
if exist('xlbl', 'var')
    xlabel(xlbl)
end
ylabel('Signal')

%set the xaxis limits
if frqdomain
    % if previously saved, use those
    if not(isnan(xdim))
        xlim([xdim(1) xdim(end)])
    elseif not(isnan(xaxis))
        xlim([xaxis(1) xaxis(end)])
    end
else
    xlim([xaxis(1) xaxis(end)])
end

if strcmp(get(handles.tog_normalize, 'State'), 'on')
    ylim([-1.1 1.1])
end

if get(handles.radio_ppm, 'Value') == 1
    set(gca,'XDir','reverse')
end

hold off;
    