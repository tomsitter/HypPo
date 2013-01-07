function data = automateSNR(handles)
%calcSNR calculates the SNR of a ft spectrum by summing the FWHM and
%dividing by the standard deviation of the last 3/4 of the data points

    data = getappdata(handles.figure1, 'data');

    isavg = getappdata(handles.figure1, 'isavg');
    
    if get(handles.slider_realmag, 'Value') == 1
        dpts = abs(getappdata(handles.figure1, 'currentDpts'));
    else
        dpts = real(getappdata(handles.figure1, 'currentDpts'));
    end
    
    if isavg
        if isempty(data.getSigRangeAvg)
            [sig, lval, rval] = FWHM(dpts);
            %Caution, I don't know why I need to do this here
            lval = lval+1;
            rval = rval+1;
            lfval = getClosestFreq(data, lval);
            rfval = getClosestFreq(data, rval);
            
            data = data.setSigRangeAvgBin([lval rval]);
            data = data.setSigRangeAvg([lfval rfval]);
            
            data = data.setSignalAvg(sig);            
        end
        
        if isempty(data.getNoiRangeAvg)
            %get number of datapoints used in signal selection
            %select that amount of datapoints from end of spectrum for
            %noise calculation
            sigrange = data.getSigRangeBinAvg;
            sig_span = sigrange(end) - sigrange(end-1);
            noi_start = fix(noi_end-sig_span);
            fnoi_start = getClosestFreq(data, noi_start);
            fnoi_end = getClosestFreq(data, noi_end);
            data = data.setNoiRangeAvgBin([noi_start noi_end]);
            data = data.setNoiRangeAvg([fnoi_start fnoi_end]);
            
            noise = std(dpts(noi_start:noi_end));
            data = data.setNoiseAvg(noise);
            
        end    
    else
        if isempty(data.getSigRange)
            [sig, lval, rval] = FWHM(dpts);
            lval = lval+1;
            rval = rval+1;
            lfval = getClosestFreq(data, lval);
            rfval = getClosestFreq(data, rval);
            
            data = data.setSigRangeBin([lval rval]);
            data = data.setSigRange([lfval rfval]);
            
            data = data.setSignal(sig);
        end

        if isempty(data.getNoiRange)
            noi_end = length(dpts);
            sigrange = data.getSigRangeBin;
            sig_span = sigrange(end) - sigrange(end-1);
            noi_start = fix(noi_end-sig_span);
            fnoi_start = getClosestFreq(data, noi_start);
            fnoi_end = getClosestFreq(data, noi_end);
            data = data.setNoiRangeBin([noi_start noi_end]);
            data = data.setNoiRange([fnoi_start fnoi_end]);
            
            noise = std(dpts(noi_start:noi_end));
            data = data.setNoise(noise);
        end

        data = data.setSNR(data.getSignal, data.getNoise);
    end

    setappdata(handles.figure1, 'data', data);
    
    hold on;
    updateVisPlot(handles);
end
