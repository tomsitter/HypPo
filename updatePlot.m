function updatePlot(handles)
    cla reset;
    hold on;
    
    data = getappdata(handles.figure1, 'data');
    if isappdata(handles.figure1, 'filterdata')
        dpts = abs(getappdata(handles.figure1, 'filterdata'));
    else
        dpts = abs(data.getFFT());
    end
    
    %plot current spectrum
    plot(1:data.parms.samples, dpts);
    
    %plot noise region as red circles
    if not(isempty(data.getNoiRange))
        xrange = data.getNoiRange;
        %datapoints = data.getDatapoints;
        plot(xrange(1):xrange(2), dpts(xrange(1):xrange(2)), 'ro', 'MarkerSize', 3);
    end
    xlim([1 data.parms.samples]);
    hold off;
end